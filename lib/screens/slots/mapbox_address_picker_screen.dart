import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../network/location_service.dart';
import '../../network/mapbox_service.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';

/// Mapbox-based address picker screen
/// Shows a map with a center pin, allowing users to select a location
class MapboxAddressPickerScreen extends StatefulWidget {
  final String? initialAddress;

  const MapboxAddressPickerScreen({super.key, this.initialAddress});

  @override
  State<MapboxAddressPickerScreen> createState() =>
      _MapboxAddressPickerScreenState();
}

class _MapboxAddressPickerScreenState extends State<MapboxAddressPickerScreen> {
  MapboxMap? mapboxMap;
  final RxBool isLoading = true.obs;
  final RxString currentAddress = ''.obs;
  final TextEditingController addressController = TextEditingController();

  // Default to Dubai coordinates
  double currentLat = 25.2048;
  double currentLng = 55.2708;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Set the access token before initializing the map
    MapboxOptions.setAccessToken(appConfigs.value.mapboxKey);

    if (widget.initialAddress != null) {
      addressController.text = widget.initialAddress!;
      currentAddress.value = widget.initialAddress!;
    }
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    addressController.dispose();
    super.dispose();
  }

  /// Get user's current location
  Future<void> _getCurrentLocation() async {
    try {
      isLoading(true);
      final position = await getUserLocationPosition();
      currentLat = position.latitude;
      currentLng = position.longitude;

      if (mapboxMap != null) {
        await _flyToLocation(currentLat, currentLng);
      }

      await _reverseGeocode(currentLat, currentLng);
    } catch (e) {
      log('Error getting location: $e');
      toast('Unable to get current location');
    } finally {
      isLoading(false);
    }
  }

  /// Fly to a specific location on the map
  Future<void> _flyToLocation(double lat, double lng) async {
    if (mapboxMap == null) return;

    await mapboxMap!.flyTo(
      CameraOptions(
        center: Point(coordinates: Position(lng, lat)),
        zoom: 16.0,
      ),
      MapAnimationOptions(duration: 1000),
    );
  }

  /// Reverse geocode the current map center
  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final address = await MapboxService.reverseGeocode(lat, lng);
      if (address.isNotEmpty) {
        currentAddress.value = address;
        addressController.text = address;
      }
    } catch (e) {
      log('Reverse geocode error: $e');
      // Fallback to coordinates if geocoding fails
      currentAddress.value = '$lat, $lng';
      addressController.text = '$lat, $lng';
    }
  }

  /// Handle map idle event (when user stops moving the map)
  void _onMapIdle() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      if (mapboxMap == null) return;

      final cameraState = await mapboxMap!.getCameraState();
      final center = cameraState.center;

      currentLat = center.coordinates.lat.toDouble();
      currentLng = center.coordinates.lng.toDouble();

      await _reverseGeocode(currentLat, currentLng);
    });
  }

  /// Handle map created callback
  void _onMapCreated(MapboxMap map) async {
    mapboxMap = map;

    // Fly to initial location
    await _flyToLocation(currentLat, currentLng);

    isLoading(false);
  }

  /// Confirm the selected address and return to previous screen
  void _confirmAddress() {
    final address = addressController.text.trim();
    if (address.isEmpty) {
      toast('Please select a valid address');
      return;
    }
    Navigator.of(context).pop({
      'address': address,
      'latitude': currentLat,
      'longitude': currentLng,
    });
  }

  /// Handle back navigation
  void _handleBack() {
    Navigator.of(context).pop({
      'address': addressController.text.trim(),
      'latitude': currentLat,
      'longitude': currentLng,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      hasLeadingWidget: true,
      leadingWidget: BackButton(onPressed: _handleBack),
      appBartitleText: locale.value.chooseYourLocation,
      body: Stack(
        children: [
          // Mapbox Map
          MapWidget(
            key: const ValueKey("mapWidget"),
            styleUri: MapboxStyles.MAPBOX_STREETS,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(currentLng, currentLat)),
              zoom: 14.0,
            ),
            onMapCreated: _onMapCreated,
            onCameraChangeListener: (cameraChangedEventData) {
              // Reset debounce on camera change
              _debounceTimer?.cancel();
            },
            onMapIdleListener: (mapIdleEventData) {
              _onMapIdle();
            },
          ),

          // Center Pin (fixed position)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 36),
              child: Icon(
                Icons.location_pin,
                size: 48,
                color: appColorPrimary,
              ),
            ),
          ),

          // My Location Button
          Positioned(
            right: 16,
            bottom: 220,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _getCurrentLocation,
              child: Icon(
                Icons.my_location,
                color: appColorPrimary,
              ),
            ),
          ),

          // Bottom Address Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale.value.address,
                    style: boldTextStyle(size: 14),
                  ),
                  8.height,
                  AppTextField(
                    controller: addressController,
                    textFieldType: TextFieldType.MULTILINE,
                    textStyle: primaryTextStyle(size: 14),
                    minLines: 2,
                    maxLines: 3,
                    decoration: inputDecoration(
                      context,
                      labelText: 'Selected Address',
                      fillColor: context.scaffoldBackgroundColor,
                      filled: true,
                    ),
                  ),
                  16.height,
                  AppButton(
                    width: Get.width,
                    color: appColorPrimary,
                    text: locale.value.setAddress,
                    textStyle: boldTextStyle(color: Colors.white),
                    onTap: _confirmAddress,
                  ),
                ],
              ),
            ),
          ),

          // Loading Indicator
          Obx(() => isLoading.value
              ? Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: const Center(child: LoaderWidget()),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}

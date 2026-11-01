// ignore_for_file: depend_on_referenced_packages
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/core_apis.dart';
import '../../utils/app_common.dart';
import '../clinic/model/clinic_detail_model.dart';
import '../clinic/model/clinics_res_model.dart';
import '../doctor/doctor_list_screen.dart';
import '../slots/booking_form_screen.dart';
import 'model/days_hours_option_model.dart';
import 'model/faq_model.dart';
import 'model/service_detail_model.dart';
import 'model/service_list_model.dart';
import 'model/session_package_model.dart';

class ServiceDetailController extends GetxController {
  RxBool isLoading = false.obs;

  Rx<Future<ServiceDetailModel>> getServiceDetails =
      Future(() => ServiceDetailModel(data: ServiceElement())).obs;
  RxBool isDescriptionExpanded = false.obs;
  // Rx<Future<ServiceDetailModel>> getServiceDetails =
  //     Future(() => ServiceDetailModel(data: ServiceElement())).obs;
  Rx<ServiceElement> serviceData = ServiceElement().obs;
  Rx<Clinic> selectedClinic = Clinic(clinicSession: ClinicSession()).obs;
  RxList<SessionPackage> sessionPackages = <SessionPackage>[].obs;
  RxList<String> ingredients = <String>[].obs;
  RxList<String> whyChooseUs = <String>[].obs;
  RxList<FAQItem> faqs = <FAQItem>[].obs;
  Rx<SessionPackage?> selectedSession = Rx<SessionPackage?>(null);

  /// Selected values
  Rx<DayOption?> selectedDays = Rx<DayOption?>(null);
  Rx<HourOption?> selectedHours = Rx<HourOption?>(null);

  /// Dropdown options (TEMP – replace with API later)
  RxList<DayOption> daysOptions = <DayOption>[].obs;
  RxList<HourOption> hoursOptions = <HourOption>[].obs;

  bool get isCustomDaysSelected => selectedDays.value?.isCustom == true;

  bool get isCustomHoursSelected => selectedHours.value?.isCustom == true;

  bool get showContactUsForHomeCare =>
      isCustomDaysSelected || isCustomHoursSelected;

  @override
  void onInit() {
    if (Get.arguments is ServiceElement) {
      serviceData(Get.arguments);
    } else if (Get.arguments is int) {
      serviceData(ServiceElement(id: Get.arguments as int));
    }
    init(showLoader: false);
    super.onInit();
    loadSessionPackages();
    loadExtraDetails();
    loadHomeCareOptions();
  }

  ///Get Service Detail
  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await getServiceDetails(
      CoreServiceApis.getServiceDetail(serviceId: serviceData.value.id),
    ).then((value) {
      serviceData(value.data);
      // Load data from API response
      loadFromApiData();
      isLoading(false);
    }).catchError((e) {
      isLoading(false);
      log('ServiceDetail getServiceDetail err ==> $e');
    }).whenComplete(() => isLoading(false));
  }

  /// Load all extended data from API response
  void loadFromApiData() {
    final data = serviceData.value;

    // Update ingredients from API
    if (data.ingredients.isNotEmpty) {
      ingredients.assignAll(data.ingredients);
    }

    // Update whyChooseUs from API
    if (data.whyChooseUs.isNotEmpty) {
      whyChooseUs.assignAll(data.whyChooseUs);
    }

    // Update FAQs from API
    if (data.faqs.isNotEmpty) {
      faqs.assignAll(data.faqs);
    }

    // Update session packages from API if available
    if (data.sessionPackages.isNotEmpty) {
      sessionPackages.assignAll(data.sessionPackages);
      if (sessionPackages.isNotEmpty) {
        selectedSession(sessionPackages.first);
      }
    }

    // Update homecare options from API if available
    if (data.homecareOptions != null) {
      final homecare = data.homecareOptions!;
      if (homecare.daysOptions.isNotEmpty) {
        daysOptions.assignAll(homecare.daysOptions);
      }
      if (homecare.hoursOptions.isNotEmpty) {
        hoursOptions.assignAll(homecare.hoursOptions);
      }
    }
  }

  void loadSessionPackages() {
    /// Only use API data - no static fallback
    if (sessionPackages.isNotEmpty && selectedSession.value == null) {
      selectedSession(sessionPackages.first);
    }
  }

  void loadHomeCareOptions() {
    /// Only use API data - no static fallback
    /// Days and hours options are populated from serviceData.homecareOptions in loadFromApiData()
  }

  void onDaysSelected(DayOption? value) {
    selectedDays(value);
    selectedHours(null); // reset hours when days change
  }

  void onHoursSelected(HourOption? value) {
    selectedHours(value);
  }

  num? get calculatedHomeCarePrice {
    if (selectedDays.value == null || selectedHours.value == null) return null;

    /// Use base hourly rate from API (serviceData.homecareOptions.baseHourlyRate)
    final homecareOptions = serviceData.value.homecareOptions;
    final baseHourlyRate = homecareOptions?.baseHourlyRate ?? 0;

    return selectedDays.value!.days *
        selectedHours.value!.hours *
        baseHourlyRate;
  }

  Future<void> bookWithFirstAvailableClinic() async {
    try {
      isLoading(true);

      /// Set the current service for booking flow
      currentSelectedService(serviceData.value);

      /// Save billing selections to global state for booking form
      currentSelectedSessionPackage(selectedSession.value);
      currentSelectedDayOption(selectedDays.value);
      currentSelectedHourOption(selectedHours.value);

      /// Temp list to receive clinics
      List<Clinic> tempClinics = [];

      /// Fetch clinics for this service
      await CoreServiceApis.getClinics(
        page: 1,
        perPage: 1, // only need first clinic
        clinics: tempClinics,
        serviceId: serviceData.value.id,
      );

      if (tempClinics.isNotEmpty) {
        /// Select first clinic globally
        currentSelectedClinic(tempClinics.first);

        /// Navigate to doctors list
        Get.to(
          () => DoctorsListScreen(),
          arguments: tempClinics.first.id,
        );
      } else {
        /// No clinics found - go directly to booking form
        Get.to(() => BookingFormScreen());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading(false);
    }
  }

  /// ==========================
  /// EXTRA DETAILS (Only from API)
  /// ==========================
  void loadExtraDetails() {
    /// No static fallbacks - only use API data
    /// Data is populated in loadFromApiData() from API response
    /// UI widgets should use .visible() extension to hide if empty
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_custom_dialog.dart';
import '../../../components/cached_image_widget.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';
import '../../clinic/clinics_list_screen.dart';
import '../../doctor/doctor_list_screen.dart';
import '../model/service_list_model.dart';
import '../service_detail_controller.dart';
import '../service_detail_screen.dart';

class PopularServiceCard extends StatelessWidget {
  final ServiceElement serviceElement;
  final bool isFromClinicDetail;

  const PopularServiceCard({
    super.key,
    required this.serviceElement,
    this.isFromClinicDetail = false,
  });
  String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;

    if (hours > 0 && mins > 0) {
      return '${hours}h ${mins}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${mins}m';
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isFromClinicDetail) {
          Get.delete<ServiceDetailController>();
        }
        Get.to(() => ServiceDetailScreen(isFromClinicDetail: isFromClinicDetail), arguments: serviceElement);
      },
      child: Container(
        decoration: boxDecorationWithRoundedCorners(
          borderRadius: radius(8),
          backgroundColor: context.cardColor,
        ),
        width: Get.width / 2 - 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4), bottom: Radius.circular(4)),
                    child: CachedImageWidget(
                      url: serviceElement.serviceImage,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 120,
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      serviceElement.categoryName,
                      style: secondaryTextStyle(color: appColorSecondary),
                    ),
                  ),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  serviceElement.name,
                  style: boldTextStyle(size: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                6.height,
                Marquee(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 6,
                    children: [
                      if (serviceElement.payableAmount != serviceElement.charges) PriceWidget(price: serviceElement.payableAmount, size: 18),
                      if (!serviceElement.isInclusiveTaxesAvailable)
                        PriceWidget(
                          price: serviceElement.charges,
                          isLineThroughEnabled: serviceElement.isDiscount ? true : false,
                          size: serviceElement.isDiscount ? 14 : 18,
                          color: serviceElement.isDiscount ? textSecondaryColorGlobal : appColorPrimary,
                        ),
                      if (serviceElement.isInclusiveTaxesAvailable) ...[
                        Text(
                          locale.value.includesInclusiveTax,
                          style: secondaryTextStyle(
                            color: appColorSecondary,
                            size: 10,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                8.height,
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: Colors.grey),
                    4.width,
                    Text(
                      "Duration: ",
                      style: secondaryTextStyle(),
                    ),
                     Text(
                       formatDuration(serviceElement.duration.validate().toInt()),
                      style: boldTextStyle(size: 14),
                    ),
                  ],
                ),
                12.height,
                AppButton(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: Get.width,
                  elevation: 0,
                  color: appColorSecondary,
                  shapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onTap: () {
                    if (isFromClinicDetail) {
                      showInDialog(
                        context,
                        contentPadding: EdgeInsets.zero,
                        builder: (context) {
                          return AppCustomDialog(
                            title: locale.value.doYouWantToReplaceThePreviousServiceWithTheCu,
                            negativeText: locale.value.no,
                            positiveText: locale.value.yes,
                            onTap: () {
                              currentSelectedService(serviceElement);
                              Get.back();
                              Get.to(() => DoctorsListScreen(), arguments: currentSelectedClinic.value.id);
                            },
                          );
                        },
                      );
                    } else {
                      currentSelectedService(serviceElement);
                      Get.to(() => ClinicListScreen(), arguments: serviceElement);
                    }
                  },
                  child: Text(
                    locale.value.bookNow,
                    style: boldTextStyle(size: 14, color: white),
                  ),
                ),
              ],
            ).paddingSymmetric(horizontal: 12, vertical: 5)
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../components/cached_image_widget.dart';
import '../../../components/app_custom_dialog.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/price_widget.dart';

import '../../doctor/doctor_list_screen.dart';
import '../model/service_list_model.dart';
import '../service_detail_controller.dart';
import '../service_detail_screen.dart';

class ServiceCard extends StatelessWidget {
  final ServiceElement serviceElement;
  final bool isFromClinicDetail;

  const ServiceCard(
      {super.key,
      required this.serviceElement,
      this.isFromClinicDetail = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isFromClinicDetail) {
          Get.delete<ServiceDetailController>();
        }
        Get.to(
            () => ServiceDetailScreen(isFromClinicDetail: isFromClinicDetail),
            arguments: serviceElement);
      },
      child: Container(
        decoration: boxDecorationDefault(
            color: context.cardColor, borderRadius: radius(8)),
        width: Get.width / 2 - 24,
        child: Column(
          children: [
            Hero(
              tag: serviceElement.serviceImage.trim().isNotEmpty
                  ? "${serviceElement.id}${serviceElement.serviceImage}"
                  : UniqueKey(),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: CachedImageWidget(
                      url: serviceElement.serviceImage,
                      fit: BoxFit.contain,
                      width: Get.width / 2 - 24,
                      height: Get.height * 0.15,
                      topLeftRadius: 8,
                      topRightRadius: 8,
                      bottomRightRadius:
                          serviceElement.isVideoConsultancy ? 6 : 0,
                    ),
                  ),
                  if (serviceElement.isVideoConsultancy)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: boxDecorationDefault(
                          color: completedStatusColor,
                          borderRadius: BorderRadius.only(
                              topLeft: radiusCircular(),
                              bottomRight: radiusCircular(6)),
                          border: Border(
                              left: BorderSide(
                                  color: context.cardColor, width: 6),
                              top: BorderSide(
                                  color: context.cardColor, width: 6)),
                        ),
                        child: CachedImageWidget(
                          url: Assets.imagesVideoCamera,
                          fit: BoxFit.fitHeight,
                          height: 10,
                          color: context.cardColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      serviceElement.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: boldTextStyle(size: 16),
                    ).flexible(),
                  ],
                ),
                8.height,
                Marquee(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 6,
                    children: [
                      if (serviceElement.payableAmount !=
                          serviceElement.charges)
                        PriceWidget(
                            price: serviceElement.payableAmount, size: 18),
                      if (!serviceElement.isInclusiveTaxesAvailable)
                        PriceWidget(
                          price: serviceElement.charges,
                          isLineThroughEnabled:
                              serviceElement.isDiscount ? true : false,
                          size: serviceElement.isDiscount ? 14 : 18,
                          color: serviceElement.isDiscount
                              ? textSecondaryColorGlobal
                              : appColorPrimary,
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
                6.height,
                AppButton(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  margin: EdgeInsets.zero,
                  width: Get.width,
                  elevation: 0,
                  color: appColorSecondary,
                  onTap: () {
                    if (isFromClinicDetail) {
                      showInDialog(
                        context,
                        contentPadding: EdgeInsets.zero,
                        builder: (context) {
                          return AppCustomDialog(
                            title: locale.value
                                .doYouWantToReplaceThePreviousServiceWithTheCu,
                            negativeText: locale.value.no,
                            positiveText: locale.value.yes,
                            onTap: () {
                              currentSelectedService(serviceElement);
                              Get.back();
                              Get.to(() => DoctorsListScreen(),
                                  arguments: currentSelectedClinic.value.id);
                            },
                          );
                        },
                      );
                    } else {
                      /// Store select service in global variable
                      currentSelectedService(serviceElement);
                      // Skip clinic selection and go directly to booking form
                      Get.to(() => ServiceDetailScreen(),
                          arguments: serviceElement);
                    }
                  },
                  child: Text(locale.value.bookNow,
                      style: boldTextStyle(
                          size: 12,
                          color: whiteTextColor,
                          weight: FontWeight.w400)),
                ),
                // const Spacer()
              ],
            ).paddingSymmetric(horizontal: 12, vertical: 12),
          ],
        ),
      ),
    );
  }
}

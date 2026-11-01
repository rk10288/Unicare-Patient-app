import 'package:date_picker_timeline/extra/color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../auth/other/whatsapp_helper_widget.dart';
import '/screens/service/service_list_controller.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/app_custom_dialog.dart';
import '../../components/app_scaffold.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../../utils/empty_error_state_widget.dart';
import '../../utils/price_widget.dart';
import '../clinic/clinic_detail_screen.dart';
import '../clinic/clinics_list_screen.dart';
import '../clinic/model/clinic_detail_model.dart';
import '../clinic/model/clinics_res_model.dart';
import '../doctor/doctor_list_screen.dart';
import '../slots/booking_form_screen.dart';
import 'components/service_detail_clinics_component.dart';
import 'model/days_hours_option_model.dart';
import 'model/helper_class_for_sessionpackages.dart';
import 'model/session_package_model.dart';
import 'service_detail_controller.dart';

class ServiceDetailScreen extends StatelessWidget {
  final bool isFromClinicDetail;
  RxBool isDescriptionExpanded = false.obs;

  ServiceDetailScreen({super.key, this.isFromClinicDetail = false});

  final ServiceDetailController serviceDetailController =
      Get.put(ServiceDetailController());

  /// Check billing mode from service data instead of hardcoded names
  bool get isSessionBasedService =>
      serviceDetailController.serviceData.value.isSessionBasedService;

  bool get isDayWiseService =>
      serviceDetailController.serviceData.value.isDayWiseService;

  // bool get isDoctorOnCall {
  //   final categoryName =
  //       serviceDetailController.serviceData.value.categoryName.toLowerCase();
  //   return categoryName.contains('doctor on call');
  // }

  Widget buildPricingSection() {
    if (isSessionBasedService) {
      return TherapyPricingSection();
    } else if (isDayWiseService) {
      return HomeCarePricingSection();
    } else {
      return NormalPricingSection();
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(Get.width);
    return Obx(() {
      return AppScaffoldNew(
        isLoading: serviceDetailController.isLoading,
        appBartitleText: serviceDetailController.serviceData.value.name,
        appBarVerticalSize: Get.height * 0.12,
        body: RefreshIndicator(
          onRefresh: () {
            return serviceDetailController.init(showLoader: false);
          },
          child: Obx(
            () => SnapHelperWidget(
              future: serviceDetailController.getServiceDetails.value,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () {
                    serviceDetailController.init();
                  },
                ).paddingSymmetric(horizontal: 16);
              },
              loadingWidget: const LoaderWidget(),
              onSuccess: (serviceDetailRes) {
                return AnimatedScrollView(
                  listAnimationType: ListAnimationType.FadeIn,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 80),
                  children: [
                    Hero(
                      tag: serviceDetailController
                              .serviceData.value.serviceImage
                              .trim()
                              .isNotEmpty
                          ? "${serviceDetailController.serviceData.value.id}${serviceDetailController.serviceData.value.serviceImage}"
                          : UniqueKey(),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: CachedImageWidget(
                          url: serviceDetailController
                              .serviceData.value.serviceImage,
                          // fit: BoxFit.cover,
                          width: Get.width,
                          // height: 260,
                          radius: defaultRadius / 2,
                        ),
                      ),
                    ),
                    16.height,
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              serviceDetailController.serviceData.value.name,
                              style: boldTextStyle(size: 16),
                            ),
                            8.height,
                            Row(
                              children: [
                                Text('${locale.value.category} : ',
                                    style: secondaryTextStyle()),
                                Text(
                                  serviceDetailController
                                      .serviceData.value.categoryName,
                                  style: boldTextStyle(
                                      size: 14, color: appColorSecondary),
                                ),
                              ],
                            ),
                            12.height,
                            // Marquee(
                            //   child: Row(
                            //     mainAxisAlignment: MainAxisAlignment.center,
                            //     children: [
                            //       if (serviceDetailController
                            //               .serviceData.value.charges !=
                            //           serviceDetailController
                            //               .serviceData.value.payableAmount)
                            //         PriceWidget(
                            //           price: serviceDetailController
                            //               .serviceData.value.payableAmount,
                            //           size: 18,
                            //         ).paddingRight(6),
                            //       if (!serviceDetailController.serviceData.value
                            //           .isInclusiveTaxesAvailable)
                            //         PriceWidget(
                            //           price: serviceDetailController
                            //               .serviceData.value.charges,
                            //           isLineThroughEnabled:
                            //               serviceDetailController
                            //                       .serviceData.value.isDiscount
                            //                   ? true
                            //                   : false,
                            //           size: serviceDetailController
                            //                   .serviceData.value.isDiscount
                            //               ? 14
                            //               : 18,
                            //           color: serviceDetailController
                            //                   .serviceData.value.isDiscount
                            //               ? textSecondaryColorGlobal
                            //               : appColorPrimary,
                            //         ),
                            //       if (serviceDetailController
                            //           .serviceData.value.isDiscount)
                            //         if (serviceDetailController
                            //                 .serviceData.value.discountType ==
                            //             TaxType.PERCENTAGE)
                            //           Text(
                            //             '${serviceDetailController.serviceData.value.discountValue}%  ${locale.value.off}',
                            //             style: boldTextStyle(
                            //                 color: greenColor, size: 14),
                            //           ).paddingLeft(8)
                            //         else if (serviceDetailController
                            //                 .serviceData.value.discountType ==
                            //             TaxType.FIXED)
                            //           PriceWidget(
                            //             price: serviceDetailController
                            //                 .serviceData.value.discountValue,
                            //             color: greenColor,
                            //             size: 14,
                            //             isDiscountedPrice: true,
                            //           ).paddingLeft(6),
                            //     ],
                            //   ),
                            // ),

                            // if (isTherapyService)
                            //   Obx( () {
                            //     final controller = serviceDetailController;
                            //     return Column(
                            //       crossAxisAlignment: CrossAxisAlignment.start,
                            //       children: [
                            //         /// Dropdown
                            //         Container(
                            //           padding: const EdgeInsets.symmetric(horizontal: 12),
                            //           decoration: BoxDecoration(
                            //             border: Border.all(color: appColorSecondary),
                            //             borderRadius: BorderRadius.circular(8),
                            //           ),
                            //           child: DropdownButtonHideUnderline(
                            //             child: DropdownButton<SessionPackage>(
                            //               value: controller.selectedSession.value,
                            //               isExpanded: true,
                            //               items: controller.sessionPackages.map((pkg) {
                            //                 return DropdownMenuItem(
                            //                   value: pkg,
                            //                   child: Text(pkg.title),
                            //                 );
                            //               }).toList(),
                            //               onChanged: (value) {
                            //                 controller.selectedSession(value);
                            //                // selectedSession.value = value!;
                            //                 //selectedPrice.value = sessionPackages[value] ?? 0;
                            //               },
                            //             ),
                            //           ),
                            //         ),
                            //
                            //         12.height,
                            //
                            //         /// Price or Contact Us
                            //         if (controller.selectedSession.value?.price != null)
                            //           PriceWidget(
                            //             price: controller.selectedSession.value!.price!,
                            //             size: 18,
                            //             color: appColorPrimary,
                            //           )
                            //         else
                            //           Text(
                            //             locale.value.contactUs,
                            //             style: boldTextStyle(color: appColorSecondary, size: 16),
                            //           ),
                            //       ],
                            //     );
                            //   })
                            // else
                            // /// Existing normal price UI (keep as-is)
                            //   Marquee(
                            //     child: Row(
                            //       mainAxisAlignment: MainAxisAlignment.center,
                            //       children: [
                            //         PriceWidget(
                            //           price: serviceDetailController.serviceData.value.charges,
                            //           size: 18,
                            //         ),
                            //       ],
                            //     ),
                            //   ),

                            buildPricingSection(),
                          ],
                        ).flexible(),
                      ],
                    ).paddingSymmetric(horizontal: 16),
                    if (serviceDetailController
                        .serviceData.value.isInclusiveTaxesAvailable) ...[
                      Text(locale.value.includesInclusiveTax,
                              style: secondaryTextStyle(
                                  color: appColorSecondary,
                                  size: 12,
                                  fontStyle: FontStyle.italic))
                          .paddingSymmetric(horizontal: 16)
                    ],
                    24.height,
                    // if (serviceDetailController
                    //     .serviceData.value.description.isNotEmpty)
                    //   Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: Text(
                    //       serviceDetailController.serviceData.value.description,
                    //       textAlign: TextAlign.justify,
                    //       style: primaryTextStyle(
                    //           size: 12,
                    //           color: secondaryTextColor.withValues(alpha: 0.8)),
                    //     ),
                    //   ).paddingSymmetric(horizontal: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// ==============================
                        /// DESCRIPTION
                        /// ==============================
                        if (serviceDetailController
                            .serviceData.value.description.isNotEmpty)
                          Obx(
                            () {
                              final isExpanded = serviceDetailController
                                  .isDescriptionExpanded.value;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    serviceDetailController
                                        .serviceData.value.description,
                                    maxLines: isExpanded ? null : 2,
                                    overflow: isExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis,
                                    style: primaryTextStyle(
                                      size: 12,
                                      color: secondaryTextColor.withValues(
                                          alpha: 0.8),
                                    ),
                                  ),
                                  6.height,
                                  GestureDetector(
                                    onTap: () {
                                      serviceDetailController
                                          .isDescriptionExpanded
                                          .toggle();
                                    },
                                    child: Text(
                                      isExpanded
                                          ? locale.value.readLess
                                          : locale.value.readMore,
                                      style: boldTextStyle(
                                        size: 12,
                                        color: appColorSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ).paddingSymmetric(horizontal: 16),

                        24.height,

                        /// ==============================
                        /// INGREDIENTS
                        /// ==============================
                        Obx(
                          () => serviceDetailController.ingredients.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      locale.value.ingredients,
                                      style: boldTextStyle(size: 14),
                                    ),
                                    12.height,
                                    ...serviceDetailController.ingredients.map(
                                      (item) => Row(
                                        children: [
                                          Icon(
                                            Icons.check_circle,
                                            size: 18,
                                            color: appColorSecondary,
                                          ),
                                          10.width,
                                          Expanded(
                                            child: Text(
                                              item,
                                              style:
                                                  secondaryTextStyle(size: 12),
                                            ),
                                          ),
                                        ],
                                      ).paddingBottom(8),
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: 16)
                              : SizedBox(),
                        ),

                        24.height,

                        /// ==============================
                        /// FAQs (Premium UI)
                        /// ==============================
                        Obx(
                          () => serviceDetailController.faqs.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Section Header with gradient accent
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                appColorPrimary,
                                                appColorSecondary,
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        12.width,
                                        Text(
                                          locale.value.faqs,
                                          style: boldTextStyle(size: 16),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: appColorPrimary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            '${serviceDetailController.faqs.length} Questions',
                                            style: secondaryTextStyle(
                                              size: 11,
                                              color: appColorPrimary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    16.height,
                                    // FAQ Items
                                    ...serviceDetailController.faqs
                                        .asMap()
                                        .entries
                                        .map(
                                      (entry) {
                                        final index = entry.key;
                                        final faq = entry.value;
                                        final RxBool isExpanded = false.obs;

                                        return Obx(
                                          () => AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            decoration: BoxDecoration(
                                              color: context.cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              border: Border.all(
                                                color: isExpanded.value
                                                    ? appColorPrimary
                                                        .withOpacity(0.4)
                                                    : Colors.grey
                                                        .withOpacity(0.15),
                                                width:
                                                    isExpanded.value ? 1.5 : 1,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: isExpanded.value
                                                      ? appColorPrimary
                                                          .withOpacity(0.08)
                                                      : Colors.black
                                                          .withOpacity(0.04),
                                                  blurRadius:
                                                      isExpanded.value ? 12 : 6,
                                                  offset: Offset(0,
                                                      isExpanded.value ? 4 : 2),
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () =>
                                                      isExpanded.toggle(),
                                                  splashColor: appColorPrimary
                                                      .withOpacity(0.1),
                                                  child: Column(
                                                    children: [
                                                      // Question Header
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(16),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            // Question Number Badge
                                                            Container(
                                                              width: 28,
                                                              height: 28,
                                                              decoration:
                                                                  BoxDecoration(
                                                                gradient:
                                                                    LinearGradient(
                                                                  colors: [
                                                                    appColorPrimary,
                                                                    appColorSecondary,
                                                                  ],
                                                                  begin: Alignment
                                                                      .topLeft,
                                                                  end: Alignment
                                                                      .bottomRight,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  'Q${index + 1}',
                                                                  style:
                                                                      boldTextStyle(
                                                                    size: 11,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            12.width,
                                                            // Question Text
                                                            Expanded(
                                                              child: Text(
                                                                faq.question,
                                                                style:
                                                                    primaryTextStyle(
                                                                  size: 14,
                                                                  weight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                            8.width,
                                                            // Animated Arrow Icon
                                                            AnimatedRotation(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              turns: isExpanded
                                                                      .value
                                                                  ? 0.5
                                                                  : 0,
                                                              child: Container(
                                                                width: 28,
                                                                height: 28,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: isExpanded
                                                                          .value
                                                                      ? appColorPrimary
                                                                          .withOpacity(
                                                                              0.15)
                                                                      : Colors
                                                                          .grey
                                                                          .withOpacity(
                                                                              0.1),
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                                child: Icon(
                                                                  Icons
                                                                      .keyboard_arrow_down_rounded,
                                                                  size: 20,
                                                                  color: isExpanded
                                                                          .value
                                                                      ? appColorPrimary
                                                                      : Colors
                                                                          .grey,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Answer Section
                                                      AnimatedCrossFade(
                                                        firstChild:
                                                            const SizedBox(
                                                                height: 0,
                                                                width: double
                                                                    .infinity),
                                                        secondChild: Container(
                                                          width:
                                                              double.infinity,
                                                          padding:
                                                              const EdgeInsets
                                                                  .fromLTRB(16,
                                                                  0, 16, 16),
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(14),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: appColorPrimary
                                                                  .withOpacity(
                                                                      0.05),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12),
                                                              border:
                                                                  Border.all(
                                                                color: appColorPrimary
                                                                    .withOpacity(
                                                                        0.1),
                                                              ),
                                                            ),
                                                            child: Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          top:
                                                                              2),
                                                                  child: Icon(
                                                                    Icons
                                                                        .format_quote_rounded,
                                                                    size: 18,
                                                                    color: appColorPrimary
                                                                        .withOpacity(
                                                                            0.6),
                                                                  ),
                                                                ),
                                                                10.width,
                                                                Expanded(
                                                                  child: Text(
                                                                    faq.answer,
                                                                    style:
                                                                        secondaryTextStyle(
                                                                      size: 13,
                                                                      height:
                                                                          1.5,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        crossFadeState:
                                                            isExpanded.value
                                                                ? CrossFadeState
                                                                    .showSecond
                                                                : CrossFadeState
                                                                    .showFirst,
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: 16)
                              : SizedBox(),
                        ),
                        12.height,

                        /// ==============================
                        /// WHY CHOOSE US
                        /// ==============================
                        Obx(
                          () => serviceDetailController.whyChooseUs.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      locale.value.whyChooseUs,
                                      style: boldTextStyle(size: 14),
                                    ),
                                    12.height,
                                    ...serviceDetailController.whyChooseUs.map(
                                      (item) => Row(
                                        children: [
                                          Icon(Icons.check_circle,
                                              size: 18,
                                              color: appColorSecondary),
                                          10.width,
                                          Expanded(
                                            child: Text(
                                              item,
                                              style:
                                                  secondaryTextStyle(size: 12),
                                            ),
                                          ),
                                        ],
                                      ).paddingBottom(8),
                                    ),
                                  ],
                                ).paddingSymmetric(horizontal: 16)
                              : SizedBox(),
                        ),
                      ],
                    )

                    /*   ServiceDetailClinicsComponent(
                      serviceDetailController: serviceDetailController,
                      onCardTap: (clinicData) {
                        /// Store selected clinic in global variable
                        if (clinicData.id ==
                            serviceDetailController.selectedClinic.value.id) {
                          /// Deselect, If again tap on same clinic
                          serviceDetailController.selectedClinic(
                              Clinic(clinicSession: ClinicSession()));
                          currentSelectedClinic(
                              serviceDetailController.selectedClinic.value);
                        } else {
                          serviceDetailController.selectedClinic(clinicData);
                          currentSelectedClinic(
                              serviceDetailController.selectedClinic.value);
                        }
                      },
                      onClickViewDetail: (clinicData) {
                        /// Store selected clinic in global variable
                        currentSelectedClinic(clinicData);
                        Get.delete<ServiceListController>();
                        Get.to(() => ClinicDetailScreen(),
                            arguments: clinicData);
                      },
                    ),    */
                    //  32.height,
                  ],
                );
              },
            ),
          ),
        ),
        widgetsStackedOverBody: [
          Positioned(
            right: 10,
            bottom: 16,
            width: Get.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// ==============================
                /// FLOATING HELP FAB
                /// ==============================
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: whiteTextColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    locale.value.needHelpDeciding,
                    style: primaryTextStyle(
                      size: 11,
                      color: appColorSecondary,
                    ),
                  ),
                ),
                6.height,
                GestureDetector(
                  onTap: () async {
                    await openWhatsAppSupport(context);
                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: appColorSecondary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: appColorSecondary.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                10.height,

                /// ==============================
                /// MAIN CTA BUTTON
                /// ==============================

                AppButton(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  width: Get.width,
                  elevation: 0,
                  color: appColorSecondary,
                  onTap: () async {
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
                              currentSelectedService(
                                  serviceDetailController.serviceData.value);
                              Get.back();

                              // Check if Doctor On Call - skip doctor selection
                              // if (isDoctorOnCall) {
                              //   Get.to(() => BookingFormScreen());
                              // } else {
                              //   Get.to(
                              //     () => DoctorsListScreen(),
                              //     arguments: currentSelectedClinic.value.id,
                              //   );
                              // }
                            },
                          );
                        },
                      );
                      return;
                    }

                    /// 👉 Unified "Contact Us" condition
                    final bool shouldContactUs = (isSessionBasedService &&
                            serviceDetailController
                                    .selectedSession.value?.price ==
                                null) ||
                        (isDayWiseService &&
                            serviceDetailController.showContactUsForHomeCare);

                    if (shouldContactUs) {
                      await openWhatsAppSupport(context);
                      return;
                    }

                    /// Store selected service
                    currentSelectedService(
                        serviceDetailController.serviceData.value);

                    /// Save billing selections to global state
                    currentSelectedSessionPackage(
                        serviceDetailController.selectedSession.value);
                    currentSelectedDayOption(
                        serviceDetailController.selectedDays.value);
                    currentSelectedHourOption(
                        serviceDetailController.selectedHours.value);

                    /// Simple navigation: has doctors → doctor selection, no doctors → booking form
                    final hasDoctors = serviceDetailController
                        .serviceData.value.assignDoctor.isNotEmpty;

                    if (hasDoctors) {
                      // Service has doctors - go to doctor selection
                      // Use bookWithFirstAvailableClinic to handle clinic + doctor flow
                      await serviceDetailController
                          .bookWithFirstAvailableClinic();
                    } else {
                      // No doctors assigned - go directly to booking form
                      Get.to(() => BookingFormScreen());
                    }
                  },
                  child: Obx(() {
                    final bool isCustomSelection = (isSessionBasedService &&
                            serviceDetailController
                                    .selectedSession.value?.price ==
                                null) ||
                        (isDayWiseService &&
                            serviceDetailController.showContactUsForHomeCare);

                    return Text(
                      isCustomSelection
                          ? locale.value.contactUs
                          : locale.value.bookNow,
                      style: boldTextStyle(
                        size: 14,
                        color: whiteTextColor,
                        weight: FontWeight.w400,
                      ),
                    ).paddingSymmetric(horizontal: 16);
                  }),
                ),
              ],
            ),
          )
        ],
      );
    });
  }
}

import 'package:flutter/material.dart';
import '/components/cached_image_widget.dart';
import '/screens/home/components/clinic_list_widget.dart';
import '/screens/home/components/quick_book_controller.dart';
import '/utils/common_base.dart';
import '/utils/view_all_label_component.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:get/get.dart';

import '../../../components/bottom_selection_widget.dart';
import '../../../components/loader_widget.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/empty_error_state_widget.dart';
import '../../../../utils/app_common.dart';
import '../home_controller.dart';

class QuickBookComponent extends StatelessWidget {
  QuickBookComponent({super.key});

  final QuickBookController quickBookController =
      Get.put(QuickBookController());
  final HomeController homeScreenController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          child: Column(
            children: [
              16.height,
              ViewAllLabel(
                label: locale.value.quicklyBookYourAppointmentNow,
                isShowAll: false,
              ),
              8.height,
              SizedBox(
                height: 40,
                child: AppTextField(
                  readOnly: true,
                  onTap: () {
                    quickBookController.currentPage.value = 1;
                    quickBookController.serviceList.clear();
                    quickBookController.getServiceList();
                    serviceCommonBottomSheet(
                      context,
                      child: Obx(
                        () => BottomSelectionSheet(
                          title: locale.value.chooseService,
                          hintText: locale.value.searchForService,
                          hasError: quickBookController
                              .hasErrorFetchingServices.value,
                          isEmpty: quickBookController.serviceList.isEmpty,
                          isLoading: quickBookController.isLoading,
                          currentPage: quickBookController.currentPage,
                          searchApiCall: (p0) {
                            log("Search Spec ==> $p0");
                            quickBookController.searchService(p0);
                            quickBookController.getServiceList();
                          },
                          onRetry: () {
                            quickBookController.currentPage.value = 1;
                            quickBookController.serviceList.clear();
                            quickBookController.getServiceList();
                          },
                          listWidget: AnimatedListView(
                            shrinkWrap: true,
                            itemCount: quickBookController.serviceList.length,
                            padding: EdgeInsets.zero,
                            physics: const AlwaysScrollableScrollPhysics(),
                            listAnimationType: ListAnimationType.Slide,
                            itemBuilder: (ctx, index) {
                              return GestureDetector(
                                onTap: () {
                                  hideKeyboard(context);
                                  quickBookController.selectedServiceId.value =
                                      quickBookController.serviceList[index].id;
                                  quickBookController.serviceCont.text =
                                      quickBookController
                                          .serviceList[index].name;
                                  quickBookController.selectedService.value =
                                      quickBookController.serviceCont.text;
                                  quickBookController.serviceData =
                                      quickBookController.serviceList[index];
                                  quickBookController.clinicCont.clear();
                                  quickBookController.dateCont.clear();
                                  quickBookController.timeCont.clear();
                                  Get.back();
                                  quickBookController.getClinicList();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: boxDecorationDefault(
                                    borderRadius: BorderRadius.circular(6),
                                    color: isDarkMode.value
                                        ? appScreenBackgroundDark
                                        : appScreenBackground,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CachedImageWidget(
                                        url: quickBookController
                                            .serviceList[index].serviceImage,
                                        width: 60,
                                        radius: 6,
                                        fit: BoxFit.cover,
                                        height: 60,
                                      ),
                                      12.width,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                              quickBookController
                                                  .serviceList[index].name
                                                  .toString(),
                                              style: boldTextStyle(
                                                  size: 16,
                                                  color: isDarkMode.value
                                                      ? null
                                                      : darkGrayTextColor)),
                                          2.height,
                                          Text(
                                              quickBookController
                                                  .serviceList[index]
                                                  .description
                                                  .toString(),
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              style: primaryTextStyle(
                                                  size: 12,
                                                  color: secondaryTextColor)),
                                        ],
                                      ).expand()
                                    ],
                                  ),
                                ),
                              ).visible(!quickBookController.isLoading.value);
                            },
                            onNextPage: () async {
                              if (!quickBookController.hasMoreData.value) {
                                quickBookController.currentPage += 1;
                                quickBookController.getServiceList();
                              }
                            },
                            onSwipeRefresh: () async {
                              quickBookController.currentPage.value = 1;
                            },
                          ).expand(),
                        ),
                      ),
                    );
                  },
                  controller: quickBookController.serviceCont,
                  textFieldType: TextFieldType.NAME,
                  textStyle: primaryTextStyle(decorationColor: appColorPrimary),
                  decoration: inputDecorationWithOutBorder(
                    context,
                    hintText: locale.value.selectService,
                    filled: true,
                    fillColor: context.cardColor,
                  ),
                  suffix:
                      Icon(Icons.arrow_drop_down_outlined, color: Colors.grey),
                ),
              ),
              16.height,
              // SizedBox(
              //   height: 40,
              //   child: AppTextField(
              //     readOnly: true,
              //     onTap: () async {
              //       //   quickBookController.getClinicList();
              //       /*  serviceCommonBottomSheet(
              //         context,
              //         child: Obx(
              //           () => BottomSelectionSheet(
              //             title: locale.value.chooseClinic,
              //             hintText: locale.value.searchForClinic,
              //             hasError:
              //                 quickBookController.hasErrorFetchingClinic.value,
              //             isEmpty: !quickBookController.isLoading.value &&
              //                 quickBookController.clinicList.isEmpty,
              //             isLoading: quickBookController.isLoading,
              //             searchApiCall: (p0) {
              //               quickBookController.searchClinic(p0);
              //               quickBookController.getClinicList();
              //             },
              //             onRetry: () {
              //               quickBookController.getClinicList();
              //             },
              //             listWidget: ClinicListWidget(
              //                     clinicList: quickBookController.clinicList)
              //                 .expand(),
              //           ),
              //         ),
              //       );*/

              //       if (quickBookController.serviceCont.text.isEmpty) {
              //         toast('Select the Service First');

              //         //toast(locale.value.selectServiceFirst);
              //         return;
              //       }

              //       // Prevent duplicate API calls
              //       if (quickBookController.clinicCont.text.isNotEmpty) return;

              //       await quickBookController.getClinicList();
              //     },
              //     controller: quickBookController.clinicCont,
              //     textFieldType: TextFieldType.NAME,
              //     textStyle: primaryTextStyle(decorationColor: appColorPrimary),
              //     decoration: inputDecorationWithOutBorder(
              //       context,
              //       hintText: locale.value.selectClinic,
              //       filled: true,
              //       fillColor: context.cardColor,
              //     ),
              //     suffix:
              //         Icon(Icons.arrow_drop_down_outlined, color: Colors.grey),
              //   ),
              // ),
              // 16.height,
              // SizedBox(
              //   height: 40,
              //   child: AppTextField(
              //     readOnly: true,
              //     onTap: () async {
              //       //   quickBookController.getClinicList();
              //       /*  serviceCommonBottomSheet(
              //         context,
              //         child: Obx(
              //           () => BottomSelectionSheet(
              //             title: locale.value.chooseClinic,
              //             hintText: locale.value.searchForClinic,
              //             hasError:
              //                 quickBookController.hasErrorFetchingClinic.value,
              //             isEmpty: !quickBookController.isLoading.value &&
              //                 quickBookController.clinicList.isEmpty,
              //             isLoading: quickBookController.isLoading,
              //             searchApiCall: (p0) {
              //               quickBookController.searchClinic(p0);
              //               quickBookController.getClinicList();
              //             },
              //             onRetry: () {
              //               quickBookController.getClinicList();
              //             },
              //             listWidget: ClinicListWidget(
              //                     clinicList: quickBookController.clinicList)
              //                 .expand(),
              //           ),
              //         ),
              //       );*/

              //       if (quickBookController.serviceCont.text.isEmpty) {
              //         toast('Select the Service First');

              //         //toast(locale.value.selectServiceFirst);
              //         return;
              //       }

              //       // Prevent duplicate API calls
              //       if (quickBookController.clinicCont.text.isNotEmpty) return;

              //       await quickBookController.getClinicList();
              //     },
              //     controller: quickBookController.clinicCont,
              //     textFieldType: TextFieldType.NAME,
              //     textStyle: primaryTextStyle(decorationColor: appColorPrimary),
              //     decoration: inputDecorationWithOutBorder(
              //       context,
              //       hintText: locale.value.selectClinic,
              //       filled: true,
              //       fillColor: context.cardColor,
              //     ),
              //     suffix:
              //         Icon(Icons.arrow_drop_down_outlined, color: Colors.grey),
              //   ),
              // ),
              // 16.height,
              SizedBox(
                height: 40,
                child: AppTextField(
                  readOnly: true,
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      quickBookController.dateCont.text =
                          selectedDate.formatDateYYYYmmdd();
                      quickBookController.selectedDate.value =
                          selectedDate.formatDateYYYYmmdd();
                      quickBookController.getTimeSlot(showLoader: true);
                    } else {
                      toast(locale.value.dateIsNotSelected);
                    }
                  },
                  controller: quickBookController.dateCont,
                  textStyle: primaryTextStyle(decorationColor: appColorPrimary),
                  decoration: inputDecorationWithOutBorder(
                    context,
                    hintText: locale.value.chooseDate,
                    filled: true,
                    fillColor: context.cardColor,
                  ),
                  textFieldType: TextFieldType.NAME,
                  suffix: Icon(
                    Icons.date_range_rounded,
                    color: Colors.grey,
                  ),
                ),
              ),
              16.height,
              SizedBox(
                height: 40,
                child: AppTextField(
                  onTap: () {
                    quickBookController.getTimeSlot(showLoader: true);
                  },
                  readOnly: true,
                  controller: quickBookController.timeCont,
                  textStyle: primaryTextStyle(decorationColor: appColorPrimary),
                  decoration: inputDecorationWithOutBorder(
                    context,
                    hintText: locale.value.chooseTime,
                    filled: true,
                    fillColor: context.cardColor,
                  ),
                  textFieldType: TextFieldType.NAME,
                  suffix: Icon(
                    Icons.arrow_drop_down_outlined,
                    color: Colors.grey,
                  ),
                ),
              ),

              Obx(
                () {
                  return SnapHelperWidget(
                    future: quickBookController.slotsFuture.value,
                    errorBuilder: (error) {
                      return NoDataWidget(
                        title: error,
                        retryText: locale.value.reload,
                        imageWidget: const ErrorStateWidget(),
                        onRetry: () {
                          quickBookController.getTimeSlot(showLoader: true);
                        },
                      ).paddingSymmetric(horizontal: 32);
                    },
                    loadingWidget: quickBookController.isLoading.value
                        ? const Offstage()
                        : const LoaderWidget(),
                    onSuccess: (p0) {
                      if (quickBookController.slots.isEmpty &&
                          quickBookController.isLoading.value == false) {
                        return NoDataWidget(
                                title: locale.value.noTimeSlotsAvailable)
                            .paddingBottom(12)
                            .visible(
                                quickBookController.dateCont.text.isNotEmpty &&
                                    quickBookController
                                        .serviceCont.text.isNotEmpty);
                      }

                      return Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            16.height,
                            ViewAllLabel(
                                    label: locale.value.chooseTime,
                                    isShowAll: false)
                                .paddingOnly(right: 8)
                                .visible(quickBookController.isLoading.value ==
                                    false),
                            LoaderWidget()
                                .visible(quickBookController.isLoading.value),
                            Container(
                              padding: const EdgeInsets.all(16),
                              width: Get.width,
                              alignment: Alignment.center,
                              decoration: boxDecorationDefault(
                                  color: context.cardColor),
                              child: AnimatedWrap(
                                spacing: 12,
                                runSpacing: 12,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.start,
                                children: List.generate(
                                  quickBookController.slots.length,
                                  (i) {
                                    String slot = quickBookController.slots[i];
                                    return Obx(
                                      () => GestureDetector(
                                        onTap: () {
                                          quickBookController
                                              .selectedSlot(slot);
                                          quickBookController
                                              .onDateTimeChange();
                                          quickBookController.timeCont.text =
                                              slot;
                                        },
                                        child: Container(
                                          width: Get.width / 3 - 32,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          decoration:
                                              boxDecorationWithRoundedCorners(
                                            backgroundColor: quickBookController
                                                        .selectedSlot.value ==
                                                    slot
                                                ? appColorPrimary
                                                : context
                                                    .scaffoldBackgroundColor,
                                            borderRadius: BorderRadius.circular(
                                                defaultRadius / 2),
                                          ),
                                          child: Text(
                                            slot,
                                            textAlign: TextAlign.center,
                                            style: primaryTextStyle(
                                              size: 12,
                                              color: (quickBookController
                                                          .selectedSlot.value ==
                                                      slot)
                                                  ? Colors.white
                                                  : appColorPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ).visible(!quickBookController.isLoading.value),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),

              Obx(
                () => Column(
                  children: [
                    16.height,
                    AppButton(
                      text: locale.value.bookNow,
                      color: appColorPrimary,
                      textStyle: boldTextStyle(color: Colors.white),
                      onTap: () {
                        doIfLoggedIn(() {
                          quickBookController.bookAppointment();
                        });
                      },
                      width: Get.width,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: radius(defaultRadius)),
                    )
                  ],
                ).visible(quickBookController.selectedSlot.value != ""),
              ),
              // 16.height,
            ],
          ).paddingAll(16),
        ).visible(homeScreenController.isLoading.value == false));
  }
}

void serviceCommonBottomSheet(BuildContext context,
    {required Widget child, final Function(dynamic)? onSheetClose}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(30),
        topRight: Radius.circular(30),
      ),
    ),
    builder: (context) => child,
  ).then((value) {
    onSheetClose?.call(value);
  });
}

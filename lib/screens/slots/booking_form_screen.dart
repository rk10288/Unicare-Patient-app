import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../components/app_scaffold.dart';
import '../../components/add_files_widget.dart';
import '../../components/applied_tax_list_bottom_sheet.dart';
import '../../components/bottom_selection_widget.dart';
import '../../components/cached_image_widget.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../../utils/empty_error_state_widget.dart';
import '../../utils/price_widget.dart';
import '../../utils/view_all_label_component.dart';
import '../auth/model/login_response.dart';
import '../clinic/model/clinic_detail_model.dart';
import '../clinic/model/clinics_res_model.dart';
import '../doctor/model/doctor_list_res.dart';
import '../other_patient/add_other_patient_screen.dart';
import '../service/model/service_list_model.dart';
import 'booking_form_controller.dart';
import 'components/clinic_selection_card_widget.dart';
import 'components/common_selection_comp.dart';
import 'components/doctor_selection_card_widget.dart';
import 'components/service_selection_card_widget.dart';
import 'mapbox_address_picker_screen.dart';

class BookingFormScreen extends StatelessWidget {
  BookingFormScreen({super.key});

  final BookingFormController timeSlotsCont = Get.put(BookingFormController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.bookingForm,
      scaffoldBackgroundColor: context.scaffoldBackgroundColor,
      appBarVerticalSize: Get.height * 0.12,
      isLoading: timeSlotsCont.isLoading,
      body: RefreshIndicator(
        onRefresh: () async => await timeSlotsCont.init(showLoader: false),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Obx(
              () => AnimatedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                listAnimationType: ListAnimationType.FadeIn,
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 90,
                ),
                children: [
                  16.height,
                  ViewAllLabel(
                          label: locale.value.bookingInfo, isShowAll: false)
                      .paddingOnly(right: 8),
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.all(16),
                      decoration:
                          boxDecorationDefault(color: context.cardColor),
                      child: Column(
                        children: [
                          CommonSelectionWid(
                            title: "${locale.value.serviceName}:",
                            selectedName: timeSlotsCont.serviceNameText.value,
                            onEdit: () {
                              timeSlotsCont.servicePage(1);
                              timeSlotsCont.getServiceList();
                              serviceCommonBottomSheet(
                                context,
                                child: BottomSelectionSheet(
                                  title: locale.value.chooseService,
                                  hintText: locale.value.searchForService,
                                  hasError: timeSlotsCont
                                      .hasErrorFetchingService.value,
                                  isEmpty: !timeSlotsCont.isLoading.value &&
                                      timeSlotsCont.serviceList.isEmpty,
                                  errorText:
                                      timeSlotsCont.errorMessageService.value,
                                  noDataTitle: locale.value.serviceListIsEmpty,
                                  noDataSubTitle: locale.value
                                      .thereAreNoServicesListedAtTheMomentStayTunedF,
                                  isLoading: timeSlotsCont.isLoading,
                                  searchApiCall: (p0) {
                                    timeSlotsCont.getServiceList(
                                        searchText: p0);
                                  },
                                  onRetry: () {
                                    timeSlotsCont.servicePage(1);
                                    timeSlotsCont.getServiceList();
                                  },
                                  listWidget: Obx(() =>
                                      serviceListWid(timeSlotsCont.serviceList)
                                          .expand()),
                                ),
                              );
                            },
                          ),
                          commonDivider.paddingSymmetric(vertical: 16),
                          // CommonSelectionWid(
                          //   title: "${locale.value.clinicName}:",
                          //   selectedName: timeSlotsCont.clinicNameText.value,
                          //   onEdit: () {
                          //     if (currentSelectedService.value.id.isNegative &&
                          //         timeSlotsCont
                          //             .selectedService.value.id.isNegative) {
                          //       toast(locale.value.kindlyChooseAServiceFirst);
                          //       return;
                          //     }
                          //     timeSlotsCont.clinicPage(1);
                          //     timeSlotsCont.getClinicList();
                          //     serviceCommonBottomSheet(
                          //       context,
                          //       child: BottomSelectionSheet(
                          //         title: locale.value.chooseClinic,
                          //         hintText: locale.value.searchForClinic,
                          //         hasError: timeSlotsCont
                          //             .hasErrorFetchingClinic.value,
                          //         isEmpty: !timeSlotsCont.isLoading.value &&
                          //             timeSlotsCont.clinicList.isEmpty,
                          //         errorText:
                          //             timeSlotsCont.errorMessageClinic.value,
                          //         noDataTitle: locale.value.clinicListIsEmpty,
                          //         noDataSubTitle: locale.value
                          //             .thereAreNoClinicsListedAtTheMomentStayTunedFo,
                          //         isLoading: timeSlotsCont.isLoading,
                          //         searchApiCall: (p0) {
                          //           timeSlotsCont.getClinicList(searchText: p0);
                          //         },
                          //         onRetry: () {
                          //           timeSlotsCont.clinicPage(1);
                          //           timeSlotsCont.getClinicList();
                          //         },
                          //         listWidget: Obx(() =>
                          //             clinicListWid(timeSlotsCont.clinicList)
                          //                 .expand()),
                          //       ),
                          //     );
                          //   },
                          // ),
                          // commonDivider.paddingSymmetric(vertical: 16),
                          // CommonSelectionWid(
                          //   title: "${locale.value.doctorName}:",
                          //   selectedName: timeSlotsCont.doctorNameText.value,
                          //   onEdit: () {
                          //     if (timeSlotsCont.doctorList.length == 1 &&
                          //         timeSlotsCont
                          //                 .selectedClinic.value.createdBy ==
                          //             timeSlotsCont.doctorList.first.id) {
                          //       //
                          //     } else {
                          //       // Allow doctor selection without clinic for home_visit/online services
                          //       timeSlotsCont.doctorPage(1);
                          //       timeSlotsCont.getDoctorList();
                          //       serviceCommonBottomSheet(
                          //         context,
                          //         child: BottomSelectionSheet(
                          //           title: locale.value.chooseDoctor,
                          //           hintText: locale.value.searchForDoctor,
                          //           hasError: timeSlotsCont
                          //               .hasErrorFetchingDoctor.value,
                          //           isEmpty: !timeSlotsCont.isLoading.value &&
                          //               timeSlotsCont.doctorList.isEmpty,
                          //           errorText:
                          //               timeSlotsCont.errorMessageDoctor.value,
                          //           isLoading: timeSlotsCont.isLoading,
                          //           noDataTitle: locale.value
                          //               .thereAreNoDoctorsListedAtTheMomentStayTunedFo,
                          //           searchApiCall: (p0) {
                          //             timeSlotsCont.getDoctorList(
                          //                 searchText: p0);
                          //           },
                          //           onRetry: () {
                          //             timeSlotsCont.doctorPage(1);
                          //             timeSlotsCont.getDoctorList();
                          //           },
                          //           listWidget: Obx(() =>
                          //               doctorListWid(timeSlotsCont.doctorList)
                          //                   .expand()),
                          //         ),
                          //       );
                          //     }
                          //   },
                          // ),
                          // commonDivider.paddingSymmetric(vertical: 16),
                          // Get Users address, if not available then show message to add address
                          CommonSelectionWid(
                            title: "${locale.value.address}:",
                            selectedName: timeSlotsCont.addressText.value,
                            onEdit: () {
                              // Show address selection sheet
                              addressBottomSheet(context);
                              // timeSlotsCont.openMapScreen();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Price Summary (read-only - selection is done on Service Detail screen)
                  Obx(() {
                    final service = timeSlotsCont.selectedService.value;
                    final isSessionBased = service.isSessionBasedService;
                    final isDayWise = service.isDayWiseService;
                    final hasSessionPackage =
                        timeSlotsCont.selectedSessionPackage.value != null;
                    final hasDayHourSelection =
                        timeSlotsCont.selectedDayOption.value != null &&
                            timeSlotsCont.selectedHourOption.value != null;

                    // Only show price summary if there's a non-standard billing selection
                    if ((isSessionBased && hasSessionPackage) ||
                        (isDayWise && hasDayHourSelection)) {
                      return Column(
                        children: [
                          16.height,
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: boxDecorationDefault(
                              color: lightPrimaryColor.withValues(alpha: 0.3),
                              border: Border.all(
                                  color:
                                      appColorPrimary.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSessionBased
                                          ? locale.value.selectPackage
                                          : 'Estimated Price',
                                      style: secondaryTextStyle(size: 12),
                                    ),
                                    4.height,
                                    if (isDayWise && hasDayHourSelection)
                                      Text(
                                        '${timeSlotsCont.selectedHourOption.value!.hours}h × ${timeSlotsCont.selectedDayOption.value!.days}d/week',
                                        style: secondaryTextStyle(size: 10),
                                      ),
                                    if (isSessionBased && hasSessionPackage)
                                      Text(
                                        '${timeSlotsCont.selectedSessionPackage.value!.title} - ${timeSlotsCont.selectedSessionPackage.value!.sessions} sessions',
                                        style: secondaryTextStyle(size: 10),
                                      ),
                                  ],
                                ),
                                Text(
                                  '${appConfigs.value.currency.currencySymbol}${timeSlotsCont.effectivePrice.toStringAsFixed(2)}',
                                  style: boldTextStyle(
                                      size: 18, color: appColorPrimary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  16.height,
                  ViewAllLabel(label: locale.value.chooseDate, isShowAll: false)
                      .paddingOnly(right: 8),
                  Container(
                    decoration: boxDecorationDefault(color: context.cardColor),
                    child: DatePicker(
                      dateTextStyle: boldTextStyle(size: 18),
                      dayTextStyle: secondaryTextStyle(size: 14),
                      monthTextStyle: secondaryTextStyle(size: 14),
                      DateTime.now(),
                      initialSelectedDate: DateTime.now(),
                      selectionColor: lightPrimaryColor,
                      selectedTextColor: appColorPrimary,
                      height: 100,
                      onDateChange: (date) {
                        timeSlotsCont.selectedDate(date.formatDateYYYYmmdd());
                        timeSlotsCont.selectedSlot("");
                        timeSlotsCont.getTimeSlot();
                        timeSlotsCont.onDateTimeChange();
                      },
                    ),
                  ),
                  16.height,
                  Obx(
                    () {
                      return SnapHelperWidget(
                        future: timeSlotsCont.slotsFuture.value,
                        errorBuilder: (error) {
                          return NoDataWidget(
                            title: error,
                            retryText: locale.value.reload,
                            imageWidget: const ErrorStateWidget(),
                            onRetry: () {
                              timeSlotsCont.getTimeSlot();
                            },
                          ).paddingSymmetric(horizontal: 32);
                        },
                        loadingWidget: timeSlotsCont.isLoading.value
                            ? const Offstage()
                            : const LoaderWidget(),
                        onSuccess: (p0) {
                          if (timeSlotsCont.slots.isEmpty) {
                            return NoDataWidget(
                                    title: locale.value.noTimeSlotsAvailable)
                                .paddingBottom(12);
                          }

                          return Obx(
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ViewAllLabel(
                                        label: locale.value.chooseTime,
                                        isShowAll: false)
                                    .paddingOnly(right: 8),
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
                                    crossAxisAlignment:
                                        WrapCrossAlignment.start,
                                    children: List.generate(
                                      timeSlotsCont.slots.length,
                                      (i) {
                                        String slot = timeSlotsCont.slots[i];
                                        return Obx(
                                          () => GestureDetector(
                                            onTap: () {
                                              timeSlotsCont.selectedSlot(slot);
                                              timeSlotsCont.onDateTimeChange();
                                            },
                                            child: Container(
                                              width: Get.width / 3 - 32,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              decoration:
                                                  boxDecorationWithRoundedCorners(
                                                backgroundColor: timeSlotsCont
                                                            .selectedSlot
                                                            .value ==
                                                        slot
                                                    ? appColorPrimary
                                                    : context
                                                        .scaffoldBackgroundColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        defaultRadius / 2),
                                              ),
                                              child: Text(
                                                slot,
                                                textAlign: TextAlign.center,
                                                style: primaryTextStyle(
                                                  size: 12,
                                                  color: (timeSlotsCont
                                                              .selectedSlot
                                                              .value ==
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
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                  16.height,
                  ViewAllLabel(
                    label: locale.value.bookedFor,
                    trailingText: locale.value.addPatient,
                    onTap: () {
                      Get.to(() => AddOtherPatientScreen(
                          titleText: locale.value.addPatient,
                          memberData: UserData()))?.then(
                        (value) {
                          if (value == true) {
                            timeSlotsCont.manageOtherPatientController
                                .getOtherPatientList();
                          }
                        },
                      );
                    },
                  ),
                  SnapHelperWidget(
                    future: timeSlotsCont.manageOtherPatientController
                        .otherPatientListFuture.value,
                    loadingWidget: const LoaderWidget().center(),
                    errorBuilder: (error) {
                      return NoDataWidget(
                        title: error,
                        retryText: locale.value.reload,
                        imageWidget: const ErrorStateWidget(),
                        onRetry: () async {
                          await timeSlotsCont.manageOtherPatientController
                              .onRefresh();
                        },
                      ).paddingSymmetric(horizontal: 32);
                    },
                    onSuccess: (data) {
                      if (data.isEmpty) return const Offstage();
                      return AnimatedWrap(
                        listAnimationType: ListAnimationType.None,
                        spacing: 16,
                        runSpacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: data.map((userData) {
                          return Obx(() {
                            return GestureDetector(
                              onTap: () {
                                if (timeSlotsCont.selectedMember.value.id ==
                                    userData.id) {
                                  timeSlotsCont.selectedMember(UserData());
                                } else {
                                  timeSlotsCont.selectedMember(userData);
                                }
                              },
                              child: AnimatedOpacity(
                                opacity: 1,
                                duration: const Duration(milliseconds: 500),
                                child: Container(
                                  width: Get.width / 3 - 24,
                                  decoration: boxDecorationDefault(
                                    color:
                                        timeSlotsCont.selectedMember.value.id ==
                                                userData.id
                                            ? appColorPrimary
                                            : context.cardColor,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 8),
                                  child: Row(
                                    spacing: 12,
                                    children: [
                                      CachedImageWidget(
                                        url: userData.profileImage,
                                        circle: true,
                                        height: 28,
                                        width: 28,
                                        fit: BoxFit.cover,
                                      ),
                                      Text(
                                        userData.firstName,
                                        style: boldTextStyle(
                                          size: 14,
                                          color: timeSlotsCont.selectedMember
                                                      .value.id ==
                                                  userData.id
                                              ? Colors.white
                                              : isDarkMode.value
                                                  ? Colors.white
                                                  : Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ).expand(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                        }).toList(),
                      );
                    },
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(size: 12),
                    textFieldType: TextFieldType.MULTILINE,
                    isValidationRequired: false,
                    minLines: 5,
                    controller: timeSlotsCont.medicalReportCont,
                    decoration: inputDecoration(context,
                        labelText: locale.value.writeMedicalHistory,
                        fillColor: context.cardColor,
                        filled: true),
                  ),
                  16.height,
                  AddFilesWidget(
                    width: Get.width * 0.9,
                    fileList: timeSlotsCont.medicalReportFiles,
                    onFilePick: timeSlotsCont.handleFilesPickerClick,
                    onFilePathRemove: (index) {
                      timeSlotsCont.medicalReportFiles
                          .remove(timeSlotsCont.medicalReportFiles[index]);
                    },
                  ),
                  ViewAllLabel(
                          label: locale.value.paymentDetails, isShowAll: false)
                      .paddingOnly(right: 8),
                  Obx(
                    () {
                      return Container(
                        width: Get.width,
                        padding: const EdgeInsets.all(16),
                        decoration:
                            boxDecorationDefault(color: context.cardColor),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            /// Service price - uses effectivePrice for session/day-wise billing
                            if (timeSlotsCont.selectedService.value
                                    .isSessionBasedService ||
                                timeSlotsCont
                                    .selectedService.value.isDayWiseService)
                              detailWidgetPrice(
                                title: locale.value.price,
                                paddingBottom: 0,
                                value: timeSlotsCont.effectivePrice,
                              )
                            else if (timeSlotsCont.finalAssignDoctor.priceDetail
                                .isIncludesInclusiveTaxAvailable)
                              detailWidgetPrice(
                                title: locale.value.price,
                                paddingBottom: timeSlotsCont.selectedService
                                        .value.assignDoctor.isNotEmpty
                                    ? 0
                                    : 10,
                                value: timeSlotsCont.selectedService.value
                                        .assignDoctor.isNotEmpty
                                    ? timeSlotsCont.finalAssignDoctor
                                        .priceDetail.serviceAmount
                                    : timeSlotsCont
                                        .selectedService.value.charges,
                              )
                            else
                              detailWidgetPrice(
                                title: locale.value.price,
                                paddingBottom: timeSlotsCont.selectedService
                                        .value.assignDoctor.isNotEmpty
                                    ? 0
                                    : 10,
                                value: timeSlotsCont.selectedService.value
                                        .assignDoctor.isNotEmpty
                                    ? timeSlotsCont.finalAssignDoctor
                                        .priceDetail.servicePrice
                                    : timeSlotsCont
                                        .selectedService.value.charges,
                              ),
                            // Show billing mode note for session/day-wise services
                            if (timeSlotsCont.selectedService.value
                                    .isSessionBasedService &&
                                timeSlotsCont.selectedSessionPackage.value !=
                                    null)
                              Text(
                                'Package: ${timeSlotsCont.selectedSessionPackage.value!.title}',
                                style: secondaryTextStyle(
                                  color: appColorSecondary,
                                  size: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ).paddingBottom(10),
                            if (timeSlotsCont
                                    .selectedService.value.isDayWiseService &&
                                (timeSlotsCont.selectedDayOption.value !=
                                        null ||
                                    timeSlotsCont.selectedHourOption.value !=
                                        null))
                              Text(
                                'Day-wise: ${timeSlotsCont.selectedDayOption.value?.title ?? ''} ${timeSlotsCont.selectedHourOption.value?.title ?? ''}',
                                style: secondaryTextStyle(
                                  color: appColorSecondary,
                                  size: 11,
                                  fontStyle: FontStyle.italic,
                                ),
                              ).paddingBottom(10),

                            ...[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (timeSlotsCont.selectedService.value
                                      .assignDoctor.isNotEmpty)
                                    Text(
                                      locale.value.asPerDoctorCharges,
                                      style: secondaryTextStyle(
                                        color: appColorSecondary,
                                        size: 11,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  if (timeSlotsCont
                                      .finalAssignDoctor
                                      .priceDetail
                                      .isIncludesInclusiveTaxAvailable)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        locale.value.includesInclusiveTax,
                                        style: secondaryTextStyle(
                                          color: appColorSecondary,
                                          size: 10,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              10.height,
                            ],

                            /// Discount price
                            if (!timeSlotsCont.finalAssignDoctor.priceDetail
                                .isIncludesInclusiveTaxAvailable) ...[
                              if (timeSlotsCont.selectedService.value
                                      .assignDoctor.isNotEmpty &&
                                  timeSlotsCont.finalAssignDoctor.priceDetail
                                          .discountAmount >
                                      0) ...[
                                detailWidgetPrice(
                                  leadingWidget: Row(
                                    children: [
                                      Text(locale.value.discount,
                                          style: secondaryTextStyle()),
                                      if (timeSlotsCont.finalAssignDoctor
                                              .priceDetail.discountType ==
                                          TaxType.PERCENTAGE)
                                        Text(
                                          ' (${timeSlotsCont.finalAssignDoctor.priceDetail.discountValue}% ${locale.value.off})',
                                          style: boldTextStyle(
                                              color: Colors.green, size: 12),
                                        )
                                      else if (timeSlotsCont.finalAssignDoctor
                                              .priceDetail.discountType ==
                                          TaxType.FIXED)
                                        PriceWidget(
                                          price: timeSlotsCont.finalAssignDoctor
                                              .priceDetail.discountValue,
                                          color: Colors.green,
                                          size: 12,
                                          isDiscountedPrice: true,
                                        )
                                    ],
                                  ),
                                  value: timeSlotsCont.finalAssignDoctor
                                      .priceDetail.discountAmount,
                                  textColor: Colors.green,
                                ),
                              ] else if (timeSlotsCont.selectedService.value
                                      .assignDoctor.isEmpty &&
                                  timeSlotsCont
                                      .selectedService.value.isDiscount)
                                detailWidgetPrice(
                                  leadingWidget: Row(
                                    children: [
                                      Text(locale.value.discount,
                                          style: secondaryTextStyle()),
                                      if (timeSlotsCont.selectedService.value
                                              .discountType ==
                                          TaxType.PERCENTAGE)
                                        Text(
                                          ' (${timeSlotsCont.selectedService.value.discountValue}% ${locale.value.off})',
                                          style: boldTextStyle(
                                              color: Colors.green, size: 12),
                                        )
                                      else if (timeSlotsCont.selectedService
                                              .value.discountType ==
                                          TaxType.FIXED)
                                        PriceWidget(
                                          price: timeSlotsCont.selectedService
                                              .value.discountValue,
                                          color: Colors.green,
                                          size: 12,
                                          isDiscountedPrice: true,
                                        )
                                    ],
                                  ),
                                  value: timeSlotsCont
                                      .selectedService.value.discountAmount,
                                  textColor: Colors.green,
                                ),

                              /// Subtotal
                              if (timeSlotsCont.selectedService.value
                                      .assignDoctor.isNotEmpty &&
                                  timeSlotsCont.finalAssignDoctor.priceDetail
                                          .serviceAmount !=
                                      timeSlotsCont
                                          .selectedService.value.payableAmount)
                                detailWidgetPrice(
                                  title: locale.value.subtotal,
                                  value: timeSlotsCont.finalAssignDoctor
                                      .priceDetail.serviceAmount,
                                  paddingBottom: timeSlotsCont
                                          .finalAssignDoctor
                                          .priceDetail
                                          .isIncludesInclusiveTaxAvailable
                                      ? 0
                                      : null,
                                )
                              else if (timeSlotsCont.selectedService.value
                                      .assignDoctor.isEmpty &&
                                  timeSlotsCont
                                      .selectedService.value.isDiscount)
                                detailWidgetPrice(
                                  title: locale.value.subtotal,
                                  value: timeSlotsCont
                                      .selectedService.value.payableAmount,
                                  paddingBottom: timeSlotsCont
                                          .finalAssignDoctor
                                          .priceDetail
                                          .isIncludesInclusiveTaxAvailable
                                      ? 0
                                      : null,
                                ),
                            ],

                            /// Tax
                            if (appConfigs.value.isExclusiveTaxesAvailable)
                              detailWidgetPrice(
                                paddingBottom: 0,
                                leadingWidget: Row(
                                  children: [
                                    Text(locale.value.exclusiveTax,
                                            style: secondaryTextStyle())
                                        .expand(),
                                    const Icon(Icons.info_outline_rounded,
                                            size: 20, color: appColorPrimary)
                                        .onTap(
                                      () {
                                        showModalBottomSheet(
                                          context: context,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: radiusCircular(16),
                                              topRight: radiusCircular(16),
                                            ),
                                          ),
                                          builder: (_) {
                                            return AppliedTaxListBottomSheet(
                                              taxes: appConfigs
                                                  .value.exclusiveTaxList,
                                              subTotal: timeSlotsCont
                                                      .selectedService
                                                      .value
                                                      .assignDoctor
                                                      .isNotEmpty
                                                  ? timeSlotsCont
                                                      .finalAssignDoctor
                                                      .priceDetail
                                                      .serviceAmount
                                                  : timeSlotsCont
                                                      .selectedService
                                                      .value
                                                      .charges,
                                            );
                                          },
                                        );
                                      },
                                    ),
                                    8.width,
                                  ],
                                ).expand(),
                                value: timeSlotsCont.finalAssignDoctor
                                    .priceDetail.totalExclusiveTax,
                                isSemiBoldText: true,
                                textColor: appColorSecondary,
                              ),
                            commonDivider.paddingSymmetric(vertical: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(locale.value.total,
                                    style: boldTextStyle(size: 14)),
                                PriceWidget(
                                  price: timeSlotsCont.totalAmount,
                                  color: appColorPrimary,
                                  size: 16,
                                )
                              ],
                            ),

                            /// Advance Payment
                            if (timeSlotsCont.selectedService.value
                                .isEnableAdvancePayment) ...[
                              8.height,
                              detailWidgetPrice(
                                leadingWidget: Row(
                                  children: [
                                    Text(locale.value.advancePayableAmount,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                        style: secondaryTextStyle()),
                                    Text(
                                      ' (${timeSlotsCont.selectedService.value.advancePaymentAmount}%)',
                                      style: boldTextStyle(
                                          color: Colors.green, size: 12),
                                    ),
                                  ],
                                ).flexible(),
                                value: timeSlotsCont.advancePayableAmount,
                                paddingBottom: 0,
                              ),
                            ]
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              height: 50,
              child: Obx(
                () {
                  return AppButton(
                    width: Get.width,
                    color: timeSlotsCont.nextBtnVisible.value
                        ? appColorSecondary
                        : null,
                    enabled: timeSlotsCont.nextBtnVisible.value ? true : false,
                    disabledColor: timeSlotsCont.nextBtnVisible.value
                        ? null
                        : appColorSecondary.withValues(alpha: 0.5),
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: radius(defaultAppButtonRadius / 2)),
                    onTap: () {
                      if (timeSlotsCont.nextBtnVisible.value) {
                        doIfLoggedIn(() {
                          timeSlotsCont.handleNextClick(context);
                        });
                      }
                    },
                    child: Text(
                      locale.value.next,
                      style: boldTextStyle(
                          color: timeSlotsCont.nextBtnVisible.value
                              ? Colors.white
                              : Colors.white70,
                          size: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a bottom sheet for address selection with options to:
  /// 1. Select saved address from profile
  /// 2. Manually enter an address
  /// 3. Pick from map (coming soon)
  void addressBottomSheet(BuildContext context) {
    final TextEditingController manualAddressController =
        TextEditingController();
    final RxBool isManualEntry = false.obs;

    // Pre-fill with current address if available
    manualAddressController.text = timeSlotsCont.addressController.text;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: Get.height * 0.7,
          ),
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      locale.value.address,
                      style: boldTextStyle(size: 18),
                    ),
                    appCloseIconButton(
                      context,
                      onPressed: () => Get.back(),
                      size: 11,
                    ),
                  ],
                ),
                24.height,

                // Saved Address Section (if user has a saved address)
                if (loginUserData.value.address.isNotEmpty) ...[
                  Text(
                    'Saved Address',
                    style: secondaryTextStyle(size: 12),
                  ),
                  8.height,
                  GestureDetector(
                    onTap: () {
                      timeSlotsCont.addressText(loginUserData.value.address);
                      timeSlotsCont.addressController.text =
                          loginUserData.value.address;
                      Get.back();
                    },
                    child: Container(
                      width: Get.width,
                      padding: const EdgeInsets.all(16),
                      decoration: boxDecorationDefault(
                        color: context.cardColor,
                        border: Border.all(
                          color: appColorPrimary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: appColorPrimary,
                            size: 24,
                          ),
                          12.width,
                          Text(
                            loginUserData.value.address,
                            style: primaryTextStyle(size: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).expand(),
                          Icon(
                            Icons.check_circle_outline,
                            color: timeSlotsCont.addressText.value ==
                                    loginUserData.value.address
                                ? appColorPrimary
                                : Colors.grey.withValues(alpha: 0.3),
                            size: 22,
                          ),
                        ],
                      ),
                    ),
                  ),
                  16.height,
                  commonDivider,
                  16.height,
                ],

                // Manual Entry Section
                Text(
                  'Enter Address Manually',
                  style: secondaryTextStyle(size: 12),
                ),
                8.height,
                AppTextField(
                  controller: manualAddressController,
                  textFieldType: TextFieldType.MULTILINE,
                  textStyle: primaryTextStyle(size: 14),
                  minLines: 2,
                  maxLines: 4,
                  onTap: () {
                    isManualEntry(true);
                  },
                  decoration: inputDecoration(
                    context,
                    labelText: 'Type your address',
                    fillColor: context.cardColor,
                    filled: true,
                  ),
                ),
                12.height,
                Obx(() => AppButton(
                      width: Get.width,
                      text: 'Confirm Address',
                      color: appColorPrimary,
                      textStyle: boldTextStyle(color: Colors.white),
                      onTap: () {
                        if (manualAddressController.text.trim().isNotEmpty) {
                          timeSlotsCont
                              .addressText(manualAddressController.text.trim());
                          timeSlotsCont.addressController.text =
                              manualAddressController.text.trim();
                          Get.back();
                        } else {
                          toast('Please enter a valid address');
                        }
                      },
                    ).visible(isManualEntry.value ||
                        loginUserData.value.address.isEmpty)),
                16.height,
                commonDivider,
                16.height,

                // Pick from Map Section
                Text(
                  'Pick from Map',
                  style: secondaryTextStyle(size: 12),
                ),
                8.height,
                GestureDetector(
                  onTap: () async {
                    // Check if Mapbox is enabled
                    if (appConfigs.value.enableMapbox &&
                        appConfigs.value.mapboxKey.isNotEmpty) {
                      // Close bottom sheet first
                      Get.back();
                      // Navigate to Mapbox picker
                      // final result = await Get.to(
                      //   () => MapboxAddressPickerScreen(
                      //     initialAddress: timeSlotsCont.addressText.value,
                      //   ),
                      // );
                      // // Update address if result is not empty
                      // if (result != null && result.toString().isNotEmpty) {
                      //   timeSlotsCont.addressText(result.toString());
                      //   timeSlotsCont.addressController.text =
                      //       result.toString();
                      // }
                      timeSlotsCont.openMapScreen();
                    } else {
                      toast(
                          'Map selection is not available. Please enable Mapbox from settings.');
                    }
                  },
                  child: Container(
                    width: Get.width,
                    padding: const EdgeInsets.all(16),
                    decoration: boxDecorationDefault(
                      color: appConfigs.value.enableMapbox
                          ? context.cardColor
                          : context.cardColor.withValues(alpha: 0.5),
                      border: Border.all(
                        color: appConfigs.value.enableMapbox
                            ? appColorPrimary.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.3),
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          color: appConfigs.value.enableMapbox
                              ? appColorPrimary
                              : Colors.grey,
                          size: 24,
                        ),
                        12.width,
                        Text(
                          'Select on Map',
                          style: primaryTextStyle(
                            color: appConfigs.value.enableMapbox
                                ? null
                                : Colors.grey,
                            size: 14,
                          ),
                        ),
                        if (!appConfigs.value.enableMapbox) ...[
                          8.width,
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: boxDecorationDefault(
                              color: appColorSecondary.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Not Available',
                              style: secondaryTextStyle(
                                  size: 10, color: appColorSecondary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                24.height,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget serviceListWid(List<ServiceElement> list) {
    return AnimatedListView(
      itemCount: list.length,
      shrinkWrap: true,
      listAnimationType: ListAnimationType.FadeIn,
      itemBuilder: (context, index) {
        return ServiceSelectionCardWidget(
          serviceElement: list[index],
          onTap: () {
            timeSlotsCont.selectedService(list[index]);
            timeSlotsCont
                .serviceNameText(timeSlotsCont.selectedService.value.name);
            currentSelectedService.value.payableAmount =
                timeSlotsCont.selectedService.value.payableAmount.toDouble();
            timeSlotsCont.clinicNameText("");
            timeSlotsCont.doctorNameText("");
            timeSlotsCont.doctorList.clear();
            timeSlotsCont.selectedSlot("");
            timeSlotsCont.slots.clear();
            timeSlotsCont.nextBtnVisible(false);
            timeSlotsCont.selectedDoctor = Doctor().obs;
            timeSlotsCont.selectedClinic =
                Clinic(clinicSession: ClinicSession()).obs;
            timeSlotsCont
                .resetBillingSelections(); // Reset session/day-wise selections
            timeSlotsCont.getClinicList();
            timeSlotsCont.getServiceList();
            Get.back();
          },
        ).paddingBottom(16);
      },
      onNextPage: () {
        if (!timeSlotsCont.isLastPage.value) {
          timeSlotsCont.servicePage(timeSlotsCont.servicePage.value + 1);
          timeSlotsCont.getServiceList();
        }
      },
      onSwipeRefresh: () async {
        timeSlotsCont.servicePage(1);
        return timeSlotsCont.getServiceList();
      },
    );
  }

  Widget clinicListWid(List<Clinic> list) {
    return AnimatedListView(
      itemCount: list.length,
      shrinkWrap: true,
      listAnimationType: ListAnimationType.FadeIn,
      itemBuilder: (context, index) {
        return ClinicSelectionCardWidget(
          clinicData: list[index],
          onTap: () {
            timeSlotsCont.selectedClinic(list[index]);
            timeSlotsCont
                .clinicNameText(timeSlotsCont.selectedClinic.value.name);
            timeSlotsCont.clearDoctorSelection();
            timeSlotsCont.getDoctorList();
            timeSlotsCont.nextBtnVisible(false);
            timeSlotsCont.getClinicList();
            Get.back();
          },
        ).paddingBottom(16);
      },
      onNextPage: () {
        if (!timeSlotsCont.isLastPage.value) {
          timeSlotsCont.clinicPage(timeSlotsCont.clinicPage.value + 1);
          timeSlotsCont.getClinicList();
        }
      },
      onSwipeRefresh: () async {
        timeSlotsCont.clinicPage(1);
        return await timeSlotsCont.getClinicList();
      },
    );
  }

  Widget doctorListWid(List<Doctor> list) {
    return AnimatedListView(
      itemCount: list.length,
      shrinkWrap: true,
      listAnimationType: ListAnimationType.FadeIn,
      itemBuilder: (context, index) {
        return DoctorSelectionCardWidget(
          doctorData: list[index],
          onTap: () {
            timeSlotsCont.selectedDoctor(list[index]);
            timeSlotsCont
                .doctorNameText(timeSlotsCont.selectedDoctor.value.fullName);
            timeSlotsCont.getTimeSlot();
            timeSlotsCont.getDoctorList();
            Get.back();
          },
        ).paddingBottom(16);
      },
      onNextPage: () {
        if (!timeSlotsCont.isLastPage.value) {
          timeSlotsCont.doctorPage(timeSlotsCont.doctorPage.value + 1);
          timeSlotsCont.getDoctorList();
        }
      },
      onSwipeRefresh: () async {
        timeSlotsCont.doctorPage(1);
        return timeSlotsCont.getDoctorList();
      },
    );
  }
}

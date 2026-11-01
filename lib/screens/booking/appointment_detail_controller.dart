// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/api/auth_apis.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/core_apis.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../home/home_controller.dart';
import 'appointments_controller.dart';
import 'model/appointment_detail_res.dart';
import 'model/appointment_invoice_res.dart';
import 'model/appointments_res_model.dart';
import 'model/booking_req.dart';
import 'model/employee_review_data.dart';

class AppointmentDetailController extends GetxController {
  final GlobalKey<FormState> bookingformKey = GlobalKey();
  RxBool isLoading = false.obs;
  RxBool hasReview = false.obs;
  RxBool showWriteReview = false.obs;

  Rx<Future<AppointmentDetailRes>> getAppointmentDetails =
      Future(() => AppointmentDetailRes(data: AppointmentData())).obs;
  Rx<DoctorReviewData> yourReview = DoctorReviewData().obs;

  /// Reschedule Booking
  Rx<Future<RxList<String>>> timeSlotsFuture =
      Future(() => RxList<String>()).obs;
  RxList<String> slots = RxList();
  RxString selectedDate = DateTime.now().formatDateYYYYmmdd().obs;
  RxString selectedSlot = "".obs;
  RxBool updateBtnVisible = false.obs;
  RxBool isUpdateBookingLoading = false.obs;
  BookingReq bookingReq = BookingReq();

  /// Invoice
  Rx<Future<Rx<AppointmentInvoiceResp>>> appointmentInvoiceFuture =
      Future(() => AppointmentInvoiceResp().obs).obs;
  Rx<AppointmentInvoiceResp> appointmentInvoice = AppointmentInvoiceResp().obs;

  RxDouble selectedRating = (0.0).obs;

  Rx<AppointmentData> appointmentDetail = AppointmentData().obs;

  int rating = 0;

  TextEditingController title = TextEditingController();
  TextEditingController reviewCont = TextEditingController();

  @override
  void onInit() {
    if (Get.arguments is AppointmentData) {
      appointmentDetail(Get.arguments);
    }
    init(showLoader: false);
    super.onInit();
  }

  bool get isAdvancePaymentFailed =>
      (appointmentDetail.value.paymentStatus
              .toLowerCase()
              .contains(PaymentStatus.failed) &&
          appointmentDetail.value.isEnableAdvancePayment) &&
      appointmentDetail.value.status
          .toLowerCase()
          .contains(StatusConst.pending.toLowerCase());

  num get payNowAmount => isAdvancePaymentFailed
      ? (appointmentDetail.value.advancePaymentAmount *
              appointmentDetail.value.totalAmount) /
          100
      : appointmentDetail.value.paymentStatus
              .toLowerCase()
              .contains(PaymentStatus.ADVANCE_PAID.toLowerCase())
          ? appointmentDetail.value.remainingPayableAmount
          : appointmentDetail.value.totalAmount;

  ///Get Appointment Detail
  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await getAppointmentDetails(
      CoreServiceApis.getAppointmentDetail(
          appointmentId: appointmentDetail.value.id,
          notifyId: appointmentDetail.value.notificationId),
    ).then((value) {
      if (appointmentDetail.value.notificationId.trim().isNotEmpty &&
          unreadNotificationCount.value > 0) {
        unreadNotificationCount(unreadNotificationCount.value - 1);
      }
      appointmentDetail(value.data);
      hasReview(value.data.reviews != null);
      if (value.data.reviews != null) {
        yourReview(value.data.reviews);
      }
      isLoading(false);
    }).catchError((e) {
      isLoading(false);
      log(e.toString());
    }).whenComplete(() => isLoading(false));
  }

  ///Appointment Invoice Download
  Future<void> getAppointmentInvoice({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }
    await appointmentInvoiceFuture(
            CoreServiceApis.appointmentInvoice(appointmentDetail.value.id))
        .then((appointmentInvoices) {
      appointmentInvoice(appointmentInvoices.value);
      if (appointmentInvoice.value.status == true &&
          appointmentInvoice.value.link.isNotEmpty) {
        viewFiles(appointmentInvoice.value.link);
      } else {
        toast(locale.value.somethingWentWrongPleaseTryAgainLater);
      }
    }).catchError((e) {
      isLoading(false);
      log("getAppointmentInvoiceDetail Err : $e");
    }).whenComplete(() => isLoading(false));
  }

  void deleteReviewHandleClick() {
    showConfirmDialogCustom(
      getContext,
      primaryColor: appColorPrimary,
      negativeText: locale.value.cancel,
      positiveText: locale.value.yes,
      onAccept: (_) {
        deleteReview();
      },
      dialogType: DialogType.DELETE,
      title: locale.value.doYouWantToRemoveThisReview,
    );
  }

  ///Save Review Api
  Future<void> saveReview() async {
    isLoading(true);
    hideKeyBoardWithoutContext();

    Map<String, dynamic> req = {
      "id": yourReview.value.id.isNegative ? "" : yourReview.value.id,
      "doctor_id": appointmentDetail.value.doctorId,
      "service_id": appointmentDetail.value.serviceId,
      "title": title.text.trim(),
      "rating": selectedRating.value,
      "review_msg": reviewCont.text.trim(),
    };

    await CoreServiceApis.updateReview(request: req).then((value) async {
      log('updateReview: ${value.toJson()}');
      showWriteReview(false);
      hasReview(true);
      yourReview(DoctorReviewData(
        rating: selectedRating.value,
        userId: loginUserData.value.id,
        title: title.text.trim(),
        reviewMsg: reviewCont.text.trim(),
        username: loginUserData.value.userName,
        doctorId: appointmentDetail.value.doctorId,
        serviceId: appointmentDetail.value.serviceId,
      ));
      init(showLoader: true);
      isLoading(false);
    }).catchError((e) {
      isLoading(false);
      log(e.toString());
    });
  }

  void handleEditReview() {
    showWriteReview(true);
    title.text = yourReview.value.title;
    reviewCont.text = yourReview.value.reviewMsg;
    selectedRating(yourReview.value.rating.toDouble());
  }

  void showReview() {
    showWriteReview(false);
  }

  ///Delete Review Api
  Future<void> deleteReview() async {
    isLoading(true);
    await CoreServiceApis.deleteReview(id: yourReview.value.id)
        .then((value) async {
      log('updateReview: ${value.toJson()}');
      showWriteReview(false);
      hasReview(false);
      title.text = "";
      reviewCont.text = "";
      selectedRating(0);
      yourReview(DoctorReviewData());
      isLoading(false);
    }).catchError((e) {
      isLoading(false);
      log(e.toString());
    });
  }

  void onDateTimeChange() {
    final appointmentDateTime = "${selectedDate.value} ${selectedSlot.value}";
    if (appointmentDateTime.isValidDateTime) {
      updateBtnVisible(true);
    } else {
      updateBtnVisible(false);
    }
  }

  ///Get Time Slots Api for Reschedule Appointment
  Future<void> getTimeSlot({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    /// Get Time Slots Api Call
    await timeSlotsFuture(
      CoreServiceApis.getTimeSlots(
        slots: slots,
        date: selectedDate.value,
        serviceId: appointmentDetail.value.serviceId,
        clinicId: appointmentDetail.value.clinicId,
        doctorId: appointmentDetail.value.doctorId,
      ),
    ).then((value) {
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isLoading(false);
      log("getTimeSlots error $e");
    }).whenComplete(() => isLoading(false));
  }

  ///Reschedule Appointment
  void handleUpdateClick(BuildContext context, {bool showLoader = true}) {
    if (showLoader) {
      isUpdateBookingLoading(true);
    }

    //BookingReq
    Map<String, dynamic> req = {
      'appointment_id': appointmentDetail.value.id,
      'appointment_date': selectedDate.value,
      'appointment_time': selectedSlot.value,
    };

    CoreServiceApis.rescheduleBooking(request: req).then((value) {
      isUpdateBookingLoading(false);
      toast(value.message.toString());
      Get.back();
      try {
        HomeController hCont = Get.find();
        hCont.init();
      } catch (e) {
        log('onItemSelected Err: $e');
      }
      try {
        AppointmentsController appointmentsCont = Get.find();
        appointmentsCont.page(1);
        appointmentsCont.getAppointmentList();
      } catch (e) {
        log('onItemSelected Err: $e');
      }
      init(showLoader: true);
    }).catchError((e) {
      isLoading(false);
      log('Reschedule booking catch ${e.toString()}');
    }).whenComplete(() => isLoading(false));
  }

  Future<void> updateStatus(
      {required int appointmentId,
      required String status,
      VoidCallback? onUpdateBooking}) async {
    isLoading(true);
    hideKeyBoardWithoutContext();

    Map<String, dynamic> req = {
      "status": status,
    };

    await CoreServiceApis.updateStatus(
            request: req, appointmentId: appointmentId)
        .then((value) async {
      if (onUpdateBooking != null) {
        onUpdateBooking.call();
        toast(locale.value.appointmentCancelSuccessfully);
      }
      try {
        HomeController hCont = Get.find();
        hCont.init();
      } catch (e) {
        log('onItemSelected Err: $e');
      }
      try {
        AuthServiceApis.getUserWallet();
      } catch (e) {
        log('onItemSelected Err: $e');
      }
      isLoading(false);
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }
}

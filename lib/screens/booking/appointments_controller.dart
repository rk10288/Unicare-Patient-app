// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:ui';

import 'package:get/get.dart';
import '/main.dart';
import 'package:nb_utils/nb_utils.dart';
import '/api/core_apis.dart';

import '../../api/auth_apis.dart';
import '../../generated/assets.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../home/home_controller.dart';
import 'model/appointment_status_model.dart';
import 'model/appointments_res_model.dart';

class AppointmentsController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLastPage = false.obs;
  Rx<Future<RxList<AppointmentData>>> getAppointments =
      Future(() => RxList<AppointmentData>()).obs;
  RxList<AppointmentData> appointments = RxList();
  RxInt page = 1.obs;
  RxSet<String> selectedStatus = RxSet();
  RxSet<String> selectedService = RxSet();

  //Tabs
  // RxList<AppointmentStatusModel> filterStatus = RxList();
  Rx<AppointmentStatusModel> selectedTab = AppointmentStatusModel(
          icon: Assets.iconsIcMenu,
          type: AppointmentStatus.all,
          name: (locale.value.all).obs)
      .obs;

  @override
  void onInit() {
    if (filterStatus.isNotEmpty) {
      selectedTab(filterStatus.first);
      // Only fetch appointments if user is logged in
      if (isLoggedIn.value) {
        getAppointmentList(showLoader: false);
      }
    }
    super.onInit();
  }

  Future<void> getAppointmentList(
      {bool showLoader = true, String search = "", String status = ""}) async {
    // Skip API call if user is not logged in
    if (!isLoggedIn.value) {
      appointments.clear();
      isLoading(false);
      return;
    }

    if (showLoader) {
      isLoading(true);
    }
    await getAppointments(CoreServiceApis.getAppointmentList(
      filterByStatus: selectedTab.value.name!.toLowerCase(),
      page: page.value,
      appointments: appointments,
      lastPageCallBack: (p0) {
        isLastPage(p0);
      },
    )).then((value) {}).catchError((e) {
      isLoading(false);
      log('getAppointments E: $e');
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

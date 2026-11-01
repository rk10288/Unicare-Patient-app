import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:unicare_patient/screens/slots/mapbox_address_picker_screen.dart';
import '/api/core_apis.dart';
import '/utils/app_common.dart';
import '/utils/common_base.dart';
import '../auth/profile/profile_controller.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../network/map_screen.dart';
import '../../utils/constants.dart';
import '../auth/model/login_response.dart';
import '../booking/model/booking_req.dart';
import '../clinic/model/clinic_detail_model.dart';
import '../clinic/model/clinics_res_model.dart';
import '../doctor/model/doctor_list_res.dart';
import '../other_patient/manage_other_patient_controller.dart';
import '../service/model/service_list_model.dart';
import '../service/model/session_package_model.dart';
import '../service/model/days_hours_option_model.dart';
import 'components/appointment_summary_comp.dart';

class BookingFormController extends GetxController {
  Rx<Future<RxList<String>>> slotsFuture = Future(() => RxList<String>()).obs;
  RxBool isLoading = false.obs;
  RxBool nextBtnVisible = false.obs;
  RxList<String> slots = RxList();
  RxString selectedDate = DateTime.now().formatDateYYYYmmdd().obs;
  RxString selectedSlot = "".obs;

  RxString addressText = "".obs;
  TextEditingController addressController = TextEditingController();

  final ManageOtherPatientController manageOtherPatientController =
      ManageOtherPatientController();
  final ProfileController profileController = ProfileController();

  Rx<UserData> selectedMember = UserData().obs;

  RxList<PlatformFile> medicalReportFiles = RxList();

  BookingReq bookingReq = BookingReq();

  RxBool isLastPage = false.obs;
  RxInt servicePage = 1.obs;
  RxInt clinicPage = 1.obs;
  RxInt doctorPage = 1.obs;

  //Service
  Rx<ServiceElement> selectedService = ServiceElement().obs;
  RxList<ServiceElement> serviceList = RxList();

  //Error Service
  RxBool hasErrorFetchingService = false.obs;
  RxString errorMessageService = "".obs;

  //Clinic
  Rx<Clinic> selectedClinic = Clinic(clinicSession: ClinicSession()).obs;
  RxList<Clinic> clinicList = RxList();

  //Error Clinic
  RxBool hasErrorFetchingClinic = false.obs;
  RxString errorMessageClinic = "".obs;

  //Doctor
  Rx<Doctor> selectedDoctor = Doctor().obs;
  RxList<Doctor> doctorList = RxList();

  //Error Clinic
  RxBool hasErrorFetchingDoctor = false.obs;
  RxString errorMessageDoctor = "".obs;

  RxString serviceNameText = "".obs;
  RxString clinicNameText = "".obs;
  RxString doctorNameText = "".obs;
  TextEditingController medicalReportCont = TextEditingController();

  // Session-based and Day-wise pricing selections
  Rx<SessionPackage?> selectedSessionPackage = Rx<SessionPackage?>(null);
  Rx<DayOption?> selectedDayOption = Rx<DayOption?>(null);
  Rx<HourOption?> selectedHourOption = Rx<HourOption?>(null);

  @override
  void onInit() {
    if (!currentSelectedService.value.id.isNegative) {
      log('currentSelectedService.value.name==> ${currentSelectedService.value.name}');
      log('currentSelectedService.value.id==> ${currentSelectedService.value.id}');
      selectedService(currentSelectedService.value);
      serviceNameText(currentSelectedService.value.name);
      getClinicList();
    }

    if (!currentSelectedClinic.value.id.isNegative) {
      log('currentSelectedClinic.value.name==> ${currentSelectedClinic.value.name}');
      log('currentSelectedClinic.value.id==> ${currentSelectedClinic.value.id}');
      selectedClinic(currentSelectedClinic.value);
      clinicNameText(currentSelectedClinic.value.name);
    }
    getDoctorList();

    if (!currentSelectedDoctor.value.doctorId.isNegative) {
      log('currentSelectedDoctor.value.name==> ${currentSelectedDoctor.value.fullName}');
      log('currentSelectedDoctor.value.doctorId==> ${currentSelectedDoctor.value.doctorId}');
      selectedDoctor(currentSelectedDoctor.value);
      doctorNameText(currentSelectedDoctor.value.fullName);
    }

    // Initialize billing selections from global state (set from Service Detail screen)
    if (currentSelectedSessionPackage.value != null) {
      selectedSessionPackage(currentSelectedSessionPackage.value);
      log('Restored session package: ${selectedSessionPackage.value?.title}');
    }
    if (currentSelectedDayOption.value != null) {
      selectedDayOption(currentSelectedDayOption.value);
      log('Restored day option: ${selectedDayOption.value?.title}');
    }
    if (currentSelectedHourOption.value != null) {
      selectedHourOption(currentSelectedHourOption.value);
      log('Restored hour option: ${selectedHourOption.value?.title}');
    }

    getTimeSlot();

    init();
    super.onInit();
  }

  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    getServiceList();
    getUserAddress();
    await manageOtherPatientController.getOtherPatientList();
  }

  Future<void> getUserAddress() async {
    // Get the address from logged-in user data
    if (loginUserData.value.address.isNotEmpty) {
      addressText(loginUserData.value.address);
      addressController.text = loginUserData.value.address;
    } else {
      addressText('');
      addressController.text = '';
    }
  }

  RxDouble latitude = 0.0.obs;
  RxDouble longitude = 0.0.obs;

  void openMapScreen() async {
    var result = await Get.to(() => MapboxAddressPickerScreen(
          initialAddress: addressText.value,
        ));
    if (result != null && result is Map) {
      addressText(result['address']);
      addressController.text = result['address'];
      latitude(result['latitude']);
      longitude(result['longitude']);
    } else if (result != null && result is String) {
      addressText(result);
      addressController.text = result;
    }
  }

  Future<void> handleFilesPickerClick() async {
    final pickedFiles = await pickFiles();
    Set<String> filePathsSet = medicalReportFiles
        .map((file) => file.name.trim().toLowerCase())
        .toSet();
    for (var i = 0; i < pickedFiles.length; i++) {
      if (!filePathsSet.contains(pickedFiles[i].name.trim().toLowerCase())) {
        medicalReportFiles.add(pickedFiles[i]);
      }
    }
  }

  ///Get Service List
  void getServiceList({String searchText = ""}) {
    isLoading(true);
    CoreServiceApis.getServiceList(
      page: servicePage.value,
      serviceList: serviceList,
      categoryId: currentSelectedService.value.categoryId,
      systemServiceId: currentSelectedService.value.systemServiceId,
      clinicId: currentSelectedClinic.value.id,
      doctorId: currentSelectedDoctor.value.doctorId,
      search: searchText.trim(),
      lastPageCallBack: (p) {
        isLastPage(p);
      },
    ).then((value) {
      isLoading(false);
      hasErrorFetchingService(false);
    }).onError((error, stackTrace) {
      hasErrorFetchingService(true);
      errorMessageService(error.toString());
      isLoading(false);
    });
  }

  ///Get Clinic List
  Future<void> getClinicList({String searchText = ""}) async {
    isLoading(true);
    await CoreServiceApis.getClinics(
      page: clinicPage.value,
      clinics: clinicList,
      serviceId: selectedService.value.id,
      search: searchText.trim(),
      lastPageCallBack: (p) {
        isLastPage(p);
      },
    ).then((value) {
      isLoading(false);
      hasErrorFetchingClinic(false);
    }).onError((error, stackTrace) {
      hasErrorFetchingClinic(true);
      errorMessageClinic(error.toString());
      isLoading(false);
    });
  }

  void clearDoctorSelection() {
    doctorNameText("");

    /// Clear selected doctor in doctor name field
    selectedDoctor(Doctor());
  }

  ///Get Doctor List
  void getDoctorList({String searchText = ""}) {
    isLoading(true);
    CoreServiceApis.getDoctors(
      page: doctorPage.value,
      doctors: doctorList,
      clinicId: selectedClinic.value.id,
      serviceId: selectedService.value.id,
      search: searchText.trim(),
      lastPageCallBack: (p) {
        isLastPage(p);
      },
    ).then((value) async {
      isLoading(false);
      hasErrorFetchingDoctor(false);
    }).onError((error, stackTrace) {
      hasErrorFetchingDoctor(true);
      errorMessageDoctor(error.toString());
      isLoading(false);
    });
  }

  Future<void> getTimeSlot({bool showLoader = true}) async {
    if (showLoader) {
      isLoading(true);
    }

    /// Get Time Slots Api Call
    await slotsFuture(
      CoreServiceApis.getTimeSlots(
        slots: slots,
        date: selectedDate.value,
        serviceId: selectedService.value.id,
        clinicId: selectedClinic.value.id,
        doctorId: selectedDoctor.value.doctorId,
      ),
    ).then((value) {
      log('value.length ==> ${value.length}');
    }).catchError((e) {
      isLoading(false);
      log("getTimeSlots error $e");
    }).whenComplete(() => isLoading(false));
  }

  void onDateTimeChange() {
    final appointmentDateTime = "${selectedDate.value} ${selectedSlot.value}";
    if (appointmentDateTime.isValidDateTime) {
      nextBtnVisible(true);
    } else {
      nextBtnVisible(false);
    }
  }

  void handleNextClick(BuildContext context) {
    // Validate address for non-online services (home visit, in-clinic, etc.)
    final isOnlineService =
        selectedService.value.type.toLowerCase() == ServiceTypeConst.online;
    if (!isOnlineService && addressText.value.trim().isEmpty) {
      toast('Please provide your address for this service');
      return;
    }

    //BookingReq
    bookingReq.files = medicalReportFiles;
    // Only set clinicId if a valid clinic is selected (supporting clinic-less bookings)
    bookingReq.clinicId =
        selectedClinic.value.id > 0 ? selectedClinic.value.id.toString() : "";
    bookingReq.serviceId = selectedService.value.id.toString();
    bookingReq.appointmentDate = selectedDate.value;
    bookingReq.userId = loginUserData.value.id.toString();
    bookingReq.status = StatusConst.pending;
    bookingReq.doctorId = selectedDoctor.value.doctorId.toString();
    bookingReq.appointmentTime = selectedSlot.value;
    bookingReq.description = medicalReportCont.text;
    //
    bookingReq.serviceName = selectedService.value.name;
    bookingReq.doctorName = selectedDoctor.value.fullName;
    bookingReq.clinicName =
        selectedClinic.value.id > 0 ? selectedClinic.value.name : '';
    // Always use patient's address for location (especially for home visits)
    bookingReq.location = addressText.value;
    bookingReq.latitude = latitude.value.toString();
    bookingReq.longitude = longitude.value.toString();

    bookingReq.totalAmount = totalAmount.toStringAsFixed(2).toDouble();
    bookingReq.isEnableAdvancePayment =
        selectedService.value.isEnableAdvancePayment;
    bookingReq.advancePayableAmount = advancePayableAmount;
    bookingReq.isOnlineService =
        selectedService.value.type.toLowerCase() == ServiceTypeConst.online;
    if (selectedMember.value.id > 0) {
      bookingReq.otherPatientId = selectedMember.value.id.toString();
    }

    // Set billing mode fields
    bookingReq.billingMode = selectedService.value.billingMode;

    // For session-based billing, set the selected package index
    if (selectedService.value.isSessionBasedService &&
        selectedSessionPackage.value != null) {
      final packageIndex = selectedService.value.sessionPackages
          .indexOf(selectedSessionPackage.value!);
      bookingReq.sessionPackageIndex = packageIndex >= 0 ? packageIndex : 0;
    }

    // For day-wise billing, set selected days and hours
    if (selectedService.value.isDayWiseService) {
      bookingReq.selectedDays = selectedDayOption.value?.days ?? 0;
      bookingReq.selectedHours = selectedHourOption.value?.hours ?? 0;
    }

    showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      builder: (_) {
        return AppointmentSummaryWidget(bookingData: bookingReq);
      },
    );
  }

  //----------------------------------------Price Calculation-----------------------------------
  AssignDoctor get finalAssignDoctor =>
      selectedService.value.assignDoctor.firstWhere(
        (element) => element.doctorId == selectedDoctor.value.doctorId,
        orElse: () => AssignDoctor(
          priceDetail: PriceDetail(
            servicePrice: selectedService.value.charges,
            serviceAmount: selectedService.value.charges,
            discountAmount: selectedService.value.discountAmount,
            discountType: selectedService.value.discountType,
            discountValue: selectedService.value.discountValue,
            totalAmount: selectedService.value.payableAmount,
            duration: selectedService.value.duration,
          ),
        ),
      );

  double get fixedExclusiveTaxAmount => appConfigs.value.taxData
      .where((element) =>
          (element.taxScope == TaxType.exclusiveTax) &&
          (element.type.toLowerCase().contains(TaxType.FIXED.toLowerCase())))
      .sumByDouble((p0) => p0.value.validate());

  double get percentExclusiveTaxAmount =>
      appConfigs.value.taxData.where((element) {
        return (element.taxScope == TaxType.exclusiveTax) &&
            (element.type
                .toLowerCase()
                .contains(TaxType.PERCENT.toLowerCase()));
      }).sumByDouble((p0) {
        // Use effectivePrice for tax calculation when using billing modes
        num baseAmount = _getBaseAmountForTax();
        return (baseAmount * p0.value.validate()) / 100;
      });

  /// Get base amount for tax calculation based on billing mode
  num _getBaseAmountForTax() {
    final service = selectedService.value;

    // For session/day-wise billing, use effectivePrice
    if (service.isSessionBasedService || service.isDayWiseService) {
      return effectivePrice;
    }

    // Standard: use assign doctor price or service payable amount
    if (service.assignDoctor.isNotEmpty) {
      return finalAssignDoctor.priceDetail.serviceAmount;
    }
    return service.payableAmount;
  }

  num get totalExclusiveTax =>
      (fixedExclusiveTaxAmount + percentExclusiveTaxAmount)
          .toStringAsFixed(Constants.DECIMAL_POINT)
          .toDouble();

  /// Total amount based on billing mode:
  /// - Standard: uses default price from assign doctor or service
  /// - Session-based: uses selected session package price
  /// - Day-wise: uses (baseRate × hours × days)
  num get totalAmount {
    final service = selectedService.value;

    // Session-based or Day-wise billing: use effectivePrice
    if (service.isSessionBasedService || service.isDayWiseService) {
      return effectivePrice + totalExclusiveTax;
    }

    // Standard billing
    if (service.assignDoctor.isNotEmpty) {
      return finalAssignDoctor.priceDetail.totalAmount;
    }
    return service.payableAmount + totalExclusiveTax;
  }

  num get advancePayableAmount =>
      (totalAmount * selectedService.value.advancePaymentAmount) / 100;

  num get remainingAmountAfterService => totalAmount - advancePayableAmount;

  //----------------------------------------Session/Day-wise Pricing-----------------------------------
  /// Get effective price based on billing mode:
  /// - Standard: uses default service charges
  /// - Session-based: uses selected session package price
  /// - Day-wise Homecare: baseRate × hours × days
  num get effectivePrice {
    final service = selectedService.value;

    // Session-based pricing: use selected session package price
    if (service.isSessionBasedService && selectedSessionPackage.value != null) {
      return selectedSessionPackage.value!.price ?? service.charges;
    }

    // Day-wise Homecare pricing: baseRate × hours × days
    if (service.isDayWiseService) {
      final homecareOptions = service.homecareOptions;
      if (homecareOptions != null &&
          selectedDayOption.value != null &&
          selectedHourOption.value != null) {
        final baseRate = homecareOptions.baseHourlyRate ?? 0;
        final hours = selectedHourOption.value!.hours;
        final days = selectedDayOption.value!.days;

        // Formula: Base Rate × Hours × Days
        final calculatedPrice = baseRate * hours * days;
        return calculatedPrice > 0 ? calculatedPrice : service.charges;
      }
      // If hours/days not selected, return service charges as fallback
      return service.charges;
    }

    // Standard pricing: use default service charges
    return service.charges;
  }

  /// Reset session/day-wise selections when service changes
  void resetBillingSelections() {
    selectedSessionPackage.value = null;
    selectedDayOption.value = null;
    selectedHourOption.value = null;
  }
}

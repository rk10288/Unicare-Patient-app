import 'package:file_picker/file_picker.dart';

class BookingReq {
  String clinicId;
  String serviceId;
  String appointmentDate;
  String userId;
  String status;
  String doctorId;
  String appointmentTime;
  String description;
  bool isOnlineService;

  //Extra local variables
  String serviceName;
  String doctorName;
  String clinicName;
  String location;
  num totalAmount;
  bool isEnableAdvancePayment;
  num advancePayableAmount;
  num remainingPayableAmountAfterService;
  String otherPatientId;
  //Files local variable
  List<PlatformFile> files;

  // Billing mode fields for session-based and day-wise pricing
  String billingMode; // 'standard', 'session_based', 'day_wise'
  int sessionPackageIndex; // Index of selected session package (for session_based)
  int selectedDays; // Selected days (for day_wise)

  int selectedHours; // Selected hours (for day_wise)
  String latitude;
  String longitude;

  BookingReq({
    this.clinicId = "",
    this.serviceId = "",
    this.appointmentDate = "",
    this.userId = "",
    this.status = "",
    this.doctorId = "",
    this.appointmentTime = "",
    this.description = "",
    this.isOnlineService = false,

    //Extra local variables
    this.serviceName = "",
    this.doctorName = "",
    this.clinicName = "",
    this.location = "",
    this.totalAmount = 0,
    this.isEnableAdvancePayment = false,
    this.advancePayableAmount = 0.0,
    this.remainingPayableAmountAfterService = 0.0,
    this.otherPatientId = "",
    //Files local variable
    this.files = const <PlatformFile>[],
    // Billing mode fields
    this.billingMode = "standard",
    this.sessionPackageIndex = -1,
    this.selectedDays = 0,
    this.selectedHours = 0,
    this.latitude = "",
    this.longitude = "",
  });

  factory BookingReq.fromJson(Map<String, dynamic> json) {
    return BookingReq(
      clinicId: json['clinic_id'] is String ? json['clinic_id'] : "",
      serviceId: json['service_id'] is String ? json['service_id'] : "",
      appointmentDate:
          json['appointment_date'] is String ? json['appointment_date'] : "",
      userId: json['user_id'] is String ? json['user_id'] : "",
      status: json['status'] is String ? json['status'] : "",
      doctorId: json['doctor_id'] is String ? json['doctor_id'] : "",
      appointmentTime:
          json['appointment_time'] is String ? json['appointment_time'] : "",
      description: json['description'] is String ? json['description'] : "",
      otherPatientId:
          json['otherpatient_id'] is num ? json['otherpatient_id'] : "",
      // Billing mode fields
      billingMode:
          json['billing_mode'] is String ? json['billing_mode'] : "standard",
      sessionPackageIndex: json['session_package_index'] is int
          ? json['session_package_index']
          : -1,
      selectedDays: json['selected_days'] is int ? json['selected_days'] : 0,
      selectedHours: json['selected_hours'] is int ? json['selected_hours'] : 0,
      latitude: json['latitude'] is String ? json['latitude'] : "",
      longitude: json['longitude'] is String ? json['longitude'] : "",
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'service_id': serviceId,
      'appointment_date': appointmentDate,
      'user_id': userId,
      'status': status,
      'appointment_time': appointmentTime,
      'description': description,
      'otherpatient_id': otherPatientId,
      // Always send billing mode
      'billing_mode': billingMode,
    };

    // Only include clinic_id if it has a value (supporting clinic-less bookings)
    if (clinicId.isNotEmpty) {
      data['clinic_id'] = clinicId;
    }

    // Only include doctor_id if it has a valid value (not empty or -1)
    if (doctorId.isNotEmpty && doctorId != '-1') {
      data['doctor_id'] = doctorId;
    }

    // Include session package index for session-based billing
    if (billingMode == 'session_based' && sessionPackageIndex >= 0) {
      data['session_package_index'] = sessionPackageIndex;
    }

    // Include days and hours for day-wise billing
    if (billingMode == 'day_wise') {
      if (selectedDays > 0) {
        data['selected_days'] = selectedDays;
      }
      if (selectedHours > 0) {
        data['selected_hours'] = selectedHours;
      }
    }

    if (latitude.isNotEmpty) {
      data['latitude'] = latitude;
    }
    if (longitude.isNotEmpty) {
      data['longitude'] = longitude;
    }

    return data;
  }
}

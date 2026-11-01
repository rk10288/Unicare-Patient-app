class APIEndPoints {
  static const String appConfiguration = 'app-configuration';
  static const String aboutPages = 'page-list';

  //Auth & User
  static const String register = 'register';
  static const String socialLogin = 'social-login';
  static const String login = 'login';
  static const String verify = 'verify';
  static const String logout = 'logout';
  static const String changePassword = 'change-password';
  static const String forgotPassword = 'forgot-password';
  static const String userDetail = 'user-detail';
  static const String updateProfile = 'update-profile';
  static const String deleteUserAccount = 'delete-account';
  static const String getNotification = 'notification-list';
  static const String removeNotification = 'notification-remove';
  static const String clearAllNotification = 'notification-deleteall';
  static const String getPatientWallet = 'get-patient-wallet';
  static const String getWalletHistory = 'get-wallet-history';
  static const String addFunds = 'add-funds';
  static const String verifyFirebaseToken = 'verify-firebase-token';
  static const String phoneLogin = 'phone-login';
  static const String otpResend = 'otp-resend';
  static const String checkContact = 'check-contact';
  static const String sendSmsOtp = 'send-sms-otp';
  static const String verifySmsOtp = 'verify-sms-otp';
  static const String sendSignupOtp = 'send-signup-otp';
  static const String verifySignupOtp = 'verify-signup-otp';

  // Documents
  static const String documents = 'documents';
  static const String documentsUpload = 'documents/upload';

  //home choose service api
  static const String getDashboard = 'dashboard-detail';
  static const String getSystemService = 'get-system-service';
  static const String getCategoryList = 'get-category-list';
  static const String getServiceList = 'get-service-list';
  static const String getServiceDetails = 'get-service-details';
  static const String getClinicList = 'get-clinic-list';
  static const String getClinicDetails = 'get-clinic-details';
  static const String getClinicGallery = 'get-clinic-gallery';
  static const String getDoctorList = 'get-doctor-list';
  static const String getDoctorDetails = 'get-doctor-details';
  static const String getTimeSlots = 'get-time-slots';

  //Booking for Other
  static const String addPatient = 'add-patient-member';
  static const String otherMemberPatientList = 'other-members-list';
  static const String deleteOtherMember = 'delete-other_member';

  //booking api-list
  static const String getAppointments = 'appointment-list';
  static const String getEncounterList = 'encounter-list';
  static const String saveBooking = 'save-booking';
  static const String savePayment = 'save-payment';
  static const String applyCoupon = 'apply-coupon';
  static const String updateStatus = 'update-status';
  static const String rescheduleBooking = 'reschedule-booking';

  //booking detail-api
  static const String getAppointmentDetail = 'appointment-detail';
  static const String downloadInvoice = 'download_invoice';

  //booking encounter detail
  static const String encounterDashboardDetail = 'encounter-dashboard-detail';

  //Review
  static const String saveRating = 'save-rating';
  static const String getRating = 'get-rating';
  static const String deleteRating = 'delete-rating';

  //Vendor
  static const String updateService = 'update-service';
  static const String addServiceTraining = 'service-training';
  static const String serviceList = 'service-list';
  static const String deleteService = 'delete-service';
  static const String getCategory = 'category-list';
  static const String addService = 'service';

  //Indicent
  static const String incidenceList = 'incidence-list';
  static const String incidenceSave = 'incidence-save';
  static const String updateIncidentStatus = 'update-incident-status';

  // Chatbot
  static const String chatbotMessage = 'chatbot/message';

  // Chatbot V2 (Enhanced)
  static const String chatbotV2Message = 'v2/chatbot/message';
  static const String chatbotV2Services = 'v2/chatbot/services';
  static const String chatbotV2Doctors = 'v2/chatbot/doctors';
  static const String chatbotV2Appointments = 'v2/chatbot/appointments';
}

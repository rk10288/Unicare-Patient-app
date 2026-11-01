import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../api/auth_apis.dart';
import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage.dart';
import '../../../utils/push_notification_service.dart';
import '../../documents/document_upload_screen.dart';

class SignupOtpVerificationController extends GetxController {
  RxBool isLoading = false.obs;

  // OTP input controller - late initialization to avoid disposal issues
  late TextEditingController otpController;

  // User data passed from signup
  String fullName = '';
  String phone = '';
  String phoneCode = '';
  String password = '';
  String? email;

  // Countdown timer for resend
  RxInt countdownSeconds = 120.obs; // 2 minutes
  Timer? _countdownTimer;
  RxBool canResend = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize controller in onInit to ensure fresh instance
    otpController = TextEditingController();

    // Get data passed from signup screen
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      fullName = args['fullName'] ?? '';
      phone = args['phone'] ?? '';
      phoneCode = args['phoneCode'] ?? '';
      password = args['password'] ?? '';
      email = args['email'];
    }
    _startCountdown();
  }

  void _startCountdown() {
    countdownSeconds.value = 120; // 2 minutes
    canResend.value = false;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
      } else {
        canResend.value = true;
        timer.cancel();
      }
    });
  }

  String get formattedCountdown {
    int minutes = countdownSeconds.value ~/ 60;
    int seconds = countdownSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (!canResend.value) return;

    isLoading.value = true;

    try {
      await AuthServiceApis.sendSignupOtp(
        fullName: fullName,
        phone: phone,
        phoneCode: phoneCode,
        password: password,
        email: email,
      );

      toast(locale.value.otpSentToPhone);
      _startCountdown();
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Verify OTP and complete registration
  Future<void> verifyOtp() async {
    if (otpController.text.trim().length != 6) {
      toast(locale.value.invalidOtp);
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthServiceApis.verifySignupOtp(
        phone: phone,
        phoneCode: phoneCode,
        otp: otpController.text.trim(),
      );

      if (response.status == true) {
        toast(response.message.toString(), print: true);

        // Store user data
        loginUserData(response.userData);
        setValueToLocal(
            SharedPreferenceConst.USER_DATA, loginUserData.toJson());
        setValueToLocal(SharedPreferenceConst.USER_PASSWORD, password);
        setValueToLocal(SharedPreferenceConst.USER_ID, response.userData.id);
        isLoggedIn(true);
        setValueToLocal(SharedPreferenceConst.IS_LOGGED_IN, true);

        // Register FCM
        PushNotificationService().registerFCMAndTopics();

        isLoading.value = false;

        // Navigate to Document Upload Screen
        Get.offAll(() => DocumentUploadScreen(isFromRegistration: true));
      } else {
        isLoading.value = false;
        toast(response.message ?? locale.value.somethingWentWrong);
      }
    } catch (e) {
      isLoading.value = false;
      toast(e.toString());
    }
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    // Only dispose if controller is not already disposed
    try {
      otpController.dispose();
    } catch (e) {
      // Controller already disposed, ignore
    }
    super.onClose();
  }
}

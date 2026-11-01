import 'dart:async';
import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';

import '../main.dart';
import '../utils/constants.dart';

/// Service class for handling Firebase Phone Authentication
class PhoneAuthService extends GetxController {
  static PhoneAuthService get instance => Get.find<PhoneAuthService>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Observable states
  RxBool isLoading = false.obs;
  RxBool isCodeSent = false.obs;
  RxString verificationId = ''.obs;
  RxInt resendToken = 0.obs;
  Rx<Country> selectedCountry = defaultCountry.obs;

  // Error handling
  RxString errorMessage = ''.obs;

  // Countdown timer for resend
  RxInt countdownSeconds = 0.obs;
  Timer? _resendTimer;

  /// Send OTP to the given phone number
  Future<bool> sendOtp({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
    Function(PhoneAuthCredential credential)? onAutoVerified,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    final String fullPhoneNumber =
        '+${selectedCountry.value.phoneCode}$phoneNumber';
    log('Sending OTP to: $fullPhoneNumber');

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android (when SMS is auto-detected)
          log('Auto verification completed');
          if (onAutoVerified != null) {
            onAutoVerified(credential);
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          log('Verification failed: ${e.message}');
          isLoading.value = false;
          errorMessage.value = _getErrorMessage(e);
          onError(errorMessage.value);
        },
        codeSent: (String verId, int? forceResendingToken) {
          log('Code sent. Verification ID: $verId');
          verificationId.value = verId;
          resendToken.value = forceResendingToken ?? 0;
          isCodeSent.value = true;
          isLoading.value = false;
          _startResendCountdown();
          onCodeSent(verId);
        },
        codeAutoRetrievalTimeout: (String verId) {
          log('Auto retrieval timeout. Verification ID: $verId');
          verificationId.value = verId;
        },
        forceResendingToken: resendToken.value > 0 ? resendToken.value : null,
      );
      return true;
    } catch (e) {
      log('Error sending OTP: $e');
      isLoading.value = false;
      errorMessage.value = e.toString();
      onError(errorMessage.value);
      return false;
    }
  }

  /// Verify the OTP entered by user and return credentials
  Future<UserCredential?> verifyOtp({
    required String otp,
    Function(String error)? onError,
  }) async {
    if (verificationId.value.isEmpty) {
      errorMessage.value = locale.value.invalidOtp;
      if (onError != null) onError(errorMessage.value);
      return null;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      // Create credential with verification ID and OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp,
      );

      // Sign in with credential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      isLoading.value = false;
      log('Phone verification successful. UID: ${userCredential.user?.uid}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      log('Error verifying OTP: ${e.message}');
      isLoading.value = false;
      errorMessage.value = _getErrorMessage(e);
      if (onError != null) onError(errorMessage.value);
      return null;
    } catch (e) {
      log('Error verifying OTP: $e');
      isLoading.value = false;
      errorMessage.value = locale.value.otpVerificationFailed;
      if (onError != null) onError(errorMessage.value);
      return null;
    }
  }

  /// Get the Firebase ID token for the current user
  Future<String?> getIdToken() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        return await user.getIdToken();
      }
      return null;
    } catch (e) {
      log('Error getting ID token: $e');
      return null;
    }
  }

  /// Get Firebase UID
  String? getFirebaseUid() {
    return _auth.currentUser?.uid;
  }

  /// Sign out from Firebase
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log('Error signing out: $e');
    }
  }

  /// Start countdown timer for resend OTP
  void _startResendCountdown() {
    countdownSeconds.value = 60; // 60 seconds countdown
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdownSeconds.value > 0) {
        countdownSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  /// Check if resend is available
  bool get canResend => countdownSeconds.value == 0 && isCodeSent.value;

  /// Reset state
  void reset() {
    isLoading.value = false;
    isCodeSent.value = false;
    verificationId.value = '';
    resendToken.value = 0;
    errorMessage.value = '';
    countdownSeconds.value = 0;
    _resendTimer?.cancel();
  }

  /// Convert Firebase error to user-friendly message
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return locale.value.invalidPhoneNumber;
      case 'too-many-requests':
        return locale.value.tooManyRequests;
      case 'invalid-verification-code':
        return locale.value.invalidOtp;
      case 'session-expired':
        return locale.value.otpVerificationFailed;
      default:
        return e.message ?? locale.value.somethingWentWrong;
    }
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    super.onClose();
  }
}

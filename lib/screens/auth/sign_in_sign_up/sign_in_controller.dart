// ignore_for_file: depend_on_referenced_packages

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../main.dart';
import '../../../utils/push_notification_service.dart';
import '../../dashboard/dashboard_controller.dart';
import '../../dashboard/dashboard_screen.dart';
import '../../home/home_controller.dart';
import '../model/login_response.dart';
import '../../../api/auth_apis.dart';
import '../../../utils/app_common.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import '../../../utils/local_storage.dart';
import '../services/social_logins.dart';
import '../../../services/phone_auth_service.dart';

class SignInController extends GetxController {
  RxBool isNavigateToDashboard = false.obs;
  RxBool loginSucessfull = false.obs;
  RxBool tryToAnother = false.obs;
  final GlobalKey<FormState> signInformKey = GlobalKey();

  RxBool isRememberMe = true.obs;
  RxBool isLoading = false.obs;
  RxString userName = "".obs;
  RxInt isGoogleAuthentication = (-1).obs;

  // Email/Password login
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController otpCont = TextEditingController();

  // Phone login
  TextEditingController phoneCont = TextEditingController();
  TextEditingController phoneOtpCont = TextEditingController();
  Rx<Country> selectedCountry = defaultCountry.obs;

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode otpFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode phoneOtpFocus = FocusNode();

  // Login mode: 0 = Email, 1 = Phone
  RxInt loginMode = 0.obs;

  // Phone verification state
  RxBool showPhoneOtpField = false.obs;
  RxString phoneVerificationId = ''.obs;

  // Phone auth service
  late PhoneAuthService phoneAuthService;

  void toggleSwitch() {
    isRememberMe.value = !isRememberMe.value;
  }

  @override
  void onInit() {
    // Initialize phone auth service
    if (!Get.isRegistered<PhoneAuthService>()) {
      Get.put(PhoneAuthService());
    }
    phoneAuthService = Get.find<PhoneAuthService>();

    if (appConfigs.value.isDummyCredential != 1) {
      emailCont.text = '';
      passwordCont.text = '';
      isRememberMe.value = false;
    } else {
      emailCont.text = Constants.DEFAULT_EMAIL;
      passwordCont.text = Constants.DEFAULT_PASS;
      otpCont.text = 123456.toString();
    }
    if (Get.arguments is bool) {
      isNavigateToDashboard(Get.arguments == true);
    }
    final userIsRemeberMe =
        getValueFromLocal(SharedPreferenceConst.IS_REMEMBER_ME);
    final userNameFromLocal =
        getValueFromLocal(SharedPreferenceConst.USER_NAME);
    if (userNameFromLocal is String) {
      userName(userNameFromLocal);
    }
    if (userIsRemeberMe == true) {
      final userEmail = getValueFromLocal(SharedPreferenceConst.USER_EMAIL);
      if (userEmail is String) {
        emailCont.text = userEmail;
      }
      final userPASSWORD =
          getValueFromLocal(SharedPreferenceConst.USER_PASSWORD);
      if (userPASSWORD is String) {
        passwordCont.text = userPASSWORD;
      }
    }
    super.onInit();
  }

  /// Switch between email and phone login
  void switchLoginMode(int mode) {
    loginMode.value = mode;
    showPhoneOtpField.value = false;
    phoneOtpCont.clear();
  }

  /// Pick country for phone code
  void pickCountry(BuildContext context) {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: context.scaffoldBackgroundColor,
        textStyle: primaryTextStyle(),
        bottomSheetHeight: Get.height * 0.7,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        inputDecoration: InputDecoration(
          labelText: locale.value.searchHere,
          hintText: locale.value.searchHere,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      onSelect: (Country country) {
        selectedCountry.value = country;
        phoneAuthService.selectedCountry.value = country;
      },
    );
  }

  /// Send OTP to phone number for login
  Future<void> sendPhoneOtp() async {
    if (phoneCont.text.trim().isEmpty) {
      toast(locale.value.phoneNumberRequired);
      return;
    }

    isLoading.value = true;

    await phoneAuthService.sendOtp(
      phoneNumber: phoneCont.text.trim(),
      onCodeSent: (String verId) {
        phoneVerificationId.value = verId;
        showPhoneOtpField.value = true;
        isLoading.value = false;
        toast(locale.value.otpSentToPhone);
      },
      onError: (String error) {
        isLoading.value = false;
        toast(error);
      },
      onAutoVerified: (PhoneAuthCredential credential) async {
        // Auto verification - proceed to login
        isLoading.value = false;
        await _handlePhoneVerificationSuccess();
      },
    );
  }

  /// Verify phone OTP for login
  Future<void> verifyPhoneOtp() async {
    if (phoneOtpCont.text.trim().length != 6) {
      toast(locale.value.invalidOtp);
      return;
    }

    isLoading.value = true;

    UserCredential? userCredential = await phoneAuthService.verifyOtp(
      otp: phoneOtpCont.text.trim(),
      onError: (String error) {
        isLoading.value = false;
        toast(error);
      },
    );

    if (userCredential != null) {
      await _handlePhoneVerificationSuccess();
    }
  }

  /// ====== SMS OTP (Backend Twilio) ======

  /// Send OTP to phone number via backend SMS (Twilio)
  Future<void> sendSmsOtp() async {
    if (phoneCont.text.trim().isEmpty) {
      toast(locale.value.phoneNumberRequired);
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthServiceApis.sendSmsOtp(
        phone: phoneCont.text.trim(),
        phoneCode: selectedCountry.value.phoneCode,
      );

      isLoading.value = false;

      if (response['status'] == true) {
        showPhoneOtpField.value = true;
        toast(locale.value.otpSentToPhone);
      } else if (response['is_new_user'] == true) {
        toast(locale.value.notRegistered);
      } else {
        toast(response['message'] ?? locale.value.somethingWentWrong);
      }
    } catch (e) {
      isLoading.value = false;
      toast(e.toString());
    }
  }

  /// Verify SMS OTP via backend and login
  Future<void> verifySmsOtp() async {
    if (phoneOtpCont.text.trim().length != 6) {
      toast(locale.value.invalidOtp);
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthServiceApis.verifySmsOtp(
        phone: phoneCont.text.trim(),
        phoneCode: selectedCountry.value.phoneCode,
        otp: phoneOtpCont.text.trim(),
      );

      handleLoginResponse(loginResponse: response, isSocialLogin: true);
    } catch (e) {
      isLoading.value = false;
      toast(e.toString());
    }
  }

  /// Handle successful phone verification - login via backend
  Future<void> _handlePhoneVerificationSuccess() async {
    String? firebaseUid = phoneAuthService.getFirebaseUid();
    String? idToken = await phoneAuthService.getIdToken();

    if (firebaseUid == null) {
      isLoading.value = false;
      toast(locale.value.somethingWentWrong);
      return;
    }

    Map<String, dynamic> req = {
      UserKeys.firebaseUid: firebaseUid,
      'phone_number': phoneCont.text.trim(),
      UserKeys.phoneCode: selectedCountry.value.phoneCode,
      'id_token': idToken ?? '',
    };

    try {
      // Call phone login API
      UserResponse loginResponse =
          await AuthServiceApis.phoneLogin(request: req);
      handleLoginResponse(loginResponse: loginResponse, isSocialLogin: true);
    } catch (e) {
      isLoading.value = false;
      // User might not exist - redirect to registration
      log('Phone login error: $e');
      toast(locale.value.notRegistered);
    }
  }

  Future<void> saveForm() async {
    isLoading(true);
    hideKeyBoardWithoutContext();

    Map<String, dynamic> req = {
      'email': emailCont.text.trim(),
      'password': passwordCont.text.trim(),
      UserKeys.userType: LoginTypeConst.LOGIN_TYPE_USER,
    };

    await AuthServiceApis.loginUser(request: req).then((value) async {
      if (value.status == true) {
        setValueToLocal(
            SharedPreferenceConst.USER_ID, value.userData.id.toString());
        setValueToLocal(SharedPreferenceConst.IS_GOOGLE_AUTHENTICATION,
            value.userData.isGoogleAuthentication.toString());
        setValueToLocal(SharedPreferenceConst.GOOGLE_AUTHENTICATION_TYPE,
            value.userData.googleAuthenticationType);
        loginSucessfull.value = true;
      } else {
        isLoading(false);
        log(value.message);
        return;
      }

      loginUserData(value.userData);
      log('loginUserData: ${loginUserData.value.toJson()}');
      isGoogleAuthentication.value = int.tryParse(
              getValueFromLocal(SharedPreferenceConst.IS_GOOGLE_AUTHENTICATION)
                  .toString()) ??
          0;
      if (isRememberMe.value) {
        setValueToLocal(
            SharedPreferenceConst.USER_EMAIL, emailCont.text.trim());
        setValueToLocal(SharedPreferenceConst.USER_NAME, userName.value);
      } else {
        setValueToLocal(SharedPreferenceConst.USER_EMAIL, "");
        setValueToLocal(SharedPreferenceConst.USER_NAME, "");
      }

      handleLoginResponse(loginResponse: value);
      setValueToLocal(SharedPreferenceConst.USER_ID, value.userData.id);
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future verifyUser({String? authentication}) async {
    isLoading(true);
    hideKeyBoardWithoutContext();
    int userId = getValueFromLocal(SharedPreferenceConst.USER_ID);
    Map<String, dynamic> req = {
      'id': userId,
      'one_time_password': otpCont.text,
      'google_authentication_type': authentication,
    };

    await AuthServiceApis.verifyUser(request: req).then((value) async {
      if (value.status == true) {
        isNavigateToDashboard.value = true;
      }
      handleLoginResponse(loginResponse: value, isVerifyOTP: true);
      log('verifyUser RESPONSE:--------------- ${value.toJson()}');
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> googleSignIn() async {
    isLoading(true);
    await GoogleSignInAuthService.signInWithGoogle().then((value) async {
      Map request = {
        UserKeys.contactNumber: value.mobile,
        UserKeys.email: value.email,
        UserKeys.firstName: value.firstName,
        UserKeys.lastName: value.lastName,
        UserKeys.username: value.userName,
        UserKeys.profileImage: value.profileImage,
        UserKeys.userType: LoginTypeConst.LOGIN_TYPE_USER,
        UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_GOOGLE,
      };
      log('signInWithGoogle REQUEST: $request');

      /// Social Login Api
      await AuthServiceApis.loginUser(request: request, isSocialLogin: true)
          .then((value) async {
        handleLoginResponse(loginResponse: value, isSocialLogin: true);
      }).catchError((e) {
        isLoading(false);
        toast(e.toString(), print: true);
      });
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }

  Future<void> appleSignIn() async {
    isLoading(true);
    await GoogleSignInAuthService.signInWithApple().then((value) async {
      Map request = {
        UserKeys.contactNumber: value.mobile,
        UserKeys.email: value.email,
        UserKeys.firstName: value.firstName,
        UserKeys.lastName: value.lastName,
        UserKeys.username: value.userName,
        UserKeys.profileImage: value.profileImage,
        UserKeys.userType: LoginTypeConst.LOGIN_TYPE_USER,
        UserKeys.loginType: LoginTypeConst.LOGIN_TYPE_APPLE,
      };
      log('signInWithGoogle REQUEST: $request');

      /// Social Login Api
      await AuthServiceApis.loginUser(request: request, isSocialLogin: true)
          .then((value) async {
        handleLoginResponse(loginResponse: value, isSocialLogin: true);
        setValueToLocal(SharedPreferenceConst.LOGIN_SUCCESSFULL, true);
      }).catchError((e) {
        isLoading(false);
        toast(e.toString(), print: true);
      });
    }).catchError((e) {
      isLoading(false);
      toast(e.toString(), print: true);
    });
  }

  void handleLoginResponse(
      {required UserResponse loginResponse,
      bool isVerifyOTP = false,
      bool isSocialLogin = false}) {
    log("-----------handleLoginResponse-------------${loginResponse.userData.userRole.contains(LoginTypeConst.LOGIN_TYPE_USER)}");
    log("-----------LOGIN_TYPE_USER-------------${LoginTypeConst.LOGIN_TYPE_USER}");
    log("-----------userRole-------------${loginResponse.userData.userRole}");
    log("-----------status-------------${loginResponse.status}");
    log("-----------apiToken-------------${loginResponse.userData.apiToken.isNotEmpty}");

    // Check for successful login: status is true AND we have a valid API token
    // Note: user role check was causing issues for users registered via SMS OTP
    // who might not have roles properly assigned in the database
    final bool isLoginSuccess = loginResponse.status &&
        loginResponse.userData.apiToken.isNotEmpty &&
        loginResponse.userData.id > 0;

    if (isLoginSuccess) {
      loginUserData(loginResponse.userData);
      loginUserData.value.isSocialLogin = isSocialLogin;
      setValueToLocal(SharedPreferenceConst.USER_DATA, loginUserData.toJson());
      setValueToLocal(SharedPreferenceConst.USER_PASSWORD,
          isSocialLogin ? "" : passwordCont.text.trim());
      isLoggedIn(true);
      setValueToLocal(SharedPreferenceConst.IS_LOGGED_IN, true);
      setValueToLocal(SharedPreferenceConst.IS_REMEMBER_ME, isRememberMe.value);

      isLoading(false);

      PushNotificationService().registerFCMAndTopics();

      if (isNavigateToDashboard.value) {
        Get.offAll(() => DashboardScreen(), binding: BindingsBuilder(() {
          Get.put(HomeController(), permanent: true);
        }));
      } else {
        try {
          DashboardController dashboardController = Get.find();
          dashboardController.reloadBottomTabs();
        } catch (e) {
          log('dashboardController Get.find E: $e');
        }
        try {
          HomeController homeScreenController = Get.find();
          homeScreenController.init();
        } catch (e) {
          log('homeScreenController Get.find E: $e');
        }
        Get.back(result: true);
      }
    } else {
      isLoading(false);
      toast(loginResponse.message.trim().isEmpty
          ? isVerifyOTP
              ? locale.value.sorryUserCannotSignin
              : locale.value.otpSentToEmail
          : loginResponse.message);
    }
  }

  @override
  void onClose() {
    phoneCont.dispose();
    phoneOtpCont.dispose();
    super.onClose();
  }
}

// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:country_picker/country_picker.dart';

import '../../../api/auth_apis.dart';
import '../../../main.dart';
import '../../../utils/common_base.dart';
import '../../../utils/constants.dart';
import 'signup_otp_verification_screen.dart';

class SignUpController extends GetxController {
  RxBool isLoading = false.obs;
  final GlobalKey<FormState> signUpformKey = GlobalKey();

  RxBool agree = false.obs;
  RxBool isAcceptedTc = false.obs;

  // User input fields
  TextEditingController fullNameCont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController passwordCont = TextEditingController();
  TextEditingController confirmPasswordCont = TextEditingController();

  // Phone field
  TextEditingController phoneCont = TextEditingController();

  // Country picker for phone code
  Rx<Country> selectedCountry = defaultCountry.obs;

  // Focus nodes
  FocusNode fullNameFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode confirmPasswordFocus = FocusNode();

  // Password validation
  RxBool passContHasFocus = false.obs;
  RxBool hasUppercase = false.obs;
  RxBool hasNumber = false.obs;
  RxBool hasSpecial = false.obs;
  RxBool hasLetter = false.obs;

  void checkPasswordRules(String password) {
    hasUppercase.value = RegExp(r'[A-Z]').hasMatch(password);
    hasNumber.value = RegExp(r'[0-9]').hasMatch(password);
    hasSpecial.value = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    hasLetter.value = RegExp(r'[a-z]').hasMatch(password);
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
      },
    );
  }

  /// Send signup OTP and navigate to verification screen
  Future<void> saveForm() async {
    if (isAcceptedTc.value) {
      // Validate phone number
      if (phoneCont.text.trim().isEmpty) {
        toast(locale.value.phoneNumberRequired);
        return;
      }

      hideKeyBoardWithoutContext();
      isLoading(true);

      try {
        await AuthServiceApis.sendSignupOtp(
          fullName: fullNameCont.text.trim(),
          phone: phoneCont.text.trim(),
          phoneCode: selectedCountry.value.phoneCode,
          password: passwordCont.text.trim(),
          email:
              emailCont.text.trim().isNotEmpty ? emailCont.text.trim() : null,
          userType: LoginTypeConst.LOGIN_TYPE_USER,
        );

        isLoading(false);
        toast(locale.value.otpSentToPhone);

        // Navigate to OTP verification screen
        Get.to(
          () => SignupOtpVerificationScreen(),
          arguments: {
            'fullName': fullNameCont.text.trim(),
            'phone': phoneCont.text.trim(),
            'phoneCode': selectedCountry.value.phoneCode,
            'password': passwordCont.text.trim(),
            'email':
                emailCont.text.trim().isNotEmpty ? emailCont.text.trim() : null,
          },
        );
      } catch (e) {
        isLoading(false);
        toast(e.toString(), print: true);
      }
    } else {
      toast(locale.value.pleaseAcceptTermsAnd);
    }
  }

  @override
  void onClose() {
    fullNameCont.dispose();
    emailCont.dispose();
    passwordCont.dispose();
    confirmPasswordCont.dispose();
    phoneCont.dispose();
    super.onClose();
  }
}

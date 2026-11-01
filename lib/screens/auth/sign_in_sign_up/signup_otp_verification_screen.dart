import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../components/app_scaffold.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import 'signup_otp_verification_controller.dart';

class SignupOtpVerificationScreen extends StatelessWidget {
  SignupOtpVerificationScreen({super.key}) {
    // Delete any existing controller to ensure fresh state
    if (Get.isRegistered<SignupOtpVerificationController>()) {
      Get.delete<SignupOtpVerificationController>();
    }
  }

  SignupOtpVerificationController get controller =>
      Get.put(SignupOtpVerificationController());

  void _goBack() {
    // Delete controller when going back to prevent stale state
    if (Get.isRegistered<SignupOtpVerificationController>()) {
      Get.delete<SignupOtpVerificationController>();
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      topBarBgColor: appScreenBackground,
      isLoading: controller.isLoading,
      hasLeadingWidget: true,
      leadingWidget: IconButton(
        onPressed: _goBack,
        icon: const Icon(Icons.arrow_back_ios_new_outlined,
            color: white, size: 20),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: Get.height * 0.05),

            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: appColorSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.sms_outlined,
                size: 40,
                color: appColorSecondary,
              ),
            ),

            24.height,

            // Title
            Text(
              locale.value.verifyOtp,
              style: boldTextStyle(size: 24),
            ),

            12.height,

            // Subtitle with phone number
            Obx(
              () => Text(
                '${locale.value.enterOtpSentTo}\n+${controller.phoneCode} ${controller.phone}\nOR\n${locale.value.enterOtpSentTo}\n${controller.email}',
                textAlign: TextAlign.center,
                style: secondaryTextStyle(size: 14),
              ),
            ),

            32.height,

            // OTP Pin Code Fields
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PinCodeTextField(
                appContext: context,
                length: 6,
                controller: controller.otpController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(8),
                  fieldHeight: 55,
                  fieldWidth: 45,
                  activeFillColor: context.cardColor,
                  inactiveFillColor: context.cardColor,
                  selectedFillColor: context.cardColor,
                  activeColor: appColorSecondary,
                  inactiveColor: borderColor.withOpacity(0.5),
                  selectedColor: appColorSecondary,
                ),
                animationDuration: const Duration(milliseconds: 300),
                enableActiveFill: true,
                onCompleted: (value) {
                  // Auto-verify when all 6 digits are entered
                  controller.verifyOtp();
                },
                onChanged: (value) {},
              ),
            ),

            24.height,

            // Verify Button
            AppButton(
              width: Get.width,
              text: locale.value.verify,
              color: appColorSecondary,
              textStyle: appButtonTextStyleWhite,
              shapeBorder: RoundedRectangleBorder(
                borderRadius: radius(defaultAppButtonRadius / 2),
              ),
              onTap: () => controller.verifyOtp(),
            ),

            32.height,

            // Resend OTP section
            Obx(
              () => Column(
                children: [
                  Text(
                    locale.value.didntReceiveCode,
                    style: secondaryTextStyle(),
                  ),
                  8.height,
                  if (!controller.canResend.value) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${locale.value.resendCodeIn} ',
                          style: secondaryTextStyle(),
                        ),
                        Text(
                          controller.formattedCountdown,
                          style: boldTextStyle(color: appColorSecondary),
                        ),
                      ],
                    ),
                  ] else ...[
                    TextButton(
                      onPressed: () => controller.resendOtp(),
                      child: Text(
                        locale.value.resendCode,
                        style: boldTextStyle(
                          color: appColorSecondary,
                          decoration: TextDecoration.underline,
                          decorationColor: appColorSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            24.height,

            // Change number option
            TextButton(
              onPressed: _goBack,
              child: Text(
                locale.value.changePhoneNumber,
                style: primaryTextStyle(
                  color: appColorSecondary,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

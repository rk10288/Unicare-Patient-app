import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:get/get.dart';
import '/utils/app_common.dart';
import '../../../components/app_logo_widget.dart';
import '../../../components/app_scaffold.dart';
import '../../../configs.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/constants.dart';
import 'sign_in_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../password/forget_password_screen.dart';
import 'signup_screen.dart';

class SignInScreen extends StatelessWidget {
  SignInScreen({super.key});
  final SignInController signInController = Get.put(SignInController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      topBarBgColor: appScreenBackground,
      isLoading: signInController.isLoading,
      hasLeadingWidget: false,
      clipBehaviorSplitRegion: Clip.none,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedScrollView(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${locale.value.welcomeBack}',
                style: primaryTextStyle(size: 24),
              ),
              8.height,
              Text(
                'Start a better experience by logging into your account.',
                style: secondaryTextStyle(size: 14),
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: Get.height * 0.05),
              Form(
                key: signInController.signInformKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Login Mode Toggle (Email / Phone)
                    Obx(
                      () => Container(
                        decoration: BoxDecoration(
                          color: context.cardColor,
                          borderRadius: radius(defaultAppButtonRadius),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    signInController.switchLoginMode(0),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: signInController.loginMode.value == 0
                                        ? appColorPrimary
                                        : Colors.transparent,
                                    borderRadius:
                                        radius(defaultAppButtonRadius),
                                  ),
                                  child: Text(
                                    locale.value.emailLogin,
                                    textAlign: TextAlign.center,
                                    style: primaryTextStyle(
                                      size: 14,
                                      color:
                                          signInController.loginMode.value == 0
                                              ? Colors.white
                                              : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    signInController.switchLoginMode(1),
                                child: Container(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: signInController.loginMode.value == 1
                                        ? appColorPrimary
                                        : Colors.transparent,
                                    borderRadius:
                                        radius(defaultAppButtonRadius),
                                  ),
                                  child: Text(
                                    locale.value.phoneLogin,
                                    textAlign: TextAlign.center,
                                    style: primaryTextStyle(
                                      size: 14,
                                      color:
                                          signInController.loginMode.value == 1
                                              ? Colors.white
                                              : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    16.height,
                    // Email Login Form
                    Obx(
                      () => signInController.loginMode.value == 0
                          ? Column(
                              children: [
                                AppTextField(
                                  title: locale.value.email,
                                  textStyle: primaryTextStyle(size: 12),
                                  controller: signInController.emailCont,
                                  focus: signInController.emailFocus,
                                  nextFocus: signInController.passwordFocus,
                                  textFieldType: TextFieldType.EMAIL_ENHANCED,
                                  decoration: inputDecoration(
                                    context,
                                    fillColor: context.cardColor,
                                    filled: true,
                                    hintText:
                                        "${locale.value.eG} john@example.com",
                                  ),
                                  suffix: commonLeadingWid(
                                          imgPath: Assets.iconsIcMail, size: 14)
                                      .paddingAll(14),
                                ),
                                16.height,
                                AppTextField(
                                  title: locale.value.password,
                                  textStyle: primaryTextStyle(size: 12),
                                  controller: signInController.passwordCont,
                                  focus: signInController.passwordFocus,
                                  textFieldType: TextFieldType.PASSWORD,
                                  obscureText: true,
                                  decoration: inputDecoration(
                                    context,
                                    fillColor: context.cardColor,
                                    filled: true,
                                    hintText: "••••••••",
                                  ),
                                  suffixPasswordVisibleWidget: commonLeadingWid(
                                          imgPath: Assets.iconsIcEye, size: 14)
                                      .paddingAll(12),
                                  suffixPasswordInvisibleWidget:
                                      commonLeadingWid(
                                              imgPath: Assets.iconsIcEyeSlash,
                                              size: 14)
                                          .paddingAll(12),
                                ),
                                Obx(() => Visibility(
                                      visible: signInController
                                          .loginSucessfull.isTrue,
                                      child: Column(
                                        children: [
                                          16.height,
                                          AppTextField(
                                            title: signInController
                                                    .tryToAnother.isTrue
                                                ? locale.value
                                                    .otpFromAuthenticatorApp
                                                : locale.value.otp,
                                            textStyle:
                                                primaryTextStyle(size: 12),
                                            controller:
                                                signInController.otpCont,
                                            focus: signInController.otpFocus,
                                            textFieldType: TextFieldType.NUMBER,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                  6),
                                            ],
                                            validator: (value) {
                                              if (value == null ||
                                                  value.length != 6) {
                                                return locale.value
                                                    .pleaseEnterValid6digitOTP;
                                              }
                                              return null;
                                            },
                                            decoration: inputDecoration(
                                              context,
                                              fillColor: context.cardColor,
                                              filled: true,
                                              hintText: "123456",
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                8.height,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Obx(
                                      () => CheckboxListTile(
                                        checkColor: whiteColor,
                                        value:
                                            signInController.isRememberMe.value,
                                        activeColor: appColorSecondary,
                                        visualDensity: VisualDensity.compact,
                                        dense: true,
                                        controlAffinity:
                                            ListTileControlAffinity.leading,
                                        contentPadding: EdgeInsets.zero,
                                        onChanged: (val) async {
                                          signInController.toggleSwitch();
                                        },
                                        checkboxShape: RoundedRectangleBorder(
                                            borderRadius: radius(0)),
                                        side: const BorderSide(
                                            color: secondaryTextColor,
                                            width: 1.5),
                                        title: Text(
                                          locale.value.rememberMe,
                                          style: secondaryTextStyle(
                                              color: darkGrayGeneral),
                                        ),
                                      ),
                                    ).expand(),
                                    TextButton(
                                      onPressed: () {
                                        Get.to(() => ForgetPassword());
                                      },
                                      child: Text(
                                        locale.value.forgotPassword,
                                        style: primaryTextStyle(
                                          size: 12,
                                          color: appColorSecondary,
                                          decoration: TextDecoration.underline,
                                          fontStyle: FontStyle.italic,
                                          decorationColor: appColorSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                20.height,
                                AppButton(
                                  width: Get.width,
                                  height: 54,
                                  text: signInController.loginSucessfull.isTrue
                                      ? locale.value.verify
                                      : locale.value.signIn,
                                  color: appColorSecondary,
                                  textStyle: appButtonTextStyleWhite,
                                  onTap: () {
                                    if (signInController
                                        .loginSucessfull.isTrue) {
                                      if (signInController
                                          .signInformKey.currentState!
                                          .validate()) {
                                        if (signInController
                                            .tryToAnother.isTrue) {
                                          signInController.verifyUser(
                                              authentication: "google2fa");
                                        } else {
                                          signInController.verifyUser(
                                              authentication: "email");
                                        }
                                      }
                                    } else {
                                      if (signInController
                                          .signInformKey.currentState!
                                          .validate()) {
                                        signInController
                                            .signInformKey.currentState!
                                            .save();
                                        signInController.saveForm();
                                      }
                                    }
                                  },
                                ),
                              ],
                            )
                          // Phone Login Form
                          : Column(
                              children: [
                                // Phone Number with Country Code Picker
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () =>
                                          signInController.pickCountry(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: context.cardColor,
                                          borderRadius:
                                              radius(defaultAppButtonRadius),
                                          border: Border.all(
                                              color:
                                                  borderColor.withOpacity(0.3)),
                                        ),
                                        child: Obx(
                                          () => Row(
                                            children: [
                                              Text(
                                                signInController.selectedCountry
                                                    .value.flagEmoji,
                                                style: const TextStyle(
                                                    fontSize: 20),
                                              ),
                                              4.width,
                                              Text(
                                                '+${signInController.selectedCountry.value.phoneCode}',
                                                style:
                                                    primaryTextStyle(size: 12),
                                              ),
                                              4.width,
                                              const Icon(Icons.arrow_drop_down,
                                                  size: 18),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    12.width,
                                    Expanded(
                                      child: AppTextField(
                                        textStyle: primaryTextStyle(size: 12),
                                        controller: signInController.phoneCont,
                                        focus: signInController.phoneFocus,
                                        textFieldType: TextFieldType.PHONE,
                                        decoration: inputDecoration(
                                          context,
                                          fillColor: context.cardColor,
                                          filled: true,
                                          hintText:
                                              locale.value.enterPhoneNumber,
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return locale
                                                .value.phoneNumberRequired;
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                16.height,
                                // OTP Field (shown after sending OTP)
                                Obx(
                                  () => signInController.showPhoneOtpField.value
                                      ? Column(
                                          children: [
                                            AppTextField(
                                              title: locale.value.enterOtp,
                                              textStyle:
                                                  primaryTextStyle(size: 12),
                                              controller:
                                                  signInController.phoneOtpCont,
                                              focus: signInController
                                                  .phoneOtpFocus,
                                              textFieldType:
                                                  TextFieldType.PHONE,
                                              maxLength: 6,
                                              decoration: inputDecoration(
                                                context,
                                                fillColor: context.cardColor,
                                                filled: true,
                                                hintText: "123456",
                                              ),
                                            ),
                                            16.height,
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                16.height,
                                // Send OTP / Verify OTP Button
                                Obx(
                                  () => AppButton(
                                    width: Get.width,
                                    height: 54,
                                    text:
                                        signInController.showPhoneOtpField.value
                                            ? locale.value.verifyOtp
                                            : locale.value.continueWithPhone,
                                    color: appColorSecondary,
                                    textStyle: appButtonTextStyleWhite,
                                    onTap: () {
                                      if (signInController
                                          .showPhoneOtpField.value) {
                                        signInController.verifySmsOtp();
                                      } else {
                                        signInController.sendSmsOtp();
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                    ),
                    // Social Login and Register Section
                    16.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (appConfigs.value.googleLoginStatus == 1)
                          GestureDetector(
                            onTap: () {
                              signInController.googleSignIn();
                            },
                            child: Container(
                              height: 54,
                              width: 54,
                              padding: const EdgeInsets.all(18),
                              decoration: boxDecorationWithRoundedCorners(
                                backgroundColor:
                                    bodyWhite.withValues(alpha: 0.1),
                                boxShape: BoxShape.circle,
                              ),
                              child: GoogleLogoWidget(size: 24),
                            ),
                          ),
                        if (isApple) 16.width,
                        GestureDetector(
                          onTap: () {
                            signInController.appleSignIn();
                          },
                          child: Container(
                            height: 54,
                            width: 54,
                            padding: const EdgeInsets.all(16),
                            decoration: boxDecorationWithRoundedCorners(
                              backgroundColor: bodyWhite.withValues(alpha: 0.1),
                              boxShape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              Assets.imagesAppleLogo,
                              color: isDarkMode.value ? null : black,
                            ).center(),
                          ),
                        ).visible(isApple),
                      ],
                    ),
                    8.height,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(locale.value.notAMember,
                            style: secondaryTextStyle()),
                        4.width,
                        InkWell(
                          onTap: () {
                            Get.to(() => SignUpScreen());
                          },
                          child: Text(
                            locale.value.registerNow,
                            style: boldTextStyle(
                              size: 12,
                              color: appColorSecondary,
                              decorationColor: appColorSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    16.height,
                  ],
                ),
              ).paddingSymmetric(horizontal: 16),
            ],
          ).paddingOnly(top: Get.height * 0.02),
          Positioned(
            width: Get.width,
            top: -Constants.appLogoSize,
            child: const AppLogoWidget(),
          ),
        ],
      ),
    );
  }
}

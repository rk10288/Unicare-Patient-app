import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '/components/app_logo_widget.dart';
import '/utils/constants.dart';

import '../../../components/app_scaffold.dart';
import '../../../configs.dart';
import '../../../generated/assets.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import 'password_rule_item.dart';
import 'sign_up_controller.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final SignUpController signUpController = Get.put(SignUpController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      topBarBgColor: appScreenBackground,
      isLoading: signUpController.isLoading,
      hasLeadingWidget: false,
      clipBehaviorSplitRegion: Clip.none,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedScrollView(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                locale.value.createYourAccount,
                style: primaryTextStyle(size: 24),
              ),
              8.height,
              Text(
                locale.value.registerYourAccountForBetterExperience,
                style: secondaryTextStyle(size: 14),
              ),
              SizedBox(height: Get.height * 0.05),
              Form(
                key: signUpController.signUpformKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    16.height,
                    // Full Name
                    AppTextField(
                      title: locale.value.fullName,
                      textStyle: primaryTextStyle(size: 12),
                      controller: signUpController.fullNameCont,
                      focus: signUpController.fullNameFocus,
                      nextFocus: signUpController.phoneFocus,
                      textFieldType: TextFieldType.NAME,
                      decoration: inputDecoration(
                        context,
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: "${locale.value.eG} John Doe",
                      ),
                      suffix: commonLeadingWid(
                              imgPath: Assets.navigationIcUserOutlined,
                              size: 14)
                          .paddingAll(14),
                    ),
                    16.height,
                    // Phone Number with Country Code Picker
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.value.phoneNumber,
                          style: primaryTextStyle(size: 12),
                        ),
                        8.height,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Country Code Picker
                            Obx(
                              () => GestureDetector(
                                onTap: () =>
                                    signUpController.pickCountry(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: context.cardColor,
                                    borderRadius:
                                        radius(defaultAppButtonRadius),
                                    border: Border.all(
                                        color: borderColor.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        signUpController
                                            .selectedCountry.value.flagEmoji,
                                        style: const TextStyle(fontSize: 20),
                                      ),
                                      4.width,
                                      Text(
                                        '+${signUpController.selectedCountry.value.phoneCode}',
                                        style: primaryTextStyle(size: 12),
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
                            // Phone Number Field
                            Expanded(
                              child: AppTextField(
                                textStyle: primaryTextStyle(size: 12),
                                controller: signUpController.phoneCont,
                                focus: signUpController.phoneFocus,
                                nextFocus: signUpController.emailFocus,
                                textFieldType: TextFieldType.PHONE,
                                decoration: inputDecoration(
                                  context,
                                  fillColor: context.cardColor,
                                  filled: true,
                                  hintText: locale.value.enterPhoneNumber,
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return locale.value.phoneNumberRequired;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    16.height,
                    // Email (Optional) - Moved after phone number
                    AppTextField(
                      title: '${locale.value.email} (${locale.value.optional})',
                      textStyle: primaryTextStyle(size: 12),
                      controller: signUpController.emailCont,
                      focus: signUpController.emailFocus,
                      nextFocus: signUpController.passwordFocus,
                      textFieldType: TextFieldType.EMAIL,
                      isValidationRequired: false,
                      decoration: inputDecoration(
                        context,
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: "${locale.value.eG} example@domain.com",
                      ),
                      suffix: commonLeadingWid(
                              imgPath: Assets.iconsIcMail, size: 14)
                          .paddingAll(14),
                    ),
                    16.height,
                    Focus(
                      onFocusChange: (value) {
                        signUpController.passContHasFocus(value);
                      },
                      child: AppTextField(
                        title: locale.value.password,
                        textStyle: primaryTextStyle(size: 12),
                        controller: signUpController.passwordCont,
                        focus: signUpController.passwordFocus,
                        nextFocus: signUpController.confirmPasswordFocus,
                        textFieldType: TextFieldType.PASSWORD,
                        obscureText: true,
                        onChanged: (val) =>
                            signUpController.checkPasswordRules(val),
                        decoration: inputDecoration(
                          context,
                          fillColor: context.cardColor,
                          filled: true,
                          hintText: "${locale.value.eG} #1234@1567",
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return locale.value.passwordIsRequired;
                          } else if (value.length < 8) {
                            return locale.value.passwordTooShort;
                          } else if (!signUpController.hasSpecial.value ||
                              !signUpController.hasNumber.value ||
                              !signUpController.hasUppercase.value ||
                              !signUpController.hasLetter.value) {
                            return locale.value.passwordDoesNotMeetRequirements;
                          }
                          return null;
                        },
                        suffixPasswordVisibleWidget: commonLeadingWid(
                                imgPath: Assets.iconsIcEye, size: 14)
                            .paddingAll(12),
                        suffixPasswordInvisibleWidget: commonLeadingWid(
                                imgPath: Assets.iconsIcEyeSlash, size: 14)
                            .paddingAll(12),
                      ),
                    ),
                    6.height,
                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PasswordRuleItem(
                            isValid: signUpController.hasUppercase.value,
                            text: locale.value
                                .passwordMustIncludeAtLeastOneCapitalCharacter,
                          ),
                          PasswordRuleItem(
                            isValid: signUpController.hasLetter.value,
                            text: locale.value
                                .passwordMustIncludeAtLeastOneLowercaseCharacter,
                          ),
                          PasswordRuleItem(
                            isValid: signUpController.hasNumber.value,
                            text: locale
                                .value.passwordMustIncludeAtLeastOneNumber,
                          ),
                          PasswordRuleItem(
                            isValid: signUpController.hasSpecial.value,
                            text: locale
                                .value.passwordMustIncludeSpacialCharacter,
                          ),
                        ],
                      ).visible(signUpController.passContHasFocus.value),
                    ),
                    16.height,
                    AppTextField(
                      title: locale.value.confirmNewPassword,
                      textStyle: primaryTextStyle(size: 12),
                      controller: signUpController.confirmPasswordCont,
                      focus: signUpController.confirmPasswordFocus,
                      textFieldType: TextFieldType.PASSWORD,
                      obscureText: true,
                      decoration: inputDecoration(
                        context,
                        fillColor: context.cardColor,
                        filled: true,
                        hintText: "${locale.value.eG} #1234@1567",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return locale.value.passwordIsRequired;
                        } else if (value !=
                            signUpController.passwordCont.text) {
                          return locale.value.yourNewPasswordDoesnT;
                        }
                        return null;
                      },
                      suffixPasswordVisibleWidget:
                          commonLeadingWid(imgPath: Assets.iconsIcEye, size: 14)
                              .paddingAll(12),
                      suffixPasswordInvisibleWidget: commonLeadingWid(
                              imgPath: Assets.iconsIcEyeSlash, size: 14)
                          .paddingAll(12),
                    ),
                    16.height,
                    Column(
                      children: [
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                checkColor: whiteColor,
                                value: signUpController.isAcceptedTc.value,
                                activeColor: appColorSecondary,
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                splashRadius: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: radius(0)),
                                side: const BorderSide(
                                    color: secondaryTextColor, width: 1.5),
                                onChanged: (val) async {
                                  signUpController.isAcceptedTc.value =
                                      !signUpController.isAcceptedTc.value;
                                },
                              ),
                              8.width,
                              RichTextWidget(
                                list: [
                                  TextSpan(
                                      text: "${locale.value.iAgreeToThe} ",
                                      style: secondaryTextStyle()),
                                  TextSpan(
                                    text: locale.value.termsConditions,
                                    style: primaryTextStyle(
                                        color: appColorSecondary,
                                        size: 12,
                                        decoration: TextDecoration.underline,
                                        decorationColor: appColorSecondary),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        commonLaunchUrl(TERMS_CONDITION_URL,
                                            launchMode:
                                                LaunchMode.externalApplication);
                                      },
                                  ),
                                  TextSpan(
                                      text: " ${locale.value.and} ",
                                      style: secondaryTextStyle()),
                                  TextSpan(
                                    text: locale.value.privacyPolicy,
                                    style: primaryTextStyle(
                                        color: appColorSecondary,
                                        size: 12,
                                        decoration: TextDecoration.underline,
                                        decorationColor: appColorSecondary),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        commonLaunchUrl(PRIVACY_POLICY_URL,
                                            launchMode:
                                                LaunchMode.externalApplication);
                                      },
                                  ),
                                ],
                              ).expand(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    16.height,
                    AppButton(
                      width: Get.width,
                      text: locale.value.next,
                      color: appColorSecondary,
                      textStyle: appButtonTextStyleWhite,
                      shapeBorder: RoundedRectangleBorder(
                          borderRadius: radius(defaultAppButtonRadius / 2)),
                      onTap: () {
                        if (signUpController.signUpformKey.currentState!
                            .validate()) {
                          signUpController.signUpformKey.currentState!.save();
                          signUpController.saveForm();
                        }
                      },
                    ),
                  ],
                ),
              ).paddingSymmetric(horizontal: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(locale.value.alreadyHaveAnAccount,
                      style: secondaryTextStyle()),
                  4.width,
                  InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Text(
                        locale.value.signIn,
                        style: boldTextStyle(
                          size: 12,
                          color: appColorSecondary,
                          decorationColor: appColorSecondary,
                        ),
                      )),
                ],
              ).paddingOnly(top: 16),
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

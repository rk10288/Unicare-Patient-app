import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../components/loader_widget.dart';
import '../../../../main.dart';
import '../../../../utils/common_base.dart';
import '../../../components/app_scaffold.dart';
import '../../../generated/assets.dart';
import '../../../utils/colors.dart';
import '../../../utils/constants.dart';
import 'common_profile_widget.dart';
import 'edit_user_profile_controller.dart';
import '../../../utils/app_common.dart';

class EditUserProfileScreen extends StatelessWidget {
  EditUserProfileScreen({super.key});
  final EditUserProfileController editUserProfileController = Get.put(EditUserProfileController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.editProfile,
      appBarVerticalSize: Get.height * 0.12,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  16.height,
                  Obx(() => ProfilePicWidget(
                        heroTag: editUserProfileController.imageFile.value.path.isNotEmpty
                            ? editUserProfileController.imageFile.value.path
                            : loginUserData.value.profileImage.isNotEmpty
                                ? loginUserData.value.profileImage
                                : loginUserData.value.profileImage,
                        profileImage: editUserProfileController.imageFile.value.path.isNotEmpty
                            ? editUserProfileController.imageFile.value.path
                            : loginUserData.value.profileImage.isNotEmpty
                                ? loginUserData.value.profileImage
                                : loginUserData.value.profileImage,
                        firstName: loginUserData.value.firstName,
                        lastName: loginUserData.value.lastName,
                        userName: loginUserData.value.userName,
                        showOnlyPhoto: true,
                        // showCameraIconOnCornar: !loginUserData.value.isSocialLoginType,
                        onCameraTap: () {
                          hideKeyboard(context);
                          editUserProfileController.showBottomSheet(context);
                        },
                        onPicTap: () {
                          hideKeyboard(context);
                          editUserProfileController.showBottomSheet(context);
                        },
                      )),
                  32.height,
                  AppTextField(
                    textStyle: primaryTextStyle(size: 12),
                    controller: editUserProfileController.fNameCont,
                    focus: editUserProfileController.fNameFocus,
                    nextFocus: editUserProfileController.lNameFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.firstName,
                      hintText: "${locale.value.eG}  ${locale.value.merry}",
                      fillColor: context.cardColor,
                      filled: true,
                    ),
                    suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, color: secondaryTextColor, size: 12).paddingAll(16),
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(size: 12),
                    controller: editUserProfileController.lNameCont,
                    focus: editUserProfileController.lNameFocus,
                    nextFocus: editUserProfileController.emailFocus,
                    textFieldType: TextFieldType.NAME,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.lastName,
                      hintText: "${locale.value.eG}  ${locale.value.doe}",
                      fillColor: context.cardColor,
                      filled: true,
                    ),
                    suffix: commonLeadingWid(imgPath: Assets.navigationIcUserOutlined, color: secondaryTextColor, size: 12).paddingAll(16),
                  ),
                  16.height,
                  AppTextField(
                    textStyle: primaryTextStyle(size: 12),
                    controller: editUserProfileController.emailCont,
                    focus: editUserProfileController.emailFocus,
                    nextFocus: editUserProfileController.mobileFocus,
                    readOnly: loginUserData.value.isSocialLoginType,
                    textFieldType: TextFieldType.EMAIL_ENHANCED,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.email,
                      fillColor: context.cardColor,
                      filled: true,
                    ),
                    suffix: commonLeadingWid(imgPath: Assets.iconsIcMail, color: secondaryTextColor, size: 12).paddingAll(16),
                  ),
                  16.height,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => AppTextField(
                          textStyle: primaryTextStyle(size: 12),
                          textFieldType: TextFieldType.OTHER,
                          controller: TextEditingController(text: " +${editUserProfileController.pickedPhoneCode.value.phoneCode}"),
                          focus: editUserProfileController.phoneCodeFocus,
                          nextFocus: editUserProfileController.mobileFocus,
                          errorThisFieldRequired: locale.value.thisFieldIsRequired,
                          readOnly: true,
                          onTap: () {
                            pickCountry(context, onSelect: (Country country) {
                              editUserProfileController.pickedPhoneCode(country);
                              editUserProfileController.phoneCodeCont.text = editUserProfileController.pickedPhoneCode.value.phoneCode;
                            });
                          },
                          textAlign: TextAlign.center,
                          decoration: inputDecoration(
                            context,
                            hintText: "",
                            prefixIcon: Text(
                              editUserProfileController.pickedPhoneCode.value.flagEmoji,
                            ).paddingOnly(top: 2, left: 8),
                            prefixIconConstraints: BoxConstraints.tight(const Size(24, 24)),
                            suffixIcon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: dividerColor,
                              size: 22,
                            ).paddingOnly(right: 32),
                            suffixIconConstraints: BoxConstraints.tight(const Size(24, 24)),
                            fillColor: context.cardColor,
                            filled: true,
                          ),
                        ),
                      ).expand(flex: 3),
                      16.width,
                      AppTextField(
                        textStyle: primaryTextStyle(size: 12),
                        textFieldType: TextFieldType.PHONE,
                        controller: editUserProfileController.mobileCont,
                        focus: editUserProfileController.mobileFocus,
                        errorThisFieldRequired: locale.value.thisFieldIsRequired,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: inputDecoration(
                          context,
                          labelText: locale.value.contactNumber,
                          fillColor: context.cardColor,
                          filled: true,
                        ),
                        suffix: commonLeadingWid(imgPath: Assets.iconsIcCall, color: secondaryTextColor, size: 12).paddingAll(16),
                      ).expand(flex: 8),
                    ],
                  ),
                  16.height,
                  AppTextField(
                    isValidationRequired: false,
                    textStyle: primaryTextStyle(size: 12),
                    textFieldType: TextFieldType.MULTILINE,
                    controller: editUserProfileController.addressCont,
                    focus: editUserProfileController.addressFocus,
                    errorThisFieldRequired: locale.value.thisFieldIsRequired,
                    decoration: inputDecoration(
                      context,
                      labelText: locale.value.address,
                      hintText: "${locale.value.eG} 123, ${locale.value.mainStreet}",
                      fillColor: context.cardColor,
                      filled: true,
                    ),
                  ),
                  16.height,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(locale.value.gender, style: primaryTextStyle()),
                      8.height,
                      Obx(
                        () => HorizontalList(
                          itemCount: genders.length,
                          spacing: 16,
                          runSpacing: 16,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            return Obx(
                              () => InkWell(
                                onTap: () {
                                  editUserProfileController.selectedGender(genders[index]);
                                  loginUserData.value.gender = editUserProfileController.selectedGender.value.slug;
                                },
                                borderRadius: radius(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  decoration: boxDecorationDefault(
                                    color: editUserProfileController.selectedGender.value.id == genders[index].id ? appColorPrimary : context.cardColor,
                                  ),
                                  child: Text(
                                    genders[index].name,
                                    style: secondaryTextStyle(
                                      color: editUserProfileController.selectedGender.value.id == genders[index].id ? white : null,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      16.height,
                      Text(locale.value.dateOfBirth, style: primaryTextStyle()),
                      AppTextField(
                        controller: editUserProfileController.dateOfBirthCont,
                        textStyle: primaryTextStyle(size: 12),
                        textFieldType: TextFieldType.OTHER,
                        readOnly: true,
                        onTap: () {
                          editUserProfileController.pickDate(context);
                        },
                        decoration: inputDecoration(
                          context,
                          hintText: DateFormatConst.DD_MM_YYYY,
                          fillColor: context.cardColor,
                          filled: true,
                        ),
                        suffix: const Icon(
                          Icons.calendar_today,
                          color: secondaryTextColor,
                        ).paddingAll(16),
                      ),
                    ],
                  ),
                  32.height,
                  AppButton(
                    width: Get.width,
                    text: locale.value.update,
                    textStyle: appButtonTextStyleWhite,
                    onTap: () async {
                      editUserProfileController.updateUserProfile();
                      /* ifNotTester(() async {
                        if (await isNetworkAvailable()) {
                          editUserProfileController.updateUserProfile();
                        } else {
                          toast(locale.value.yourInternetIsNotWorking);
                        }
                      }); */
                    },
                  ),
                  24.height,
                ],
              ),
            ).paddingSymmetric(horizontal: 24),
          ),
          Obx(() => const LoaderWidget().visible(editUserProfileController.isLoading.value)),
        ],
      ),
    );
  }
}

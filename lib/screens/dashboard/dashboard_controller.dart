// ignore_for_file: invalid_use_of_protected_member

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/auth_apis.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../../utils/local_storage.dart';
import '../auth/other/settings_screen.dart';
import '../auth/profile/profile_controller.dart';
import '../auth/profile/profile_screen.dart';
import '../auth/profile/patient_wallet_history_screen.dart';
import '../booking/appointments_screen.dart';
import '../home/home_controller.dart';
import '../home/home_screen.dart';
import 'components/menu.dart';

class DashboardController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxBool isLoading = false.obs;

  Rx<BottomBarItem> selectedBottomNav = BottomBarItem(
          title: (locale.value.home).obs,
          icon: Assets.navigationIcHomeOutlined,
          activeIcon: Assets.navigationIcHomeFilled,
          type: BottomItem.home.name)
      .obs;

  // Late initialization to avoid creating screens before controllers are ready
  late final RxList<StatelessWidget> screen;

  @override
  void onInit() {
    // Ensure HomeController is registered before creating screens
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }

    // Initialize screens after HomeController is available
    screen = [
      HomeScreen(),
      AppointmentsScreen(),
      PatientWalletHistory(),
    ].obs;

    if (!isLoggedIn.value) {
      ProfileController().getAboutPageData();
    }
    getAppConfigurations().then((value) {
      Future.delayed(const Duration(seconds: 2), () {
        if (Get.context != null) {
          showForceUpdateDialog(Get.context!);
        }
      });
    });
    super.onInit();
  }

  @override
  void onReady() {
    reloadBottomTabs();
    if (Get.context != null) {
      View.of(Get.context!).platformDispatcher.onPlatformBrightnessChanged =
          () {
        WidgetsBinding.instance.handlePlatformBrightnessChanged();
        try {
          final getThemeFromLocal =
              getValueFromLocal(SettingsLocalConst.THEME_MODE);
          if (getThemeFromLocal is int) {
            toggleThemeMode(themeId: getThemeFromLocal);
          }
        } catch (e) {
          log('getThemeFromLocal from cache E: $e');
        }
      };
    }
    super.onReady();
  }

  void reloadBottomTabs() {
    // debugPrint('reloadBottomTabs ISLOGGEDIN.VALUE: ${isLoggedIn.value}');
    if (isLoggedIn.value) {
      screen.removeWhere((element) => element is SettingScreen);
      if (screen
          .indexWhere((element) => element is PatientWalletHistory)
          .isNegative) {
        // Insert wallet screen at index 2 (after appointments)
        if (screen.length >= 2) {
          screen.insert(2, PatientWalletHistory());
        } else {
          screen.add(PatientWalletHistory());
        }
      }
      if (screen.indexWhere((element) => element is ProfileScreen).isNegative) {
        screen.add(ProfileScreen());
      }
      screen.toSet();

      bottomNavItems
          .removeWhere((element) => element.type == BottomItem.settings.name);
      if (bottomNavItems
          .indexWhere((element) => element.type == BottomItem.wallet.name)
          .isNegative) {
        // Insert wallet nav item at index 2 (after appointments)
        if (bottomNavItems.length >= 2) {
          bottomNavItems.insert(
              2,
              BottomBarItem(
                  title: (locale.value.walletHistory).obs,
                  icon: Assets.iconsIcUnFillWallet,
                  activeIcon: Assets.iconsIcUnFillWallet,
                  type: BottomItem.wallet.name));
        } else {
          bottomNavItems.add(BottomBarItem(
              title: (locale.value.walletHistory).obs,
              icon: Assets.iconsIcUnFillWallet,
              activeIcon: Assets.iconsIcUnFillWallet,
              type: BottomItem.wallet.name));
        }
      }
      if (bottomNavItems
          .indexWhere((element) => element.type == BottomItem.profile.name)
          .isNegative) {
        bottomNavItems.add(BottomBarItem(
            title: (locale.value.profile).obs,
            icon: Assets.navigationIcUserOutlined,
            activeIcon: Assets.navigationIcUserFilled,
            type: BottomItem.profile.name));
      }
      bottomNavItems.toSet();
    } else {
      screen.removeWhere((element) => element is ProfileScreen);
      screen.removeWhere((element) => element is PatientWalletHistory);
      screen.add(SettingScreen());
      screen.toSet();

      bottomNavItems
          .removeWhere((element) => element.type == BottomItem.profile.name);
      bottomNavItems
          .removeWhere((element) => element.type == BottomItem.wallet.name);
      if (bottomNavItems
          .indexWhere((element) => element.type == BottomItem.settings.name)
          .isNegative) {
        bottomNavItems.add(BottomBarItem(
            title: (locale.value.settings).obs,
            icon: Assets.iconsIcSettingOutlined,
            activeIcon: Assets.iconsIcSetting,
            type: BottomItem.settings.name));
      }
      bottomNavItems.toSet();
    }
    selectedBottomNav(bottomNavItems[currentIndex.value]);
  }
}

///Get App Configuration Api
Future<void> getAppConfigurations() async {
  await AuthServiceApis.getAppConfigurations().then((value) async {
    appConfigs(value);

    /// Place ChatGPT Key Here
    chatGPTAPIkey = value.chatgptKey;
  }).onError((error, stackTrace) {
    toast(error.toString());
  });
}

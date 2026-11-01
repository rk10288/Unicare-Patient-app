import 'package:get/get_rx/src/rx_types/rx_types.dart';
import '/generated/assets.dart';
import '/main.dart';

enum AppointmentStatus {
  all,
  upcoming,
  completed,
}

class AppointmentStatusModel {
  final String icon;
  final AppointmentStatus type;
  RxString? name; // Change this to RxString

  AppointmentStatusModel({
    this.type = AppointmentStatus.all,
    this.name,
    this.icon = '',
  });
}

RxList<AppointmentStatusModel> filterStatus = [
  AppointmentStatusModel(
      icon: Assets.iconsIcMenu,
      type: AppointmentStatus.all,
      name: (locale.value.all).obs),
  AppointmentStatusModel(
      icon: Assets.iconsIcUpcomingAppoinment,
      type: AppointmentStatus.upcoming,
      name: (locale.value.upcoming).obs),
  AppointmentStatusModel(
      icon: Assets.iconsIcChecked,
      type: AppointmentStatus.completed,
      name: (locale.value.completed).obs),
].obs;

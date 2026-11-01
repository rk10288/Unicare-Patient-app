import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '/screens/doctor/components/doctor_card.dart';
import '/screens/doctor/search_doctor_widget.dart';

import '../../../components/app_scaffold.dart';
import '../../components/loader_widget.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../../utils/empty_error_state_widget.dart';
import '../slots/booking_form_screen.dart';
import 'doctor_list_controller.dart';
import 'model/doctor_list_res.dart';

class DoctorsListScreen extends StatelessWidget {
  DoctorsListScreen({super.key});

  final DoctorListController doctorsListCont = Get.put(DoctorListController());

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.chooseDoctor,
      scaffoldBackgroundColor: context.scaffoldBackgroundColor,
      appBarVerticalSize: Get.height * 0.12,
      isLoading: doctorsListCont.isLoading,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchDoctorWidget(
            doctorListController: doctorsListCont,
            onFieldSubmitted: (p0) {
              hideKeyboard(context);
            },
          ).paddingAll(16),
          Obx(() {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: doctorsListCont.selectedDoctor.value.doctorId.isNegative
                    ? appColorSecondary.withValues(alpha: 0.08)
                    : greenColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    doctorsListCont.selectedDoctor.value.doctorId.isNegative
                        ? Icons.touch_app
                        : Icons.check_circle,
                    color: appColorSecondary,
                  ),
                  12.width,
                  Expanded(
                    child: Text(
                      doctorsListCont.selectedDoctor.value.doctorId.isNegative
                          ? locale.value.tapDoctorToContinue
                          : locale.value.doctorSelectedContinue,
                      style: primaryTextStyle(size: 13),
                    ),
                  ),
                ],
              ),
            );
          }),

          Obx(
            () => SnapHelperWidget(
              future: doctorsListCont.doctorsFuture.value,
              errorBuilder: (error) {
                return NoDataWidget(
                  title: error,
                  retryText: locale.value.reload,
                  imageWidget: const ErrorStateWidget(),
                  onRetry: () {
                    doctorsListCont.page(1);
                    doctorsListCont.getDoctors();
                  },
                ).paddingSymmetric(horizontal: 32);
              },
              loadingWidget: doctorsListCont.isLoading.value
                  ? const Offstage()
                  : const LoaderWidget(),
              onSuccess: (p0) {
                if (doctorsListCont.doctors.isEmpty) {
                  return NoDataWidget(
                    title: locale.value.noDoctorsFoundAtAMoment,
                    subTitle: locale
                        .value.looksLikeThereIsNoDoctorsForThisClinicWellKee,
                    titleTextStyle: primaryTextStyle(),
                    imageWidget: const EmptyStateWidget(),
                    retryText: locale.value.reload,
                    onRetry: () {
                      doctorsListCont.page(1);
                      doctorsListCont.getDoctors();
                    },
                  )
                      .paddingSymmetric(horizontal: 32)
                      .paddingBottom(Get.height * 0.15);
                }
                return AnimatedScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  listAnimationType: ListAnimationType.FadeIn,
                  children: [
                    16.height,
                    AnimatedWrap(
                      spacing: 16,
                      runSpacing: 45,
                      listAnimationType: ListAnimationType.FadeIn,
                      children: List.generate(
                        doctorsListCont.doctors.length,
                        (index) {
                          Doctor doctorData = doctorsListCont.doctors[index];
                          return DoctorCard(doctorData: doctorData);
                        },
                      ),
                    ),
                  ],
                  onNextPage: () async {
                    if (!doctorsListCont.isLastPage.value) {
                      doctorsListCont.page(doctorsListCont.page.value + 1);
                      doctorsListCont.getDoctors();
                    }
                  },
                  onSwipeRefresh: () async {
                    doctorsListCont.page(1);
                    return await doctorsListCont.getDoctors(showLoader: false);
                  },
                ).paddingSymmetric(horizontal: 16);
              },
            ),
          ).expand(),
        ],
      ),
      fabWidget: Obx(
            () => AnimatedScale(
          scale:
          doctorsListCont.selectedDoctor.value.doctorId.isNegative ? 0 : 1,
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton.extended(
            backgroundColor: appColorSecondary,
            onPressed: () {
              Get.to(() => BookingFormScreen());
            },
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            label: Text(
              locale.value.continueText,
              style: boldTextStyle(color: Colors.white),
            ),
          ),
        ),
      ),

    );
  }
}

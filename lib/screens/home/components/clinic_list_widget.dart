import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/screens/clinic/model/clinics_res_model.dart';
import '/screens/home/components/quick_book_controller.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../../utils/colors.dart';
import '../../../utils/app_common.dart';

class ClinicListWidget extends StatelessWidget {
  final List<Clinic> clinicList;

  ClinicListWidget({super.key, required this.clinicList});

  final QuickBookController quickBookController = Get.find();

  @override
  Widget build(BuildContext context) {
    return AnimatedListView(
      shrinkWrap: true,
      itemCount: clinicList.length,
      padding: EdgeInsets.zero,
      physics: const AlwaysScrollableScrollPhysics(),
      listAnimationType: ListAnimationType.Slide,
      itemBuilder: (ctx, index) {
        return GestureDetector(
          onTap: () {
            hideKeyboard(context);
            quickBookController.selectedClinicId.value = clinicList[index].id;
            quickBookController.clinicCont.text = clinicList[index].name;
            quickBookController.selectedService.value =
                quickBookController.clinicCont.text;
            quickBookController.selectedClinicData = clinicList[index];
            Get.back();
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: boxDecorationDefault(
              borderRadius: BorderRadius.circular(6),
              color: isDarkMode.value
                  ? appScreenBackgroundDark
                  : appScreenBackground,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(clinicList[index].name.toString(),
                        style: boldTextStyle(
                            size: 16,
                            color:
                                isDarkMode.value ? null : darkGrayTextColor)),
                    2.height,
                    Text(
                      clinicList[index].description.toString(),
                      style: primaryTextStyle(
                        size: 12,
                        color: secondaryTextColor,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ).expand()
              ],
            ),
          ),
        ).visible(!quickBookController.isLoading.value);
      },
    );
  }
}

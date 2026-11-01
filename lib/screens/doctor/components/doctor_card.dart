import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '/components/cached_image_widget.dart';
import '/screens/doctor/model/doctor_list_res.dart';

import '../../../../generated/assets.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/common_base.dart';
import '../doctor_detail_screen.dart';
import '../doctor_list_controller.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctorData;

  DoctorCard({super.key, required this.doctorData});

  final DoctorListController doctorsListCont = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final isSelected = doctorData.doctorId ==
            doctorsListCont.selectedDoctor.value.doctorId;

        return GestureDetector(
          onTap: () {
            /// Toggle selection
            if (isSelected) {
              doctorsListCont.selectedDoctor(Doctor());
              currentSelectedDoctor(doctorsListCont.selectedDoctor.value);
            } else {
              doctorsListCont.selectedDoctor(doctorData);
              currentSelectedDoctor(doctorsListCont.selectedDoctor.value);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? appColorPrimary.withOpacity(0.3)
                      : Colors.black.withOpacity(0.08),
                  blurRadius: isSelected ? 16 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Background Image with gradient overlay
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      CachedImageWidget(
                        url: doctorData.profileImage,
                        height: 200,
                        fit: BoxFit.cover,
                        width: Get.width / 2 - 24,
                      ),
                      // Premium gradient overlay
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),
                      // Selection overlay
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: appColorPrimary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Online indicator
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade500,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        4.width,
                        Text(
                          'Available',
                          style: boldTextStyle(size: 9, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),

                // Selected checkmark badge
                if (isSelected)
                  Positioned(
                    top: -8,
                    right: -8,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: appColorPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: appColorPrimary.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                // Expert/Specialty info at bottom
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => DoctorDetailScreen(), arguments: doctorData);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (doctorData.expert.isNotEmpty)
                                  Text(
                                    doctorData.expert,
                                    style: boldTextStyle(
                                      size: 13,
                                      color: appColorPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                4.height,
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      color: Colors.amber.shade600,
                                      size: 14,
                                    ),
                                    4.width,
                                    Text(
                                      'Specialist',
                                      style: secondaryTextStyle(size: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: appColorPrimary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: appColorPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).visible(doctorData.expert.isNotEmpty),

                // Select Button
                Positioned(
                  bottom: -18,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        doctorsListCont.selectedDoctor(Doctor());
                        currentSelectedDoctor(
                            doctorsListCont.selectedDoctor.value);
                      } else {
                        doctorsListCont.selectedDoctor(doctorData);
                        currentSelectedDoctor(
                            doctorsListCont.selectedDoctor.value);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isSelected
                              ? [
                                  appColorPrimary,
                                  appColorPrimary.withOpacity(0.8)
                                ]
                              : [
                                  appColorSecondary,
                                  appColorSecondary.withOpacity(0.8)
                                ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: (isSelected
                                    ? appColorPrimary
                                    : appColorSecondary)
                                .withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.add_circle_outline,
                            color: Colors.white,
                            size: 16,
                          ),
                          6.width,
                          Text(
                            isSelected ? 'Selected' : 'Select',
                            style: boldTextStyle(size: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

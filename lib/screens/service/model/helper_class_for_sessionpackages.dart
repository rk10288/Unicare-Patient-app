import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../main.dart';
import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';
import '../../../utils/price_widget.dart';
import '../service_detail_controller.dart';

/// Therapy/Session-based Pricing Section with chip-style selection
class TherapyPricingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailController>();

    return Obx(() {
      if (controller.sessionPackages.isEmpty) {
        return PriceWidget(
          price: controller.serviceData.value.charges,
          size: 18,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.value.selectPackage,
            style: boldTextStyle(size: 12, color: textSecondaryColorGlobal),
          ),
          12.height,
          // Chip-style session packages
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: controller.sessionPackages.map((package) {
              final isSelected = controller.selectedSession.value == package;
              return GestureDetector(
                onTap: () => controller.selectedSession(package),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? appColorPrimary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? appColorPrimary
                          : appColorSecondary.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: appColorPrimary.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        package.title,
                        style: boldTextStyle(
                          size: 13,
                          color: isSelected ? Colors.white : appColorPrimary,
                        ),
                      ),
                      if (package.sessions != null) ...[
                        4.height,
                        Text(
                          '${package.sessions} ${locale.value.sessions}',
                          style: secondaryTextStyle(
                            size: 10,
                            color: isSelected
                                ? Colors.white70
                                : textSecondaryColorGlobal,
                          ),
                        ),
                      ],
                      if (package.price != null) ...[
                        6.height,
                        Text(
                          '${appConfigs.value.currency.currencySymbol}${package.price}',
                          style: boldTextStyle(
                            size: 14,
                            color:
                                isSelected ? Colors.white : appColorSecondary,
                          ),
                        ),
                      ] else ...[
                        6.height,
                        Text(
                          locale.value.customPrice,
                          style: secondaryTextStyle(
                            size: 10,
                            color:
                                isSelected ? Colors.white70 : appColorSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          16.height,
          // Show selected price or contact us
          if (controller.selectedSession.value?.price != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: lightPrimaryColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${locale.value.total}: ',
                    style: secondaryTextStyle(size: 12),
                  ),
                  PriceWidget(
                    price: controller.selectedSession.value!.price!,
                    size: 18,
                  ),
                ],
              ),
            )
          else if (controller.selectedSession.value != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: appColorSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                locale.value.contactUsForPricing,
                style: boldTextStyle(size: 13, color: appColorSecondary),
              ),
            ),
        ],
      );
    });
  }
}

/// Home Care/Day-wise Pricing Section with chip-style selection
class HomeCarePricingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailController>();

    return Obx(() {
      if (controller.daysOptions.isEmpty && controller.hoursOptions.isEmpty) {
        return PriceWidget(
          price: controller.serviceData.value.charges,
          size: 18,
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Days Selection
          if (controller.daysOptions.isNotEmpty) ...[
            Text(
              locale.value.selectDaysPerWeek,
              style: boldTextStyle(size: 12, color: textSecondaryColorGlobal),
            ),
            10.height,
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.daysOptions.map((dayOption) {
                final isSelected = controller.selectedDays.value == dayOption;
                return GestureDetector(
                  onTap: () => controller.onDaysSelected(dayOption),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? appColorPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? appColorPrimary
                            : appColorSecondary.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: appColorPrimary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dayOption.title,
                          style: boldTextStyle(
                            size: 13,
                            color: isSelected ? Colors.white : appColorPrimary,
                          ),
                        ),
                        4.height,
                        Text(
                          '${dayOption.days} ${locale.value.days}',
                          style: secondaryTextStyle(
                            size: 10,
                            color: isSelected
                                ? Colors.white70
                                : textSecondaryColorGlobal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            16.height,
          ],

          // Hours Selection (only show if days selected and not custom)
          if (controller.selectedDays.value != null &&
              !controller.isCustomDaysSelected &&
              controller.hoursOptions.isNotEmpty) ...[
            Text(
              locale.value.selectHoursPerDay,
              style: boldTextStyle(size: 12, color: textSecondaryColorGlobal),
            ),
            10.height,
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: controller.hoursOptions.map((hourOption) {
                final isSelected = controller.selectedHours.value == hourOption;
                return GestureDetector(
                  onTap: () => controller.onHoursSelected(hourOption),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? appColorPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? appColorPrimary
                            : appColorSecondary.withValues(alpha: 0.3),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: appColorPrimary.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          hourOption.title,
                          style: boldTextStyle(
                            size: 13,
                            color: isSelected ? Colors.white : appColorPrimary,
                          ),
                        ),
                        4.height,
                        Text(
                          '${hourOption.hours} ${locale.value.hours}',
                          style: secondaryTextStyle(
                            size: 10,
                            color: isSelected
                                ? Colors.white70
                                : textSecondaryColorGlobal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            16.height,
          ],

          // Price Display Section
          if (controller.showContactUsForHomeCare)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: appColorSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                locale.value.contactUsForPricing,
                style: boldTextStyle(size: 13, color: appColorSecondary),
              ),
            )
          else if (controller.calculatedHomeCarePrice != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: lightPrimaryColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.selectedDays.value != null &&
                      controller.selectedHours.value != null)
                    Text(
                      '${controller.selectedHours.value!.hours}h × ${controller.selectedDays.value!.days}d/week',
                      style: secondaryTextStyle(size: 10),
                    ),
                  4.height,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${locale.value.total}: ',
                        style: secondaryTextStyle(size: 12),
                      ),
                      PriceWidget(
                        price: controller.calculatedHomeCarePrice!,
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}

/// Normal/Standard Pricing Section
class NormalPricingSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailController>();

    return PriceWidget(
      price: controller.serviceData.value.charges,
      size: 18,
    );
  }
}

/// Reusable dropdown box (kept for backward compatibility)
class ServiceDropdownBox<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const ServiceDropdownBox({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: appColorSecondary.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          value: value,
          hint: Text(
            hint,
            style: secondaryTextStyle(size: 12),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                (item as dynamic).title,
                style: primaryTextStyle(size: 13),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

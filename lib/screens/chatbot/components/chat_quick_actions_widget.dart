import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../utils/app_common.dart';
import '../../../utils/colors.dart';

class ChatQuickActionsWidget extends StatelessWidget {
  final List<Map<String, String>> actions;
  final Function(String) onActionTap;

  const ChatQuickActionsWidget({
    super.key,
    required this.actions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Quick Actions',
            style: secondaryTextStyle(size: 12),
          ),
          12.height,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: actions.map((action) {
              return _QuickActionChip(
                label: action['label'] ?? '',
                onTap: () => onActionTap(action['action'] ?? ''),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDarkMode.value
              ? appColorPrimary.withValues(alpha: 0.15)
              : appColorPrimary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: appColorPrimary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: primaryTextStyle(
            color: appColorPrimary,
            size: 13,
          ),
        ),
      ),
    );
  }
}

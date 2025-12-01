import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class MedicationCard extends StatelessWidget {
  final String name;
  final String dosage;
  final String frequency;
  final Widget? statusIcon;
  final VoidCallback? onTap;
  final Widget? actionButton;

  const MedicationCard({
    super.key,
    required this.name,
    required this.dosage,
    required this.frequency,
    this.statusIcon,
    this.onTap,
    this.actionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border.all(color: AppColors.primaryBlack, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          hoverColor: AppColors.gray50,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.medication,
                      size: 20,
                      color: AppColors.primaryBlack,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                    if (statusIcon != null) statusIcon!,
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  dosage,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  frequency,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gray400,
                  ),
                ),
                if (actionButton != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  actionButton!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

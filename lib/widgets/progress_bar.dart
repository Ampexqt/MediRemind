import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ProgressBar extends StatelessWidget {
  final String label;
  final double percentage;
  final String? subtitle;

  const ProgressBar({
    super.key,
    required this.label,
    required this.percentage,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlack,
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: const TextStyle(fontSize: 12, color: AppColors.gray500),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.gray100,
            border: Border.all(color: AppColors.primaryBlack, width: 1),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(color: AppColors.primaryBlack),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: const TextStyle(fontSize: 12, color: AppColors.gray500),
          ),
        ],
      ],
    );
  }
}

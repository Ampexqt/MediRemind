import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/medication_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/medication_card.dart';
import '../widgets/app_button.dart';

class MedicationsScreen extends StatelessWidget {
  const MedicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      100, // Space for fixed button
                    ),
                    child: _buildMedicationsList(context),
                  ),
                  _buildAddButton(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: const BoxDecoration(
            color: AppColors.pureWhite,
            border: Border(
              bottom: BorderSide(color: AppColors.primaryBlack, width: 1),
            ),
          ),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, size: 24),
                onPressed: () {
                  // Navigate back
                },
              ),
              const SizedBox(width: AppSpacing.xs),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Medications',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.medications.length} active medications',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMedicationsList(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        final medications = provider.medications;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ACTIVE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...medications.map((medication) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: MedicationCard(
                  name: medication.name,
                  dosage: medication.dosage,
                  frequency: medication.frequency,
                  statusIcon: const Icon(
                    Icons.circle,
                    size: 20,
                    color: AppColors.primaryBlack,
                  ),
                  onTap: () {
                    // Navigate to medication details
                  },
                ),
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      bottom: AppSpacing.lg,
      child: AppButton(
        text: '+ Add Medication',
        variant: ButtonVariant.primary,
        fullWidth: true,
        onPressed: () {
          // Navigate to add medication screen
        },
      ),
    );
  }
}

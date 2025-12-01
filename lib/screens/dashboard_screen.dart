import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medication_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/progress_bar.dart';
import '../widgets/medication_card.dart';
import '../widgets/app_button.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAdherenceCard(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildNextDoseCard(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildUpcomingSection(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('EEEE, MMM d');

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.primaryBlack, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateFormat.format(now),
                style: const TextStyle(fontSize: 14, color: AppColors.gray500),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 24),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdherenceCard(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        final adherence = provider.getTodaysAdherence();
        final stats = provider.getStats();

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            border: Border.all(color: AppColors.primaryBlack, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgressBar(label: "Today's Adherence", percentage: adherence),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${stats['taken']} of ${stats['total']} doses taken',
                style: const TextStyle(fontSize: 12, color: AppColors.gray500),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNextDoseCard(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        final nextDose = provider.getNextDose();

        if (nextDose == null) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              border: Border.all(color: AppColors.primaryBlack, width: 1),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.primaryBlack,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'All doses taken for today!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Great job staying on track',
                  style: TextStyle(fontSize: 14, color: AppColors.gray500),
                ),
              ],
            ),
          );
        }

        final medication = provider.medications.firstWhere(
          (m) => m.id == nextDose.medicationId,
        );
        final timeFormat = DateFormat('h:mm a');

        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primaryBlack,
            border: Border.all(color: AppColors.primaryBlack, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, size: 24, color: AppColors.pureWhite),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Next Dose',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.pureWhite,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                timeFormat.format(nextDose.scheduledTime),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pureWhite,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                medication.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pureWhite,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                medication.dosage,
                style: const TextStyle(fontSize: 14, color: AppColors.gray200),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                text: 'Take Now',
                variant: ButtonVariant.secondary,
                fullWidth: true,
                onPressed: () {
                  provider.markDoseAsTaken(nextDose.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpcomingSection(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        final upcoming = provider.getUpcomingDoses();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'UPCOMING TODAY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to schedule
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (upcoming.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  border: Border.all(color: AppColors.gray200, width: 1),
                ),
                child: const Center(
                  child: Text(
                    'No more doses scheduled for today',
                    style: TextStyle(fontSize: 14, color: AppColors.gray400),
                  ),
                ),
              )
            else
              ...upcoming.take(3).map((dose) {
                final medication = provider.medications.firstWhere(
                  (m) => m.id == dose.medicationId,
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: MedicationCard(
                    name: medication.name,
                    dosage: medication.dosage,
                    frequency: DateFormat('h:mm a').format(dose.scheduledTime),
                    actionButton: AppButton(
                      text: 'Take Now',
                      variant: ButtonVariant.primary,
                      fullWidth: true,
                      onPressed: () {
                        provider.markDoseAsTaken(dose.id);
                      },
                    ),
                  ),
                );
              }),
            if (upcoming.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: AppButton(
                  text: '+ Add Medication',
                  variant: ButtonVariant.secondary,
                  fullWidth: true,
                  onPressed: () {
                    // Navigate to add medication
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

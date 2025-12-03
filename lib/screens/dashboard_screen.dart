import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medication_provider.dart';
import '../models/dose_log.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/progress_bar.dart';
import '../widgets/medication_card.dart';
import '../widgets/app_button.dart';
import 'add_medication_screen.dart';

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
              child: Consumer<MedicationProvider>(
                builder: (context, provider, child) {
                  // Show empty state if no medications
                  if (provider.medications.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return SingleChildScrollView(
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
                  );
                },
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
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200, width: 2),
            ),
            child: const Center(
              child: Icon(Icons.medication, size: 64, color: AppColors.gray300),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const Text(
            'No Medications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Add your first medication to start\ntracking your medication schedule.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            text: '+ Add Medication',
            variant: ButtonVariant.primary,
            fullWidth: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddMedicationScreen(),
                ),
              );
            },
          ),
          const Spacer(),
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
        final todaysDoses = provider.getTodaysDoses();

        // If no doses at all today
        if (todaysDoses.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              border: Border.all(color: AppColors.primaryBlack, width: 1),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 48,
                  color: AppColors.gray300,
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'No doses scheduled',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlack,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Add medications to see your schedule',
                  style: TextStyle(fontSize: 14, color: AppColors.gray500),
                ),
              ],
            ),
          );
        }

        // Check if all doses are actually taken (not just no upcoming doses)
        final allTaken = todaysDoses.every(
          (dose) => dose.status == DoseStatus.taken,
        );

        if (allTaken) {
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

        // Find the next dose that should be taken
        // This includes both upcoming doses and overdue doses
        final pendingDoses =
            todaysDoses
                .where((dose) => dose.status == DoseStatus.pending)
                .toList()
              ..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));

        if (pendingDoses.isEmpty) {
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

        final nextDose = pendingDoses.first;
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
                onPressed: () async {
                  final result = await provider.markDoseAsTaken(nextDose.id);
                  if (context.mounted) {
                    if (result.canTake) {
                      _showSuccessToast(
                        context,
                        '${medication.name} taken successfully!',
                      );
                    } else {
                      _showToast(context, result.message);
                    }
                  }
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
            const Text(
              'UPCOMING TODAY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
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
                  ),
                );
              }),
          ],
        );
      },
    );
  }

  void _showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _ToastNotification(message: message, isSuccess: false),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  void _showSuccessToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: _ToastNotification(message: message, isSuccess: true),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }
}

class _ToastNotification extends StatefulWidget {
  final String message;
  final bool isSuccess;

  const _ToastNotification({required this.message, this.isSuccess = false});

  @override
  State<_ToastNotification> createState() => _ToastNotificationState();
}

class _ToastNotificationState extends State<_ToastNotification>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // Start fade out after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryBlack,
            border: Border.all(color: AppColors.primaryBlack, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.pureWhite, width: 2),
                ),
                child: Center(
                  child: Icon(
                    widget.isSuccess ? Icons.check_circle : Icons.access_time,
                    size: 20,
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pureWhite,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

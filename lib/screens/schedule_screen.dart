import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medication_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int selectedDay = 0; // 0 = Monday

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildWeekSelector(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildTimeline(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.pureWhite,
        border: Border(
          bottom: BorderSide(color: AppColors.primaryBlack, width: 1),
        ),
      ),
      child: const Row(
        children: [
          Text(
            'Schedule',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlack,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: List.generate(7, (index) {
          final isSelected = selectedDay == index;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index < 6 ? 8 : 0),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedDay = index;
                  });
                },
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryBlack
                        : AppColors.pureWhite,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primaryBlack
                          : AppColors.gray200,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      days[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.pureWhite
                            : AppColors.gray400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final dateFormat = DateFormat('EEEE, MMMM d, yyyy');

        // Get today's doses
        final doses = provider.getTodaysDoses();

        // Group doses by time
        final Map<String, List<dynamic>> dosesByTime = {};
        for (var dose in doses) {
          final timeKey = DateFormat('h:mm a').format(dose.scheduledTime);
          if (!dosesByTime.containsKey(timeKey)) {
            dosesByTime[timeKey] = [];
          }
          dosesByTime[timeKey]!.add(dose);
        }

        // Sort times
        final sortedTimes = dosesByTime.keys.toList()
          ..sort((a, b) {
            final timeA = DateFormat('h:mm a').parse(a);
            final timeB = DateFormat('h:mm a').parse(b);
            return timeA.compareTo(timeB);
          });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormat.format(today),
              style: const TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              "TODAY'S SCHEDULE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...sortedTimes.map((timeStr) {
              final dosesAtTime = dosesByTime[timeStr]!;

              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlack,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: dosesAtTime.map<Widget>((dose) {
                          final medication = provider.medications.firstWhere(
                            (m) => m.id == dose.medicationId,
                          );

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.pureWhite,
                              border: Border.all(
                                color: AppColors.primaryBlack,
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.medication,
                                  size: 16,
                                  color: AppColors.primaryBlack,
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    medication.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryBlack,
                                    ),
                                  ),
                                ),
                                Icon(
                                  dose.status.toString().contains('taken')
                                      ? Icons.check_circle
                                      : Icons.circle_outlined,
                                  size: 20,
                                  color: AppColors.primaryBlack,
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    );
  }
}

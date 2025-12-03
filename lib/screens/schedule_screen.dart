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
  late int selectedDay;

  @override
  void initState() {
    super.initState();
    // Set selectedDay to today's weekday (1=Monday, 7=Sunday)
    // Convert to 0-indexed (0=Monday, 6=Sunday)
    selectedDay = DateTime.now().weekday - 1;
  }

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

        // Calculate the date for the selected day
        final currentWeekday = now.weekday - 1; // 0-indexed
        final dayDifference = selectedDay - currentWeekday;
        final selectedDate = today.add(Duration(days: dayDifference));
        final selectedWeekday =
            selectedDay +
            1; // Convert back to 1-indexed for medication.selectedDays

        // Get medications that should be taken on the selected day
        final medicationsForDay = provider.medications.where((med) {
          return med.selectedDays.contains(selectedWeekday);
        }).toList();

        // Create dose entries for the selected day
        final Map<String, List<Map<String, dynamic>>> dosesByTime = {};
        for (var med in medicationsForDay) {
          for (var timeStr in med.times) {
            final timeParts = timeStr.split(':');
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            final scheduledTime = DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              hour,
              minute,
            );
            final timeKey = DateFormat('h:mm a').format(scheduledTime);

            if (!dosesByTime.containsKey(timeKey)) {
              dosesByTime[timeKey] = [];
            }
            dosesByTime[timeKey]!.add({
              'medication': med,
              'scheduledTime': scheduledTime,
            });
          }
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
              dateFormat.format(selectedDate),
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
            if (sortedTimes.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.gray50,
                  border: Border.all(color: AppColors.gray200, width: 1),
                ),
                child: const Center(
                  child: Text(
                    'No medications scheduled for this day',
                    style: TextStyle(fontSize: 14, color: AppColors.gray400),
                  ),
                ),
              )
            else
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
                          children: dosesAtTime.map<Widget>((doseInfo) {
                            final medication = doseInfo['medication'];

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
                                  const Icon(
                                    Icons.circle_outlined,
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

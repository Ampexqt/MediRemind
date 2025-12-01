import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/medication_provider.dart';
import '../models/dose_log.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pureWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    _buildStatsGrid(context),
                    const SizedBox(height: AppSpacing.lg),
                    _buildLogEntries(context),
                  ],
                ),
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
            'History',
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

  Widget _buildStatsGrid(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        final stats = provider.getStats();

        return Row(
          children: [
            Expanded(child: _buildStatCard('${stats['taken']}', 'Taken')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildStatCard('${stats['missed']}', 'Missed')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _buildStatCard(
                '${((stats['taken']! / (stats['total']! > 0 ? stats['total']! : 1)) * 100).toInt()}%',
                'Rate',
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        border: Border.all(color: AppColors.primaryBlack, width: 1),
      ),
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlack,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.gray500),
          ),
        ],
      ),
    );
  }

  Widget _buildLogEntries(BuildContext context) {
    return Consumer<MedicationProvider>(
      builder: (context, provider, child) {
        final doses = provider.getTodaysDoses()
          ..sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "TODAY'S LOG",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            ...doses.map((dose) {
              final medication = provider.medications.firstWhere(
                (m) => m.id == dose.medicationId,
              );

              return _buildLogEntry(
                medication.name,
                medication.dosage,
                dose.scheduledTime,
                dose.status,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildLogEntry(
    String name,
    String dosage,
    DateTime time,
    DoseStatus status,
  ) {
    final isTaken = status == DoseStatus.taken;
    final timeFormat = DateFormat('h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isTaken ? AppColors.pureWhite : AppColors.gray50,
        border: Border.all(
          color: isTaken ? AppColors.primaryBlack : AppColors.gray200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isTaken ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isTaken ? AppColors.primaryBlack : AppColors.gray400,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isTaken ? AppColors.primaryBlack : AppColors.gray400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dosage,
                  style: TextStyle(
                    fontSize: 12,
                    color: isTaken ? AppColors.gray500 : AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeFormat.format(time),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isTaken ? AppColors.primaryBlack : AppColors.gray400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                isTaken ? 'Taken' : 'Pending',
                style: const TextStyle(fontSize: 10, color: AppColors.gray400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

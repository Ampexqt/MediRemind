import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';
import '../models/dose_validation_result.dart';

class MedicationProvider with ChangeNotifier {
  final List<Medication> _medications = [];
  final List<DoseLog> _doseLogs = [];
  bool _isLoaded = false;

  List<Medication> get medications => List.unmodifiable(_medications);
  List<DoseLog> get doseLogs => List.unmodifiable(_doseLogs);
  bool get isLoaded => _isLoaded;

  MedicationProvider() {
    _loadData();
  }

  // Load data from shared preferences
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load medications
    final medicationsJson = prefs.getString('medications');
    if (medicationsJson != null) {
      final List<dynamic> decoded = jsonDecode(medicationsJson);
      _medications.clear();
      _medications.addAll(
        decoded.map((json) => Medication.fromJson(json)).toList(),
      );
    }

    // Load dose logs
    final doseLogsJson = prefs.getString('doseLogs');
    if (doseLogsJson != null) {
      final List<dynamic> decoded = jsonDecode(doseLogsJson);
      _doseLogs.clear();
      _doseLogs.addAll(decoded.map((json) => DoseLog.fromJson(json)).toList());
    }

    // Generate today's dose logs if needed
    _generateTodaysDoseLogs();

    // Save to persist any regenerated logs
    await _saveData();

    _isLoaded = true;
    notifyListeners();
  }

  // Save data to shared preferences
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save medications
    final medicationsJson = jsonEncode(
      _medications.map((m) => m.toJson()).toList(),
    );
    await prefs.setString('medications', medicationsJson);

    // Save dose logs
    final doseLogsJson = jsonEncode(
      _doseLogs.map((log) => log.toJson()).toList(),
    );
    await prefs.setString('doseLogs', doseLogsJson);
  }

  void _generateTodaysDoseLogs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Remove old logs (keep only last 30 days)
    final thirtyDaysAgo = today.subtract(const Duration(days: 30));
    _doseLogs.removeWhere((log) {
      final logDate = DateTime(
        log.scheduledTime.year,
        log.scheduledTime.month,
        log.scheduledTime.day,
      );
      return logDate.isBefore(thirtyDaysAgo);
    });

    // Get today's day of week (1=Monday, 7=Sunday)
    final todayDayOfWeek = today.weekday;

    // Get medications that should have doses today
    final medicationsForToday = _medications.where((med) {
      return med.selectedDays.contains(todayDayOfWeek);
    }).toList();

    // Check if we need to regenerate logs for today
    // This handles cases where medications were updated or selectedDays changed
    bool needsRegeneration = false;

    // Check if all medications that should have doses today have logs
    for (var med in medicationsForToday) {
      final hasLogsForMed = _doseLogs.any((log) {
        final logDate = DateTime(
          log.scheduledTime.year,
          log.scheduledTime.month,
          log.scheduledTime.day,
        );
        return logDate.isAtSameMomentAs(today) && log.medicationId == med.id;
      });

      if (!hasLogsForMed) {
        needsRegeneration = true;
        break;
      }
    }

    // Also check if there are logs for medications that shouldn't have doses today
    final todaysLogs = _doseLogs.where((log) {
      final logDate = DateTime(
        log.scheduledTime.year,
        log.scheduledTime.month,
        log.scheduledTime.day,
      );
      return logDate.isAtSameMomentAs(today);
    }).toList();

    for (var log in todaysLogs) {
      final med = _medications
          .where((m) => m.id == log.medicationId)
          .firstOrNull;
      if (med != null && !med.selectedDays.contains(todayDayOfWeek)) {
        needsRegeneration = true;
        break;
      }
    }

    if (!needsRegeneration && todaysLogs.isNotEmpty) {
      return; // Logs are correct, no need to regenerate
    }

    // Remove today's logs before regenerating
    _doseLogs.removeWhere((log) {
      final logDate = DateTime(
        log.scheduledTime.year,
        log.scheduledTime.month,
        log.scheduledTime.day,
      );
      return logDate.isAtSameMomentAs(today);
    });

    // Generate logs for today
    for (var med in medicationsForToday) {
      for (var timeStr in med.times) {
        final timeParts = timeStr.split(':');
        final hour = int.parse(timeParts[0]);
        final minute = int.parse(timeParts[1]);
        final scheduledTime = DateTime(
          today.year,
          today.month,
          today.day,
          hour,
          minute,
        );

        _doseLogs.add(
          DoseLog(
            id: '${med.id}_${timeStr}_${today.toIso8601String()}',
            medicationId: med.id,
            medicationName: med.name,
            scheduledTime: scheduledTime,
            takenTime: null,
            status: DoseStatus.pending,
          ),
        );
      }
    }
  }

  Future<void> addMedication(Medication medication) async {
    _medications.add(medication);
    _generateTodaysDoseLogs();
    await _saveData();
    notifyListeners();
  }

  Future<void> updateMedication(Medication medication) async {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;

      // Update dose logs for this medication
      _doseLogs.removeWhere((log) => log.medicationId == medication.id);
      _generateTodaysDoseLogs();

      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteMedication(String id) async {
    _medications.removeWhere((m) => m.id == id);
    _doseLogs.removeWhere((log) => log.medicationId == id);
    await _saveData();
    notifyListeners();
  }

  // Validation result for dose taking
  DoseValidationResult canTakeDose(String doseLogId) {
    final doseIndex = _doseLogs.indexWhere((log) => log.id == doseLogId);
    if (doseIndex == -1) {
      return DoseValidationResult(canTake: false, message: 'Dose not found');
    }

    final dose = _doseLogs[doseIndex];
    final medication = _medications.firstWhere(
      (m) => m.id == dose.medicationId,
    );
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayWeekday = now.weekday;

    // Check if today is in the medication's selected days
    if (!medication.selectedDays.contains(todayWeekday)) {
      final dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      final selectedDayNames = medication.selectedDays
          .map((d) => dayNames[d - 1])
          .join(', ');
      return DoseValidationResult(
        canTake: false,
        message: 'This medication is only scheduled for: $selectedDayNames',
      );
    }

    // Check if the dose is scheduled for today
    final doseDate = DateTime(
      dose.scheduledTime.year,
      dose.scheduledTime.month,
      dose.scheduledTime.day,
    );
    if (!doseDate.isAtSameMomentAs(today)) {
      return DoseValidationResult(
        canTake: false,
        message: 'This dose is not scheduled for today',
      );
    }

    // Check if current time is within acceptable window (30 minutes before/after)
    final timeDifference = now.difference(dose.scheduledTime).inMinutes.abs();
    const timeWindow = 30; // minutes

    if (timeDifference > timeWindow) {
      final scheduledTimeStr = DateFormat('h:mm a').format(dose.scheduledTime);
      if (now.isBefore(dose.scheduledTime)) {
        return DoseValidationResult(
          canTake: false,
          message: 'Too early! This dose is scheduled for $scheduledTimeStr',
        );
      } else {
        return DoseValidationResult(
          canTake: false,
          message: 'Too late! This dose was scheduled for $scheduledTimeStr',
        );
      }
    }

    return DoseValidationResult(canTake: true, message: '');
  }

  Future<DoseValidationResult> markDoseAsTaken(String doseLogId) async {
    // Validate before marking as taken
    final validation = canTakeDose(doseLogId);
    if (!validation.canTake) {
      return validation;
    }

    final index = _doseLogs.indexWhere((log) => log.id == doseLogId);
    if (index != -1) {
      _doseLogs[index] = _doseLogs[index].copyWith(
        status: DoseStatus.taken,
        takenTime: DateTime.now(),
      );
      await _saveData();
      notifyListeners();
    }
    return DoseValidationResult(canTake: true, message: 'Dose marked as taken');
  }

  Future<void> markDoseAsSkipped(String doseLogId) async {
    final index = _doseLogs.indexWhere((log) => log.id == doseLogId);
    if (index != -1) {
      _doseLogs[index] = _doseLogs[index].copyWith(status: DoseStatus.skipped);
      await _saveData();
      notifyListeners();
    }
  }

  List<DoseLog> getTodaysDoses() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _doseLogs.where((log) {
      final logDate = DateTime(
        log.scheduledTime.year,
        log.scheduledTime.month,
        log.scheduledTime.day,
      );
      return logDate.isAtSameMomentAs(today);
    }).toList()..sort((a, b) => a.scheduledTime.compareTo(b.scheduledTime));
  }

  List<DoseLog> getUpcomingDoses() {
    final now = DateTime.now();
    return getTodaysDoses()
        .where(
          (log) =>
              log.scheduledTime.isAfter(now) &&
              log.status == DoseStatus.pending,
        )
        .toList();
  }

  DoseLog? getNextDose() {
    final upcoming = getUpcomingDoses();
    return upcoming.isEmpty ? null : upcoming.first;
  }

  double getTodaysAdherence() {
    final todaysDoses = getTodaysDoses();
    if (todaysDoses.isEmpty) return 0.0;

    final takenCount = todaysDoses
        .where((log) => log.status == DoseStatus.taken)
        .length;
    return takenCount / todaysDoses.length;
  }

  Map<String, int> getStats() {
    final todaysDoses = getTodaysDoses();
    final taken = todaysDoses
        .where((log) => log.status == DoseStatus.taken)
        .length;
    final missed = todaysDoses
        .where((log) => log.status == DoseStatus.missed)
        .length;

    return {'taken': taken, 'missed': missed, 'total': todaysDoses.length};
  }

  Medication? getMedicationById(String id) {
    try {
      return _medications.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }
}

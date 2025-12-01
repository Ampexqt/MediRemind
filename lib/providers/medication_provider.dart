import 'package:flutter/foundation.dart';
import '../models/medication.dart';
import '../models/dose_log.dart';

class MedicationProvider with ChangeNotifier {
  final List<Medication> _medications = [];
  final List<DoseLog> _doseLogs = [];

  List<Medication> get medications => List.unmodifiable(_medications);
  List<DoseLog> get doseLogs => List.unmodifiable(_doseLogs);

  MedicationProvider() {
    _initializeMockData();
  }

  void _initializeMockData() {
    // Mock medications as per specification
    _medications.addAll([
      Medication(
        id: '1',
        name: 'Aspirin',
        dosage: '100mg • 1 tablet',
        form: 'Tablet',
        frequency: 'Once daily',
        times: ['14:00'],
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Medication(
        id: '2',
        name: 'Lisinopril',
        dosage: '10mg • 1 tablet',
        form: 'Tablet',
        frequency: 'Once daily',
        times: ['18:00'],
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Medication(
        id: '3',
        name: 'Metformin',
        dosage: '500mg • 2 tablets',
        form: 'Tablet',
        frequency: 'Twice daily',
        times: ['08:00', '20:00'],
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Medication(
        id: '4',
        name: 'Atorvastatin',
        dosage: '20mg • 1 tablet',
        form: 'Tablet',
        frequency: 'Once daily',
        times: ['21:00'],
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Medication(
        id: '5',
        name: 'Omeprazole',
        dosage: '40mg • 1 capsule',
        form: 'Capsule',
        frequency: 'Once daily',
        times: ['07:00'],
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
      Medication(
        id: '6',
        name: 'Vitamin D3',
        dosage: '2000 IU • 1 softgel',
        form: 'Capsule',
        frequency: 'Once daily',
        times: ['08:00'],
        startDate: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ]);

    _generateTodaysDoseLogs();
  }

  void _generateTodaysDoseLogs() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var med in _medications) {
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

        DoseStatus status;
        DateTime? takenTime;

        if (scheduledTime.isBefore(now)) {
          // Randomly mark some as taken for demo
          if (scheduledTime.hour < 14) {
            status = DoseStatus.taken;
            takenTime = scheduledTime.add(const Duration(minutes: 5));
          } else {
            status = DoseStatus.pending;
          }
        } else {
          status = DoseStatus.pending;
        }

        _doseLogs.add(
          DoseLog(
            id: '${med.id}_${timeStr}_${today.toIso8601String()}',
            medicationId: med.id,
            medicationName: med.name,
            scheduledTime: scheduledTime,
            takenTime: takenTime,
            status: status,
          ),
        );
      }
    }
  }

  void addMedication(Medication medication) {
    _medications.add(medication);
    notifyListeners();
  }

  void updateMedication(Medication medication) {
    final index = _medications.indexWhere((m) => m.id == medication.id);
    if (index != -1) {
      _medications[index] = medication;
      notifyListeners();
    }
  }

  void deleteMedication(String id) {
    _medications.removeWhere((m) => m.id == id);
    _doseLogs.removeWhere((log) => log.medicationId == id);
    notifyListeners();
  }

  void markDoseAsTaken(String doseLogId) {
    final index = _doseLogs.indexWhere((log) => log.id == doseLogId);
    if (index != -1) {
      _doseLogs[index] = _doseLogs[index].copyWith(
        status: DoseStatus.taken,
        takenTime: DateTime.now(),
      );
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
}

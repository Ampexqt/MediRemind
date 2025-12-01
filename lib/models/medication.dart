/// Medication Model
class Medication {
  final String id;
  final String name;
  final String dosage;
  final String form; // tablet, capsule, liquid
  final String frequency;
  final List<String> times;
  final DateTime startDate;
  final int? durationDays;
  final bool remindersEnabled;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.form,
    required this.frequency,
    required this.times,
    required this.startDate,
    this.durationDays,
    this.remindersEnabled = true,
  });

  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    String? form,
    String? frequency,
    List<String>? times,
    DateTime? startDate,
    int? durationDays,
    bool? remindersEnabled,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      form: form ?? this.form,
      frequency: frequency ?? this.frequency,
      times: times ?? this.times,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
    );
  }
}

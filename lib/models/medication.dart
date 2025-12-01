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

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'form': form,
      'frequency': frequency,
      'times': times,
      'startDate': startDate.toIso8601String(),
      'durationDays': durationDays,
      'remindersEnabled': remindersEnabled,
    };
  }

  // Create from JSON
  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      form: json['form'] as String,
      frequency: json['frequency'] as String,
      times: List<String>.from(json['times'] as List),
      startDate: DateTime.parse(json['startDate'] as String),
      durationDays: json['durationDays'] as int?,
      remindersEnabled: json['remindersEnabled'] as bool? ?? true,
    );
  }
}

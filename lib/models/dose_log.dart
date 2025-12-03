/// Dose Log Model
class DoseLog {
  final String id;
  final String medicationId;
  final String medicationName;
  final DateTime scheduledTime;
  final DateTime? takenTime;
  final DoseStatus status;

  DoseLog({
    required this.id,
    required this.medicationId,
    required this.medicationName,
    required this.scheduledTime,
    this.takenTime,
    required this.status,
  });

  DoseLog copyWith({
    String? id,
    String? medicationId,
    String? medicationName,
    DateTime? scheduledTime,
    DateTime? takenTime,
    DoseStatus? status,
  }) {
    return DoseLog(
      id: id ?? this.id,
      medicationId: medicationId ?? this.medicationId,
      medicationName: medicationName ?? this.medicationName,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      takenTime: takenTime ?? this.takenTime,
      status: status ?? this.status,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'medicationId': medicationId,
      'medicationName': medicationName,
      'scheduledTime': scheduledTime.toIso8601String(),
      'takenTime': takenTime?.toIso8601String(),
      'status': status.toString(),
    };
  }

  // Create from JSON
  factory DoseLog.fromJson(Map<String, dynamic> json) {
    return DoseLog(
      id: json['id'] as String,
      medicationId: json['medicationId'] as String,
      medicationName: json['medicationName'] as String,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      takenTime: json['takenTime'] != null
          ? DateTime.parse(json['takenTime'] as String)
          : null,
      status: DoseStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => DoseStatus.pending,
      ),
    );
  }
}

enum DoseStatus { pending, taken, missed, skipped }

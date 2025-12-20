class AttendanceModel {
  final String id;
  final String userId;
  final DateTime punchInTime;
  final DateTime? punchOutTime;
  final String status;
  final String? notes;
  final double? punchInLatitude;
  final double? punchInLongitude;
  final double? punchOutLatitude;
  final double? punchOutLongitude;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.punchInTime,
    this.punchOutTime,
    required this.status,
    this.notes,
    this.punchInLatitude,
    this.punchInLongitude,
    this.punchOutLatitude,
    this.punchOutLongitude,
  });

  /// Create AttendanceModel from JSON
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      punchInTime: DateTime.parse(json['punch_in_time']),
      punchOutTime: json['punch_out_time'] != null
          ? DateTime.parse(json['punch_out_time'])
          : null,
      status: json['status'] ?? '',
      notes: json['notes'],
      punchInLatitude: json['punch_in_latitude']?.toDouble(),
      punchInLongitude: json['punch_in_longitude']?.toDouble(),
      punchOutLatitude: json['punch_out_latitude']?.toDouble(),
      punchOutLongitude: json['punch_out_longitude']?.toDouble(),
    );
  }

  /// Convert AttendanceModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'punch_in_time': punchInTime.toIso8601String(),
      'punch_out_time': punchOutTime?.toIso8601String(),
      'status': status,
      'notes': notes,
      'punch_in_latitude': punchInLatitude,
      'punch_in_longitude': punchInLongitude,
      'punch_out_latitude': punchOutLatitude,
      'punch_out_longitude': punchOutLongitude,
    };
  }

  /// Check if attendance is active (not punched out)
  bool get isActive => punchOutTime == null;

  /// Calculate work duration
  Duration? get workDuration {
    if (punchOutTime == null) return null;
    return punchOutTime!.difference(punchInTime);
  }

  /// Check if has punch in location
  bool get hasPunchInLocation =>
      punchInLatitude != null && punchInLongitude != null;

  /// Check if has punch out location
  bool get hasPunchOutLocation =>
      punchOutLatitude != null && punchOutLongitude != null;

  @override
  String toString() {
    return 'AttendanceModel(id: $id, status: $status, isActive: $isActive, hasPunchInLocation: $hasPunchInLocation)';
  }
}
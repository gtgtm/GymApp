class AttendanceRecord {
  const AttendanceRecord({
    required this.date,
    required this.status,
    this.checkInTime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      checkInTime: json['check_in_time'] as String?,
    );
  }

  final DateTime date;
  final String status;
  final String? checkInTime;
}

class MemberNotification {
  const MemberNotification({
    required this.id,
    required this.title,
    required this.createdAt,
    this.body,
    this.readAt,
  });

  factory MemberNotification.fromJson(Map<String, dynamic> json) {
    return MemberNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String?,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at'] as String) : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final int id;
  final String title;
  final String? body;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;
}

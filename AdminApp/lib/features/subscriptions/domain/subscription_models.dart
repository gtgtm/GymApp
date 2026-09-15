class Subscription {
  const Subscription({
    required this.plan,
    required this.memberLimit,
    required this.expiryDate,
    required this.paymentStatus,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      plan: json['plan'] as String,
      memberLimit: json['member_limit'] as int,
      expiryDate: json['expiry_date'] as String,
      paymentStatus: json['payment_status'] as String,
    );
  }

  final String plan;
  final int memberLimit;
  final String expiryDate;
  final String paymentStatus;
}

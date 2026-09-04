class PaymentRecord {
  const PaymentRecord({
    required this.receiptNumber,
    required this.amount,
    required this.method,
    required this.paidAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      receiptNumber: json['receipt_number'] as String,
      amount: double.parse(json['amount'].toString()),
      method: json['method'] as String,
      paidAt: DateTime.parse(json['paid_at'] as String),
    );
  }

  final String receiptNumber;
  final double amount;
  final String method;
  final DateTime paidAt;
}

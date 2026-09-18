class PaymentMemberRef {
  const PaymentMemberRef({
    required this.id,
    required this.fullName,
    required this.memberCode,
  });

  factory PaymentMemberRef.fromJson(Map<String, dynamic> json) {
    return PaymentMemberRef(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      memberCode: json['member_code'] as String,
    );
  }

  final int id;
  final String fullName;
  final String memberCode;
}

class Payment {
  const Payment({
    required this.id,
    required this.receiptNumber,
    required this.amount,
    required this.method,
    required this.status,
    required this.paidAt,
    this.member,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      receiptNumber: json['receipt_number'] as String,
      amount: json['amount'] as String,
      method: json['method'] as String,
      status: json['status'] as String,
      paidAt: json['paid_at'] as String,
      member: json['member'] == null
          ? null
          : PaymentMemberRef.fromJson(json['member'] as Map<String, dynamic>),
    );
  }

  final int id;
  final String receiptNumber;
  final String amount;
  final String method;
  final String status;
  final String paidAt;
  final PaymentMemberRef? member;
}

class PaymentInput {
  const PaymentInput({
    required this.memberId,
    required this.amount,
    required this.method,
    this.discount,
    this.tax,
  });

  final int memberId;
  final double amount;
  final String method;
  final double? discount;
  final double? tax;

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'amount': amount,
      'method': method,
      if (discount != null) 'discount': discount,
      if (tax != null) 'tax': tax,
    };
  }
}

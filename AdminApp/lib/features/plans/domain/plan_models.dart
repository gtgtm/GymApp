class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.totalAmount,
    required this.status,
    this.registrationFee,
    this.discount,
    this.tax,
    this.description,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      durationDays: json['duration_days'] as int,
      price: json['price'] as String,
      totalAmount: json['total_amount'] as String,
      status: json['status'] as String,
      registrationFee: json['registration_fee'] as String?,
      discount: json['discount'] as String?,
      tax: json['tax'] as String?,
      description: json['description'] as String?,
    );
  }

  final int id;
  final String name;
  final int durationDays;
  final String price;
  final String totalAmount;
  final String status;
  final String? registrationFee;
  final String? discount;
  final String? tax;
  final String? description;
}

class PlanInput {
  const PlanInput({
    required this.name,
    required this.durationDays,
    required this.price,
    this.registrationFee,
    this.discount,
    this.tax,
    this.description,
  });

  final String name;
  final int durationDays;
  final double price;
  final double? registrationFee;
  final double? discount;
  final double? tax;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'duration_days': durationDays,
      'price': price,
      if (registrationFee != null) 'registration_fee': registrationFee,
      if (discount != null) 'discount': discount,
      if (tax != null) 'tax': tax,
      if (description != null && description!.isNotEmpty) 'description': description,
    };
  }
}

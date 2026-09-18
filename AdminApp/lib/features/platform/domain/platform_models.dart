class GymSubscription {
  const GymSubscription({
    required this.plan,
    required this.paymentStatus,
    required this.expiryDate,
  });

  factory GymSubscription.fromJson(Map<String, dynamic> json) {
    return GymSubscription(
      plan: json['plan'] as String,
      paymentStatus: json['payment_status'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
    );
  }

  final String plan;
  final String paymentStatus;
  final DateTime expiryDate;
}

class GymSummary {
  const GymSummary({
    required this.id,
    required this.name,
    required this.slug,
    required this.status,
    required this.membersCount,
    required this.subscription,
  });

  factory GymSummary.fromJson(Map<String, dynamic> json) {
    final subscriptionJson = json['subscription'] as Map<String, dynamic>?;
    return GymSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      status: json['status'] as String,
      membersCount: json['members_count'] as int,
      subscription: subscriptionJson != null
          ? GymSubscription.fromJson(subscriptionJson)
          : null,
    );
  }

  final int id;
  final String name;
  final String slug;
  final String status;
  final int membersCount;
  final GymSubscription? subscription;
}

class GymDetail {
  const GymDetail({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.membersCount,
    required this.activeMembersCount,
    required this.subscription,
  });

  factory GymDetail.fromJson(Map<String, dynamic> json) {
    final subscriptionJson = json['subscription'] as Map<String, dynamic>?;
    return GymDetail(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      status: json['status'] as String,
      membersCount: json['members_count'] as int,
      activeMembersCount: json['active_members_count'] as int,
      subscription: subscriptionJson != null
          ? GymSubscription.fromJson(subscriptionJson)
          : null,
    );
  }

  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String status;
  final int membersCount;
  final int activeMembersCount;
  final GymSubscription? subscription;
}

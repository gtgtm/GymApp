enum ExpiryBucket { green, yellow, orange, red, unknown }

ExpiryBucket parseExpiryBucket(String? value) {
  return switch (value) {
    'green' => ExpiryBucket.green,
    'yellow' => ExpiryBucket.yellow,
    'orange' => ExpiryBucket.orange,
    'red' => ExpiryBucket.red,
    _ => ExpiryBucket.unknown,
  };
}

class MemberTrainerRef {
  const MemberTrainerRef({required this.id, required this.name});

  factory MemberTrainerRef.fromJson(Map<String, dynamic> json) {
    return MemberTrainerRef(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  final int id;
  final String name;
}

class CurrentMembership {
  const CurrentMembership({
    required this.planId,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory CurrentMembership.fromJson(Map<String, dynamic> json) {
    return CurrentMembership(
      planId: json['plan_id'] as int,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      status: json['status'] as String,
    );
  }

  final int planId;
  final String startDate;
  final String endDate;
  final String status;
}

class Member {
  const Member({
    required this.id,
    required this.memberCode,
    required this.fullName,
    required this.mobile,
    required this.email,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.joiningDate,
    required this.trainer,
    required this.heightCm,
    required this.weightKg,
    required this.bloodGroup,
    required this.notes,
    required this.status,
    required this.expiryBucket,
    required this.currentMembership,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int,
      memberCode: json['member_code'] as String,
      fullName: json['full_name'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      gender: json['gender'] as String?,
      address: json['address'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
      joiningDate: json['joining_date'] as String,
      trainer: json['trainer'] == null
          ? null
          : MemberTrainerRef.fromJson(json['trainer'] as Map<String, dynamic>),
      heightCm: json['height_cm'] as String?,
      weightKg: json['weight_kg'] as String?,
      bloodGroup: json['blood_group'] as String?,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      expiryBucket: parseExpiryBucket(json['expiry_bucket'] as String?),
      currentMembership: json['current_membership'] == null
          ? null
          : CurrentMembership.fromJson(
              json['current_membership'] as Map<String, dynamic>,
            ),
    );
  }

  final int id;
  final String memberCode;
  final String fullName;
  final String mobile;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String joiningDate;
  final MemberTrainerRef? trainer;
  final String? heightCm;
  final String? weightKg;
  final String? bloodGroup;
  final String? notes;
  final String status;
  final ExpiryBucket expiryBucket;
  final CurrentMembership? currentMembership;
}

class MemberListPage {
  const MemberListPage({required this.members, required this.total});

  final List<Member> members;
  final int total;
}

class MemberPayment {
  const MemberPayment({
    required this.id,
    required this.receiptNumber,
    required this.amount,
    required this.method,
    required this.status,
    required this.paidAt,
  });

  factory MemberPayment.fromJson(Map<String, dynamic> json) {
    return MemberPayment(
      id: json['id'] as int,
      receiptNumber: json['receipt_number'] as String,
      amount: json['amount'] as String,
      method: json['method'] as String,
      status: json['status'] as String,
      paidAt: json['paid_at'] as String,
    );
  }

  final int id;
  final String receiptNumber;
  final String amount;
  final String method;
  final String status;
  final String paidAt;
}

/// Fields accepted by POST/PUT /members. All optional except the required
/// ones enforced server-side (full_name, mobile, joining_date).
class MemberInput {
  const MemberInput({
    required this.fullName,
    required this.mobile,
    required this.joiningDate,
    this.email,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.trainerId,
    this.heightCm,
    this.weightKg,
    this.bloodGroup,
    this.notes,
    this.status,
    this.password,
  });

  final String fullName;
  final String mobile;
  final String joiningDate;
  final String? email;
  final String? dateOfBirth;
  final String? gender;
  final String? address;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final int? trainerId;
  final double? heightCm;
  final double? weightKg;
  final String? bloodGroup;
  final String? notes;
  final String? status;
  final String? password;

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'mobile': mobile,
      'joining_date': joiningDate,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
      if (gender != null) 'gender': gender,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (emergencyContactName != null && emergencyContactName!.isNotEmpty)
        'emergency_contact_name': emergencyContactName,
      if (emergencyContactPhone != null && emergencyContactPhone!.isNotEmpty)
        'emergency_contact_phone': emergencyContactPhone,
      if (trainerId != null) 'trainer_id': trainerId,
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      if (bloodGroup != null && bloodGroup!.isNotEmpty)
        'blood_group': bloodGroup,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (status != null) 'status': status,
      if (password != null && password!.isNotEmpty) 'password': password,
    };
  }
}

class RenewMembershipInput {
  const RenewMembershipInput({
    required this.membershipPlanId,
    required this.amountPaid,
    required this.paymentMethod,
    this.discount,
    this.tax,
  });

  final int membershipPlanId;
  final double amountPaid;
  final String paymentMethod;
  final double? discount;
  final double? tax;

  Map<String, dynamic> toJson() {
    return {
      'membership_plan_id': membershipPlanId,
      'amount_paid': amountPaid,
      'payment_method': paymentMethod,
      if (discount != null) 'discount': discount,
      if (tax != null) 'tax': tax,
    };
  }
}

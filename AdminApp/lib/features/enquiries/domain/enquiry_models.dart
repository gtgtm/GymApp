const enquiryStatuses = ['new', 'contacted', 'trial', 'follow_up', 'converted', 'lost'];

class EnquiryRef {
  const EnquiryRef({required this.id, required this.name});

  factory EnquiryRef.fromJson(Map<String, dynamic> json) {
    return EnquiryRef(id: json['id'] as int, name: json['name'] as String);
  }

  final int id;
  final String name;
}

class Enquiry {
  const Enquiry({
    required this.id,
    required this.name,
    required this.mobile,
    required this.email,
    required this.source,
    required this.followUpDate,
    required this.status,
    required this.notes,
    this.interestedPlan,
    this.assignedStaff,
  });

  factory Enquiry.fromJson(Map<String, dynamic> json) {
    return Enquiry(
      id: json['id'] as int,
      name: json['name'] as String,
      mobile: json['mobile'] as String,
      email: json['email'] as String?,
      source: json['source'] as String?,
      followUpDate: json['follow_up_date'] as String?,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      interestedPlan: json['interested_plan'] == null
          ? null
          : EnquiryRef.fromJson(json['interested_plan'] as Map<String, dynamic>),
      assignedStaff: json['assigned_staff'] == null
          ? null
          : EnquiryRef.fromJson(json['assigned_staff'] as Map<String, dynamic>),
    );
  }

  final int id;
  final String name;
  final String mobile;
  final String? email;
  final String? source;
  final String? followUpDate;
  final String status;
  final String? notes;
  final EnquiryRef? interestedPlan;
  final EnquiryRef? assignedStaff;
}

class EnquiryInput {
  const EnquiryInput({
    required this.name,
    required this.mobile,
    this.email,
    this.source,
    this.followUpDate,
    this.notes,
    this.status,
  });

  final String name;
  final String mobile;
  final String? email;
  final String? source;
  final String? followUpDate;
  final String? notes;
  final String? status;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      if (email != null && email!.isNotEmpty) 'email': email,
      if (source != null && source!.isNotEmpty) 'source': source,
      if (followUpDate != null) 'follow_up_date': followUpDate,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (status != null) 'status': status,
    };
  }
}

class ConversionStats {
  const ConversionStats({required this.total, required this.converted, required this.conversionRate});

  factory ConversionStats.fromJson(Map<String, dynamic> json) {
    return ConversionStats(
      total: json['total'] as int,
      converted: json['converted'] as int,
      conversionRate: (json['conversion_rate'] as num).toDouble(),
    );
  }

  final int total;
  final int converted;
  final double conversionRate;
}

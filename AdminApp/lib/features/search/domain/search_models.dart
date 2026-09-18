class SearchMemberResult {
  const SearchMemberResult({
    required this.id,
    required this.fullName,
    required this.mobile,
    required this.memberCode,
  });

  factory SearchMemberResult.fromJson(Map<String, dynamic> json) {
    return SearchMemberResult(
      id: json['id'] as int,
      fullName: json['full_name'] as String,
      mobile: json['mobile'] as String,
      memberCode: json['member_code'] as String,
    );
  }

  final int id;
  final String fullName;
  final String mobile;
  final String memberCode;
}

class SearchTrainerResult {
  const SearchTrainerResult({required this.id, required this.name, this.phone});

  factory SearchTrainerResult.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    return SearchTrainerResult(
      id: json['id'] as int,
      name: user?['name'] as String? ?? '',
      phone: user?['phone'] as String?,
    );
  }

  final int id;
  final String name;
  final String? phone;
}

class SearchPaymentResult {
  const SearchPaymentResult({
    required this.id,
    required this.receiptNumber,
    required this.amount,
  });

  factory SearchPaymentResult.fromJson(Map<String, dynamic> json) {
    return SearchPaymentResult(
      id: json['id'] as int,
      receiptNumber: json['receipt_number'] as String,
      amount: json['amount'] as String,
    );
  }

  final int id;
  final String receiptNumber;
  final String amount;
}

class SearchEnquiryResult {
  const SearchEnquiryResult({
    required this.id,
    required this.name,
    required this.status,
  });

  factory SearchEnquiryResult.fromJson(Map<String, dynamic> json) {
    return SearchEnquiryResult(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
    );
  }

  final int id;
  final String name;
  final String status;
}

class GlobalSearchResults {
  const GlobalSearchResults({
    required this.members,
    required this.trainers,
    required this.payments,
    required this.enquiries,
  });

  factory GlobalSearchResults.fromJson(Map<String, dynamic> json) {
    return GlobalSearchResults(
      members: (json['members'] as List<dynamic>)
          .map((e) => SearchMemberResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      trainers: (json['trainers'] as List<dynamic>)
          .map((e) => SearchTrainerResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      payments: (json['payments'] as List<dynamic>)
          .map((e) => SearchPaymentResult.fromJson(e as Map<String, dynamic>))
          .toList(),
      enquiries: (json['enquiries'] as List<dynamic>)
          .map((e) => SearchEnquiryResult.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<SearchMemberResult> members;
  final List<SearchTrainerResult> trainers;
  final List<SearchPaymentResult> payments;
  final List<SearchEnquiryResult> enquiries;

  bool get isEmpty =>
      members.isEmpty &&
      trainers.isEmpty &&
      payments.isEmpty &&
      enquiries.isEmpty;
}

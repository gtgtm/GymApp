class DashboardSummary {
  const DashboardSummary({
    required this.totalMembers,
    required this.activeMembers,
    required this.expiredMemberships,
    required this.expiringSoon,
    required this.todaysAttendance,
    required this.todaysNewMembers,
    required this.todaysRevenue,
    required this.monthlyRevenue,
    required this.pendingPayments,
    required this.monthlyExpenses,
    required this.monthlyNetProfit,
    required this.newEnquiries,
    required this.activeTrainers,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    num asNum(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value;
      return num.parse(value as String);
    }

    return DashboardSummary(
      totalMembers: asNum(json['total_members']).toInt(),
      activeMembers: asNum(json['active_members']).toInt(),
      expiredMemberships: asNum(json['expired_memberships']).toInt(),
      expiringSoon: asNum(json['expiring_soon']).toInt(),
      todaysAttendance: asNum(json['todays_attendance']).toInt(),
      todaysNewMembers: asNum(json['todays_new_members']).toInt(),
      todaysRevenue: asNum(json['todays_revenue']).toDouble(),
      monthlyRevenue: asNum(json['monthly_revenue']).toDouble(),
      pendingPayments: asNum(json['pending_payments']).toDouble(),
      monthlyExpenses: asNum(json['monthly_expenses']).toDouble(),
      monthlyNetProfit: asNum(json['monthly_net_profit']).toDouble(),
      newEnquiries: asNum(json['new_enquiries']).toInt(),
      activeTrainers: asNum(json['active_trainers']).toInt(),
    );
  }

  final int totalMembers;
  final int activeMembers;
  final int expiredMemberships;
  final int expiringSoon;
  final int todaysAttendance;
  final int todaysNewMembers;
  final double todaysRevenue;
  final double monthlyRevenue;
  final double pendingPayments;
  final double monthlyExpenses;
  final double monthlyNetProfit;
  final int newEnquiries;
  final int activeTrainers;
}

/// A membership nearing (or past) its end date — i.e. a renewal payment
/// the gym should collect. Built from the `/dashboard` response's
/// `expiring` buckets.
class RenewalDue {
  const RenewalDue({
    required this.membershipId,
    required this.memberId,
    required this.memberName,
    required this.endDate,
  });

  factory RenewalDue.fromJson(Map<String, dynamic> json) {
    final member = json['member'] as Map<String, dynamic>?;
    // end_date is serialized as UTC midnight ("2026-10-13T00:00:00Z"); only
    // the calendar date matters, so parse the date part to avoid a
    // timezone shift moving it by a day.
    final rawEndDate = json['end_date'] as String;

    return RenewalDue(
      membershipId: json['id'] as int,
      memberId: json['member_id'] as int,
      memberName: member?['full_name'] as String? ?? 'Unknown member',
      endDate: DateTime.parse(rawEndDate.substring(0, 10)),
    );
  }

  final int membershipId;
  final int memberId;
  final String memberName;
  final DateTime endDate;

  /// Negative when overdue, 0 when due today.
  int daysRemaining(DateTime today) {
    final todayDate = DateTime(today.year, today.month, today.day);
    return endDate.difference(todayDate).inDays;
  }
}

class DashboardData {
  const DashboardData({required this.summary, required this.renewals});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final buckets = json['expiring'] as Map<String, dynamic>? ?? const {};
    final renewals = [
      for (final bucket in buckets.values)
        for (final membership in bucket as List<dynamic>)
          RenewalDue.fromJson(membership as Map<String, dynamic>),
    ]..sort((a, b) => a.endDate.compareTo(b.endDate));

    return DashboardData(
      summary: DashboardSummary.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      renewals: List.unmodifiable(renewals),
    );
  }

  final DashboardSummary summary;
  final List<RenewalDue> renewals;
}

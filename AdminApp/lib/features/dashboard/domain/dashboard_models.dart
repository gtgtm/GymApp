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

class DashboardData {
  const DashboardData({required this.summary});

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      summary: DashboardSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  final DashboardSummary summary;
}

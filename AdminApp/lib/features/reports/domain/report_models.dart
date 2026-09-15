class FinancialSummary {
  const FinancialSummary({
    required this.revenue,
    required this.expenses,
    required this.profit,
    required this.paymentMethodBreakdown,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    final breakdown = json['payment_method_breakdown'] as Map<String, dynamic>? ?? {};
    return FinancialSummary(
      revenue: _asDouble(json['revenue']),
      expenses: _asDouble(json['expenses']),
      profit: _asDouble(json['profit']),
      paymentMethodBreakdown: breakdown.map((key, value) => MapEntry(key, _asDouble(value))),
    );
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.parse(value as String);
  }

  final double revenue;
  final double expenses;
  final double profit;
  final Map<String, double> paymentMethodBreakdown;
}

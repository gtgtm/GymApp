import 'package:intl/intl.dart';

final _rupees = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

/// "₹14,998" — Indian digit grouping, no paise.
String formatRupees(double value) => _rupees.format(value);

/// Up to two initials from a full name: "shashank kumar" -> "SK".
String initialsOf(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
  final initials = parts.take(2).map((p) => p[0].toUpperCase()).join();
  return initials.isEmpty ? '?' : initials;
}

/// "Due today", "Due tomorrow", "Due in 3 days", "Overdue by 2 days".
String dueLabel(int daysRemaining) {
  if (daysRemaining == 0) return 'Due today';
  if (daysRemaining == 1) return 'Due tomorrow';
  if (daysRemaining > 1) return 'Due in $daysRemaining days';
  final overdue = -daysRemaining;
  return 'Overdue by $overdue ${overdue == 1 ? 'day' : 'days'}';
}

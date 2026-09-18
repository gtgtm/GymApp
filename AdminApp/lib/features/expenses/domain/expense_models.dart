const expenseCategories = [
  'rent',
  'electricity',
  'equipment',
  'maintenance',
  'salary',
  'marketing',
  'cleaning',
  'other',
];

class Expense {
  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.description,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int,
      category: json['category'] as String,
      amount: json['amount'] as String,
      expenseDate: json['expense_date'] as String,
      description: json['description'] as String?,
    );
  }

  final int id;
  final String category;
  final String amount;
  final String expenseDate;
  final String? description;
}

class ExpenseInput {
  const ExpenseInput({
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.description,
  });

  final String category;
  final double amount;
  final String expenseDate;
  final String? description;

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
      'expense_date': expenseDate,
      if (description != null && description!.isNotEmpty)
        'description': description,
    };
  }
}

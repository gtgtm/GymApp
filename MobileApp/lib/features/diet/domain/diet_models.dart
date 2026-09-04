class DietMeal {
  const DietMeal({
    required this.mealSlot,
    required this.foodItem,
    this.quantity,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  factory DietMeal.fromJson(Map<String, dynamic> json) {
    return DietMeal(
      mealSlot: json['meal_slot'] as String,
      foodItem: json['food_item'] as String,
      quantity: json['quantity'] as String?,
      calories: json['calories'] != null ? double.tryParse(json['calories'].toString()) : null,
      proteinG: json['protein_g'] != null ? double.tryParse(json['protein_g'].toString()) : null,
      carbsG: json['carbs_g'] != null ? double.tryParse(json['carbs_g'].toString()) : null,
      fatG: json['fat_g'] != null ? double.tryParse(json['fat_g'].toString()) : null,
    );
  }

  final String mealSlot;
  final String foodItem;
  final String? quantity;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;
}

const mealSlotLabels = {
  'breakfast': 'Breakfast',
  'mid_morning': 'Mid Morning',
  'lunch': 'Lunch',
  'evening_snack': 'Evening Snack',
  'dinner': 'Dinner',
  'before_bed': 'Before Bed',
};

class DailyNutritionSummary {
  const DailyNutritionSummary({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory DailyNutritionSummary.fromJson(Map<String, dynamic> json) {
    return DailyNutritionSummary(
      calories: (json['calories'] as num).toDouble(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatG: (json['fat_g'] as num).toDouble(),
    );
  }

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

class DietPlan {
  const DietPlan({
    required this.id,
    required this.name,
    required this.status,
    required this.meals,
    required this.dailySummary,
    this.trainerName,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      trainerName: (json['trainer'] as Map<String, dynamic>?)?['user']?['name'] as String?,
      meals: (json['meals'] as List<dynamic>? ?? [])
          .map((item) => DietMeal.fromJson(item as Map<String, dynamic>))
          .toList(),
      dailySummary: DailyNutritionSummary.fromJson(json['daily_summary'] as Map<String, dynamic>),
    );
  }

  final int id;
  final String name;
  final String status;
  final String? trainerName;
  final List<DietMeal> meals;
  final DailyNutritionSummary dailySummary;
}

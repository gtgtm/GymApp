const mealSlots = [
  'breakfast',
  'mid_morning',
  'lunch',
  'evening_snack',
  'dinner',
  'before_bed',
];

String mealSlotLabel(String slot) {
  return switch (slot) {
    'breakfast' => 'Breakfast',
    'mid_morning' => 'Mid-Morning',
    'lunch' => 'Lunch',
    'evening_snack' => 'Evening Snack',
    'dinner' => 'Dinner',
    'before_bed' => 'Before Bed',
    _ => slot,
  };
}

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
    double? asDouble(dynamic value) => value == null ? null : num.parse('$value').toDouble();
    return DietMeal(
      mealSlot: json['meal_slot'] as String,
      foodItem: json['food_item'] as String,
      quantity: json['quantity'] as String?,
      calories: asDouble(json['calories']),
      proteinG: asDouble(json['protein_g']),
      carbsG: asDouble(json['carbs_g']),
      fatG: asDouble(json['fat_g']),
    );
  }

  final String mealSlot;
  final String foodItem;
  final String? quantity;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  Map<String, dynamic> toJson() {
    return {
      'meal_slot': mealSlot,
      'food_item': foodItem,
      if (quantity != null && quantity!.isNotEmpty) 'quantity': quantity,
      if (calories != null) 'calories': calories,
      if (proteinG != null) 'protein_g': proteinG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (fatG != null) 'fat_g': fatG,
    };
  }
}

class DietPlan {
  const DietPlan({
    required this.id,
    required this.memberId,
    required this.name,
    required this.status,
    required this.meals,
    this.notes,
  });

  factory DietPlan.fromJson(Map<String, dynamic> json) {
    return DietPlan(
      id: json['id'] as int,
      memberId: json['member_id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      meals: (json['meals'] as List<dynamic>? ?? [])
          .map((e) => DietMeal.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final int memberId;
  final String name;
  final String status;
  final String? notes;
  final List<DietMeal> meals;
}

class DietPlanInput {
  const DietPlanInput({
    required this.memberId,
    required this.name,
    required this.meals,
    this.trainerId,
    this.notes,
  });

  final int memberId;
  final String name;
  final List<DietMeal> meals;
  final int? trainerId;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'name': name,
      'meals': meals.map((m) => m.toJson()).toList(),
      if (trainerId != null) 'trainer_id': trainerId,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

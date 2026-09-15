const equipmentConditions = ['good', 'fair', 'needs_repair', 'out_of_service'];

class Equipment {
  const Equipment({
    required this.id,
    required this.name,
    this.category,
    this.condition,
    this.nextMaintenanceDate,
  });

  factory Equipment.fromJson(Map<String, dynamic> json) {
    return Equipment(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String?,
      condition: json['condition'] as String?,
      nextMaintenanceDate: json['next_maintenance_date'] as String?,
    );
  }

  final int id;
  final String name;
  final String? category;
  final String? condition;
  final String? nextMaintenanceDate;
}

class EquipmentInput {
  const EquipmentInput({required this.name, this.category, this.condition});

  final String name;
  final String? category;
  final String? condition;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (category != null && category!.isNotEmpty) 'category': category,
      if (condition != null) 'condition': condition,
    };
  }
}

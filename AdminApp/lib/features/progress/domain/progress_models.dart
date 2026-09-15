class BodyMeasurement {
  const BodyMeasurement({
    required this.id,
    required this.recordedDate,
    this.weightKg,
    this.heightCm,
    this.bodyFatPercent,
    this.chestCm,
    this.waistCm,
    this.armsCm,
    this.thighCm,
    this.hipsCm,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic value) => value == null ? null : num.parse('$value').toDouble();
    return BodyMeasurement(
      id: json['id'] as int,
      recordedDate: json['recorded_date'] as String,
      weightKg: asDouble(json['weight_kg']),
      heightCm: asDouble(json['height_cm']),
      bodyFatPercent: asDouble(json['body_fat_percent']),
      chestCm: asDouble(json['chest_cm']),
      waistCm: asDouble(json['waist_cm']),
      armsCm: asDouble(json['arms_cm']),
      thighCm: asDouble(json['thigh_cm']),
      hipsCm: asDouble(json['hips_cm']),
    );
  }

  final int id;
  final String recordedDate;
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercent;
  final double? chestCm;
  final double? waistCm;
  final double? armsCm;
  final double? thighCm;
  final double? hipsCm;
}

class BodyMeasurementInput {
  const BodyMeasurementInput({
    required this.memberId,
    required this.recordedDate,
    this.weightKg,
    this.heightCm,
    this.bodyFatPercent,
    this.chestCm,
    this.waistCm,
    this.armsCm,
    this.thighCm,
    this.hipsCm,
  });

  final int memberId;
  final String recordedDate;
  final double? weightKg;
  final double? heightCm;
  final double? bodyFatPercent;
  final double? chestCm;
  final double? waistCm;
  final double? armsCm;
  final double? thighCm;
  final double? hipsCm;

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'recorded_date': recordedDate,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (bodyFatPercent != null) 'body_fat_percent': bodyFatPercent,
      if (chestCm != null) 'chest_cm': chestCm,
      if (waistCm != null) 'waist_cm': waistCm,
      if (armsCm != null) 'arms_cm': armsCm,
      if (thighCm != null) 'thigh_cm': thighCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
    };
  }
}

class ProgressPhoto {
  const ProgressPhoto({
    required this.id,
    required this.url,
    required this.takenOn,
    this.type,
    this.notes,
  });

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    return ProgressPhoto(
      id: json['id'] as int,
      url: json['url'] as String,
      takenOn: json['taken_on'] as String,
      type: json['type'] as String?,
      notes: json['notes'] as String?,
    );
  }

  final int id;
  final String url;
  final String takenOn;
  final String? type;
  final String? notes;
}

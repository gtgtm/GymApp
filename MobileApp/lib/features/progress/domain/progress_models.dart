class BodyMeasurement {
  const BodyMeasurement({
    required this.recordedDate,
    this.weightKg,
    this.bmi,
    this.bodyFatPercent,
    this.chestCm,
    this.waistCm,
    this.armsCm,
    this.thighCm,
    this.hipsCm,
  });

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    double? parse(dynamic value) => value != null ? double.tryParse(value.toString()) : null;

    return BodyMeasurement(
      recordedDate: DateTime.parse(json['recorded_date'] as String),
      weightKg: parse(json['weight_kg']),
      bmi: parse(json['bmi']),
      bodyFatPercent: parse(json['body_fat_percent']),
      chestCm: parse(json['chest_cm']),
      waistCm: parse(json['waist_cm']),
      armsCm: parse(json['arms_cm']),
      thighCm: parse(json['thigh_cm']),
      hipsCm: parse(json['hips_cm']),
    );
  }

  final DateTime recordedDate;
  final double? weightKg;
  final double? bmi;
  final double? bodyFatPercent;
  final double? chestCm;
  final double? waistCm;
  final double? armsCm;
  final double? thighCm;
  final double? hipsCm;
}

class ProgressPhoto {
  const ProgressPhoto({
    required this.url,
    required this.type,
    required this.takenOn,
  });

  factory ProgressPhoto.fromJson(Map<String, dynamic> json) {
    return ProgressPhoto(
      url: json['url'] as String,
      type: json['type'] as String,
      takenOn: DateTime.parse(json['taken_on'] as String),
    );
  }

  final String url;
  final String type;
  final DateTime takenOn;
}

class ProgressData {
  const ProgressData({required this.measurements, required this.photos});

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      measurements: (json['measurements'] as List<dynamic>? ?? [])
          .map((item) => BodyMeasurement.fromJson(item as Map<String, dynamic>))
          .toList(),
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map((item) => ProgressPhoto.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<BodyMeasurement> measurements;
  final List<ProgressPhoto> photos;
}

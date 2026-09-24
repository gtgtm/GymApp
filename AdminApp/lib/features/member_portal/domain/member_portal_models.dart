import 'package:gymapp_admin/features/members/domain/member_models.dart';

/// Models for the member-facing `/me/*` API (MemberPortalController on the
/// backend). Ported from the standalone member app, with parsing fixed to
/// match the live payloads (e.g. progress photos carry `photo_path`, not
/// `url`).

double? _toDouble(dynamic value) =>
    value == null ? null : double.tryParse(value.toString());

/// Parses a date that may be "2026-09-24" or a UTC-midnight timestamp;
/// only the calendar date is meaningful, so the time part is dropped to
/// avoid a timezone shift moving it by a day.
DateTime _toDate(String value) => DateTime.parse(value.substring(0, 10));

class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.memberCode,
    required this.fullName,
    required this.mobile,
    required this.status,
    required this.expiryBucket,
    this.email,
    this.trainerName,
    this.joiningDate,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    final joining = json['joining_date'] as String?;

    return MemberProfile(
      id: json['id'] as int,
      memberCode: json['member_code'] as String,
      fullName: json['full_name'] as String,
      mobile: json['mobile'] as String? ?? '',
      status: json['status'] as String? ?? '',
      expiryBucket: parseExpiryBucket(json['expiry_bucket'] as String?),
      email: json['email'] as String?,
      trainerName:
          (json['trainer'] as Map<String, dynamic>?)?['name'] as String?,
      joiningDate: joining == null ? null : _toDate(joining),
    );
  }

  final int id;
  final String memberCode;
  final String fullName;
  final String mobile;
  final String status;
  final ExpiryBucket expiryBucket;
  final String? email;
  final String? trainerName;
  final DateTime? joiningDate;
}

class MembershipPeriod {
  const MembershipPeriod({
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.planName,
  });

  factory MembershipPeriod.fromJson(Map<String, dynamic> json) {
    return MembershipPeriod(
      id: json['id'] as int,
      startDate: _toDate(json['start_date'] as String),
      endDate: _toDate(json['end_date'] as String),
      status: json['status'] as String,
      planName: (json['plan'] as Map<String, dynamic>?)?['name'] as String?,
    );
  }

  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? planName;

  int daysRemaining(DateTime today) =>
      endDate.difference(DateTime(today.year, today.month, today.day)).inDays;
}

class MembershipDetails {
  const MembershipDetails({
    required this.current,
    required this.history,
    required this.expiryBucket,
  });

  factory MembershipDetails.fromJson(Map<String, dynamic> json) {
    final history = [
      for (final item in json['history'] as List<dynamic>? ?? const [])
        MembershipPeriod.fromJson(item as Map<String, dynamic>),
    ];
    final currentJson = json['current'] as Map<String, dynamic>?;
    var current = currentJson == null
        ? null
        : MembershipPeriod.fromJson(currentJson);

    // `current` is sent without its plan; the same row in `history` has it.
    if (current != null && current.planName == null) {
      final match = history.where((period) => period.id == current!.id);
      if (match.isNotEmpty) current = match.first;
    }

    return MembershipDetails(
      current: current,
      history: List.unmodifiable(history),
      expiryBucket: parseExpiryBucket(json['expiry_bucket'] as String?),
    );
  }

  final MembershipPeriod? current;
  final List<MembershipPeriod> history;
  final ExpiryBucket expiryBucket;
}

class MemberQrCode {
  const MemberQrCode({required this.qrToken, required this.memberCode});

  factory MemberQrCode.fromJson(Map<String, dynamic> json) {
    return MemberQrCode(
      qrToken: json['qr_token'] as String,
      memberCode: json['member_code'] as String,
    );
  }

  final String qrToken;
  final String memberCode;
}

class MemberAttendanceRecord {
  const MemberAttendanceRecord({
    required this.date,
    required this.status,
    this.checkInTime,
  });

  factory MemberAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return MemberAttendanceRecord(
      date: _toDate(json['date'] as String),
      status: json['status'] as String,
      checkInTime: json['check_in_time'] as String?,
    );
  }

  final DateTime date;
  final String status;

  /// "HH:mm:ss".
  final String? checkInTime;
}

class MemberPaymentRecord {
  const MemberPaymentRecord({
    required this.receiptNumber,
    required this.amount,
    required this.method,
    required this.paidAt,
  });

  factory MemberPaymentRecord.fromJson(Map<String, dynamic> json) {
    return MemberPaymentRecord(
      receiptNumber: json['receipt_number'] as String,
      amount: _toDouble(json['amount']) ?? 0,
      method: json['method'] as String,
      paidAt: DateTime.parse(json['paid_at'] as String),
    );
  }

  final String receiptNumber;
  final double amount;
  final String method;
  final DateTime paidAt;
}

class MemberNotification {
  const MemberNotification({
    required this.id,
    required this.title,
    required this.createdAt,
    this.body,
    this.readAt,
  });

  factory MemberNotification.fromJson(Map<String, dynamic> json) {
    final readAt = json['read_at'] as String?;

    return MemberNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String?,
      readAt: readAt == null ? null : DateTime.parse(readAt),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final int id;
  final String title;
  final String? body;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isUnread => readAt == null;
}

class PortalExercise {
  const PortalExercise({
    required this.dayNumber,
    required this.exerciseName,
    this.dayLabel,
    this.muscleGroup,
    this.sets,
    this.reps,
    this.weightKg,
    this.restSeconds,
    this.trainerNotes,
  });

  factory PortalExercise.fromJson(Map<String, dynamic> json) {
    return PortalExercise(
      dayNumber: json['day_number'] as int,
      dayLabel: json['day_label'] as String?,
      exerciseName: json['exercise_name'] as String,
      muscleGroup: json['muscle_group'] as String?,
      sets: json['sets'] as int?,
      reps: json['reps'] as String?,
      weightKg: _toDouble(json['weight_kg']),
      restSeconds: json['rest_seconds'] as int?,
      trainerNotes: json['trainer_notes'] as String?,
    );
  }

  final int dayNumber;
  final String? dayLabel;
  final String exerciseName;
  final String? muscleGroup;
  final int? sets;
  final String? reps;
  final double? weightKg;
  final int? restSeconds;
  final String? trainerNotes;

  /// "3 sets × 10 @ 20kg", skipping whatever isn't set.
  String get prescription => [
    if (sets != null) '$sets sets',
    if (reps != null) '× $reps',
    if (weightKg != null) '@ ${_trimZero(weightKg!)}kg',
  ].join(' ');
}

String _trimZero(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

String? _trainerName(Map<String, dynamic> json) {
  final trainer = json['trainer'] as Map<String, dynamic>?;
  return (trainer?['user'] as Map<String, dynamic>?)?['name'] as String?;
}

class PortalWorkoutPlan {
  const PortalWorkoutPlan({
    required this.id,
    required this.name,
    required this.status,
    required this.exercises,
    this.trainerName,
  });

  factory PortalWorkoutPlan.fromJson(Map<String, dynamic> json) {
    return PortalWorkoutPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      trainerName: _trainerName(json),
      exercises: List.unmodifiable([
        for (final item in json['exercises'] as List<dynamic>? ?? const [])
          PortalExercise.fromJson(item as Map<String, dynamic>),
      ]),
    );
  }

  final int id;
  final String name;
  final String status;
  final String? trainerName;
  final List<PortalExercise> exercises;

  /// Exercises grouped by day number, days in ascending order.
  List<(int day, List<PortalExercise> exercises)> get days {
    final byDay = <int, List<PortalExercise>>{};
    for (final exercise in exercises) {
      byDay.putIfAbsent(exercise.dayNumber, () => []).add(exercise);
    }
    final sortedDays = byDay.keys.toList()..sort();
    return [for (final day in sortedDays) (day, byDay[day]!)];
  }
}

const mealSlotLabels = {
  'breakfast': 'Breakfast',
  'mid_morning': 'Mid morning',
  'lunch': 'Lunch',
  'evening_snack': 'Evening snack',
  'dinner': 'Dinner',
  'before_bed': 'Before bed',
};

class PortalMeal {
  const PortalMeal({
    required this.mealSlot,
    required this.foodItem,
    this.quantity,
    this.calories,
    this.proteinG,
    this.carbsG,
    this.fatG,
  });

  factory PortalMeal.fromJson(Map<String, dynamic> json) {
    return PortalMeal(
      mealSlot: json['meal_slot'] as String,
      foodItem: json['food_item'] as String,
      quantity: json['quantity'] as String?,
      calories: _toDouble(json['calories']),
      proteinG: _toDouble(json['protein_g']),
      carbsG: _toDouble(json['carbs_g']),
      fatG: _toDouble(json['fat_g']),
    );
  }

  final String mealSlot;
  final String foodItem;
  final String? quantity;
  final double? calories;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  String get slotLabel => mealSlotLabels[mealSlot] ?? mealSlot;
}

class NutritionTotals {
  const NutritionTotals({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  factory NutritionTotals.fromJson(Map<String, dynamic>? json) {
    return NutritionTotals(
      calories: _toDouble(json?['calories']) ?? 0,
      proteinG: _toDouble(json?['protein_g']) ?? 0,
      carbsG: _toDouble(json?['carbs_g']) ?? 0,
      fatG: _toDouble(json?['fat_g']) ?? 0,
    );
  }

  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

class PortalDietPlan {
  const PortalDietPlan({
    required this.id,
    required this.name,
    required this.status,
    required this.meals,
    required this.dailyTotals,
    this.trainerName,
  });

  factory PortalDietPlan.fromJson(Map<String, dynamic> json) {
    return PortalDietPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      trainerName: _trainerName(json),
      meals: List.unmodifiable([
        for (final item in json['meals'] as List<dynamic>? ?? const [])
          PortalMeal.fromJson(item as Map<String, dynamic>),
      ]),
      dailyTotals: NutritionTotals.fromJson(
        json['daily_summary'] as Map<String, dynamic>?,
      ),
    );
  }

  final int id;
  final String name;
  final String status;
  final String? trainerName;
  final List<PortalMeal> meals;
  final NutritionTotals dailyTotals;
}

class PortalMeasurement {
  const PortalMeasurement({
    required this.recordedDate,
    this.weightKg,
    this.bmi,
    this.bodyFatPercent,
    this.chestCm,
    this.waistCm,
    this.armsCm,
  });

  factory PortalMeasurement.fromJson(Map<String, dynamic> json) {
    return PortalMeasurement(
      recordedDate: _toDate(json['recorded_date'] as String),
      weightKg: _toDouble(json['weight_kg']),
      bmi: _toDouble(json['bmi']),
      bodyFatPercent: _toDouble(json['body_fat_percent']),
      chestCm: _toDouble(json['chest_cm']),
      waistCm: _toDouble(json['waist_cm']),
      armsCm: _toDouble(json['arms_cm']),
    );
  }

  final DateTime recordedDate;
  final double? weightKg;
  final double? bmi;
  final double? bodyFatPercent;
  final double? chestCm;
  final double? waistCm;
  final double? armsCm;
}

class PortalProgress {
  const PortalProgress({required this.measurements, required this.photoCount});

  factory PortalProgress.fromJson(Map<String, dynamic> json) {
    final measurements = [
      for (final item in json['measurements'] as List<dynamic>? ?? const [])
        PortalMeasurement.fromJson(item as Map<String, dynamic>),
    ]..sort((a, b) => a.recordedDate.compareTo(b.recordedDate));

    return PortalProgress(
      measurements: List.unmodifiable(measurements),
      photoCount: (json['photos'] as List<dynamic>? ?? const []).length,
    );
  }

  /// Oldest first.
  final List<PortalMeasurement> measurements;
  final int photoCount;
}

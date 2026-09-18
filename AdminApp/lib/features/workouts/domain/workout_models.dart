class WorkoutExercise {
  const WorkoutExercise({
    required this.dayNumber,
    required this.exerciseName,
    this.dayLabel,
    this.muscleGroup,
    this.sets,
    this.reps,
    this.weightKg,
    this.restSeconds,
    this.instructions,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      dayNumber: json['day_number'] as int,
      dayLabel: json['day_label'] as String?,
      exerciseName: json['exercise_name'] as String,
      muscleGroup: json['muscle_group'] as String?,
      sets: json['sets'] as int?,
      reps: json['reps'] as String?,
      weightKg: json['weight_kg'] == null
          ? null
          : num.parse('${json['weight_kg']}').toDouble(),
      restSeconds: json['rest_seconds'] as int?,
      instructions: json['instructions'] as String?,
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
  final String? instructions;

  Map<String, dynamic> toJson() {
    return {
      'day_number': dayNumber,
      if (dayLabel != null && dayLabel!.isNotEmpty) 'day_label': dayLabel,
      'exercise_name': exerciseName,
      if (muscleGroup != null && muscleGroup!.isNotEmpty)
        'muscle_group': muscleGroup,
      if (sets != null) 'sets': sets,
      if (reps != null && reps!.isNotEmpty) 'reps': reps,
      if (weightKg != null) 'weight_kg': weightKg,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (instructions != null && instructions!.isNotEmpty)
        'instructions': instructions,
    };
  }
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.memberId,
    required this.name,
    required this.status,
    required this.exercises,
    this.notes,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as int,
      memberId: json['member_id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      notes: json['notes'] as String?,
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((e) => WorkoutExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final int memberId;
  final String name;
  final String status;
  final String? notes;
  final List<WorkoutExercise> exercises;
}

class WorkoutPlanInput {
  const WorkoutPlanInput({
    required this.memberId,
    required this.name,
    required this.exercises,
    this.trainerId,
    this.notes,
  });

  final int memberId;
  final String name;
  final List<WorkoutExercise> exercises;
  final int? trainerId;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'member_id': memberId,
      'name': name,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      if (trainerId != null) 'trainer_id': trainerId,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

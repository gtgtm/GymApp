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
    this.videoUrl,
    this.trainerNotes,
  });

  factory WorkoutExercise.fromJson(Map<String, dynamic> json) {
    return WorkoutExercise(
      dayNumber: json['day_number'] as int,
      dayLabel: json['day_label'] as String?,
      exerciseName: json['exercise_name'] as String,
      muscleGroup: json['muscle_group'] as String?,
      sets: json['sets'] as int?,
      reps: json['reps'] as String?,
      weightKg: json['weight_kg'] != null ? double.tryParse(json['weight_kg'].toString()) : null,
      restSeconds: json['rest_seconds'] as int?,
      instructions: json['instructions'] as String?,
      videoUrl: json['video_url'] as String?,
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
  final String? instructions;
  final String? videoUrl;
  final String? trainerNotes;
}

class WorkoutPlan {
  const WorkoutPlan({
    required this.id,
    required this.name,
    required this.status,
    required this.exercises,
    this.trainerName,
  });

  factory WorkoutPlan.fromJson(Map<String, dynamic> json) {
    return WorkoutPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      trainerName: (json['trainer'] as Map<String, dynamic>?)?['user']?['name'] as String?,
      exercises: (json['exercises'] as List<dynamic>? ?? [])
          .map((item) => WorkoutExercise.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String name;
  final String status;
  final String? trainerName;
  final List<WorkoutExercise> exercises;

  Map<int, List<WorkoutExercise>> get exercisesByDay {
    final map = <int, List<WorkoutExercise>>{};
    for (final exercise in exercises) {
      map.putIfAbsent(exercise.dayNumber, () => []).add(exercise);
    }
    return map;
  }
}

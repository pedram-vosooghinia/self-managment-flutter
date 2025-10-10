import 'package:hive/hive.dart';

part 'workout_model.g.dart';

@HiveType(typeId: 7)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  List<String> imagePaths; // Paths to locally stored images

  @HiveField(4)
  String? durationOrReps; // e.g., "3 sets x 12 reps" or "30 minutes"

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? lastPerformed;

  @HiveField(7)
  int timesCompleted;

  WorkoutModel({
    required this.id,
    required this.title,
    this.description,
    List<String>? imagePaths,
    this.durationOrReps,
    required this.createdAt,
    this.lastPerformed,
    this.timesCompleted = 0,
  }) : imagePaths = imagePaths ?? [];

  WorkoutModel copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? imagePaths,
    String? durationOrReps,
    DateTime? createdAt,
    DateTime? lastPerformed,
    int? timesCompleted,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imagePaths: imagePaths ?? this.imagePaths,
      durationOrReps: durationOrReps ?? this.durationOrReps,
      createdAt: createdAt ?? this.createdAt,
      lastPerformed: lastPerformed ?? this.lastPerformed,
      timesCompleted: timesCompleted ?? this.timesCompleted,
    );
  }

  String get displayDurationOrReps {
    return durationOrReps?.isNotEmpty == true ? durationOrReps! : 'Not specified';
  }

  bool get hasImages {
    return imagePaths.isNotEmpty;
  }
}


import 'package:hive/hive.dart';
import '../models/workout_model.dart';
import '../../core/services/hive_service.dart';

class WorkoutRepository {
  late Box<WorkoutModel> _box;

  WorkoutRepository() {
    _box = HiveService.workoutsBoxInstance;
  }

  // Create
  Future<void> addWorkout(WorkoutModel workout) async {
    await _box.put(workout.id, workout);
  }

  // Read
  List<WorkoutModel> getAllWorkouts() {
    return _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  WorkoutModel? getWorkoutById(String id) {
    return _box.get(id);
  }

  List<WorkoutModel> searchWorkouts(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((workout) {
      return workout.title.toLowerCase().contains(lowerQuery) ||
          (workout.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<WorkoutModel> getRecentWorkouts({int limit = 5}) {
    final workouts = _box.values.toList();
    workouts.sort((a, b) {
      if (a.lastPerformed == null && b.lastPerformed == null) {
        return b.createdAt.compareTo(a.createdAt);
      }
      if (a.lastPerformed == null) return 1;
      if (b.lastPerformed == null) return -1;
      return b.lastPerformed!.compareTo(a.lastPerformed!);
    });
    return workouts.take(limit).toList();
  }

  // Update
  Future<void> updateWorkout(WorkoutModel workout) async {
    await _box.put(workout.id, workout);
  }

  Future<void> markAsPerformed(String id) async {
    final workout = _box.get(id);
    if (workout != null) {
      workout.lastPerformed = DateTime.now();
      workout.timesCompleted += 1;
      await workout.save();
    }
  }

  // Delete
  Future<void> deleteWorkout(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAllWorkouts() async {
    await _box.clear();
  }

  // Stream for real-time updates
  Stream<List<WorkoutModel>> watchWorkouts() {
    return _box.watch().map((_) => getAllWorkouts());
  }
}


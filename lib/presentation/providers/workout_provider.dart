import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/workout_model.dart';
import '../../data/repositories/workout_repository.dart';

class WorkoutProvider extends ChangeNotifier {
  final WorkoutRepository _workoutRepository;

  WorkoutProvider({
    required WorkoutRepository workoutRepository,
  }) : _workoutRepository = workoutRepository;

  List<WorkoutModel> _workouts = [];
  bool _isLoading = false;

  List<WorkoutModel> get workouts => _workouts;
  bool get isLoading => _isLoading;

  List<WorkoutModel> get recentWorkouts => _workoutRepository.getRecentWorkouts();

  void loadWorkouts() {
    _isLoading = true;
    notifyListeners();

    _workouts = _workoutRepository.getAllWorkouts();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addWorkout({
    required String title,
    String? description,
    List<String>? imagePaths,
    String? durationOrReps,
  }) async {
    final workout = WorkoutModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      imagePaths: imagePaths,
      durationOrReps: durationOrReps,
      createdAt: DateTime.now(),
    );

    await _workoutRepository.addWorkout(workout);
    loadWorkouts();
  }

  Future<void> updateWorkout(WorkoutModel workout) async {
    await _workoutRepository.updateWorkout(workout);
    loadWorkouts();
  }

  Future<void> deleteWorkout(String id) async {
    await _workoutRepository.deleteWorkout(id);
    loadWorkouts();
  }

  Future<void> markAsPerformed(String id) async {
    await _workoutRepository.markAsPerformed(id);
    loadWorkouts();
  }

  Future<void> deleteAllWorkouts() async {
    await _workoutRepository.deleteAllWorkouts();
    loadWorkouts();
  }

  WorkoutModel? getWorkoutById(String id) {
    return _workoutRepository.getWorkoutById(id);
  }

  List<WorkoutModel> searchWorkouts(String query) {
    return _workoutRepository.searchWorkouts(query);
  }
}


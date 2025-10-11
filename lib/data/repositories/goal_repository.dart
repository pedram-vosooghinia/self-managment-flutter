import 'package:hive/hive.dart';
import '../models/goal_model.dart';
import '../../core/services/hive_service.dart';

class GoalRepository {
  late Box<GoalModel> _box;

  GoalRepository() {
    _box = HiveService.goalsBoxInstance;
  }

  // Create
  Future<void> addGoal(GoalModel goal) async {
    await _box.put(goal.id, goal);
  }

  // Read
  List<GoalModel> getAllGoals() {
    return _box.values.toList();
  }

  GoalModel? getGoalById(String id) {
    return _box.get(id);
  }

  List<GoalModel> getShortTermGoals() {
    return _box.values
        .where((goal) => goal.type == GoalType.shortTerm)
        .toList();
  }

  List<GoalModel> getLongTermGoals() {
    return _box.values.where((goal) => goal.type == GoalType.longTerm).toList();
  }

  List<GoalModel> getCompletedGoals() {
    return _box.values.where((goal) => goal.isCompleted).toList();
  }

  List<GoalModel> getActiveGoals() {
    return _box.values.where((goal) => !goal.isCompleted).toList();
  }

  // Update
  Future<void> updateGoal(GoalModel goal) async {
    await _box.put(goal.id, goal);
  }

  Future<void> toggleGoalCompletion(String id) async {
    final goal = _box.get(id);
    if (goal != null) {
      goal.isCompleted = !goal.isCompleted;
      await goal.save();
    }
  }

  // Delete
  Future<void> deleteGoal(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAllGoals() async {
    await _box.clear();
  }

  // Stream for real-time updates
  Stream<List<GoalModel>> watchGoals() {
    return _box.watch().map((_) => getAllGoals());
  }
}

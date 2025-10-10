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
    return _box.values
        .where((goal) => goal.type == GoalType.longTerm)
        .toList();
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

  Future<void> addSubTask(String goalId, SubTask subTask) async {
    final goal = _box.get(goalId);
    if (goal != null) {
      goal.subTasks.add(subTask);
      await goal.save();
    }
  }

  Future<void> updateSubTask(String goalId, SubTask updatedSubTask) async {
    final goal = _box.get(goalId);
    if (goal != null) {
      final index = goal.subTasks.indexWhere((st) => st.id == updatedSubTask.id);
      if (index != -1) {
        goal.subTasks[index] = updatedSubTask;
        await goal.save();
      }
    }
  }

  Future<void> deleteSubTask(String goalId, String subTaskId) async {
    final goal = _box.get(goalId);
    if (goal != null) {
      goal.subTasks.removeWhere((st) => st.id == subTaskId);
      await goal.save();
    }
  }

  Future<void> toggleSubTaskCompletion(String goalId, String subTaskId) async {
    final goal = _box.get(goalId);
    if (goal != null) {
      final subTask = goal.subTasks.firstWhere((st) => st.id == subTaskId);
      final index = goal.subTasks.indexOf(subTask);
      goal.subTasks[index] = subTask.copyWith(isCompleted: !subTask.isCompleted);
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


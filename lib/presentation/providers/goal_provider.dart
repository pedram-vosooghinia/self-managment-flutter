import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/goal_model.dart';
import '../../data/repositories/goal_repository.dart';
import '../../data/repositories/reminder_repository.dart';

class GoalProvider extends ChangeNotifier {
  final GoalRepository _goalRepository;
  final ReminderRepository _reminderRepository;

  GoalProvider({
    required GoalRepository goalRepository,
    required ReminderRepository reminderRepository,
  })  : _goalRepository = goalRepository,
        _reminderRepository = reminderRepository;

  List<GoalModel> _goals = [];
  bool _isLoading = false;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;

  List<GoalModel> get shortTermGoals => _goalRepository.getShortTermGoals();
  List<GoalModel> get longTermGoals => _goalRepository.getLongTermGoals();
  List<GoalModel> get completedGoals => _goalRepository.getCompletedGoals();
  List<GoalModel> get activeGoals => _goalRepository.getActiveGoals();

  void loadGoals() {
    _isLoading = true;
    notifyListeners();

    _goals = _goalRepository.getAllGoals();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addGoal({
    required String title,
    String? description,
    required GoalType type,
    DateTime? targetDate,
    DateTime? reminderDateTime,
    String? alarmSoundId,
    String? notes,
  }) async {
    final goal = GoalModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      type: type,
      createdAt: DateTime.now(),
      targetDate: targetDate,
      reminderDateTime: reminderDateTime,
      alarmSoundId: alarmSoundId,
      notes: notes,
    );

    await _goalRepository.addGoal(goal);
    loadGoals();
  }

  Future<void> updateGoal(GoalModel goal) async {
    await _goalRepository.updateGoal(goal);
    loadGoals();
  }

  Future<void> toggleGoalCompletion(String id) async {
    await _goalRepository.toggleGoalCompletion(id);
    loadGoals();
  }

  Future<void> deleteGoal(String id) async {
    await _goalRepository.deleteGoal(id);
    await _reminderRepository.deleteRemindersByItemId(id);
    loadGoals();
  }

  Future<void> deleteAllGoals() async {
    await _goalRepository.deleteAllGoals();
    loadGoals();
  }

  Future<void> addSubTask(String goalId, String title) async {
    final subTask = SubTask(
      id: const Uuid().v4(),
      title: title,
    );
    await _goalRepository.addSubTask(goalId, subTask);
    loadGoals();
  }

  Future<void> updateSubTask(String goalId, SubTask subTask) async {
    await _goalRepository.updateSubTask(goalId, subTask);
    loadGoals();
  }

  Future<void> deleteSubTask(String goalId, String subTaskId) async {
    await _goalRepository.deleteSubTask(goalId, subTaskId);
    loadGoals();
  }

  Future<void> toggleSubTaskCompletion(String goalId, String subTaskId) async {
    await _goalRepository.toggleSubTaskCompletion(goalId, subTaskId);
    loadGoals();
  }

  GoalModel? getGoalById(String id) {
    return _goalRepository.getGoalById(id);
  }
}


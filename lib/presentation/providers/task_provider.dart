import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/reminder_repository.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final ReminderRepository _reminderRepository;

  TaskProvider({
    required TaskRepository taskRepository,
    required ReminderRepository reminderRepository,
  })  : _taskRepository = taskRepository,
        _reminderRepository = reminderRepository;

  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  List<TaskModel> get todayTasks => _taskRepository.getTodayTasks();
  List<TaskModel> get upcomingTasks => _taskRepository.getUpcomingTasks();
  List<TaskModel> get completedTasks => _taskRepository.getCompletedTasks();
  List<TaskModel> get incompleteTasks => _taskRepository.getIncompleteTasks();
  List<TaskModel> get overdueTasks => _taskRepository.getOverdueTasks();

  void loadTasks() {
    _isLoading = true;
    notifyListeners();

    _tasks = _taskRepository.getAllTasks();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask({
    required String title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderDateTime,
    String? alarmSoundId,
    int priority = 1,
  }) async {
    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      reminderDateTime: reminderDateTime,
      alarmSoundId: alarmSoundId,
      priority: priority,
    );

    await _taskRepository.addTask(task);
    loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskRepository.updateTask(task);
    loadTasks();
  }

  Future<void> toggleTaskCompletion(String id) async {
    await _taskRepository.toggleTaskCompletion(id);
    loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _taskRepository.deleteTask(id);
    await _reminderRepository.deleteRemindersByItemId(id);
    loadTasks();
  }

  Future<void> deleteAllTasks() async {
    await _taskRepository.deleteAllTasks();
    loadTasks();
  }

  TaskModel? getTaskById(String id) {
    return _taskRepository.getTaskById(id);
  }
}


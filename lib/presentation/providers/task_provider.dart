import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../core/services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _repository;
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  TaskProvider({required TaskRepository taskRepository})
    : _repository = taskRepository;

  // Getters
  List<TaskModel> get allTasks => _tasks;
  bool get isLoading => _isLoading;

  List<TaskModel> get todayTasks => _repository.getTodayTasks();
  List<TaskModel> get upcomingTasks => _repository.getUpcomingTasks();
  List<TaskModel> get completedTasks => _repository.getCompletedTasks();
  List<TaskModel> get incompleteTasks => _repository.getIncompleteTasks();
  List<TaskModel> get overdueTasks => _repository.getOverdueTasks();

  // Load tasks
  void loadTasks() {
    _isLoading = true;
    notifyListeners();

    _tasks = _repository.getAllTasks();
    _isLoading = false;
    notifyListeners();
  }

  // Add task
  Future<void> addTask({
    required String title,
    DateTime? reminderDateTime,
    bool isRecurring = false,
    DateTime? recurringTime,
  }) async {
    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      createdAt: DateTime.now(),
      reminderDateTime: reminderDateTime,
      isRecurring: isRecurring,
      recurringTime: recurringTime,
    );

    await _repository.addTask(task);

    // تنظیم آلارم اگر زمان یادآوری مشخص شده باشد
    if (reminderDateTime != null) {
      await NotificationService.showNotification(
        id: task.id,
        title: task.title,
        scheduledDate: reminderDateTime,
      );
    }

    loadTasks();
  }

  // Update task
  Future<void> updateTask(TaskModel task) async {
    // لغو آلارم قبلی
    await NotificationService.cancelNotification(task.id);

    await _repository.updateTask(task);

    // تنظیم آلارم جدید اگر زمان یادآوری مشخص شده باشد
    if (task.reminderDateTime != null) {
      await NotificationService.showNotification(
        id: task.id,
        title: task.title,
        scheduledDate: task.reminderDateTime!,
      );
    }

    loadTasks();
  }

  // Toggle completion
  Future<void> toggleTaskCompletion(String id) async {
    await _repository.toggleTaskCompletion(id);
    loadTasks();
  }

  // Delete task
  Future<void> deleteTask(String id) async {
    // لغو آلارم قبل از حذف تسک
    await NotificationService.cancelNotification(id);

    await _repository.deleteTask(id);
    loadTasks();
  }

  // تست سیستم آلارم (برای 10 ثانیه بعد)
  Future<void> testAlarm() async {
    final testTime = DateTime.now().add(const Duration(seconds: 10));
    await NotificationService.showNotification(
      id: 'test_alarm',
      title: 'تست آلارم',
      scheduledDate: testTime,
    );
  }
}

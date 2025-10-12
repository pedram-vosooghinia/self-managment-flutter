import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/task_model.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/reminder_repository.dart';
import '../../data/repositories/alarm_sound_repository.dart';
import '../../core/services/recurring_task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;
  final ReminderRepository _reminderRepository;
  // ignore: unused_field
  final AlarmSoundRepository _alarmSoundRepository;
  late final RecurringTaskService _recurringTaskService;

  TaskProvider({
    required TaskRepository taskRepository,
    required ReminderRepository reminderRepository,
    required AlarmSoundRepository alarmSoundRepository,
  }) : _taskRepository = taskRepository,
       _reminderRepository = reminderRepository,
       _alarmSoundRepository = alarmSoundRepository {
    _recurringTaskService = RecurringTaskService(
      taskRepository: taskRepository,
      reminderRepository: reminderRepository,
      alarmSoundRepository: alarmSoundRepository,
    );
  }

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
    DateTime? reminderDateTime,
    String? alarmSoundId,
    bool isRecurring = false,
    DateTime? recurringTime,
  }) async {
    final task = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: description,
      createdAt: DateTime.now(),
      reminderDateTime: reminderDateTime,
      alarmSoundId: alarmSoundId,
      isRecurring: isRecurring,
      recurringTime: recurringTime,
    );

    await _taskRepository.addTask(task);

    // اگر تسک تکراری است، یادآور روزانه ایجاد کن
    if (isRecurring) {
      await _recurringTaskService.scheduleReminderForTask(task);
    }

    loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await _taskRepository.updateTask(task);

    // اگر تسک تکراری است، یادآورهای آن را بروزرسانی کن
    if (task.isRecurring) {
      await _recurringTaskService.scheduleReminderForTask(task);
    } else {
      // اگر دیگر تکراری نیست، یادآورهای تکراری قبلی را حذف کن
      await _recurringTaskService.removeRecurringRemindersForTask(task.id);
    }

    loadTasks();
  }

  Future<void> toggleTaskCompletion(String id) async {
    await _taskRepository.toggleTaskCompletion(id);
    loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _recurringTaskService.removeRecurringRemindersForTask(id);
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

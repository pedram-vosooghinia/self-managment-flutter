import 'package:hive/hive.dart';
import '../models/task_model.dart';
import '../../core/services/hive_service.dart';

class TaskRepository {
  late Box<TaskModel> _box;

  TaskRepository() {
    _box = HiveService.tasksBoxInstance;
  }

  // Create
  Future<void> addTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  // Read
  List<TaskModel> getAllTasks() {
    return _box.values.toList();
  }

  TaskModel? getTaskById(String id) {
    return _box.get(id);
  }

  List<TaskModel> getTodayTasks() {
    final now = DateTime.now();
    return _box.values.where((task) {
      if (task.isCompleted) return false;

      // تسک‌های تکراری همیشه در لیست امروز نمایش داده می‌شوند
      if (task.isRecurring) return true;

      // اگر یادآوری دارد، چک می‌کنیم که امروز باشد
      if (task.reminderDateTime != null) {
        return task.reminderDateTime!.year == now.year &&
            task.reminderDateTime!.month == now.month &&
            task.reminderDateTime!.day == now.day;
      }

      // اگر یادآوری ندارد، همه وظایف انجام نشده را نمایش می‌دهیم
      return true;
    }).toList();
  }

  List<TaskModel> getUpcomingTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return _box.values.where((task) {
      if (task.isCompleted) return false;

      // تسک‌های تکراری را در لیست آینده نمایش نمی‌دهیم (فقط در امروز)
      if (task.isRecurring) return false;

      // فقط وظایفی که یادآوری در آینده دارند
      if (task.reminderDateTime != null) {
        final reminderDate = DateTime(
          task.reminderDateTime!.year,
          task.reminderDateTime!.month,
          task.reminderDateTime!.day,
        );
        return reminderDate.isAfter(today);
      }

      return false;
    }).toList()..sort((a, b) {
      if (a.reminderDateTime != null && b.reminderDateTime != null) {
        return a.reminderDateTime!.compareTo(b.reminderDateTime!);
      }
      if (a.reminderDateTime != null) return -1;
      if (b.reminderDateTime != null) return 1;
      return 0;
    });
  }

  List<TaskModel> getCompletedTasks() {
    return _box.values.where((task) => task.isCompleted).toList();
  }

  List<TaskModel> getIncompleteTasks() {
    return _box.values.where((task) => !task.isCompleted).toList();
  }

  List<TaskModel> getOverdueTasks() {
    final now = DateTime.now();
    return _box.values.where((task) {
      if (task.isCompleted) return false;

      // تسک‌های تکراری هرگز overdue نمی‌شوند
      if (task.isRecurring) return false;

      // وظایفی که یادآوری‌شان گذشته است
      return task.reminderDateTime != null &&
          task.reminderDateTime!.isBefore(now);
    }).toList();
  }

  // Update
  Future<void> updateTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _box.get(id);
    if (task != null) {
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);
      await _box.put(id, updatedTask);
    }
  }

  // Delete
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  // Stream for real-time updates
  Stream<List<TaskModel>> watchTasks() {
    return _box.watch().map((_) => getAllTasks());
  }
}

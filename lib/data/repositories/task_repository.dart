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
      if (task.dueDate == null) return false;
      return task.dueDate!.year == now.year &&
          task.dueDate!.month == now.month &&
          task.dueDate!.day == now.day;
    }).toList();
  }

  List<TaskModel> getUpcomingTasks() {
    final now = DateTime.now();
    return _box.values.where((task) {
      return task.dueDate != null && task.dueDate!.isAfter(now);
    }).toList()
      ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
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
      return task.dueDate != null &&
          task.dueDate!.isBefore(now) &&
          !task.isCompleted;
    }).toList();
  }

  // Update
  Future<void> updateTask(TaskModel task) async {
    await _box.put(task.id, task);
  }

  Future<void> toggleTaskCompletion(String id) async {
    final task = _box.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      await task.save();
    }
  }

  // Delete
  Future<void> deleteTask(String id) async {
    await _box.delete(id);
  }

  Future<void> deleteAllTasks() async {
    await _box.clear();
  }

  // Stream for real-time updates
  Stream<List<TaskModel>> watchTasks() {
    return _box.watch().map((_) => getAllTasks());
  }
}


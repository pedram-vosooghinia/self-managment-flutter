import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/task_model.dart';
import '../../data/models/goal_model.dart';
import '../../data/models/reminder_model.dart';
import '../../data/models/alarm_sound_model.dart';
import '../../data/models/workout_model.dart';

class HiveService {
  static const String tasksBox = 'tasks';
  static const String goalsBox = 'goals';
  static const String remindersBox = 'reminders';
  static const String settingsBox = 'settings';
  static const String alarmSoundsBox = 'alarmSounds';
  static const String workoutsBox = 'workouts';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(GoalTypeAdapter());
    Hive.registerAdapter(ReminderModelAdapter());
    Hive.registerAdapter(ReminderTypeAdapter());
    Hive.registerAdapter(AlarmSoundModelAdapter());
    Hive.registerAdapter(WorkoutModelAdapter());

    // Open boxes
    await Hive.openBox<TaskModel>(tasksBox);
    await Hive.openBox<GoalModel>(goalsBox);
    await Hive.openBox<ReminderModel>(remindersBox);
    await Hive.openBox<AlarmSoundModel>(alarmSoundsBox);
    await Hive.openBox<WorkoutModel>(workoutsBox);
    await Hive.openBox(settingsBox);
  }

  static Box<TaskModel> get tasksBoxInstance => Hive.box<TaskModel>(tasksBox);
  static Box<GoalModel> get goalsBoxInstance => Hive.box<GoalModel>(goalsBox);
  static Box<ReminderModel> get remindersBoxInstance =>
      Hive.box<ReminderModel>(remindersBox);
  static Box<AlarmSoundModel> get alarmSoundsBoxInstance =>
      Hive.box<AlarmSoundModel>(alarmSoundsBox);
  static Box<WorkoutModel> get workoutsBoxInstance =>
      Hive.box<WorkoutModel>(workoutsBox);
  static Box get settingsBoxInstance => Hive.box(settingsBox);

  static Future<void> close() async {
    await Hive.close();
  }
}

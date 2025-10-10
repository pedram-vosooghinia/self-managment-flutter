import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/reminder_repository.dart';
import 'data/repositories/alarm_sound_repository.dart';
import 'data/repositories/workout_repository.dart';
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/goal_provider.dart';
import 'presentation/providers/reminder_provider.dart';
import 'presentation/providers/alarm_sound_provider.dart';
import 'presentation/providers/workout_provider.dart';
import 'presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive database
  await HiveService.initialize();

  // Initialize notification service
  await NotificationService().initialize();

  // Reschedule all active reminders (important for post-reboot)
  // This ensures alarms persist after device reboot
  try {
    final reminderRepository = ReminderRepository();
    await reminderRepository.rescheduleAllActiveReminders();
  } catch (e) {
    print('Error rescheduling reminders on startup: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize repositories
    final taskRepository = TaskRepository();
    final goalRepository = GoalRepository();
    final reminderRepository = ReminderRepository();
    final alarmSoundRepository = AlarmSoundRepository();
    final workoutRepository = WorkoutRepository();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            taskRepository: taskRepository,
            reminderRepository: reminderRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalProvider(
            goalRepository: goalRepository,
            reminderRepository: reminderRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ReminderProvider(
            reminderRepository: reminderRepository,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => AlarmSoundProvider(
            alarmSoundRepository: alarmSoundRepository,
          )..initializeDefaultSounds(),
        ),
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(
            workoutRepository: workoutRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Self Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey.shade200,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Colors.grey.shade800,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}

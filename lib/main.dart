// ==================== واردات کتابخانه‌ها ====================
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

// سرویس‌های اصلی برنامه
import 'core/services/hive_service.dart';
import 'core/services/notification_service.dart';

// مخزن‌های داده (Repositories)
import 'data/repositories/task_repository.dart';
import 'data/repositories/goal_repository.dart';
import 'data/repositories/reminder_repository.dart';
import 'data/repositories/alarm_sound_repository.dart';
import 'data/repositories/workout_repository.dart';

// مدیریت وضعیت (State Management - Providers)
import 'presentation/providers/task_provider.dart';
import 'presentation/providers/goal_provider.dart';
import 'presentation/providers/reminder_provider.dart';
import 'presentation/providers/alarm_sound_provider.dart';
import 'presentation/providers/workout_provider.dart';

// صفحه اصلی برنامه
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/alarm/alarm_notification_screen.dart';

// ==================== تابع اصلی برنامه ====================
/// نقطه شروع اصلی اپلیکیشن
/// این تابع قبل از اجرای برنامه، سرویس‌های ضروری را راه‌اندازی می‌کند
void main() async {
  // اطمینان از آماده بودن Flutter قبل از اجرای کدهای async
  WidgetsFlutterBinding.ensureInitialized();

  // راه‌اندازی پایگاه داده محلی Hive
  await HiveService.initialize();

  // راه‌اندازی سرویس نوتیفیکیشن و آلارم
  await NotificationService().initialize();

  // بازنشانی همه آلارم‌های فعال (مهم برای بعد از ری‌استارت گوشی)
  // این کد تضمین می‌کند که آلارم‌ها بعد از خاموش و روشن شدن گوشی حفظ شوند
  try {
    final reminderRepository = ReminderRepository();
    await reminderRepository.rescheduleAllActiveReminders();
  } catch (e) {
    debugPrint('خطا در بازنشانی آلارم‌ها در زمان شروع برنامه: $e');
  }

  // اجرای برنامه اصلی
  runApp(const MyApp());
}

// ==================== کلاس اصلی برنامه ====================
/// ویجت اصلی اپلیکیشن که تمام تنظیمات و providerها را راه‌اندازی می‌کند
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();

    // تنظیم callback برای handle کردن notification
    NotificationService.onNotificationReceived = (payload) {
      _handleNotification(payload);
    };
  }

  void _handleNotification(Map<String, dynamic> payload) {
    final context = _navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AlarmNotificationScreen(
            reminderId: payload['reminderId'] ?? '',
            title: payload['title'] ?? 'یادآور',
            body: payload['body'],
            alarmSoundPath: payload['soundPath'],
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ایجاد نمونه از مخزن‌های داده (Repositories)
    // این کلاس‌ها مسئول ارتباط با پایگاه داده هستند
    final taskRepository = TaskRepository();
    final goalRepository = GoalRepository();
    final reminderRepository = ReminderRepository();
    final alarmSoundRepository = AlarmSoundRepository();
    final workoutRepository = WorkoutRepository();

    return MultiProvider(
      // لیست Providerها برای مدیریت وضعیت در سراسر برنامه
      providers: [
        // Provider مدیریت تسک‌ها (وظایف)
        ChangeNotifierProvider(
          create: (_) => TaskProvider(
            taskRepository: taskRepository,
            reminderRepository: reminderRepository,
            alarmSoundRepository: alarmSoundRepository,
          ),
        ),
        // Provider مدیریت اهداف (Goals)
        ChangeNotifierProvider(
          create: (_) => GoalProvider(
            goalRepository: goalRepository,
            reminderRepository: reminderRepository,
          ),
        ),
        // Provider مدیریت یادآورها (Reminders)
        ChangeNotifierProvider(
          create: (_) =>
              ReminderProvider(reminderRepository: reminderRepository),
        ),
        // Provider مدیریت صداهای آلارم
        ChangeNotifierProvider(
          create: (_) =>
              AlarmSoundProvider(alarmSoundRepository: alarmSoundRepository)
                ..initializeDefaultSounds(),
        ),
        // Provider مدیریت تمرینات ورزشی
        ChangeNotifierProvider(
          create: (_) => WorkoutProvider(workoutRepository: workoutRepository),
        ),
      ],
      child: MaterialApp(
        // ==================== تنظیمات اصلی برنامه ====================
        navigatorKey: _navigatorKey,
        title: 'مدیریت شخصی',
        debugShowCheckedModeBanner: false,

        // تنظیمات زبان و جهت متن (راست به چپ برای فارسی)
        locale: const Locale('fa', 'IR'),
        supportedLocales: const [
          Locale('fa', 'IR'), // فارسی
          Locale('en', 'US'), // انگلیسی
        ],
        // افزودن delegates برای پشتیبانی از localization
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // ==================== تم روشن ====================
        theme: ThemeData(
          useMaterial3: true,

          // رنگ‌بندی اصلی برنامه
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),

          // تنظیمات کارت‌ها
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),

          // تنظیمات فیلدهای ورودی
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
        ),

        // صفحه اصلی برنامه
        home: const HomeScreen(),
      ),
    );
  }
}

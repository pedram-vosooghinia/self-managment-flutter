import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(settings);

    // ایجاد notification channel برای Android
    await _createNotificationChannel();

    // درخواست مجوزهای لازم
    await _requestPermissions();
  }

  /// ایجاد کانال اعلان برای Android
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'task_channel', // id
      'Task Reminders', // name
      description: 'Notifications for task reminders and alarms',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// درخواست مجوزهای لازم برای نوتیفیکیشن و آلارم
  static Future<void> _requestPermissions() async {
    // مجوز نوتیفیکیشن (برای Android 13+)
    await Permission.notification.request();

    // مجوز آلارم دقیق
    await Permission.scheduleExactAlarm.request();
  }

  static Future<void> showNotification({
    required String id,
    required String title,
    required DateTime scheduledDate,
    String? sound,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'task_channel',
      'Task Reminders',
      channelDescription: 'Notifications for task reminders and alarms',
      importance: Importance.max,
      priority: Priority.high,
      sound: sound != null
          ? RawResourceAndroidNotificationSound(sound)
          : const RawResourceAndroidNotificationSound(
              'alarm_sound',
            ), // صدای پیش‌فرض آلارم
      playSound: true,
      enableVibration: true,
      enableLights: true,
      fullScreenIntent: true, // آلارم روی صفحه بیاد
      category: AndroidNotificationCategory.alarm, // مشخص کردن نوع آلارم
      visibility: NotificationVisibility.public, // نمایش روی صفحه قفل
    );

    await _notifications.zonedSchedule(
      id.hashCode,
      title,
      'زمان یادآوری فرا رسیده است!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }
}

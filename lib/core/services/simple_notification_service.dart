import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class SimpleNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      debugPrint('شروع راه‌اندازی سرویس نوتیفیکیشن...');

      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );

      await _notifications.initialize(settings);
      debugPrint('سرویس نوتیفیکیشن راه‌اندازی شد');

      // ایجاد کانال ساده
      await _createSimpleChannel();

      // درخواست مجوزهای ساده
      await _requestSimplePermissions();
    } catch (e) {
      debugPrint('خطا در راه‌اندازی سرویس نوتیفیکیشن: $e');
    }
  }

  static Future<void> _createSimpleChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'simple_channel',
      'Simple Notifications',
      description: 'Simple notifications for tasks',
      importance: Importance.high,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> _requestSimplePermissions() async {
    try {
      await Permission.notification.request();
      debugPrint('مجوز نوتیفیکیشن درخواست شد');
    } catch (e) {
      debugPrint('خطا در درخواست مجوز: $e');
    }
  }

  static Future<void> showSimpleNotification({
    required String id,
    required String title,
    required DateTime scheduledDate,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'simple_channel',
        'Simple Notifications',
        importance: Importance.high,
        priority: Priority.high,
      );

      await _notifications.zonedSchedule(
        id.hashCode,
        title,
        'زمان یادآوری فرا رسیده است!',
        tz.TZDateTime.from(scheduledDate, tz.local),
        const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      debugPrint('نوتیفیکیشن ساده برای $title تنظیم شد');
    } catch (e) {
      debugPrint('خطا در تنظیم نوتیفیکیشن ساده: $e');
    }
  }

  static Future<void> cancelNotification(String id) async {
    try {
      await _notifications.cancel(id.hashCode);
      debugPrint('نوتیفیکیشن $id لغو شد');
    } catch (e) {
      debugPrint('خطا در لغو نوتیفیکیشن: $e');
    }
  }
}

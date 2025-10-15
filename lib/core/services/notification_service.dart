import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:audioplayers/audioplayers.dart';
import 'alarm_manager.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _isAlarmPlaying = false;

  static Future<void> init() async {
    try {
      tz.initializeTimeZones();

      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // ایجاد notification channel برای Android
      await _createNotificationChannel();

      // درخواست مجوزهای لازم
      await _requestPermissions();
    } catch (e) {
      debugPrint('خطا در راه‌اندازی NotificationService: $e');
    }
  }

  /// مدیریت کلیک روی نوتیفیکیشن
  static void _onNotificationTapped(NotificationResponse response) {
    if (response.actionId == 'dismiss') {
      _stopAlarm();
    } else if (response.actionId == 'snooze') {
      _snoozeAlarm(response.payload);
    } else {
      // کلیک روی خود نوتیفیکیشن - باز کردن صفحه آلارم
      _openAlarmScreen(response.payload);
    }
  }

  /// باز کردن صفحه آلارم
  static void _openAlarmScreen(String? payload) {
    if (payload != null) {
      // تقسیم payload برای دریافت عنوان و ID تسک
      final parts = payload.split('|');
      if (parts.length >= 2) {
        final taskTitle = parts[0];
        final taskId = parts[1];
        AlarmManager.openAlarmScreen(taskTitle, taskId);
      }
    }
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
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
      showBadge: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// درخواست مجوزهای لازم برای نوتیفیکیشن و آلارم
  static Future<void> _requestPermissions() async {
    try {
      // مجوز نوتیفیکیشن (برای Android 13+)
      final notificationStatus = await Permission.notification.request();
      debugPrint('وضعیت مجوز نوتیفیکیشن: $notificationStatus');

      // مجوز آلارم دقیق
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      debugPrint('وضعیت مجوز آلارم: $alarmStatus');

      // مجوز ویبره (اختیاری - در AndroidManifest.xml تعریف شده)
    } catch (e) {
      debugPrint('خطا در درخواست مجوزها: $e');
    }
  }

  static Future<void> showNotification({
    required String id,
    required String title,
    required DateTime scheduledDate,
    String? sound,
  }) async {
    try {
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
        ongoing: true, // نوتیفیکیشن مداوم
        autoCancel: false, // خودکار پاک نشود
        actions: [
          const AndroidNotificationAction(
            'dismiss',
            'قطع',
            cancelNotification: true,
            icon: DrawableResourceAndroidBitmap('@drawable/ic_close'),
          ),
          const AndroidNotificationAction(
            'snooze',
            'چرت (5 دقیقه)',
            cancelNotification: false,
            icon: DrawableResourceAndroidBitmap('@drawable/ic_snooze'),
          ),
        ],
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
        payload: '$title|$id', // عنوان و ID تسک برای باز کردن صفحه آلارم
      );

      debugPrint('آلارم برای $title در $scheduledDate تنظیم شد');
    } catch (e) {
      debugPrint('خطا در تنظیم آلارم: $e');
    }
  }

  static Future<void> cancelNotification(String id) async {
    await _notifications.cancel(id.hashCode);
  }

  /// توقف آلارم
  static Future<void> _stopAlarm() async {
    if (_isAlarmPlaying) {
      await _audioPlayer.stop();
      _isAlarmPlaying = false;
    }
  }

  /// چرت زدن آلارم (5 دقیقه بعد)
  static Future<void> _snoozeAlarm(String? payload) async {
    if (payload != null) {
      final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
      await showNotification(
        id: '${payload}_snooze',
        title: 'چرت آلارم',
        scheduledDate: snoozeTime,
      );
    }
  }

  /// پخش صدای آلارم با تکرار
  static Future<void> playAlarmSound({String? customSound}) async {
    if (!_isAlarmPlaying) {
      _isAlarmPlaying = true;
      final soundFile = customSound ?? 'alarm_sound.mp3';

      // پخش صدای آلارم با تکرار
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
    }
  }

  /// بررسی وضعیت پخش صدا
  static bool get isAlarmPlaying => _isAlarmPlaying;

  /// دریافت تمام آلارم‌های فعال
  static Future<List<PendingNotificationRequest>>
  getActiveNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// لغو تمام آلارم‌ها
  static Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    await _stopAlarm();
  }
}

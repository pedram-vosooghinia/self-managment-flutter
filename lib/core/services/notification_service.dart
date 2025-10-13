import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:developer' as developer;
import 'dart:convert';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Callback برای handle کردن notification
  static Function(Map<String, dynamic>)? onNotificationReceived;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // تنظیمات ساده‌تر برای Android
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final bool? initialized = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      if (initialized == true) {
        developer.log('Notification service initialized successfully');

        // Request necessary permissions
        await requestPermissions();
        _isInitialized = true;
      } else {
        developer.log('Failed to initialize notification service');
      }
    } catch (e) {
      developer.log('Error initializing notification service: $e');
      // اگر initialization شکست خورد، سعی کنیم بدون notification service ادامه دهیم
      _isInitialized = false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      'Notification received: ${response.payload}',
      name: 'NotificationService',
    );

    if (response.payload != null && onNotificationReceived != null) {
      try {
        final payload = jsonDecode(response.payload!);
        onNotificationReceived!(payload);
      } catch (e) {
        developer.log(
          'Error parsing notification payload: $e',
          name: 'NotificationService',
        );
      }
    }
  }

  Future<bool> requestPermissions() async {
    // در Web، از بررسی permission صرف‌نظر می‌کنیم زیرا پشتیبانی نمی‌شود
    if (kIsWeb) {
      developer.log(
        'Running on Web - skipping permission checks',
        name: 'NotificationService',
      );
      return true;
    }

    // Request notification permission (Android 13+)
    try {
      if (await Permission.notification.isDenied) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          developer.log(
            'Notification permission denied',
            name: 'NotificationService',
          );
          return false;
        }
      }
    } catch (e) {
      developer.log(
        'Error checking notification permission: $e',
        name: 'NotificationService',
      );
    }

    // Request schedule exact alarm permission (Android 12+)
    try {
      if (await Permission.scheduleExactAlarm.isDenied) {
        final status = await Permission.scheduleExactAlarm.request();
        if (!status.isGranted) {
          developer.log(
            'Schedule exact alarm permission denied',
            name: 'NotificationService',
          );
        }
      }
    } catch (e) {
      developer.log(
        'Error checking schedule exact alarm permission: $e',
        name: 'NotificationService',
      );
    }

    return true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? soundPath,
    String? reminderId,
  }) async {
    // بررسی اینکه service initialized شده باشد
    if (!_isInitialized) {
      developer.log(
        'Cannot schedule notification: service not initialized',
        name: 'NotificationService',
      );
      return;
    }

    try {
      // Ensure permissions are granted
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        developer.log(
          'Cannot schedule notification: permissions not granted',
          name: 'NotificationService',
        );
        return;
      }

      // Check if the scheduled time is in the future
      if (scheduledDateTime.isBefore(DateTime.now())) {
        developer.log(
          'Cannot schedule notification: time is in the past',
          name: 'NotificationService',
        );
        return;
      }

      // ساخت payload برای notification
      final payload = jsonEncode({
        'id': id,
        'reminderId': reminderId ?? '',
        'title': title,
        'body': body,
        'soundPath': soundPath ?? '',
      });

      // برای صدا، فعلاً از صدای پیش‌فرض سیستم استفاده می‌کنیم
      // چون استفاده از custom sound در runtime نیاز به configuration خاص دارد
      const androidDetails = AndroidNotificationDetails(
        'task_reminder_channel',
        'Task Reminders',
        channelDescription: 'Notifications for task and goal reminders',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        styleInformation: DefaultStyleInformation(true, true),
        ticker: 'Alarm',
        channelShowBadge: true,
        onlyAlertOnce: false,
        autoCancel: false,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification.aiff',
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // تبدیل DateTime به TZDateTime
      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        scheduledDateTime,
        tz.local,
      );

      // استفاده از zonedSchedule
      try {
        await _notifications.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          payload: payload,
        );

        developer.log(
          'Notification scheduled successfully for $scheduledDateTime (ID: $id)',
          name: 'NotificationService',
        );
      } catch (e) {
        developer.log(
          'Schedule failed, trying instant notification: $e',
          name: 'NotificationService',
        );

        // اگر schedule شکست خورد، instant notification نمایش بده
        await showInstantNotification(id: id, title: title, body: body);
      }
    } catch (e) {
      developer.log(
        'Error scheduling notification: $e',
        name: 'NotificationService',
      );
      // اگر scheduling شکست خورد، برنامه crash نکنه
    }
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Instant Notifications',
      channelDescription: 'Instant notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, notificationDetails);
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Method to reschedule all pending notifications
  // This should be called on app startup to ensure alarms persist after device reboot
  Future<void> rescheduleAllNotifications(
    List<Map<String, dynamic>> notifications,
  ) async {
    for (final notification in notifications) {
      try {
        await scheduleNotification(
          id: notification['id'] as int,
          title: notification['title'] as String,
          body: notification['body'] as String,
          scheduledDateTime: notification['scheduledDateTime'] as DateTime,
          soundPath: notification['soundPath'] as String?,
        );
      } catch (e) {
        developer.log(
          'Error rescheduling notification: $e',
          name: 'NotificationService',
        );
      }
    }
  }
}

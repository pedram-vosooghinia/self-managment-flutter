import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as developer;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone with local location
    tz.initializeTimeZones();
    // Set local timezone (you can change this to your timezone, e.g., 'Asia/Tehran')
    tz.setLocalLocation(tz.getLocation('Asia/Tehran'));

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

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Request necessary permissions
    await requestPermissions();

    _isInitialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screen based on payload
    developer.log(
      'Notification tapped: ${response.payload}',
      name: 'NotificationService',
    );
  }

  Future<bool> requestPermissions() async {
    // Request notification permission (Android 13+)
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

    // Request schedule exact alarm permission (Android 12+)
    if (await Permission.scheduleExactAlarm.isDenied) {
      final status = await Permission.scheduleExactAlarm.request();
      if (!status.isGranted) {
        developer.log(
          'Schedule exact alarm permission denied',
          name: 'NotificationService',
        );
      }
    }

    return true;
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? soundPath,
  }) async {
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

    final androidDetails = AndroidNotificationDetails(
      'task_reminder_channel',
      'Task Reminders',
      channelDescription: 'Notifications for task and goal reminders',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: soundPath != null
          ? UriAndroidNotificationSound(soundPath)
          : const RawResourceAndroidNotificationSound('notification'),
      enableVibration: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
      styleInformation: const DefaultStyleInformation(true, true),
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

    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDateTime, tz.local),
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      developer.log(
        'Notification scheduled successfully for $scheduledDateTime (ID: $id)',
        name: 'NotificationService',
      );
    } catch (e) {
      developer.log(
        'Error scheduling notification: $e',
        name: 'NotificationService',
      );
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
  Future<void> rescheduleAllNotifications(List<Map<String, dynamic>> notifications) async {
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

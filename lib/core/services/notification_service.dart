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

  // Callback برای handle کردن notification (وقتی روی نوتیفیکیشن کلیک می‌شود)
  static Function(Map<String, dynamic>)? onNotificationReceived;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Tehran'));

      // تنظیمات Android
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
        await requestPermissions();
        _isInitialized = true;
      } else {
        developer.log('Failed to initialize notification service');
      }
    } catch (e) {
      developer.log('Error initializing notification service: $e');
      _isInitialized = false;
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    developer.log(
      'Notification tapped: ${response.payload}',
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
    if (kIsWeb) {
      developer.log(
        'Running on Web - skipping permission checks',
        name: 'NotificationService',
      );
      return true;
    }

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

  /// زمان‌بندی نوتیفیکیشن برای background
  /// این حتی وقتی برنامه بسته است کار می‌کند
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? soundPath,
    String? reminderId,
  }) async {
    if (!_isInitialized) {
      developer.log(
        'Cannot schedule notification: service not initialized',
        name: 'NotificationService',
      );
      return;
    }

    try {
      final hasPermission = await requestPermissions();
      if (!hasPermission) {
        developer.log(
          'Cannot schedule notification: permissions not granted',
          name: 'NotificationService',
        );
        return;
      }

      if (scheduledDateTime.isBefore(DateTime.now())) {
        developer.log(
          'Cannot schedule notification: time is in the past',
          name: 'NotificationService',
        );
        return;
      }

      final payload = jsonEncode({
        'id': id,
        'reminderId': reminderId ?? '',
        'title': title,
        'body': body,
        'soundPath': soundPath ?? '',
      });

      // تنظیمات Android با fullScreenIntent
      // این باعث می‌شود حتی وقتی برنامه بسته است، صفحه تمام‌صفحه باز شود
      final androidDetails = AndroidNotificationDetails(
        'alarm_channel',
        'آلارم‌ها',
        channelDescription: 'نوتیفیکیشن آلارم با اولویت بالا',
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true, // 🔥 کلیدی: برای باز کردن صفحه روی lock screen
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        ticker: 'آلارم',
        channelShowBadge: true,
        onlyAlertOnce: false,
        autoCancel: false,
        ongoing: true, // نوتیفیکیشن قابل dismiss نیست تا کاربر آلارم را ببیند
        styleInformation: BigTextStyleInformation(body),
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

      final tz.TZDateTime scheduledDate = tz.TZDateTime.from(
        scheduledDateTime,
        tz.local,
      );

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
        'Background notification scheduled for $scheduledDateTime (ID: $id)',
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

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}

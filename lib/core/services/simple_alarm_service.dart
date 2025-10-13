import 'dart:async';
import 'dart:developer' as developer;
import 'notification_service.dart';

class SimpleAlarmService {
  static final SimpleAlarmService _instance = SimpleAlarmService._internal();
  factory SimpleAlarmService() => _instance;
  SimpleAlarmService._internal();

  final Map<int, Timer> _activeTimers = {};
  final NotificationService _notificationService = NotificationService();

  /// زمان‌بندی یک آلارم ساده
  Future<void> scheduleSimpleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? reminderId,
  }) async {
    try {
      // حذف timer قبلی اگر وجود داشته باشد
      _activeTimers[id]?.cancel();
      _activeTimers.remove(id);

      // محاسبه مدت زمان تا زمان آلارم
      final now = DateTime.now();
      final duration = scheduledDateTime.difference(now);

      if (duration.isNegative) {
        developer.log('Alarm time is in the past, showing immediately');
        await _showNotification(id, title, body, reminderId);
        return;
      }

      developer.log(
        'Scheduling alarm for ${duration.inSeconds} seconds from now',
      );

      // ایجاد timer
      final timer = Timer(duration, () async {
        await _showNotification(id, title, body, reminderId);
        _activeTimers.remove(id);
      });

      _activeTimers[id] = timer;
      developer.log('Alarm scheduled successfully (ID: $id)');
    } catch (e) {
      developer.log('Error scheduling simple alarm: $e');
    }
  }

  /// نمایش نوتیفیکیشن
  Future<void> _showNotification(
    int id,
    String title,
    String body,
    String? reminderId,
  ) async {
    try {
      await _notificationService.showInstantNotification(
        id: id,
        title: title,
        body: body,
      );
      developer.log('Alarm notification shown (ID: $id)');
    } catch (e) {
      developer.log('Error showing alarm notification: $e');
    }
  }

  /// لغو یک آلارم
  void cancelAlarm(int id) {
    _activeTimers[id]?.cancel();
    _activeTimers.remove(id);
    developer.log('Alarm cancelled (ID: $id)');
  }

  /// لغو تمام آلارم‌ها
  void cancelAllAlarms() {
    for (final timer in _activeTimers.values) {
      timer.cancel();
    }
    _activeTimers.clear();
    developer.log('All alarms cancelled');
  }

  /// دریافت تعداد آلارم‌های فعال
  int get activeAlarmsCount => _activeTimers.length;

  /// بررسی اینکه آیا آلارمی با ID مشخص فعال است
  bool isAlarmActive(int id) => _activeTimers.containsKey(id);
}

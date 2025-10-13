import 'dart:async';
import 'dart:developer' as developer;

class SimpleAlarmService {
  static final SimpleAlarmService _instance = SimpleAlarmService._internal();
  factory SimpleAlarmService() => _instance;
  SimpleAlarmService._internal();

  final Map<int, Timer> _activeTimers = {};

  // Callback برای نمایش صفحه آلارم
  static Function(
    int id,
    String title,
    String body,
    String? reminderId,
    String? soundPath,
  )?
  onAlarmTriggered;

  /// زمان‌بندی یک آلارم ساده
  Future<void> scheduleSimpleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    String? reminderId,
    String? soundPath,
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
        _triggerAlarm(id, title, body, reminderId, soundPath);
        return;
      }

      developer.log(
        'Scheduling alarm for ${duration.inSeconds} seconds from now',
      );

      // ایجاد timer
      final timer = Timer(duration, () {
        _triggerAlarm(id, title, body, reminderId, soundPath);
        _activeTimers.remove(id);
      });

      _activeTimers[id] = timer;
      developer.log('Alarm scheduled successfully (ID: $id)');
    } catch (e) {
      developer.log('Error scheduling simple alarm: $e');
    }
  }

  /// فعال کردن آلارم و نمایش صفحه
  void _triggerAlarm(
    int id,
    String title,
    String body,
    String? reminderId,
    String? soundPath,
  ) {
    try {
      if (onAlarmTriggered != null) {
        onAlarmTriggered!(id, title, body, reminderId, soundPath);
        developer.log(
          'Alarm triggered - opening screen (ID: $id) with sound: $soundPath',
        );
      } else {
        developer.log('Warning: onAlarmTriggered callback not set!');
      }
    } catch (e) {
      developer.log('Error triggering alarm: $e');
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

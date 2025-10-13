import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';

class AlarmNotificationScreen extends StatefulWidget {
  final String reminderId;
  final String title;
  final String? body;
  final String? alarmSoundPath;

  const AlarmNotificationScreen({
    super.key,
    required this.reminderId,
    required this.title,
    this.body,
    this.alarmSoundPath,
  });

  @override
  State<AlarmNotificationScreen> createState() =>
      _AlarmNotificationScreenState();
}

class _AlarmNotificationScreenState extends State<AlarmNotificationScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _dismissAlarm() {
    Navigator.of(context).pop();
  }

  void _snoozeAlarm() async {
    // زمان‌بندی مجدد برای 5 دقیقه بعد
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));

    final notificationService = NotificationService();
    await notificationService.scheduleNotification(
      id: DateTime.now().millisecondsSinceEpoch % 100000,
      title: '⏰ ${widget.title}',
      body: widget.body ?? 'یادآور به تعویق افتاد',
      scheduledDateTime: snoozeTime,
      soundPath: widget.alarmSoundPath,
      reminderId: widget.reminderId,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('آلارم برای ۵ دقیقه دیگر به تعویق افتاد'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // آیکون آلارم با انیمیشن
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.alarm,
                        size: 64,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // عنوان آلارم
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                textAlign: TextAlign.center,
              ),

              if (widget.body != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.body!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 48),

              // دکمه Dismiss
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: _dismissAlarm,
                  icon: const Icon(Icons.check_circle),
                  label: const Text(
                    'بستن آلارم',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // دکمه Snooze
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _snoozeAlarm,
                  icon: const Icon(Icons.snooze),
                  label: const Text(
                    'به تعویق انداختن (۵ دقیقه)',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

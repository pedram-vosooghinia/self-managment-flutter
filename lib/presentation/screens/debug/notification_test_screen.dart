import 'package:flutter/material.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/simple_alarm_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final NotificationService _notificationService = NotificationService();
  final SimpleAlarmService _simpleAlarmService = SimpleAlarmService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تست نوتیفیکیشن')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تست ساده نوتیفیکیشن',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // تست Instant Notification
            ElevatedButton(
              onPressed: () async {
                try {
                  await _notificationService.showInstantNotification(
                    id: 1,
                    title: 'تست فوری',
                    body: 'این یک نوتیفیکیشن فوری است',
                  );
                  _showMessage('نوتیفیکیشن فوری ارسال شد');
                } catch (e) {
                  _showError('خطا در ارسال نوتیفیکیشن فوری: $e');
                }
              },
              child: const Text('تست نوتیفیکیشن فوری'),
            ),

            const SizedBox(height: 16),

            // تست Scheduled Notification با SimpleAlarmService
            ElevatedButton(
              onPressed: () async {
                try {
                  final testTime = DateTime.now().add(
                    const Duration(seconds: 5),
                  );
                  await _simpleAlarmService.scheduleSimpleAlarm(
                    id: 2,
                    title: 'تست زمان‌بندی شده (Simple)',
                    body: 'این نوتیفیکیشن بعد از ۵ ثانیه نمایش داده می‌شود',
                    scheduledDateTime: testTime,
                  );
                  _showMessage('آلارم ساده برای ۵ ثانیه بعد زمان‌بندی شد');
                } catch (e) {
                  _showError('خطا در زمان‌بندی آلارم ساده: $e');
                }
              },
              child: const Text('تست آلارم ساده ۵ ثانیه بعد'),
            ),

            const SizedBox(height: 16),

            // تست Permissions
            ElevatedButton(
              onPressed: () async {
                try {
                  final hasPermission = await _notificationService
                      .requestPermissions();
                  _showMessage(
                    'مجوزها: ${hasPermission ? "اعطا شده" : "رد شده"}',
                  );
                } catch (e) {
                  _showError('خطا در بررسی مجوزها: $e');
                }
              },
              child: const Text('بررسی مجوزها'),
            ),

            const SizedBox(height: 32),

            const Text(
              'نکات مهم:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('• اگر نوتیفیکیشن فوری کار کرد، مشکل از زمان‌بندی است'),
            const Text(
              '• اگر نوتیفیکیشن فوری هم کار نکرد، مشکل از مجوزها یا تنظیمات است',
            ),
            const Text('• برای تست زمان‌بندی، ۵ ثانیه صبر کنید'),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
  }
}

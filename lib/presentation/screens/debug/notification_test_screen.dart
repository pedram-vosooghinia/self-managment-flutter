import 'package:flutter/material.dart';
import '../../../core/services/simple_alarm_service.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final SimpleAlarmService _simpleAlarmService = SimpleAlarmService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تست آلارم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'تست سیستم آلارم صفحه‌باز',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // تست آلارم فوری
            ElevatedButton(
              onPressed: () async {
                try {
                  final testTime = DateTime.now().add(
                    const Duration(seconds: 5),
                  );
                  await _simpleAlarmService.scheduleSimpleAlarm(
                    id: 2,
                    title: 'یادآور تست',
                    body: 'این آلارم بعد از ۵ ثانیه صفحه تمام‌صفحه باز می‌کند',
                    scheduledDateTime: testTime,
                    reminderId: 'test_reminder_1',
                    soundPath: 'default', // استفاده از صدای پیش‌فرض برای تست
                  );
                  _showMessage(
                    'آلارم برای ۵ ثانیه بعد زمان‌بندی شد - صفحه آلارم باز خواهد شد',
                  );
                } catch (e) {
                  _showError('خطا در زمان‌بندی آلارم: $e');
                }
              },
              child: const Text('تست آلارم صفحه‌باز ۵ ثانیه بعد'),
            ),

            const SizedBox(height: 16),

            // تست فوری
            ElevatedButton(
              onPressed: () async {
                try {
                  await _simpleAlarmService.scheduleSimpleAlarm(
                    id: 3,
                    title: 'آلارم فوری',
                    body: 'این آلارم باید فوراً صفحه را باز کند',
                    scheduledDateTime: DateTime.now(),
                    reminderId: 'test_reminder_immediate',
                    soundPath: 'default', // استفاده از صدای پیش‌فرض برای تست
                  );
                } catch (e) {
                  _showError('خطا در آلارم فوری: $e');
                }
              },
              child: const Text('تست آلارم فوری'),
            ),

            const SizedBox(height: 32),

            const Text(
              'نکات مهم:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '• دکمه "تست آلارم فوری" باید فوراً صفحه آلارم را باز کند',
            ),
            const Text(
              '• دکمه "تست آلارم ۵ ثانیه بعد" بعد از ۵ ثانیه صفحه باز می‌شود',
            ),
            const Text('• صفحه آلارم دارای دکمه "بستن آلارم" است'),
            const Text('• این سیستم بدون نیاز به نوتیفیکیشن کار می‌کند'),
            const SizedBox(height: 16),
            Text(
              'آلارم‌های فعال: ${_simpleAlarmService.activeAlarmsCount}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
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

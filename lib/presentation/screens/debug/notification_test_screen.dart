import 'package:flutter/material.dart';
import '../../../core/services/simple_alarm_service.dart';
import 'dart:developer' as developer;

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  final SimpleAlarmService _simpleAlarmService = SimpleAlarmService();
  String _lastLog = 'هیچ لاگی وجود ندارد';

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
                  developer.log('🧪 شروع تست آلارم 5 ثانیه بعد', name: 'TEST');

                  final testTime = DateTime.now().add(
                    const Duration(seconds: 5),
                  );

                  setState(() {
                    _lastLog =
                        'آلارم برای ${testTime.hour}:${testTime.minute}:${testTime.second} زمان‌بندی شد';
                  });

                  await _simpleAlarmService.scheduleSimpleAlarm(
                    id: 2,
                    title: 'یادآور تست',
                    body: 'این آلارم بعد از ۵ ثانیه صفحه تمام‌صفحه باز می‌کند',
                    scheduledDateTime: testTime,
                    reminderId: 'test_reminder_1',
                    soundPath: null, // بدون صدا برای تست
                  );

                  _showMessage('آلارم برای ۵ ثانیه بعد زمان‌بندی شد');

                  developer.log('✅ آلارم با موفقیت زمان‌بندی شد', name: 'TEST');
                } catch (e) {
                  developer.log('❌ خطا: $e', name: 'TEST');
                  setState(() {
                    _lastLog = 'خطا: $e';
                  });
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
                  developer.log('🧪 شروع تست آلارم فوری', name: 'TEST');

                  setState(() {
                    _lastLog = 'آلارم فوری در حال اجرا...';
                  });

                  await _simpleAlarmService.scheduleSimpleAlarm(
                    id: 3,
                    title: 'آلارم فوری',
                    body: 'این آلارم باید فوراً صفحه را باز کند',
                    scheduledDateTime: DateTime.now(),
                    reminderId: 'test_reminder_immediate',
                    soundPath: null, // بدون صدا برای تست
                  );

                  developer.log('✅ آلارم فوری فراخوانی شد', name: 'TEST');
                } catch (e) {
                  developer.log('❌ خطا: $e', name: 'TEST');
                  setState(() {
                    _lastLog = 'خطا در آلارم فوری: $e';
                  });
                  _showError('خطا در آلارم فوری: $e');
                }
              },
              child: const Text('تست آلارم فوری (بدون صدا)'),
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
            const SizedBox(height: 24),

            // نمایش وضعیت
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'وضعیت:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'آلارم‌های فعال: ${_simpleAlarmService.activeAlarmsCount}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _lastLog,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
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

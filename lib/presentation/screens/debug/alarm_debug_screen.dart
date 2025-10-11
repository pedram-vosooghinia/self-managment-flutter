import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../../core/services/alarm_debug_helper.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../../../data/models/reminder_model.dart';

class AlarmDebugScreen extends StatefulWidget {
  const AlarmDebugScreen({super.key});

  @override
  State<AlarmDebugScreen> createState() => _AlarmDebugScreenState();
}

class _AlarmDebugScreenState extends State<AlarmDebugScreen> {
  final AlarmDebugHelper _debugHelper = AlarmDebugHelper();
  final ReminderRepository _reminderRepo = ReminderRepository();

  List<PendingNotificationRequest> _pendingNotifications = [];
  List<ReminderModel> _activeReminders = [];
  Map<String, bool> _permissions = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDebugInfo();
  }

  Future<void> _loadDebugInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pending = await _debugHelper.getPendingAlarms();
      final reminders = _reminderRepo.getUpcomingReminders();
      final permissions = await _debugHelper.checkPermissions();

      setState(() {
        _pendingNotifications = pending;
        _activeReminders = reminders;
        _permissions = permissions;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا در بارگذاری اطلاعات: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _scheduleTestAlarm() async {
    await _debugHelper.scheduleTestAlarm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('آلارم تستی برای یک دقیقه دیگر تنظیم شد'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    await _loadDebugInfo();
  }

  Future<void> _cancelTestAlarm() async {
    await _debugHelper.cancelTestAlarm();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('آلارم تستی لغو شد'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    await _loadDebugInfo();
  }

  Future<void> _rescheduleAll() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _reminderRepo.rescheduleAllActiveReminders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('همه آلارم‌ها مجدداً زمان‌بندی شدند'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('خطا: $e')));
      }
    } finally {
      await _loadDebugInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اطلاعات آلارم'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDebugInfo,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDebugInfo,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Permissions Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _permissions['notifications'] == true
                                    ? Icons.check_circle
                                    : Icons.error,
                                color: _permissions['notifications'] == true
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'مجوزها',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'نوتیفیکیشن: ${_permissions['notifications'] == true ? "فعال ✓" : "غیرفعال ✗"}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Statistics Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'آمار',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'آلارم‌های زمان‌بندی شده: ${_pendingNotifications.length}',
                          ),
                          Text('یادآورهای فعال: ${_activeReminders.length}'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Test Buttons
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'تست',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _scheduleTestAlarm,
                            icon: const Icon(Icons.add_alarm),
                            label: const Text('تنظیم آلارم تستی (۱ دقیقه)'),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: _cancelTestAlarm,
                            icon: const Icon(Icons.cancel),
                            label: const Text('لغو آلارم تستی'),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _rescheduleAll,
                            icon: const Icon(Icons.refresh),
                            label: const Text('بازنشانی همه آلارم‌ها'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Pending Notifications List
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'آلارم‌های زمان‌بندی شده',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_pendingNotifications.isEmpty)
                            const Text('هیچ آلارمی زمان‌بندی نشده است')
                          else
                            ..._pendingNotifications.map((notification) {
                              return ListTile(
                                leading: const Icon(Icons.notifications_active),
                                title: Text(notification.title ?? 'بدون عنوان'),
                                subtitle: Text(
                                  'ID: ${notification.id}\n${notification.body ?? ""}',
                                ),
                                dense: true,
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Active Reminders List
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'یادآورهای فعال',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (_activeReminders.isEmpty)
                            const Text('هیچ یادآوری فعالی وجود ندارد')
                          else
                            ..._activeReminders.map((reminder) {
                              return ListTile(
                                leading: const Icon(Icons.alarm),
                                title: Text(reminder.title),
                                subtitle: Text(
                                  'زمان: ${reminder.scheduledDateTime.toString().substring(0, 16)}\n'
                                  'Notification ID: ${reminder.notificationId}',
                                ),
                                dense: true,
                              );
                            }),
                        ],
                      ),
                    ),
                  ),

                  // Help Card
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue.shade700),
                              const SizedBox(width: 8),
                              Text(
                                'راهنما',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '• تعداد "آلارم‌های زمان‌بندی شده" باید با "یادآورهای فعال" برابر باشد\n'
                            '• اگر تعداد‌ها برابر نیست، روی "بازنشانی همه آلارم‌ها" کلیک کنید\n'
                            '• برای تست، یک آلارم تستی ایجاد کنید و منتظر بمانید\n'
                            '• اگر آلارم تستی کار نکرد، مجوزهای برنامه را در تنظیمات گوشی بررسی کنید',
                            style: TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

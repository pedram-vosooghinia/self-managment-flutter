// ==================== واردات کتابخانه‌ها ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/alarm_sound_provider.dart';
import '../alarm_sounds/alarm_sounds_screen.dart';
import '../debug/alarm_debug_screen.dart';

// ==================== صفحه تنظیمات ====================
/// صفحه تنظیمات برنامه که شامل تنظیمات مختلف، مدیریت داده‌ها و اطلاعات برنامه است
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // نوار بالای صفحه
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(
        children: [
          const SizedBox(height: 8),

          // ==================== بخش یادآورها و آلارم‌ها ====================
          _buildSection(
            context,
            title: 'یادآورها و آلارم‌ها',
            children: [
              // نمایش تعداد یادآورهای فعال
              Consumer<ReminderProvider>(
                builder: (context, reminderProvider, child) {
                  final upcomingReminders = reminderProvider.upcomingReminders;
                  return ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('یادآورهای فعال'),
                    subtitle: Text('${upcomingReminders.length} یادآور آینده'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      _showRemindersDialog(context, upcomingReminders);
                    },
                  );
                },
              ),

              // مدیریت صداهای آلارم
              Consumer<AlarmSoundProvider>(
                builder: (context, alarmSoundProvider, child) {
                  final soundsCount = alarmSoundProvider.alarmSounds.length;
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: const Text('صداهای آلارم'),
                    subtitle: Text('$soundsCount صدا موجود است'),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AlarmSoundsScreen(),
                        ),
                      );
                    },
                  );
                },
              ),

              // ابزار عیب‌یابی آلارم‌ها
              ListTile(
                leading: const Icon(Icons.bug_report),
                title: const Text('عیب‌یابی آلارم‌ها'),
                subtitle: const Text('تست و رفع مشکلات آلارم'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AlarmDebugScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          // ==================== بخش مدیریت داده‌ها ====================
          _buildSection(
            context,
            title: 'مدیریت داده‌ها',
            children: [
              Consumer2<TaskProvider, GoalProvider>(
                builder: (context, taskProvider, goalProvider, child) {
                  final tasksCount = taskProvider.tasks.length;
                  final goalsCount = goalProvider.goals.length;

                  return Column(
                    children: [
                      // نمایش اطلاعات ذخیره‌سازی
                      ListTile(
                        leading: const Icon(Icons.storage),
                        title: const Text('فضای ذخیره‌سازی'),
                        subtitle: Text('$tasksCount وظیفه، $goalsCount هدف'),
                      ),

                      // پاک کردن وظایف انجام شده
                      ListTile(
                        leading: const Icon(Icons.delete_sweep),
                        title: const Text('پاک کردن وظایف انجام شده'),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          _showClearCompletedDialog(context);
                        },
                      ),

                      // پاک کردن تمام داده‌ها (خطرناک!)
                      ListTile(
                        leading: const Icon(Icons.warning, color: Colors.red),
                        title: const Text(
                          'پاک کردن همه داده‌ها',
                          style: TextStyle(color: Colors.red),
                        ),
                        trailing: const Icon(Icons.chevron_left),
                        onTap: () {
                          _showClearAllDataDialog(context);
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          // ==================== بخش درباره برنامه ====================
          _buildSection(
            context,
            title: 'درباره برنامه',
            children: [
              // نسخه برنامه
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('نسخه'),
                subtitle: Text('1.0.0'),
              ),

              // اطلاعات سازنده
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('ساخته شده با Flutter'),
                subtitle: const Text('Material Design 3'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'مدیریت شخصی',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.task_alt, size: 48),
                    children: [
                      const Text(
                        'برنامه‌ای زیبا و ساده برای مدیریت وظایف و اهداف شخصی',
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== متد کمکی: ساخت بخش‌های تنظیمات ====================
  /// ساخت یک بخش در صفحه تنظیمات با عنوان و لیست آیتم‌ها
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ==================== متد کمکی: نمایش دیالوگ یادآورها ====================
  /// نمایش لیست یادآورهای آینده در یک دیالوگ
  void _showRemindersDialog(BuildContext context, List reminders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('یادآورهای آینده'),
        content: SizedBox(
          width: double.maxFinite,
          child: reminders.isEmpty
              ? const Text('هیچ یادآور آینده‌ای وجود ندارد')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: reminders.length,
                  itemBuilder: (context, index) {
                    final reminder = reminders[index];
                    return ListTile(
                      title: Text(reminder.title),
                      subtitle: Text(reminder.body ?? ''),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  // ==================== متد کمکی: دیالوگ حذف وظایف انجام شده ====================
  /// نمایش دیالوگ تأیید برای حذف وظایف انجام شده
  void _showClearCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاک کردن وظایف انجام شده'),
        content: const Text(
          'این عملیات تمام وظایف انجام شده را به طور دائمی حذف می‌کند. این عمل قابل بازگشت نیست.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              final taskProvider = context.read<TaskProvider>();
              final completedTasks = taskProvider.completedTasks;
              for (var task in completedTasks) {
                taskProvider.deleteTask(task.id);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${completedTasks.length} وظیفه حذف شد'),
                ),
              );
            },
            child: const Text('پاک کردن'),
          ),
        ],
      ),
    );
  }

  // ==================== متد کمکی: دیالوگ حذف تمام داده‌ها ====================
  /// نمایش دیالوگ تأیید برای حذف تمام داده‌های برنامه (خطرناک!)
  void _showClearAllDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('پاک کردن همه داده‌ها'),
        content: const Text(
          'این عملیات تمام وظایف، اهداف و یادآورها را به طور دائمی حذف می‌کند. این عمل قابل بازگشت نیست.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().deleteAllTasks();
              context.read<GoalProvider>().deleteAllGoals();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمام داده‌ها پاک شد')),
              );
            },
            child: const Text('پاک کردن همه'),
          ),
        ],
      ),
    );
  }
}

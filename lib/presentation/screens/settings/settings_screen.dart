// ==================== واردات کتابخانه‌ها ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/alarm_sound_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/goal_provider.dart';
import '../alarm_sounds/alarm_sounds_screen.dart';
import '../debug/alarm_debug_screen.dart';
import '../../../core/services/export_service.dart';

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

          // ==================== بخش Export داده‌ها ====================
          _buildSection(
            context,
            title: 'خروجی داده‌ها (Export)',
            children: [
              // Export تسک‌ها
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('خروجی تسک‌ها'),
                subtitle: const Text('دریافت فایل Excel از تسک‌ها'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _exportTasks(context),
              ),

              // Export اهداف
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('خروجی اهداف'),
                subtitle: const Text('دریافت فایل Excel از اهداف'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _exportGoals(context),
              ),

              // Export همه داده‌ها
              ListTile(
                leading: const Icon(Icons.cloud_download),
                title: const Text('خروجی کامل'),
                subtitle: const Text('دریافت فایل Excel از همه داده‌ها'),
                trailing: const Icon(Icons.chevron_left),
                onTap: () => _exportAll(context),
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

  // ==================== متدهای Export ====================

  /// Export تسک‌ها به Excel
  Future<void> _exportTasks(BuildContext context) async {
    final taskProvider = context.read<TaskProvider>();
    final tasks = taskProvider.tasks;

    if (tasks.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هیچ تسکی برای خروجی وجود ندارد')),
      );
      return;
    }

    // نمایش loading
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('در حال ایجاد فایل Excel...'),
              ],
            ),
          ),
        ),
      ),
    );

    final exportService = ExportService();
    final filePath = await exportService.exportTasksToExcel(tasks);

    if (!context.mounted) return;
    Navigator.pop(context); // بستن loading

    if (filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ فایل Excel با موفقیت ایجاد شد\n${tasks.length} تسک'),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ خطا در ایجاد فایل Excel'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Export اهداف به Excel
  Future<void> _exportGoals(BuildContext context) async {
    final goalProvider = context.read<GoalProvider>();
    final goals = goalProvider.goals;

    if (goals.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هیچ هدفی برای خروجی وجود ندارد')),
      );
      return;
    }

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('در حال ایجاد فایل Excel...'),
              ],
            ),
          ),
        ),
      ),
    );

    final exportService = ExportService();
    final filePath = await exportService.exportGoalsToExcel(goals);

    if (!context.mounted) return;
    Navigator.pop(context);

    if (filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ فایل Excel با موفقیت ایجاد شد\n${goals.length} هدف'),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ خطا در ایجاد فایل Excel'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Export همه داده‌ها به Excel
  Future<void> _exportAll(BuildContext context) async {
    final taskProvider = context.read<TaskProvider>();
    final goalProvider = context.read<GoalProvider>();
    final tasks = taskProvider.tasks;
    final goals = goalProvider.goals;

    if (tasks.isEmpty && goals.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('هیچ داده‌ای برای خروجی وجود ندارد')),
      );
      return;
    }

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('در حال ایجاد فایل Excel...'),
              ],
            ),
          ),
        ),
      ),
    );

    final exportService = ExportService();
    final filePath = await exportService.exportAllToExcel(tasks, goals);

    if (!context.mounted) return;
    Navigator.pop(context);

    if (filePath != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '✅ فایل Excel با موفقیت ایجاد شد\n'
            '${tasks.length} تسک و ${goals.length} هدف',
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('❌ خطا در ایجاد فایل Excel'),
          backgroundColor: Colors.red,
        ),
      );
    }
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
}

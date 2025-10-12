// ==================== واردات کتابخانه‌ها ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
}

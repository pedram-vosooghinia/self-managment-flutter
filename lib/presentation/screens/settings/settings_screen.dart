import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/goal_provider.dart';
import '../../providers/alarm_sound_provider.dart';
import '../alarm_sounds/alarm_sounds_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _buildSection(
            context,
            title: 'Reminders',
            children: [
              Consumer<ReminderProvider>(
                builder: (context, reminderProvider, child) {
                  final upcomingReminders = reminderProvider.upcomingReminders;
                  return ListTile(
                    leading: const Icon(Icons.notifications_active),
                    title: const Text('Active Reminders'),
                    subtitle: Text('${upcomingReminders.length} upcoming'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _showRemindersDialog(context, upcomingReminders);
                    },
                  );
                },
              ),
              Consumer<AlarmSoundProvider>(
                builder: (context, alarmSoundProvider, child) {
                  final soundsCount = alarmSoundProvider.alarmSounds.length;
                  return ListTile(
                    leading: const Icon(Icons.music_note),
                    title: const Text('Alarm Sounds'),
                    subtitle: Text('$soundsCount sound${soundsCount != 1 ? 's' : ''} available'),
                    trailing: const Icon(Icons.chevron_right),
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
            ],
          ),
          _buildSection(
            context,
            title: 'Data',
            children: [
              Consumer2<TaskProvider, GoalProvider>(
                builder: (context, taskProvider, goalProvider, child) {
                  final tasksCount = taskProvider.tasks.length;
                  final goalsCount = goalProvider.goals.length;
                  
                  return Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.storage),
                        title: const Text('Storage'),
                        subtitle: Text('$tasksCount tasks, $goalsCount goals'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_sweep),
                        title: const Text('Clear Completed Tasks'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          _showClearCompletedDialog(context);
                        },
                      ),
                      ListTile(
                        leading: Icon(
                          Icons.warning,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        title: Text(
                          'Clear All Data',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
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
          _buildSection(
            context,
            title: 'About',
            children: [
              const ListTile(
                leading: Icon(Icons.info),
                title: Text('Version'),
                subtitle: Text('1.0.0'),
              ),
              ListTile(
                leading: const Icon(Icons.code),
                title: const Text('Built with Flutter'),
                subtitle: const Text('Material Design 3'),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Self Management',
                    applicationVersion: '1.0.0',
                    applicationIcon: const Icon(Icons.task_alt, size: 48),
                    children: [
                      const Text(
                        'A beautiful and minimal task and goal management app.',
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
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
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

  void _showRemindersDialog(BuildContext context, List reminders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upcoming Reminders'),
        content: SizedBox(
          width: double.maxFinite,
          child: reminders.isEmpty
              ? const Text('No upcoming reminders')
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
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClearCompletedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: const Text(
          'This will permanently delete all completed tasks. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
                  content: Text('Deleted ${completedTasks.length} tasks'),
                ),
              );
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showClearAllDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will permanently delete ALL tasks, goals, and reminders. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().deleteAllTasks();
              context.read<GoalProvider>().deleteAllGoals();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared'),
                ),
              );
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}


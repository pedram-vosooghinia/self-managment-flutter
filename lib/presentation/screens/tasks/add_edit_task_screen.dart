import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../../providers/reminder_provider.dart';
import '../../providers/alarm_sound_provider.dart';
import '../../../data/models/reminder_model.dart';
import '../alarm_sounds/alarm_sounds_screen.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _reminderDateTime;
  String? _alarmSoundId;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _reminderDateTime = widget.task?.reminderDateTime;
    _alarmSoundId = widget.task?.alarmSoundId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'ویرایش وظیفه' : 'افزودن وظیفه'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteDialog(context);
              },
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'عنوان',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'توضیحات (اختیاری)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('یادآوری'),
                  subtitle: _reminderDateTime != null
                      ? Text(
                          DateFormat(
                            'MMM dd, yyyy - HH:mm',
                          ).format(_reminderDateTime!),
                        )
                      : const Text('یادآوری ندارد'),
                  trailing: _reminderDateTime != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _reminderDateTime = null;
                              _alarmSoundId = null;
                            });
                          },
                        )
                      : null,
                  onTap: _pickReminderDateTime,
                ),
                if (_reminderDateTime != null) ...[
                  const Divider(height: 1),
                  Consumer<AlarmSoundProvider>(
                    builder: (context, alarmSoundProvider, child) {
                      final selectedSound = _alarmSoundId != null
                          ? alarmSoundProvider.getAlarmSoundById(_alarmSoundId!)
                          : null;
                      final soundName =
                          selectedSound?.name ?? 'انتخاب صدای آلارم';

                      return ListTile(
                        leading: const Icon(Icons.music_note),
                        title: const Text('صدای آلارم'),
                        subtitle: Text(soundName),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _selectAlarmSound,
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saveTask,
            icon: const Icon(Icons.save),
            label: Text(isEditing ? 'بروزرسانی وظیفه' : 'ایجاد وظیفه'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickReminderDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _reminderDateTime ?? DateTime.now(),
        ),
      );

      if (time != null) {
        setState(() {
          _reminderDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _selectAlarmSound() async {
    final alarmSoundProvider = context.read<AlarmSoundProvider>();
    final alarmSounds = alarmSoundProvider.alarmSounds;

    if (alarmSounds.isEmpty) {
      // No alarm sounds available, navigate to alarm sounds screen
      final result = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('صدای آلارم ندارد'),
          content: const Text(
            'شما هیچ صدای آلارمی ندارید. آیا می‌خواهید یکی اضافه کنید؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('انصراف'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('اضافه کردن صدای آلارم'),
            ),
          ],
        ),
      );

      if (result == true) {
        if (!mounted) return;
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AlarmSoundsScreen()),
        );
        if (!mounted) return;
        // Reload alarm sounds after returning
        alarmSoundProvider.loadAlarmSounds();
      }
      return;
    }

    // Show alarm sound picker
    String? tempSelectedSound = _alarmSoundId;
    final selectedSound = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('انتخاب صدای آلارم'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: alarmSounds.length,
              itemBuilder: (context, index) {
                final sound = alarmSounds[index];

                final isSelected = sound.id == tempSelectedSound;
                return ListTile(
                  leading: Icon(
                    sound.isSystemSound
                        ? Icons.notifications_active
                        : Icons.music_note,
                  ),
                  title: Text(sound.name),
                  subtitle: Text(
                    sound.isSystemSound ? 'صدای سیستم' : 'صدای سفارشی',
                  ),
                  trailing: isSelected ? const Icon(Icons.check) : null,
                  onTap: () {
                    Navigator.pop(context, sound.id);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('انصراف'),
            ),
            TextButton(
              onPressed: () async {
                // Navigate to add alarm sound
                Navigator.pop(context);
                if (!context.mounted) return;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AlarmSoundsScreen(),
                  ),
                );
              },
              child: const Text('مدیریت صدای آلارم'),
            ),
          ],
        ),
      ),
    );

    if (selectedSound != null) {
      setState(() {
        _alarmSoundId = selectedSound;
      });
    }
  }

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('لطفا عنوان وارد کنید')));
      return;
    }

    final taskProvider = context.read<TaskProvider>();
    final reminderProvider = context.read<ReminderProvider>();

    if (widget.task != null) {
      // Update existing task
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        reminderDateTime: _reminderDateTime,
        alarmSoundId: _alarmSoundId,
      );
      taskProvider.updateTask(updatedTask);

      // Update reminder if needed
      if (_reminderDateTime != null) {
        // Get the alarm sound file path from the ID
        final alarmSoundPath = _alarmSoundId != null
            ? context
                  .read<AlarmSoundProvider>()
                  .getAlarmSoundById(_alarmSoundId!)
                  ?.filePath
            : null;

        reminderProvider.addReminder(
          itemId: updatedTask.id,
          type: ReminderType.task,
          scheduledDateTime: _reminderDateTime!,
          title: 'Task Reminder: ${updatedTask.title}',
          body: updatedTask.description,
          alarmSoundPath: alarmSoundPath,
        );
      }
    } else {
      // Create new task
      taskProvider.addTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        reminderDateTime: _reminderDateTime,
        alarmSoundId: _alarmSoundId,
      );

      // Add reminder if set
      if (_reminderDateTime != null) {
        // Note: We need the task ID, so this should be handled differently
        // For now, we'll add it in the task creation method
      }
    }

    Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف وظیفه'),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید این وظیفه را حذف کنید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(widget.task!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

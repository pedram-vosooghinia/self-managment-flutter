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
  DateTime? _dueDate;
  DateTime? _reminderDateTime;
  String? _alarmSoundId;
  int _priority = 1;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _dueDate = widget.task?.dueDate;
    _reminderDateTime = widget.task?.reminderDateTime;
    _alarmSoundId = widget.task?.alarmSoundId;
    _priority = widget.task?.priority ?? 1;
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
        title: Text(isEditing ? 'Edit Task' : 'Add Task'),
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
              labelText: 'Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
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
                  leading: const Icon(Icons.priority_high),
                  title: const Text('Priority'),
                  trailing: SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Low')),
                      ButtonSegment(value: 1, label: Text('Medium')),
                      ButtonSegment(value: 2, label: Text('High')),
                    ],
                    selected: {_priority},
                    onSelectionChanged: (Set<int> selected) {
                      setState(() {
                        _priority = selected.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Due Date'),
                  subtitle: _dueDate != null
                      ? Text(DateFormat('MMM dd, yyyy').format(_dueDate!))
                      : const Text('No date set'),
                  trailing: _dueDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _dueDate = null;
                            });
                          },
                        )
                      : null,
                  onTap: _pickDueDate,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Reminder'),
                  subtitle: _reminderDateTime != null
                      ? Text(
                          DateFormat(
                            'MMM dd, yyyy - HH:mm',
                          ).format(_reminderDateTime!),
                        )
                      : const Text('No reminder set'),
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
                          selectedSound?.name ?? 'Select alarm sound';

                      return ListTile(
                        leading: const Icon(Icons.music_note),
                        title: const Text('Alarm Sound'),
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
            label: Text(isEditing ? 'Update Task' : 'Create Task'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (date != null) {
      setState(() {
        _dueDate = date;
      });
    }
  }

  Future<void> _pickReminderDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _reminderDateTime ?? _dueDate ?? DateTime.now(),
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
          title: const Text('No Alarm Sounds'),
          content: const Text(
            'You haven\'t added any alarm sounds yet. Would you like to add one now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Add Sounds'),
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
          title: const Text('Select Alarm Sound'),
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
                    sound.isSystemSound ? 'System Sound' : 'Custom Sound',
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
              child: const Text('Cancel'),
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
              child: const Text('Manage Sounds'),
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
      ).showSnackBar(const SnackBar(content: Text('Please enter a title')));
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
        dueDate: _dueDate,
        reminderDateTime: _reminderDateTime,
        alarmSoundId: _alarmSoundId,
        priority: _priority,
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
        dueDate: _dueDate,
        reminderDateTime: _reminderDateTime,
        alarmSoundId: _alarmSoundId,
        priority: _priority,
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
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(widget.task!.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

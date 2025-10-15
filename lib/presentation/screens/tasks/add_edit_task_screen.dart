import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/task_model.dart';
import '../../providers/task_provider.dart';
import '../tasks/task_title_field.dart';
import '../tasks/recurring_section.dart';
import '../tasks/reminder_section.dart';

class AddEditTaskScreen extends StatefulWidget {
  final TaskModel? task;
  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late TextEditingController _titleController;
  DateTime? _reminderDateTime;
  bool _isRecurring = false;
  TimeOfDay? _recurringTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _reminderDateTime = widget.task?.reminderDateTime;
    _isRecurring = widget.task?.isRecurring ?? false;
    if (widget.task?.recurringTime != null) {
      _recurringTime = TimeOfDay.fromDateTime(widget.task!.recurringTime!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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
              onPressed: () => _showDeleteDialog(context),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TaskTitleField(controller: _titleController),

          const SizedBox(height: 16),

          // بخش انتخاب نوع وظیفه (تکراری یا یکبار)
          SwitchListTile(
            title: const Text('تکرار روزانه'),
            subtitle: const Text('این وظیفه هر روز در ساعت مشخص تکرار شود'),
            value: _isRecurring,
            onChanged: (value) {
              setState(() {
                _isRecurring = value;
                if (!value) _recurringTime = null;
                if (value) _reminderDateTime = null;
              });
            },
          ),

          const SizedBox(height: 8),

          if (_isRecurring)
            RecurringSection(
              recurringTime: _recurringTime,
              onPickTime: _pickRecurringTime,
            )
          else
            ReminderSection(
              reminderDateTime: _reminderDateTime,
              onPickReminder: _pickReminderDateTime,
              onClear: () => setState(() => _reminderDateTime = null),
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
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (!mounted || date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_reminderDateTime ?? DateTime.now()),
    );

    if (!mounted || time == null) return;

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

  Future<void> _pickRecurringTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _recurringTime ?? TimeOfDay.now(),
    );

    if (!mounted || time == null) return;

    setState(() => _recurringTime = time);
  }

  Future<void> _saveTask() async {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      _showSnack('لطفا عنوان را وارد کنید');
      return;
    }

    if (_isRecurring && _recurringTime == null) {
      _showSnack('لطفا ساعت تکرار را انتخاب کنید');
      return;
    }

    if (!_isRecurring && _reminderDateTime == null) {
      _showSnack('لطفا تاریخ و ساعت یادآوری را انتخاب کنید');
      return;
    }

    final provider = context.read<TaskProvider>();
    final now = DateTime.now();

    final recurringDateTime = _isRecurring && _recurringTime != null
        ? DateTime(
            now.year,
            now.month,
            now.day,
            _recurringTime!.hour,
            _recurringTime!.minute,
          )
        : null;

    if (widget.task != null) {
      await provider.updateTask(
        widget.task!.copyWith(
          title: title,
          reminderDateTime: _isRecurring ? null : _reminderDateTime,
          isRecurring: _isRecurring,
          recurringTime: recurringDateTime,
        ),
      );
    } else {
      await provider.addTask(
        title: title,
        reminderDateTime: _isRecurring ? null : _reminderDateTime,
        isRecurring: _isRecurring,
        recurringTime: recurringDateTime,
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showDeleteDialog(BuildContext dialogContext) {
    final provider = context.read<TaskProvider>();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف وظیفه'),
        content: const Text('آیا مطمئن هستید که می‌خواهید حذف کنید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await provider.deleteTask(widget.task!.id);
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

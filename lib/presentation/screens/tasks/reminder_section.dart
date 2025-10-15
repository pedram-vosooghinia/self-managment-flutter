import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReminderSection extends StatelessWidget {
  final DateTime? reminderDateTime;
  final VoidCallback onPickReminder;
  final VoidCallback onClear;

  const ReminderSection({
    super.key,
    required this.reminderDateTime,
    required this.onPickReminder,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.alarm),
        title: const Text('یادآوری'),
        subtitle: reminderDateTime != null
            ? Text(DateFormat('MMM dd, yyyy - HH:mm').format(reminderDateTime!))
            : const Text('یادآوری ندارد'),
        trailing: reminderDateTime != null
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: onClear,
              )
            : const Icon(Icons.chevron_right),
        onTap: onPickReminder,
      ),
    );
  }
}

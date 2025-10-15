import 'package:flutter/material.dart';

class RecurringSection extends StatelessWidget {
  final TimeOfDay? recurringTime;
  final VoidCallback onPickTime;

  const RecurringSection({
    super.key,
    required this.recurringTime,
    required this.onPickTime,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: const Text('ساعت تکرار'),
        subtitle: recurringTime != null
            ? Text(recurringTime!.format(context))
            : const Text('انتخاب ساعت'),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPickTime,
      ),
    );
  }
}

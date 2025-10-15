import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/task_model.dart';

class TaskCard extends StatelessWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(value: task.isCompleted, onChanged: (_) => onToggle()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (task.reminderDateTime != null) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Chip(
                            avatar: const Icon(Icons.alarm, size: 16),
                            label: Text(
                              DateFormat(
                                'MMM dd, HH:mm',
                              ).format(task.reminderDateTime!),
                              style: const TextStyle(fontSize: 12),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

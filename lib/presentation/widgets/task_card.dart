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
    final colorScheme = Theme.of(context).colorScheme;
    
    Color? priorityColor;
    switch (task.priority) {
      case 0:
        priorityColor = Colors.blue;
        break;
      case 1:
        priorityColor = Colors.orange;
        break;
      case 2:
        priorityColor = Colors.red;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => onToggle(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    if (task.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (task.dueDate != null)
                          Chip(
                            avatar: Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: task.isOverdue
                                  ? Colors.red
                                  : task.isToday
                                      ? Colors.green
                                      : null,
                            ),
                            label: Text(
                              DateFormat('MMM dd').format(task.dueDate!),
                              style: TextStyle(
                                fontSize: 12,
                                color: task.isOverdue
                                    ? Colors.red
                                    : task.isToday
                                        ? Colors.green
                                        : null,
                              ),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        if (task.reminderDateTime != null)
                          Chip(
                            avatar: const Icon(Icons.alarm, size: 16),
                            label: Text(
                              DateFormat('HH:mm').format(task.reminderDateTime!),
                              style: const TextStyle(fontSize: 12),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        Chip(
                          avatar: Icon(
                            Icons.priority_high,
                            size: 16,
                            color: priorityColor,
                          ),
                          label: Text(
                            ['Low', 'Medium', 'High'][task.priority],
                            style: TextStyle(
                              fontSize: 12,
                              color: priorityColor,
                            ),
                          ),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onDelete,
                color: colorScheme.error,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/goal_model.dart';

class GoalCard extends StatelessWidget {
  final GoalModel goal;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const GoalCard({
    super.key,
    required this.goal,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: goal.isCompleted,
                    onChanged: (_) => onToggle(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            decoration: goal.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        if (goal.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            goal.description!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(
                    avatar: Icon(
                      goal.type == GoalType.shortTerm
                          ? Icons.calendar_today
                          : Icons.calendar_month,
                      size: 16,
                    ),
                    label: Text(
                      goal.type == GoalType.shortTerm
                          ? 'Short Term'
                          : 'Long Term',
                      style: const TextStyle(fontSize: 12),
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                  if (goal.targetDate != null)
                    Chip(
                      avatar: const Icon(Icons.flag, size: 16),
                      label: Text(
                        'Due ${DateFormat('MMM dd, yyyy').format(goal.targetDate!)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (goal.reminderDateTime != null)
                    Chip(
                      avatar: const Icon(Icons.alarm, size: 16),
                      label: Text(
                        DateFormat(
                          'MMM dd, HH:mm',
                        ).format(goal.reminderDateTime!),
                        style: const TextStyle(fontSize: 12),
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TaskTitleField extends StatelessWidget {
  final TextEditingController controller;
  const TaskTitleField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'عنوان وظیفه',
        prefixIcon: Icon(Icons.title),
        border: OutlineInputBorder(),
      ),
      textCapitalization: TextCapitalization.sentences,
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../data/models/workout_model.dart';
import '../../providers/workout_provider.dart';

class AddEditWorkoutScreen extends StatefulWidget {
  final WorkoutModel? workout;

  const AddEditWorkoutScreen({super.key, this.workout});

  @override
  State<AddEditWorkoutScreen> createState() => _AddEditWorkoutScreenState();
}

class _AddEditWorkoutScreenState extends State<AddEditWorkoutScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _durationOrRepsController;
  List<String> _imagePaths = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.workout?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.workout?.description ?? '',
    );
    _durationOrRepsController = TextEditingController(
      text: widget.workout?.durationOrReps ?? '',
    );
    _imagePaths = List<String>.from(widget.workout?.imagePaths ?? []);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationOrRepsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.workout != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Workout' : 'Add Workout'),
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
              labelText: 'Workout Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.fitness_center),
              hintText: 'e.g., Biceps Curl',
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
              hintText: 'Brief description of the exercise',
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _durationOrRepsController,
            decoration: const InputDecoration(
              labelText: 'Duration/Reps (optional)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer),
              hintText: 'e.g., 3 sets x 12 reps or 30 minutes',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          // Images Section
          Text(
            'Exercise Images',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Add images showing how to perform the exercise',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          // Image Grid
          if (_imagePaths.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _imagePaths.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: FileImage(File(_imagePaths[index])),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.red,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _imagePaths.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickImages,
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('Add Images'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _saveWorkout,
            icon: const Icon(Icons.save),
            label: Text(isEditing ? 'Update Workout' : 'Create Workout'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          _imagePaths.addAll(result.paths.whereType<String>());
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
      }
    }
  }

  void _saveWorkout() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workout name')),
      );
      return;
    }

    final workoutProvider = context.read<WorkoutProvider>();

    if (widget.workout != null) {
      // Update existing workout
      final updatedWorkout = widget.workout!.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        durationOrReps: _durationOrRepsController.text.trim().isEmpty
            ? null
            : _durationOrRepsController.text.trim(),
        imagePaths: _imagePaths,
      );
      workoutProvider.updateWorkout(updatedWorkout);
    } else {
      // Create new workout
      workoutProvider.addWorkout(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        durationOrReps: _durationOrRepsController.text.trim().isEmpty
            ? null
            : _durationOrRepsController.text.trim(),
        imagePaths: _imagePaths.isEmpty ? null : _imagePaths,
      );
    }

    Navigator.pop(context);
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout'),
        content: const Text('Are you sure you want to delete this workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              context.read<WorkoutProvider>().deleteWorkout(widget.workout!.id);
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

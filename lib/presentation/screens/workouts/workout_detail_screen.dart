import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/workout_model.dart';
import '../../providers/workout_provider.dart';
import 'add_edit_workout_screen.dart';

class WorkoutDetailScreen extends StatefulWidget {
  final WorkoutModel workout;

  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  State<WorkoutDetailScreen> createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends State<WorkoutDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AddEditWorkoutScreen(workout: widget.workout),
                ),
              ).then((_) {
                // Reload workout data after editing
                setState(() {});
              });
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          // Image Carousel
          if (widget.workout.hasImages)
            SizedBox(
              height: 300,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: widget.workout.imagePaths.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showFullScreenImage(
                            context,
                            widget.workout.imagePaths,
                            index,
                          );
                        },
                        child: Image.file(
                          File(widget.workout.imagePaths[index]),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 64),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  // Image indicator
                  if (widget.workout.imagePaths.length > 1)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.workout.imagePaths.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            Container(
              height: 200,
              color: Colors.blue[100],
              child: const Center(
                child: Icon(Icons.fitness_center, size: 64, color: Colors.blue),
              ),
            ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.workout.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatItem(
                                context,
                                Icons.timer,
                                'Duration/Reps',
                                widget.workout.displayDurationOrReps,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            Expanded(
                              child: _buildStatItem(
                                context,
                                Icons.check_circle,
                                'Completed',
                                '${widget.workout.timesCompleted}x',
                              ),
                            ),
                          ],
                        ),
                        if (widget.workout.lastPerformed != null) ...[
                          const Divider(height: 24),
                          _buildStatItem(
                            context,
                            Icons.calendar_today,
                            'Last Performed',
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(widget.workout.lastPerformed!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Description
                if (widget.workout.description != null) ...[
                  Text(
                    'Description',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.workout.description!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Mark as performed button
                FilledButton.icon(
                  onPressed: () {
                    context.read<WorkoutProvider>().markAsPerformed(
                      widget.workout.id,
                    );
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Workout marked as completed!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Mark as Completed'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _showFullScreenImage(
    BuildContext context,
    List<String> imagePaths,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _FullScreenImageGallery(
          imagePaths: imagePaths,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _FullScreenImageGallery extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const _FullScreenImageGallery({
    required this.imagePaths,
    required this.initialIndex,
  });

  @override
  State<_FullScreenImageGallery> createState() =>
      _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<_FullScreenImageGallery> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_currentIndex + 1} / ${widget.imagePaths.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.imagePaths.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            child: Center(
              child: Image.file(
                File(widget.imagePaths[index]),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      ),
    );
  }
}

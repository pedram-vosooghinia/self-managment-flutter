import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../widgets/task_card.dart';
import 'add_edit_task_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            onPressed: () async {
              final taskProvider = context.read<TaskProvider>();
              await taskProvider.testAlarm();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('آلارم تست برای 10 ثانیه بعد تنظیم شد'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
            icon: const Icon(Icons.alarm),
            tooltip: 'تست آلارم',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'وظایف فعلی'),
            Tab(text: 'یادآوری‌های آینده'),
            Tab(text: 'انجام شده'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList('today'),
          _buildTaskList('upcoming'),
          _buildTaskList('completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditTaskScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('افزودن وظیفه'),
      ),
    );
  }

  Widget _buildTaskList(String filter) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final tasks = switch (filter) {
          'today' => taskProvider.todayTasks,
          'upcoming' => taskProvider.upcomingTasks,
          'completed' => taskProvider.completedTasks,
          _ => taskProvider.incompleteTasks,
        };

        if (taskProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (tasks.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.task_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'هیچ وظیفه‌ای نداریم',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditTaskScreen(task: task),
                  ),
                );
              },
              onToggle: () {
                taskProvider.toggleTaskCompletion(task.id);
              },
              onDelete: () {
                _showDeleteDialog(context, task.id);
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف وظیفه'),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید این وظیفه را حذف کنید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(taskId);
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

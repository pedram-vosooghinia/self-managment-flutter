import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/goal_provider.dart';
import '../../widgets/goal_card.dart';
import 'add_edit_goal_screen.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen>
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
        title: const Text('هدف ها'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'کوتاه مدت'),
            Tab(text: 'بلند مدت'),
            Tab(text: 'تکمیل شده'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGoalList('shortTerm'),
          _buildGoalList('longTerm'),
          _buildGoalList('completed'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditGoalScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('اضافه کردن هدف'),
      ),
    );
  }

  Widget _buildGoalList(String filter) {
    return Consumer<GoalProvider>(
      builder: (context, goalProvider, child) {
        final goals = switch (filter) {
          'shortTerm' => goalProvider.shortTermGoals,
          'longTerm' => goalProvider.longTermGoals,
          'completed' => goalProvider.completedGoals,
          _ => goalProvider.activeGoals,
        };

        if (goalProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (goals.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.flag_outlined, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'هیچ هدفی نداریم',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return GoalCard(
              goal: goal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditGoalScreen(goal: goal),
                  ),
                );
              },
              onToggle: () {
                goalProvider.toggleGoalCompletion(goal.id);
              },
              onDelete: () {
                _showDeleteDialog(context, goal.id);
              },
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String goalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف هدف'),
        content: const Text(
          'آیا مطمئن هستید که می‌خواهید این هدف را حذف کنید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف'),
          ),
          FilledButton(
            onPressed: () {
              context.read<GoalProvider>().deleteGoal(goalId);
              Navigator.pop(context);
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}

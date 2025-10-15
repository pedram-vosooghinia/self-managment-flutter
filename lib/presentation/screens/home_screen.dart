// وارد کردن کتابخانه‌های لازم
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
// import '../providers/goal_provider.dart';
import '../providers/workout_provider.dart';
import 'tasks/tasks_screen.dart';
// import 'goals/goals_screen.dart';
import 'workouts/workouts_screen.dart';
// import 'settings/settings_screen.dart';

/// صفحه اصلی برنامه که شامل نوار ناوبری پایین و مدیریت صفحات مختلف است
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// کلاس State برای مدیریت وضعیت صفحه اصلی
class _HomeScreenState extends State<HomeScreen> {
  // اندیس صفحه انتخاب شده در نوار ناوبری (پیش‌فرض: 0)
  int _selectedIndex = 0;

  // لیست صفحات قابل نمایش در برنامه
  final List<Widget> _screens = [
    const TasksScreen(), // صفحه وظایف
    // const GoalsScreen(), // صفحه اهداف
    const WorkoutsScreen(), // صفحه تمرینات ورزشی
    // const SettingsScreen(), // صفحه تنظیمات
  ];

  @override
  void initState() {
    super.initState();
    // بارگذاری داده‌های اولیه پس از ساخته شدن ویجت
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // بارگذاری وظایف از دیتابیس
      context.read<TaskProvider>().loadTasks();
      // بارگذاری اهداف از دیتابیس
      // context.read<GoalProvider>().loadGoals();
      // بارگذاری تمرینات ورزشی از دیتابیس
      context.read<WorkoutProvider>().loadWorkouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // نمایش صفحه انتخاب شده بر اساس اندیس
      body: _screens[_selectedIndex],
      // نوار ناوبری پایین صفحه
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        // هنگام انتخاب آیتم جدید، وضعیت به‌روزرسانی می‌شود
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // آیتم‌های نوار ناوبری
        destinations: const [
          // آیتم وظایف
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'تسک‌ها',
          ),

          // // آیتم اهداف
          // NavigationDestination(
          //   icon: Icon(Icons.flag_outlined),
          //   selectedIcon: Icon(Icons.flag),
          //   label: 'اهداف',
          // ),

          // آیتم تمرینات ورزشی
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'باشگاه',
          ),
          // آیتم تنظیمات
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'تنظیمات',
          ),
        ],
      ),
    );
  }
}

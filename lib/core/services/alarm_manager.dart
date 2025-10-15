import 'package:flutter/material.dart';
import 'package:self_management/presentation/screens/alarm/alarm_screen.dart';

class AlarmManager {
  static GlobalKey<NavigatorState>? navigatorKey;

  /// باز کردن صفحه آلارم
  static void openAlarmScreen(String taskTitle, String taskId) {
    final context = navigatorKey?.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              AlarmScreen(taskTitle: taskTitle, taskId: taskId),
        ),
      );
    }
  }

  /// بستن صفحه آلارم
  static void closeAlarmScreen() {
    final context = navigatorKey?.currentContext;
    if (context != null) {
      Navigator.of(context).pop();
    }
  }
}

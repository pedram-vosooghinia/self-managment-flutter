
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;

import '../../data/models/task_model.dart';
import '../../data/models/goal_model.dart';

// Conditional imports for platform-specific implementation
import 'export_service_stub.dart' 
  if (dart.library.io) 'export_service_mobile.dart' 
  if (dart.library.html) 'export_service_web.dart';


/// A service for exporting data to Excel format.
class ExportService {
  /// Exports a list of tasks to an Excel file.
  Future<String?> exportTasksToExcel(List<TaskModel> tasks) async {
    try {
      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      Sheet sheet = excel['Tasks'];

      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Title'),
        TextCellValue('Description'),
        TextCellValue('Status'),
        TextCellValue('Recurring'),
        TextCellValue('Creation Date'),
        TextCellValue('Reminder'),
        TextCellValue('Recurring Time'),
      ]);

      for (int col = 0; col < 8; col++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).cellStyle = headerStyle;
      }

      int rowIndex = 1;
      for (var task in tasks) {
        sheet.appendRow([
          IntCellValue(rowIndex),
          TextCellValue(task.title),
          TextCellValue(task.isCompleted ? '✅ Completed' : '⏳ Pending'),
          TextCellValue(task.isRecurring ? '🔄 Daily' : '📌 Once'),
          TextCellValue(DateFormat('yyyy/MM/dd - HH:mm').format(task.createdAt)),
          TextCellValue(task.reminderDateTime != null ? DateFormat('yyyy/MM/dd - HH:mm').format(task.reminderDateTime!) : '-'),
          TextCellValue(task.recurringTime != null ? DateFormat('HH:mm').format(task.recurringTime!) : '-'),
        ]);
        rowIndex++;
      }

      sheet.setColumnWidth(0, 8.0);
      sheet.setColumnWidth(1, 30.0);
      sheet.setColumnWidth(2, 40.0);
      sheet.setColumnWidth(3, 15.0);
      sheet.setColumnWidth(4, 12.0);
      sheet.setColumnWidth(5, 20.0);
      sheet.setColumnWidth(6, 20.0);
      sheet.setColumnWidth(7, 12.0);

      return await saveAndShareExcel(excel, 'tasks_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx');
    } catch (e) {
      developer.log('Error exporting tasks: $e', name: 'ExportService');
      return null;
    }
  }

  /// Exports a list of goals to an Excel file.
  Future<String?> exportGoalsToExcel(List<GoalModel> goals) async {
    try {
      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      Sheet sheet = excel['Goals'];

      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      sheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Title'),
        TextCellValue('Description'),
        TextCellValue('Type'),
        TextCellValue('Status'),
        TextCellValue('Creation Date'),
        TextCellValue('Reminder'),
      ]);

      for (int col = 0; col < 7; col++) {
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).cellStyle = headerStyle;
      }

      int rowIndex = 1;
      for (var goal in goals) {
        sheet.appendRow([
          IntCellValue(rowIndex),
          TextCellValue(goal.title),
          TextCellValue(goal.description ?? '-'),
          TextCellValue(goal.type == GoalType.shortTerm ? '📅 Short-term' : '🎯 Long-term'),
          TextCellValue(goal.isCompleted ? '✅ Completed' : '⏳ In Progress'),
          TextCellValue(DateFormat('yyyy/MM/dd - HH:mm').format(goal.createdAt)),
          TextCellValue(goal.reminderDateTime != null ? DateFormat('yyyy/MM/dd - HH:mm').format(goal.reminderDateTime!) : '-'),
        ]);
        rowIndex++;
      }

      sheet.setColumnWidth(0, 8.0);
      sheet.setColumnWidth(1, 30.0);
      sheet.setColumnWidth(2, 40.0);
      sheet.setColumnWidth(3, 15.0);
      sheet.setColumnWidth(4, 15.0);
      sheet.setColumnWidth(5, 20.0);
      sheet.setColumnWidth(6, 20.0);

      return await saveAndShareExcel(excel, 'goals_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx');
    } catch (e) {
      developer.log('Error exporting goals: $e', name: 'ExportService');
      return null;
    }
  }

  /// Exports all data (tasks and goals) into a single Excel file.
  Future<String?> exportAllToExcel(List<TaskModel> tasks, List<GoalModel> goals) async {
    try {
      var excel = Excel.createExcel();
      excel.delete('Sheet1');

      // ===== Tasks Sheet =====
      Sheet tasksSheet = excel['Tasks'];
      CellStyle taskHeaderStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      tasksSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Title'),
        TextCellValue('Description'),
        TextCellValue('Status'),
        TextCellValue('Recurring'),
        TextCellValue('Creation Date'),
        TextCellValue('Reminder'),
        TextCellValue('Recurring Time'),
      ]);

      for (int col = 0; col < 8; col++) {
        tasksSheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).cellStyle = taskHeaderStyle;
      }

      int taskRowIndex = 1;
      for (var task in tasks) {
        tasksSheet.appendRow([
          IntCellValue(taskRowIndex),
          TextCellValue(task.title),
          TextCellValue(task.isCompleted ? '✅ Completed' : '⏳ Pending'),
          TextCellValue(task.isRecurring ? '🔄 Daily' : '📌 Once'),
          TextCellValue(DateFormat('yyyy/MM/dd - HH:mm').format(task.createdAt)),
          TextCellValue(task.reminderDateTime != null ? DateFormat('yyyy/MM/dd - HH:mm').format(task.reminderDateTime!) : '-'),
          TextCellValue(task.recurringTime != null ? DateFormat('HH:mm').format(task.recurringTime!) : '-'),
        ]);
        taskRowIndex++;
      }

      tasksSheet.setColumnWidth(0, 8.0);
      tasksSheet.setColumnWidth(1, 30.0);
      tasksSheet.setColumnWidth(2, 40.0);
      tasksSheet.setColumnWidth(3, 15.0);
      tasksSheet.setColumnWidth(4, 12.0);
      tasksSheet.setColumnWidth(5, 20.0);
      tasksSheet.setColumnWidth(6, 20.0);
      tasksSheet.setColumnWidth(7, 12.0);

      // ===== Goals Sheet =====
      Sheet goalsSheet = excel['Goals'];
      CellStyle goalHeaderStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      goalsSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Title'),
        TextCellValue('Description'),
        TextCellValue('Type'),
        TextCellValue('Status'),
        TextCellValue('Creation Date'),
        TextCellValue('Reminder'),
      ]);

      for (int col = 0; col < 7; col++) {
        goalsSheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0)).cellStyle = goalHeaderStyle;
      }

      int goalRowIndex = 1;
      for (var goal in goals) {
        goalsSheet.appendRow([
          IntCellValue(goalRowIndex),
          TextCellValue(goal.title),
          TextCellValue(goal.description ?? '-'),
          TextCellValue(goal.type == GoalType.shortTerm ? '📅 Short-term' : '🎯 Long-term'),
          TextCellValue(goal.isCompleted ? '✅ Completed' : '⏳ In Progress'),
          TextCellValue(DateFormat('yyyy/MM/dd - HH:mm').format(goal.createdAt)),
          TextCellValue(goal.reminderDateTime != null ? DateFormat('yyyy/MM/dd - HH:mm').format(goal.reminderDateTime!) : '-'),
        ]);
        goalRowIndex++;
      }

      goalsSheet.setColumnWidth(0, 8.0);
      goalsSheet.setColumnWidth(1, 30.0);
      goalsSheet.setColumnWidth(2, 40.0);
      goalsSheet.setColumnWidth(3, 15.0);
      goalsSheet.setColumnWidth(4, 15.0);
      goalsSheet.setColumnWidth(5, 20.0);
      goalsSheet.setColumnWidth(6, 20.0);

      // ===== Summary Sheet =====
      Sheet summarySheet = excel['Summary'];
      CellStyle summaryHeaderStyle = CellStyle(
        bold: true,
        fontSize: 14,
        backgroundColorHex: ExcelColor.fromHexString('#FF9800'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      summarySheet.appendRow([TextCellValue('Summary Report'), TextCellValue('Count')]);
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).cellStyle = summaryHeaderStyle;
      summarySheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).cellStyle = summaryHeaderStyle;

      summarySheet.appendRow([TextCellValue('📝 Total Tasks'), IntCellValue(tasks.length)]);
      summarySheet.appendRow([TextCellValue('✅ Completed Tasks'), IntCellValue(tasks.where((t) => t.isCompleted).length)]);
      summarySheet.appendRow([TextCellValue('⏳ Pending Tasks'), IntCellValue(tasks.where((t) => !t.isCompleted).length)]);
      summarySheet.appendRow([TextCellValue('🔄 Recurring Tasks'), IntCellValue(tasks.where((t) => t.isRecurring).length)]);
      summarySheet.appendRow([TextCellValue(''), TextCellValue('')]); // Empty row
      summarySheet.appendRow([TextCellValue('🎯 Total Goals'), IntCellValue(goals.length)]);
      summarySheet.appendRow([TextCellValue('✅ Completed Goals'), IntCellValue(goals.where((g) => g.isCompleted).length)]);
      summarySheet.appendRow([TextCellValue('⏳ In-Progress Goals'), IntCellValue(goals.where((g) => !g.isCompleted).length)]);
      summarySheet.appendRow([TextCellValue('📅 Short-term Goals'), IntCellValue(goals.where((g) => g.type == GoalType.shortTerm).length)]);
      summarySheet.appendRow([TextCellValue('🎯 Long-term Goals'), IntCellValue(goals.where((g) => g.type == GoalType.longTerm).length)]);

      summarySheet.setColumnWidth(0, 30.0);
      summarySheet.setColumnWidth(1, 15.0);

      return await saveAndShareExcel(excel, 'all_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx');
    } catch (e) {
      developer.log('Error exporting all data: $e', name: 'ExportService');
      return null;
    }
  }
}

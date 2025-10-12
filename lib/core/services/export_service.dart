import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:developer' as developer;
import 'dart:typed_data';
import 'dart:js_interop';
import '../../data/models/task_model.dart';
import '../../data/models/goal_model.dart';

// برای Web
import 'package:web/web.dart' as web;

/// سرویس Export برای خروجی گرفتن داده‌ها به فرمت Excel
class ExportService {
  /// Export تسک‌ها به Excel
  Future<String?> exportTasksToExcel(List<TaskModel> tasks) async {
    try {
      // ایجاد فایل Excel
      var excel = Excel.createExcel();

      // حذف sheet پیش‌فرض و ایجاد sheet جدید
      excel.delete('Sheet1');
      Sheet sheet = excel['تسک‌ها'];

      // استایل‌ها
      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      // هدر جدول
      sheet.appendRow([
        TextCellValue('ردیف'),
        TextCellValue('عنوان'),
        TextCellValue('توضیحات'),
        TextCellValue('وضعیت'),
        TextCellValue('تکراری'),
        TextCellValue('تاریخ ایجاد'),
        TextCellValue('زمان یادآوری'),
        TextCellValue('ساعت تکرار'),
      ]);

      // اعمال استایل به هدر
      for (int col = 0; col < 8; col++) {
        sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
                .cellStyle =
            headerStyle;
      }

      // افزودن داده‌ها
      int rowIndex = 1;
      for (var task in tasks) {
        sheet.appendRow([
          IntCellValue(rowIndex),
          TextCellValue(task.title),
          TextCellValue(task.description ?? '-'),
          TextCellValue(task.isCompleted ? '✅ انجام شده' : '⏳ در انتظار'),
          TextCellValue(task.isRecurring ? '🔄 روزانه' : '📌 یکبار'),
          TextCellValue(
            DateFormat('yyyy/MM/dd - HH:mm').format(task.createdAt),
          ),
          TextCellValue(
            task.reminderDateTime != null
                ? DateFormat(
                    'yyyy/MM/dd - HH:mm',
                  ).format(task.reminderDateTime!)
                : '-',
          ),
          TextCellValue(
            task.recurringTime != null
                ? DateFormat('HH:mm').format(task.recurringTime!)
                : '-',
          ),
        ]);
        rowIndex++;
      }

      // تنظیم عرض ستون‌ها
      sheet.setColumnWidth(0, 8.0); // ردیف
      sheet.setColumnWidth(1, 30.0); // عنوان
      sheet.setColumnWidth(2, 40.0); // توضیحات
      sheet.setColumnWidth(3, 15.0); // وضعیت
      sheet.setColumnWidth(4, 12.0); // تکراری
      sheet.setColumnWidth(5, 20.0); // تاریخ ایجاد
      sheet.setColumnWidth(6, 20.0); // یادآوری
      sheet.setColumnWidth(7, 12.0); // ساعت تکرار

      // ذخیره فایل
      return await _saveAndShareExcel(
        excel,
        'tasks_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx',
      );
    } catch (e) {
      developer.log('خطا در export تسک‌ها: $e', name: 'ExportService');
      return null;
    }
  }

  /// Export اهداف به Excel
  Future<String?> exportGoalsToExcel(List<GoalModel> goals) async {
    try {
      var excel = Excel.createExcel();
      excel.delete('Sheet1');
      Sheet sheet = excel['اهداف'];

      // استایل هدر
      CellStyle headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      // هدر جدول
      sheet.appendRow([
        TextCellValue('ردیف'),
        TextCellValue('عنوان'),
        TextCellValue('توضیحات'),
        TextCellValue('نوع'),
        TextCellValue('وضعیت'),
        TextCellValue('تاریخ ایجاد'),
        TextCellValue('زمان یادآوری'),
      ]);

      // اعمال استایل به هدر
      for (int col = 0; col < 7; col++) {
        sheet
                .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
                .cellStyle =
            headerStyle;
      }

      // افزودن داده‌ها
      int rowIndex = 1;
      for (var goal in goals) {
        sheet.appendRow([
          IntCellValue(rowIndex),
          TextCellValue(goal.title),
          TextCellValue(goal.description ?? '-'),
          TextCellValue(
            goal.type == GoalType.shortTerm ? '📅 کوتاه مدت' : '🎯 بلند مدت',
          ),
          TextCellValue(goal.isCompleted ? '✅ انجام شده' : '⏳ در حال انجام'),
          TextCellValue(
            DateFormat('yyyy/MM/dd - HH:mm').format(goal.createdAt),
          ),
          TextCellValue(
            goal.reminderDateTime != null
                ? DateFormat(
                    'yyyy/MM/dd - HH:mm',
                  ).format(goal.reminderDateTime!)
                : '-',
          ),
        ]);
        rowIndex++;
      }

      // تنظیم عرض ستون‌ها
      sheet.setColumnWidth(0, 8.0); // ردیف
      sheet.setColumnWidth(1, 30.0); // عنوان
      sheet.setColumnWidth(2, 40.0); // توضیحات
      sheet.setColumnWidth(3, 15.0); // نوع
      sheet.setColumnWidth(4, 15.0); // وضعیت
      sheet.setColumnWidth(5, 20.0); // تاریخ ایجاد
      sheet.setColumnWidth(6, 20.0); // یادآوری

      return await _saveAndShareExcel(
        excel,
        'goals_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx',
      );
    } catch (e) {
      developer.log('خطا در export اهداف: $e', name: 'ExportService');
      return null;
    }
  }

  /// Export همه داده‌ها (تسک‌ها و اهداف) در یک فایل
  Future<String?> exportAllToExcel(
    List<TaskModel> tasks,
    List<GoalModel> goals,
  ) async {
    try {
      var excel = Excel.createExcel();
      excel.delete('Sheet1');

      // ===== Sheet تسک‌ها =====
      Sheet tasksSheet = excel['تسک‌ها'];
      CellStyle taskHeaderStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4CAF50'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      tasksSheet.appendRow([
        TextCellValue('ردیف'),
        TextCellValue('عنوان'),
        TextCellValue('توضیحات'),
        TextCellValue('وضعیت'),
        TextCellValue('تکراری'),
        TextCellValue('تاریخ ایجاد'),
        TextCellValue('زمان یادآوری'),
        TextCellValue('ساعت تکرار'),
      ]);

      for (int col = 0; col < 8; col++) {
        tasksSheet
                .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
                .cellStyle =
            taskHeaderStyle;
      }

      int taskRowIndex = 1;
      for (var task in tasks) {
        tasksSheet.appendRow([
          IntCellValue(taskRowIndex),
          TextCellValue(task.title),
          TextCellValue(task.description ?? '-'),
          TextCellValue(task.isCompleted ? '✅ انجام شده' : '⏳ در انتظار'),
          TextCellValue(task.isRecurring ? '🔄 روزانه' : '📌 یکبار'),
          TextCellValue(
            DateFormat('yyyy/MM/dd - HH:mm').format(task.createdAt),
          ),
          TextCellValue(
            task.reminderDateTime != null
                ? DateFormat(
                    'yyyy/MM/dd - HH:mm',
                  ).format(task.reminderDateTime!)
                : '-',
          ),
          TextCellValue(
            task.recurringTime != null
                ? DateFormat('HH:mm').format(task.recurringTime!)
                : '-',
          ),
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

      // ===== Sheet اهداف =====
      Sheet goalsSheet = excel['اهداف'];
      CellStyle goalHeaderStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#2196F3'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      goalsSheet.appendRow([
        TextCellValue('ردیف'),
        TextCellValue('عنوان'),
        TextCellValue('توضیحات'),
        TextCellValue('نوع'),
        TextCellValue('وضعیت'),
        TextCellValue('تاریخ ایجاد'),
        TextCellValue('زمان یادآوری'),
      ]);

      for (int col = 0; col < 7; col++) {
        goalsSheet
                .cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0))
                .cellStyle =
            goalHeaderStyle;
      }

      int goalRowIndex = 1;
      for (var goal in goals) {
        goalsSheet.appendRow([
          IntCellValue(goalRowIndex),
          TextCellValue(goal.title),
          TextCellValue(goal.description ?? '-'),
          TextCellValue(
            goal.type == GoalType.shortTerm ? '📅 کوتاه مدت' : '🎯 بلند مدت',
          ),
          TextCellValue(goal.isCompleted ? '✅ انجام شده' : '⏳ در حال انجام'),
          TextCellValue(
            DateFormat('yyyy/MM/dd - HH:mm').format(goal.createdAt),
          ),
          TextCellValue(
            goal.reminderDateTime != null
                ? DateFormat(
                    'yyyy/MM/dd - HH:mm',
                  ).format(goal.reminderDateTime!)
                : '-',
          ),
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

      // ===== Sheet خلاصه =====
      Sheet summarySheet = excel['خلاصه'];
      CellStyle summaryHeaderStyle = CellStyle(
        bold: true,
        fontSize: 14,
        backgroundColorHex: ExcelColor.fromHexString('#FF9800'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      summarySheet.appendRow([
        TextCellValue('گزارش خلاصه'),
        TextCellValue('تعداد'),
      ]);

      summarySheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
              .cellStyle =
          summaryHeaderStyle;
      summarySheet
              .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
              .cellStyle =
          summaryHeaderStyle;

      summarySheet.appendRow([
        TextCellValue('📝 کل تسک‌ها'),
        IntCellValue(tasks.length),
      ]);
      summarySheet.appendRow([
        TextCellValue('✅ تسک‌های انجام شده'),
        IntCellValue(tasks.where((t) => t.isCompleted).length),
      ]);
      summarySheet.appendRow([
        TextCellValue('⏳ تسک‌های در انتظار'),
        IntCellValue(tasks.where((t) => !t.isCompleted).length),
      ]);
      summarySheet.appendRow([
        TextCellValue('🔄 تسک‌های تکراری'),
        IntCellValue(tasks.where((t) => t.isRecurring).length),
      ]);
      summarySheet.appendRow([TextCellValue(''), TextCellValue('')]);
      summarySheet.appendRow([
        TextCellValue('🎯 کل اهداف'),
        IntCellValue(goals.length),
      ]);
      summarySheet.appendRow([
        TextCellValue('✅ اهداف انجام شده'),
        IntCellValue(goals.where((g) => g.isCompleted).length),
      ]);
      summarySheet.appendRow([
        TextCellValue('⏳ اهداف در حال انجام'),
        IntCellValue(goals.where((g) => !g.isCompleted).length),
      ]);
      summarySheet.appendRow([
        TextCellValue('📅 اهداف کوتاه مدت'),
        IntCellValue(goals.where((g) => g.type == GoalType.shortTerm).length),
      ]);
      summarySheet.appendRow([
        TextCellValue('🎯 اهداف بلند مدت'),
        IntCellValue(goals.where((g) => g.type == GoalType.longTerm).length),
      ]);

      summarySheet.setColumnWidth(0, 30.0);
      summarySheet.setColumnWidth(1, 15.0);

      return await _saveAndShareExcel(
        excel,
        'all_data_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx',
      );
    } catch (e) {
      developer.log('خطا در export همه داده‌ها: $e', name: 'ExportService');
      return null;
    }
  }

  /// ذخیره و اشتراک‌گذاری فایل Excel
  Future<String?> _saveAndShareExcel(Excel excel, String fileName) async {
    try {
      var bytes = excel.encode();
      if (bytes == null) {
        developer.log('خطا در encode فایل Excel', name: 'ExportService');
        return null;
      }

      // برای Web از download API استفاده می‌کنیم
      if (kIsWeb) {
        return _downloadExcelForWeb(bytes, fileName);
      }

      // برای موبایل/دسکتاپ
      // دریافت مسیر ذخیره‌سازی
      final Directory? directory = await getExternalStorageDirectory();
      if (directory == null) {
        developer.log('مسیر ذخیره‌سازی پیدا نشد', name: 'ExportService');
        return null;
      }

      // ایجاد مسیر فایل
      final String filePath = '${directory.path}/$fileName';

      // ذخیره فایل
      File file = File(filePath);
      await file.writeAsBytes(bytes);

      developer.log(
        'فایل Excel با موفقیت ذخیره شد: $filePath',
        name: 'ExportService',
      );

      // اشتراک‌گذاری فایل
      await Share.shareXFiles(
        [XFile(filePath)],
        subject: 'گزارش داده‌ها',
        text: 'گزارش Excel تسک‌ها و اهداف',
      );

      return filePath;
    } catch (e) {
      developer.log('خطا در ذخیره فایل: $e', name: 'ExportService');
      return null;
    }
  }

  /// دانلود فایل Excel برای Web
  String _downloadExcelForWeb(List<int> bytes, String fileName) {
    try {
      // تبدیل List<int> به Uint8List
      final uint8List = Uint8List.fromList(bytes);

      // ایجاد blob از bytes
      final blob = web.Blob(
        [uint8List.toJS].toJS,
        web.BlobPropertyBag(
          type:
              'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        ),
      );

      // ایجاد URL برای blob
      final url = web.URL.createObjectURL(blob);

      // ایجاد anchor element برای دانلود
      web.document.createElement('a') as web.HTMLAnchorElement
        ..href = url
        ..download = fileName
        ..click();

      // پاک کردن URL بعد از دانلود
      web.URL.revokeObjectURL(url);

      developer.log(
        'فایل Excel برای Web آماده دانلود شد: $fileName',
        name: 'ExportService',
      );

      return fileName;
    } catch (e) {
      developer.log('خطا در دانلود فایل Web: $e', name: 'ExportService');
      rethrow;
    }
  }
}

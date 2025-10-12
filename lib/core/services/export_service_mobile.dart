
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:developer' as developer;

/// Mobile implementation for saving and sharing Excel files.
Future<String?> saveAndShareExcel(Excel excel, String fileName) async {
  try {
    var bytes = excel.encode();
    if (bytes == null) {
      developer.log('Error encoding Excel file', name: 'ExportService');
      return null;
    }

    final Directory? directory = await getExternalStorageDirectory();
    if (directory == null) {
      developer.log('Storage directory not found', name: 'ExportService');
      return null;
    }

    final String filePath = '${directory.path}/$fileName';
    File file = File(filePath);
    await file.writeAsBytes(bytes);

    developer.log('Excel file saved successfully: $filePath', name: 'ExportService');

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Data Report',
      text: 'Excel report of tasks and goals',
    );

    return filePath;
  } catch (e) {
    developer.log('Error saving file: $e', name: 'ExportService');
    return null;
  }
}

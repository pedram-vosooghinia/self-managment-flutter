
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'dart:js_interop';
import 'package:web/web.dart' as web;
import 'dart:developer' as developer;

/// Web implementation for downloading Excel files.
Future<String?> saveAndShareExcel(Excel excel, String fileName) async {
  try {
    var bytes = excel.encode();
    if (bytes == null) {
      developer.log('Error encoding Excel file', name: 'ExportService');
      return null;
    }

    final uint8List = Uint8List.fromList(bytes);

    final blob = web.Blob(
      [uint8List.toJS].toJS,
      web.BlobPropertyBag(type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
    );

    final url = web.URL.createObjectURL(blob);

    web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = fileName
      ..click();

    web.URL.revokeObjectURL(url);

    developer.log('Excel file ready for download on Web: $fileName', name: 'ExportService');

    return fileName;
  } catch (e) {
    developer.log('Error downloading file on Web: $e', name: 'ExportService');
    rethrow;
  }
}

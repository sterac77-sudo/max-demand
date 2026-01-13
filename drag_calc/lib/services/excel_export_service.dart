import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/data_log_entry.dart';

class ExcelExportService {
  Future<void> exportToExcel(List<DataLogEntry> logs) async {
    // Create a new Excel document
    final excel = Excel.createExcel();
    final Sheet sheet = excel['Data Logs'];

    // Define header style
    final headerStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#FF6B35'),
      fontColorHex: ExcelColor.white,
    );

    // Add headers
    final headers = [
      'Track Name',
      'Pass Number',
      'Date',
      'Time',
      'Track Length',
      '60ft ET',
      '60ft MPH',
      '330ft ET',
      '330ft MPH',
      '660ft ET',
      '660ft MPH',
      '1000ft ET',
      '1000ft MPH',
      '1/4 Mile ET',
      '1/4 Mile MPH',
      '1/8 Mile ET',
      '1/8 Mile MPH',
      'Air Temp (°F)',
      'Track Temp (°F)',
      'Density Altitude (ft)',
      'Humidity (%)',
      'Wind Speed (mph)',
      'Wind Direction',
      'Tune Up Notes',
    ];

    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.cell(
        CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
      );
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = headerStyle;
    }

    // Sort logs by date (most recent first)
    logs.sort((a, b) => b.date.compareTo(a.date));

    // Add data rows
    for (var rowIndex = 0; rowIndex < logs.length; rowIndex++) {
      final log = logs[rowIndex];
      final dateFormat = DateFormat('MM/dd/yyyy');

      final rowData = [
        log.trackName,
        log.passNumber,
        dateFormat.format(log.date),
        log.time,
        log.trackLength,
        log.et60ft ?? '',
        log.mph60ft ?? '',
        log.et330ft ?? '',
        log.mph330ft ?? '',
        log.et660ft ?? '',
        log.mph660ft ?? '',
        log.et1000ft ?? '',
        log.mph1000ft ?? '',
        log.etQuarterMile ?? '',
        log.mphQuarterMile ?? '',
        log.etEighthMile ?? '',
        log.mphEighthMile ?? '',
        log.airTemp ?? '',
        log.trackTemp ?? '',
        log.densityAltitude ?? '',
        log.humidity ?? '',
        log.windSpeed ?? '',
        log.windDirection ?? '',
        log.tuneUpNotes ?? '',
      ];

      for (var colIndex = 0; colIndex < rowData.length; colIndex++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(
            columnIndex: colIndex,
            rowIndex: rowIndex + 1,
          ),
        );
        cell.value = TextCellValue(rowData[colIndex]);
      }
    }

    // Auto-fit columns (set reasonable widths)
    for (var i = 0; i < headers.length; i++) {
      sheet.setColumnWidth(i, 15.0);
    }
    // Make notes column wider
    sheet.setColumnWidth(23, 30.0);

    // Save the file
    final bytes = excel.encode();
    if (bytes == null) {
      throw Exception('Failed to encode Excel file');
    }

    // Get the downloads directory
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      directory = await getDownloadsDirectory();
    }

    if (directory == null) {
      throw Exception('Could not access storage directory');
    }

    // Create filename with timestamp
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final fileName = 'DragRacing_DataLogs_$timestamp.xlsx';
    final filePath = '${directory.path}/$fileName';

    // Write the file
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    // Share the file
    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Drag Racing Data Logs',
      text: 'Export of ${logs.length} data log entries',
    );
  }
}

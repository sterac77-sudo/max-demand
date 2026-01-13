import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_log_entry.dart';
import '../services/data_log_storage.dart';
import '../services/excel_export_service.dart';
import 'data_log_detail_screen.dart';
import 'data_log_screen.dart';

class SavedDataLogsScreen extends StatefulWidget {
  const SavedDataLogsScreen({super.key});

  @override
  State<SavedDataLogsScreen> createState() => _SavedDataLogsScreenState();
}

class _SavedDataLogsScreenState extends State<SavedDataLogsScreen> {
  final DataLogStorage _storage = DataLogStorage();
  final ExcelExportService _exportService = ExcelExportService();
  List<DataLogEntry> _logs = [];
  bool _isLoading = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _isLoading = true);
    final logs = await _storage.getAllDataLogs();
    // Sort by date descending (most recent first)
    logs.sort((a, b) => b.date.compareTo(a.date));
    setState(() {
      _logs = logs;
      _isLoading = false;
    });
  }

  Future<void> _deleteLog(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Data Log'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _storage.deleteDataLog(id);
      _loadLogs();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Data log deleted')));
      }
    }
  }

  String _getTimingDisplay(DataLogEntry log) {
    switch (log.trackLength) {
      case '1/4 Mile':
        return log.etQuarterMile != null && log.etQuarterMile!.isNotEmpty
            ? '${log.etQuarterMile} @ ${log.mphQuarterMile ?? "?"} mph'
            : 'No time recorded';
      case '1000 ft':
        return log.et1000ft != null && log.et1000ft!.isNotEmpty
            ? '${log.et1000ft} @ ${log.mph1000ft ?? "?"} mph'
            : 'No time recorded';
      case '1/8 Mile':
        return log.etEighthMile != null && log.etEighthMile!.isNotEmpty
            ? '${log.etEighthMile} @ ${log.mphEighthMile ?? "?"} mph'
            : 'No time recorded';
      default:
        return 'No time recorded';
    }
  }

  Future<void> _exportToExcel() async {
    if (_logs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No data logs to export')));
      return;
    }

    setState(() => _isExporting = true);

    try {
      await _exportService.exportToExcel(_logs);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${_logs.length} data logs to Excel'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Data Logs'),
        backgroundColor: Colors.orange,
        actions: [
          if (_logs.isNotEmpty)
            IconButton(
              icon: _isExporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.file_download),
              onPressed: _isExporting ? null : _exportToExcel,
              tooltip: 'Export to Excel',
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DataLogScreen()),
          );
          _loadLogs();
        },
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _logs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.note_add, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No data logs yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button to add your first log',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                final log = _logs[index];
                final dateStr = DateFormat('MMM d, yyyy').format(log.date);

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(
                        log.passNumber,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      log.trackName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('$dateStr • ${log.time}'),
                        Text('${log.trackLength}: ${_getTimingDisplay(log)}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteLog(log.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DataLogDetailScreen(log: log),
                        ),
                      );
                      _loadLogs();
                    },
                  ),
                );
              },
            ),
    );
  }
}

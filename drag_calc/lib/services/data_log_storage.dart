import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_log_entry.dart';

class DataLogStorage {
  static const String _storageKey = 'data_logs';

  // Save a new data log entry
  Future<void> saveDataLog(DataLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getAllDataLogs();
    logs.add(entry);
    
    final jsonList = logs.map((log) => log.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // Get all data log entries
  Future<List<DataLogEntry>> getAllDataLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => DataLogEntry.fromJson(json)).toList();
  }

  // Delete a data log entry by ID
  Future<void> deleteDataLog(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getAllDataLogs();
    logs.removeWhere((log) => log.id == id);
    
    final jsonList = logs.map((log) => log.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  // Update an existing data log entry
  Future<void> updateDataLog(DataLogEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getAllDataLogs();
    final index = logs.indexWhere((log) => log.id == entry.id);
    
    if (index != -1) {
      logs[index] = entry;
      final jsonList = logs.map((log) => log.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    }
  }

  // Get a single data log by ID
  Future<DataLogEntry?> getDataLogById(String id) async {
    final logs = await getAllDataLogs();
    try {
      return logs.firstWhere((log) => log.id == id);
    } catch (e) {
      return null;
    }
  }
}

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/engine_spec_entry.dart';

class EngineSpecStorage {
  static const String _key = 'engine_specs';

  static Future<List<EngineSpecEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString == null || jsonString.isEmpty) return [];

    try {
      final List<dynamic> decoded = json.decode(jsonString);
      return decoded
          .map((item) => EngineSpecEntry.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveAll(List<EngineSpecEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  static Future<void> add(EngineSpecEntry entry) async {
    final entries = await loadAll();
    entries.add(entry);
    await saveAll(entries);
  }

  static Future<void> delete(String id) async {
    final entries = await loadAll();
    entries.removeWhere((e) => e.id == id);
    await saveAll(entries);
  }

  static Future<void> update(EngineSpecEntry updatedEntry) async {
    final entries = await loadAll();
    final index = entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      entries[index] = updatedEntry;
      await saveAll(entries);
    }
  }
}

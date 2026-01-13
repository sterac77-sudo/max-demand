import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/engine_spec_entry.dart';
import 'services/engine_spec_storage.dart';
import 'engine_spec_entry_screen.dart';
import 'engine_spec_detail_screen.dart';

class SavedEngineSpecsScreen extends StatefulWidget {
  const SavedEngineSpecsScreen({super.key});

  @override
  State<SavedEngineSpecsScreen> createState() => _SavedEngineSpecsScreenState();
}

class _SavedEngineSpecsScreenState extends State<SavedEngineSpecsScreen> {
  List<EngineSpecEntry> _specs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSpecs();
  }

  Future<void> _loadSpecs() async {
    setState(() => _loading = true);
    final specs = await EngineSpecStorage.loadAll();
    setState(() {
      _specs = specs..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _loading = false;
    });
  }

  Future<void> _deleteSpec(EngineSpecEntry spec) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Engine Spec'),
        content: Text('Delete "${spec.engineName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await EngineSpecStorage.delete(spec.id);
      _loadSpecs();
    }
  }

  Future<void> _editSpec(EngineSpecEntry spec) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EngineSpecEntryScreen(existingEntry: spec),
      ),
    );
    if (result == true) {
      _loadSpecs();
    }
  }

  Future<void> _viewSpec(EngineSpecEntry spec) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EngineSpecDetailScreen(entry: spec),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Engine Specs'),
        backgroundColor: Colors.green,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _specs.isEmpty
              ? const Center(
                  child: Text(
                    'No engine specs saved yet.\nTap + to add one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _specs.length,
                  itemBuilder: (context, index) {
                    final spec = _specs[index];
                    final dateStr =
                        DateFormat('MMM dd, yyyy').format(spec.timestamp);
                    
                    String subtitle = '';
                    if (spec.cid.isNotEmpty) subtitle += '${spec.cid} CID';
                    if (spec.blockType.isNotEmpty) {
                      if (subtitle.isNotEmpty) subtitle += ' • ';
                      subtitle += spec.blockType;
                    }
                    if (spec.inductionType.isNotEmpty) {
                      if (subtitle.isNotEmpty) subtitle += ' • ';
                      subtitle += spec.inductionType;
                    }
                    if (subtitle.isEmpty) subtitle = 'Tap to view details';

                    return Card(
                      color: Colors.green[50],
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.engineering, color: Colors.green, size: 36),
                        title: Text(
                          spec.engineName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(subtitle),
                            const SizedBox(height: 2),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'view') {
                              _viewSpec(spec);
                            } else if (value == 'edit') {
                              _editSpec(spec);
                            } else if (value == 'delete') {
                              _deleteSpec(spec);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility, size: 20),
                                  SizedBox(width: 8),
                                  Text('View'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 20),
                                  SizedBox(width: 8),
                                  Text('Edit'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, size: 20, color: Colors.red),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => _viewSpec(spec),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => const EngineSpecEntryScreen(),
            ),
          );
          if (result == true) {
            _loadSpecs();
          }
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

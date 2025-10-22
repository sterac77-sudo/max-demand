import 'package:flutter/material.dart';

class SpaPoolConfig {
  final List<double> spaHeaters;
  final List<double> poolHeaters;
  const SpaPoolConfig({required this.spaHeaters, required this.poolHeaters});
}

class SpaPoolDialog extends StatefulWidget {
  const SpaPoolDialog({super.key});

  @override
  State<SpaPoolDialog> createState() => _SpaPoolDialogState();
}

class _SpaPoolDialogState extends State<SpaPoolDialog> {
  final _spaController = TextEditingController();
  final _poolController = TextEditingController();

  List<double> _parseList(String text) {
    return text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => double.tryParse(s))
        .whereType<double>()
        .toList();
  }

  @override
  void dispose() {
    _spaController.dispose();
    _poolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Spa and Pool Heaters (A)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter amps as comma-separated lists'),
            const SizedBox(height: 12),
            TextField(
              controller: _spaController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Spa heaters (A) — e.g. 30, 25, 18',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _poolController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'Pool heaters (A) — e.g. 40, 22',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final spas = _parseList(_spaController.text);
            final pools = _parseList(_poolController.text);
            Navigator.of(context).pop(
              SpaPoolConfig(spaHeaters: spas, poolHeaters: pools),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

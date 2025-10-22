import 'package:flutter/material.dart';

class ApplianceConfig {
  final double largestApplianceAmps;
  final List<double> additionalApplianceAmps;
  ApplianceConfig({
    required this.largestApplianceAmps,
    required this.additionalApplianceAmps,
  });
}

class ApplianceDialog extends StatefulWidget {
  const ApplianceDialog({super.key});

  @override
  State<ApplianceDialog> createState() => _ApplianceDialogState();
}

class _ApplianceDialogState extends State<ApplianceDialog> {
  final TextEditingController _largestController = TextEditingController();
  int _numAdditional = 0;
  final List<TextEditingController> _additionalControllers = [];

  @override
  void dispose() {
    _largestController.dispose();
    for (final c in _additionalControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateAdditional(int count) {
    setState(() {
      _numAdditional = count;
      while (_additionalControllers.length < count) {
        _additionalControllers.add(TextEditingController());
      }
      while (_additionalControllers.length > count) {
        _additionalControllers.removeLast().dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Appliances (A)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _largestController,
              decoration: const InputDecoration(labelText: 'Highest-rated appliance (A)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Number of additional appliances',
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final count = int.tryParse(val) ?? 0;
                _updateAdditional(count);
              },
            ),
            ...List.generate(
              _numAdditional,
              (i) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  controller: _additionalControllers[i],
                  decoration: InputDecoration(
                    labelText: 'Additional appliance ${i + 1} (A)',
                  ),
                  keyboardType: TextInputType.number,
                ),
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
        ElevatedButton(
          onPressed: () {
            final largest = double.tryParse(_largestController.text) ?? 0.0;
            final additional = _additionalControllers
                .map((c) => double.tryParse(c.text) ?? 0.0)
                .toList();
            Navigator.of(context).pop(
              ApplianceConfig(
                largestApplianceAmps: largest,
                additionalApplianceAmps: additional,
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

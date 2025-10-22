import 'package:flutter/material.dart';

class LiftMotorConfig {
  final double largestLiftMotorAmps;
  final List<double> additionalLiftAmps;
  LiftMotorConfig({
    required this.largestLiftMotorAmps,
    required this.additionalLiftAmps,
  });
}

class LiftMotorDialog extends StatefulWidget {
  const LiftMotorDialog({super.key});

  @override
  State<LiftMotorDialog> createState() => _LiftMotorDialogState();
}

class _LiftMotorDialogState extends State<LiftMotorDialog> {
  final TextEditingController _largestLiftController = TextEditingController();
  int _numAdditionalLifts = 0;
  final List<TextEditingController> _additionalLiftControllers = [];

  @override
  void dispose() {
    _largestLiftController.dispose();
    for (final c in _additionalLiftControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateAdditionalLifts(int count) {
    setState(() {
      _numAdditionalLifts = count;
      while (_additionalLiftControllers.length < count) {
        _additionalLiftControllers.add(TextEditingController());
      }
      while (_additionalLiftControllers.length > count) {
        _additionalLiftControllers.removeLast().dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lift Motors'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _largestLiftController,
              decoration: const InputDecoration(
                labelText: 'Largest Lift Motor (A)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Number of Additional Lifts',
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final count = int.tryParse(val) ?? 0;
                _updateAdditionalLifts(count);
              },
            ),
            ...List.generate(
              _numAdditionalLifts,
              (i) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  controller: _additionalLiftControllers[i],
                  decoration: InputDecoration(
                    labelText: 'Additional Lift ${i + 1} (A)',
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
            final largest = double.tryParse(_largestLiftController.text) ?? 0.0;
            final additional = _additionalLiftControllers
                .map((c) => double.tryParse(c.text) ?? 0.0)
                .toList();
            Navigator.of(context).pop(
              LiftMotorConfig(
                largestLiftMotorAmps: largest,
                additionalLiftAmps: additional,
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

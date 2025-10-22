import 'package:flutter/material.dart';

class MotorConfig {
  final double largestMotorAmps;
  final List<double> additionalMotorAmps;
  MotorConfig({
    required this.largestMotorAmps,
    required this.additionalMotorAmps,
  });
}

class MotorDialog extends StatefulWidget {
  const MotorDialog({super.key});

  @override
  State<MotorDialog> createState() => _MotorDialogState();
}

class _MotorDialogState extends State<MotorDialog> {
  final TextEditingController _largestMotorController = TextEditingController();
  int _numAdditionalMotors = 0;
  final List<TextEditingController> _additionalMotorControllers = [];

  @override
  void dispose() {
    _largestMotorController.dispose();
    for (final c in _additionalMotorControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _updateAdditionalMotors(int count) {
    setState(() {
      _numAdditionalMotors = count;
      while (_additionalMotorControllers.length < count) {
        _additionalMotorControllers.add(TextEditingController());
      }
      while (_additionalMotorControllers.length > count) {
        _additionalMotorControllers.removeLast().dispose();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Motors (A)'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _largestMotorController,
              decoration: const InputDecoration(labelText: 'Largest Motor (A)'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Number of Additional Motors',
              ),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                final count = int.tryParse(val) ?? 0;
                _updateAdditionalMotors(count);
              },
            ),
            ...List.generate(
              _numAdditionalMotors,
              (i) => Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: TextFormField(
                  controller: _additionalMotorControllers[i],
                  decoration: InputDecoration(
                    labelText: 'Additional Motor ${i + 1} (A)',
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
            final largest =
                double.tryParse(_largestMotorController.text) ?? 0.0;
            final additional = _additionalMotorControllers
                .map((c) => double.tryParse(c.text) ?? 0.0)
                .toList();
            Navigator.of(context).pop(
              MotorConfig(
                largestMotorAmps: largest,
                additionalMotorAmps: additional,
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

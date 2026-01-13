import 'package:flutter/material.dart';
import 'ad_manager.dart';
import 'dart:math' as math;

enum LengthUnit { inch, mm }

class CubicInchCalculator extends StatefulWidget {
  const CubicInchCalculator({super.key});

  @override
  State<CubicInchCalculator> createState() => _CubicInchCalculatorState();
}

class _CubicInchCalculatorState extends State<CubicInchCalculator> {
  final _boreController = TextEditingController();
  final _strokeController = TextEditingController();
  final _cylindersController = TextEditingController(text: '8');

  LengthUnit _lengthUnit = LengthUnit.inch;

  String _cidResult = '';
  String _ccResult = '';

  @override
  void dispose() {
    _boreController.dispose();
    _strokeController.dispose();
    _cylindersController.dispose();
    super.dispose();
  }

  void _calculate() {
    final boreText = _boreController.text.trim();
    final strokeText = _strokeController.text.trim();
    final cylText = _cylindersController.text.trim();

    if (boreText.isEmpty || strokeText.isEmpty || cylText.isEmpty) {
      setState(() {
        _cidResult = 'Please fill in all fields';
        _ccResult = '';
      });
      return;
    }

    try {
      final boreInput = double.parse(boreText);
      final strokeInput = double.parse(strokeText);
      final cylinders = int.parse(cylText);

      if (boreInput <= 0 || strokeInput <= 0 || cylinders <= 0) {
        setState(() {
          _cidResult = 'Values must be greater than zero';
          _ccResult = '';
        });
        return;
      }

      // Convert to inches if needed
      final boreIn = _lengthUnit == LengthUnit.mm
          ? boreInput / 25.4
          : boreInput;
      final strokeIn = _lengthUnit == LengthUnit.mm
          ? strokeInput / 25.4
          : strokeInput;

      // CID formula: (pi/4) * bore^2 * stroke * cylinders
      final cid = (math.pi / 4.0) * (boreIn * boreIn) * strokeIn * cylinders;

      // Convert CID to cc: 1 cubic inch = 16.387064 cc
      final cc = cid * 16.387064;

      setState(() {
        _cidResult = '${cid.toStringAsFixed(1)} ci';
        _ccResult = '${cc.toStringAsFixed(0)} cc';
      });
    } catch (e) {
      setState(() {
        _cidResult = 'Invalid input';
        _ccResult = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cubic Inch Displacement'),
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: SafeArea(child: AdBanner()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bore with unit toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _boreController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Bore',
                      border: const OutlineInputBorder(),
                      suffixText: _lengthUnit == LengthUnit.inch ? 'in' : 'mm',
                    ),
                    onChanged: (_) => setState(() {
                      _cidResult = '';
                      _ccResult = '';
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<LengthUnit>(
                  segments: const [
                    ButtonSegment(value: LengthUnit.inch, label: Text('in')),
                    ButtonSegment(value: LengthUnit.mm, label: Text('mm')),
                  ],
                  selected: {_lengthUnit},
                  onSelectionChanged: (s) => setState(() {
                    _lengthUnit = s.first;
                    _cidResult = '';
                    _ccResult = '';
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stroke
            TextField(
              controller: _strokeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Stroke',
                border: const OutlineInputBorder(),
                suffixText: _lengthUnit == LengthUnit.inch ? 'in' : 'mm',
              ),
              onChanged: (_) => setState(() {
                _cidResult = '';
                _ccResult = '';
              }),
            ),
            const SizedBox(height: 12),

            // Cylinders
            TextField(
              controller: _cylindersController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: false,
              ),
              decoration: const InputDecoration(
                labelText: 'Number of Cylinders',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {
                _cidResult = '';
                _ccResult = '';
              }),
            ),
            const SizedBox(height: 20),

            // Calculate
            ElevatedButton(
              onPressed: () =>
                  AdManager.showInterstitial(onDismissed: _calculate),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            if (_cidResult.isNotEmpty)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Displacement',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _cidResult,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_ccResult.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _ccResult,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

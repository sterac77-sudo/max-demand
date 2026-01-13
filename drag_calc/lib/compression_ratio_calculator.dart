import 'package:flutter/material.dart';
import 'ad_manager.dart';
import 'dart:math' as math;

enum LengthUnit { inch, mm }

class CompressionRatioCalculator extends StatefulWidget {
  const CompressionRatioCalculator({super.key});

  @override
  State<CompressionRatioCalculator> createState() =>
      _CompressionRatioCalculatorState();
}

class _CompressionRatioCalculatorState
    extends State<CompressionRatioCalculator> {
  final _boreController = TextEditingController();
  final _strokeController = TextEditingController();
  final _headCcController = TextEditingController();
  final _reliefDomeCcController = TextEditingController(text: '0');
  final _gasketThicknessController = TextEditingController();
  final _gasketBoreController = TextEditingController();
  final _deckHeightController = TextEditingController(text: '0');
  final _additionalCcController = TextEditingController(text: '0');

  LengthUnit _lengthUnit = LengthUnit.inch;

  String _crResult = '';

  @override
  void dispose() {
    _boreController.dispose();
    _strokeController.dispose();
    _headCcController.dispose();
    _reliefDomeCcController.dispose();
    _gasketThicknessController.dispose();
    _gasketBoreController.dispose();
    _deckHeightController.dispose();
    _additionalCcController.dispose();
    super.dispose();
  }

  void _calculate() {
    final boreText = _boreController.text.trim();
    final strokeText = _strokeController.text.trim();
    final headCcText = _headCcController.text.trim();
    final reliefDomeCcText = _reliefDomeCcController.text.trim();
    final gasketThicknessText = _gasketThicknessController.text.trim();
    final gasketBoreText = _gasketBoreController.text.trim();
    final deckHeightText = _deckHeightController.text.trim();
    final additionalCcText = _additionalCcController.text.trim();

    if ([
      boreText,
      strokeText,
      headCcText,
      reliefDomeCcText,
      gasketThicknessText,
      gasketBoreText,
      deckHeightText,
      additionalCcText,
    ].any((s) => s.isEmpty)) {
      setState(() {
        _crResult = 'Please fill in all fields';
      });
      return;
    }

    try {
      final bore = double.parse(boreText);
      final stroke = double.parse(strokeText);
      final headCc = double.parse(headCcText); // cc
      final reliefDomeCc = double.parse(
        reliefDomeCcText,
      ); // cc (negative for dome)
      final gasketThickness = double.parse(gasketThicknessText);
      final gasketBore = double.parse(gasketBoreText);
      final deckHeight = double.parse(
        deckHeightText,
      ); // distance piston below deck at TDC
      final additionalCc = double.parse(additionalCcText); // cc

      if (bore <= 0 ||
          stroke <= 0 ||
          headCc <= 0 ||
          gasketThickness < 0 ||
          gasketBore <= 0 ||
          deckHeight < 0) {
        setState(() {
          _crResult = 'Invalid values (check for negatives/zeros)';
        });
        return;
      }

      // Convert lengths to inches if needed
      final toInches = (double v) =>
          _lengthUnit == LengthUnit.mm ? v / 25.4 : v;
      final boreIn = toInches(bore);
      final strokeIn = toInches(stroke);
      final gasketThicknessIn = toInches(gasketThickness);
      final gasketBoreIn = toInches(gasketBore);
      final deckHeightIn = toInches(deckHeight);

      // Volumes in cubic inches
      final sweptIn3 =
          (math.pi / 4.0) * (boreIn * boreIn) * strokeIn; // per cylinder
      final gasketVolIn3 =
          (math.pi / 4.0) * (gasketBoreIn * gasketBoreIn) * gasketThicknessIn;
      final deckVolIn3 = (math.pi / 4.0) * (boreIn * boreIn) * deckHeightIn;

      // Convert cc to in^3 (1 in^3 = 16.387064 cc)
      const ccPerIn3 = 16.387064;
      final headIn3 = headCc / ccPerIn3;
      final reliefDomeIn3 =
          reliefDomeCc / ccPerIn3; // negative reduces clearance
      final additionalIn3 = additionalCc / ccPerIn3;

      // Clearance volume
      final clearanceIn3 =
          headIn3 + gasketVolIn3 + deckVolIn3 + reliefDomeIn3 + additionalIn3;

      if (clearanceIn3 <= 0) {
        setState(() {
          _crResult = 'Computed clearance volume ≤ 0. Check inputs.';
        });
        return;
      }

      final cr = (sweptIn3 + clearanceIn3) / clearanceIn3;

      setState(() {
        _crResult = '${cr.toStringAsFixed(2)} : 1';
      });
    } catch (e) {
      setState(() {
        _crResult = 'Invalid input';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compression Ratio'),
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
            // Bore (with unit toggle)
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
                    onChanged: (_) => setState(() => _crResult = ''),
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
                    _crResult = '';
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
              onChanged: (_) => setState(() => _crResult = ''),
            ),
            const SizedBox(height: 12),

            // Head chamber (cc)
            TextField(
              controller: _headCcController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Head Chamber (cc)',
                border: OutlineInputBorder(),
                helperText: 'Per cylinder chamber volume at TDC',
              ),
              onChanged: (_) => setState(() => _crResult = ''),
            ),
            const SizedBox(height: 12),

            // Valve relief / dome (cc)
            TextField(
              controller: _reliefDomeCcController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Valve Relief / Dome (cc)',
                border: OutlineInputBorder(),
                helperText:
                    'Use positive for reliefs/valve pockets; negative for domes',
              ),
              onChanged: (_) => setState(() => _crResult = ''),
            ),
            const SizedBox(height: 12),

            // Gasket thickness
            TextField(
              controller: _gasketThicknessController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Gasket Thickness',
                border: const OutlineInputBorder(),
                suffixText: _lengthUnit == LengthUnit.inch ? 'in' : 'mm',
              ),
              onChanged: (_) => setState(() => _crResult = ''),
            ),
            const SizedBox(height: 12),

            // Gasket bore
            TextField(
              controller: _gasketBoreController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Gasket Bore Diameter',
                border: const OutlineInputBorder(),
                suffixText: _lengthUnit == LengthUnit.inch ? 'in' : 'mm',
              ),
              onChanged: (_) => setState(() => _crResult = ''),
            ),
            const SizedBox(height: 12),

            // Deck height
            TextField(
              controller: _deckHeightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Piston to Deck Height',
                border: const OutlineInputBorder(),
                suffixText: _lengthUnit == LengthUnit.inch ? 'in' : 'mm',
                helperText:
                    'Distance piston is below deck at TDC (use 0 for zero-deck)',
              ),
              onChanged: (_) => setState(() => _crResult = ''),
            ),
            const SizedBox(height: 12),

            // Additional cc's
            TextField(
              controller: _additionalCcController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Additional CC\'s',
                border: OutlineInputBorder(),
                helperText: 'Crevice volume, coatings, etc. (cc)',
              ),
              onChanged: (_) => setState(() => _crResult = ''),
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

            if (_crResult.isNotEmpty)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Compression Ratio',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _crResult,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

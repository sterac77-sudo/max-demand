import 'package:flutter/material.dart';
import 'ad_manager.dart';

enum PSLengthUnit { inch, mm }

class PistonSpeedCalculator extends StatefulWidget {
  const PistonSpeedCalculator({super.key});

  @override
  State<PistonSpeedCalculator> createState() => _PistonSpeedCalculatorState();
}

class _PistonSpeedCalculatorState extends State<PistonSpeedCalculator> {
  final _strokeController = TextEditingController();
  final _rpmController = TextEditingController();

  PSLengthUnit _lengthUnit = PSLengthUnit.inch;

  String _fpsResult = '';
  String _mpsResult = '';
  String _maxFpsResult = '';
  String _maxMpsResult = '';

  @override
  void dispose() {
    _strokeController.dispose();
    _rpmController.dispose();
    super.dispose();
  }

  void _calculate() {
    final strokeText = _strokeController.text.trim();
    final rpmText = _rpmController.text.trim();

    if (strokeText.isEmpty || rpmText.isEmpty) {
      setState(() {
        _fpsResult = 'Please fill in all fields';
        _mpsResult = '';
        _maxFpsResult = '';
        _maxMpsResult = '';
      });
      return;
    }

    try {
      final strokeInput = double.parse(strokeText);
      final rpm = double.parse(rpmText);

      if (strokeInput <= 0 || rpm <= 0) {
        setState(() {
          _fpsResult = 'Values must be greater than zero';
          _mpsResult = '';
          _maxFpsResult = '';
          _maxMpsResult = '';
        });
        return;
      }

      // Convert stroke to feet
      final strokeInches = _lengthUnit == PSLengthUnit.mm
          ? (strokeInput / 25.4)
          : strokeInput;
      final strokeFeet = strokeInches / 12.0;

      // Mean piston speed: 2 * stroke * RPM (units: feet/min when stroke is in feet)
      final meanFtPerMin = 2.0 * strokeFeet * rpm;
      final meanMetersPerSec = meanFtPerMin * 0.3048 / 60.0;

      // Approximate maximum piston speed ~ (π/2) × mean piston speed (simple harmonic approximation)
      const kMaxOverMean = 1.5708; // ≈ π/2
      final maxFtPerMin = meanFtPerMin * kMaxOverMean;
      final maxMetersPerSec = meanMetersPerSec * kMaxOverMean;

      setState(() {
        _fpsResult = '${meanFtPerMin.toStringAsFixed(0)} ft/min';
        _mpsResult = '${meanMetersPerSec.toStringAsFixed(2)} m/s';
        _maxFpsResult = '${maxFtPerMin.toStringAsFixed(0)} ft/min';
        _maxMpsResult = '${maxMetersPerSec.toStringAsFixed(2)} m/s';
      });
    } catch (_) {
      setState(() {
        _fpsResult = 'Invalid input';
        _mpsResult = '';
        _maxFpsResult = '';
        _maxMpsResult = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Piston Speed'),
        backgroundColor: Colors.indigo,
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
            // Stroke with unit toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _strokeController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Stroke',
                      border: const OutlineInputBorder(),
                      suffixText: _lengthUnit == PSLengthUnit.inch
                          ? 'in'
                          : 'mm',
                    ),
                    onChanged: (_) => setState(() {
                      _fpsResult = '';
                      _mpsResult = '';
                      _maxFpsResult = '';
                      _maxMpsResult = '';
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<PSLengthUnit>(
                  segments: const [
                    ButtonSegment(value: PSLengthUnit.inch, label: Text('in')),
                    ButtonSegment(value: PSLengthUnit.mm, label: Text('mm')),
                  ],
                  selected: {_lengthUnit},
                  onSelectionChanged: (s) => setState(() {
                    _lengthUnit = s.first;
                    _fpsResult = '';
                    _mpsResult = '';
                    _maxFpsResult = '';
                    _maxMpsResult = '';
                  }),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // RPM
            TextField(
              controller: _rpmController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'RPM',
                border: OutlineInputBorder(),
                suffixText: 'rev/min',
              ),
              onChanged: (_) => setState(() {
                _fpsResult = '';
                _mpsResult = '';
                _maxFpsResult = '';
                _maxMpsResult = '';
              }),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () =>
                  AdManager.showInterstitial(onDismissed: _calculate),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            if (_fpsResult.isNotEmpty)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mean Piston Speed',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _fpsResult,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_mpsResult.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _mpsResult,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                      if (_maxFpsResult.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Max Piston Speed',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _maxFpsResult,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_maxMpsResult.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _maxMpsResult,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ],
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

import 'package:flutter/material.dart';
import 'ad_manager.dart';

enum WeightUnit { kg, lb }

enum TempUnit { celsius, fahrenheit }

class PowerToTrackCalculator extends StatefulWidget {
  const PowerToTrackCalculator({super.key});

  @override
  State<PowerToTrackCalculator> createState() => _PowerToTrackCalculatorState();
}

class _PowerToTrackCalculatorState extends State<PowerToTrackCalculator> {
  final _totalWeightController = TextEditingController();
  final _trackTempController = TextEditingController();
  final _tireDiameterController = TextEditingController();
  final _launchRpmController = TextEditingController();
  final _rearWeightPercentController = TextEditingController(text: '60');

  WeightUnit _weightUnit = WeightUnit.lb;
  TempUnit _tempUnit = TempUnit.celsius;

  String _result = '';
  String _details = '';

  @override
  void dispose() {
    _totalWeightController.dispose();
    _trackTempController.dispose();
    _tireDiameterController.dispose();
    _launchRpmController.dispose();
    _rearWeightPercentController.dispose();
    super.dispose();
  }

  double _estimateFrictionCoefficient(double tempCelsius) {
    // Track Temperature vs. Friction (for slicks on VHT-prepped track)
    // < 20°C: μ = 0.6–0.8
    // 25–35°C: μ = 1.0–1.2
    // > 40°C: μ = 1.2–1.4 (optimal)
    // > 50°C: starts to drop (rubber gets greasy)

    if (tempCelsius < 20) {
      // Cold track: interpolate between 0.6 (0°C) and 0.8 (20°C)
      return 0.6 + (tempCelsius / 20) * 0.2;
    } else if (tempCelsius < 25) {
      // Warming up: interpolate between 0.8 (20°C) and 1.0 (25°C)
      return 0.8 + ((tempCelsius - 20) / 5) * 0.2;
    } else if (tempCelsius < 35) {
      // Good range: interpolate between 1.0 (25°C) and 1.2 (35°C)
      return 1.0 + ((tempCelsius - 25) / 10) * 0.2;
    } else if (tempCelsius < 45) {
      // Optimal range: interpolate between 1.2 (35°C) and 1.4 (45°C)
      return 1.2 + ((tempCelsius - 35) / 10) * 0.2;
    } else if (tempCelsius < 55) {
      // Hot but stable: stay around 1.4
      return 1.4;
    } else {
      // Too hot: rubber starts to lose grip, drop back down
      return 1.4 - ((tempCelsius - 55) / 10) * 0.2;
    }
  }

  void _calculate() {
    final totalWeightText = _totalWeightController.text.trim();
    final trackTempText = _trackTempController.text.trim();
    final tireDiameterText = _tireDiameterController.text.trim();
    final launchRpmText = _launchRpmController.text.trim();
    final rearWeightPercentText = _rearWeightPercentController.text.trim();

    if (totalWeightText.isEmpty ||
        trackTempText.isEmpty ||
        tireDiameterText.isEmpty ||
        launchRpmText.isEmpty ||
        rearWeightPercentText.isEmpty) {
      setState(() {
        _result = 'Please fill in all fields';
        _details = '';
      });
      return;
    }

    try {
      final totalWeight = double.parse(totalWeightText);
      final trackTemp = double.parse(trackTempText);
      final tireDiameter = double.parse(tireDiameterText);
      final launchRpm = double.parse(launchRpmText);
      final rearWeightPercent = double.parse(rearWeightPercentText);

      if (totalWeight <= 0 ||
          tireDiameter <= 0 ||
          launchRpm <= 0 ||
          rearWeightPercent <= 0 ||
          rearWeightPercent > 100) {
        setState(() {
          _result = 'Invalid input values';
          _details = '';
        });
        return;
      }

      // Convert weight to lbs if needed
      final totalWeightLb = _weightUnit == WeightUnit.kg
          ? totalWeight * 2.20462
          : totalWeight;

      // Convert temp to Celsius if needed
      final trackTempC = _tempUnit == TempUnit.fahrenheit
          ? (trackTemp - 32) * 5 / 9
          : trackTemp;

      // Calculate weight on driven (rear) tires
      final rearWeightLb = totalWeightLb * (rearWeightPercent / 100);

      // Estimate coefficient of friction based on track temp
      final mu = _estimateFrictionCoefficient(trackTempC);

      // 1. Calculate Maximum Tractive Force: F = μ × W
      final tractionForce = mu * rearWeightLb;

      // 2. Convert Force to Torque: T = F × r (radius in feet)
      // Radius = diameter / 2
      final tireRadius = tireDiameter / 2;
      final torque =
          tractionForce * (tireRadius / 12); // convert inches to feet

      // 3. Convert Torque to Horsepower: HP = (T × RPM) / 5252
      final usableHp = (torque * launchRpm) / 5252;

      // Generate detailed breakdown
      final details =
          '''
Track Temperature: ${trackTempC.toStringAsFixed(1)}°C (${(_tempUnit == TempUnit.fahrenheit ? trackTemp : trackTemp * 9 / 5 + 32).toStringAsFixed(1)}°F)
Coefficient of Friction (μ): ${mu.toStringAsFixed(2)}
Rear Weight: ${rearWeightLb.toStringAsFixed(0)} lb (${rearWeightPercent.toStringAsFixed(0)}%)
Maximum Tractive Force: ${tractionForce.toStringAsFixed(0)} lb
Torque at Tire: ${torque.toStringAsFixed(0)} lb-ft
Launch RPM: ${launchRpm.toStringAsFixed(0)}
''';

      setState(() {
        _result = '${usableHp.toStringAsFixed(1)} HP';
        _details = details;
      });
    } catch (e) {
      setState(() {
        _result = 'Invalid input';
        _details = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Power to Track Calculator'),
        backgroundColor: Colors.deepPurple,
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: SafeArea(child: AdBanner()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[700]),
                        const SizedBox(width: 8),
                        Text(
                          'Launch Traction Calculator',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Estimates usable horsepower at launch based on track temperature, tire grip, and weight transfer. Helps determine how much power can be applied without wheelspin.',
                      style: TextStyle(fontSize: 13, color: Colors.blue[900]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Total Weight Input with Unit Toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _totalWeightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Total Vehicle Weight',
                      border: const OutlineInputBorder(),
                      suffixText: _weightUnit == WeightUnit.kg ? 'kg' : 'lb',
                    ),
                    onChanged: (_) => setState(() {
                      _result = '';
                      _details = '';
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<WeightUnit>(
                  segments: const [
                    ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                    ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                  ],
                  selected: {_weightUnit},
                  onSelectionChanged: (Set<WeightUnit> newSelection) {
                    setState(() {
                      _weightUnit = newSelection.first;
                      _result = '';
                      _details = '';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rear Weight Percentage
            TextField(
              controller: _rearWeightPercentController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Rear Weight % (with weight transfer)',
                border: OutlineInputBorder(),
                suffixText: '%',
                helperText: 'Typical: 60-70% (good launch)',
              ),
              onChanged: (_) => setState(() {
                _result = '';
                _details = '';
              }),
            ),
            const SizedBox(height: 12),

            // Track Temperature with Unit Toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _trackTempController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Track Surface Temperature',
                      border: const OutlineInputBorder(),
                      suffixText: _tempUnit == TempUnit.celsius ? '°C' : '°F',
                      helperText: 'Optimal: 40-50°C (104-122°F)',
                    ),
                    onChanged: (_) => setState(() {
                      _result = '';
                      _details = '';
                    }),
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<TempUnit>(
                  segments: const [
                    ButtonSegment(value: TempUnit.celsius, label: Text('°C')),
                    ButtonSegment(
                      value: TempUnit.fahrenheit,
                      label: Text('°F'),
                    ),
                  ],
                  selected: {_tempUnit},
                  onSelectionChanged: (Set<TempUnit> newSelection) {
                    setState(() {
                      _tempUnit = newSelection.first;
                      _result = '';
                      _details = '';
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Tire Diameter
            TextField(
              controller: _tireDiameterController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Tire Diameter',
                border: OutlineInputBorder(),
                suffixText: 'inches',
                helperText:
                    'Overall diameter (e.g., 26" for typical drag tire)',
              ),
              onChanged: (_) => setState(() {
                _result = '';
                _details = '';
              }),
            ),
            const SizedBox(height: 12),

            // Launch RPM
            TextField(
              controller: _launchRpmController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Launch RPM',
                border: OutlineInputBorder(),
                suffixText: 'RPM',
                helperText: 'Typical: 4000-6000 RPM',
              ),
              onChanged: (_) => setState(() {
                _result = '';
                _details = '';
              }),
            ),
            const SizedBox(height: 20),

            // Calculate Button
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

            // Result
            if (_result.isNotEmpty)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Usable Power at Launch',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_details.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'Breakdown',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _details,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // Formula Info
            Card(
              color: Colors.grey[100],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Calculation Method',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. F_traction = μ × W_rear\n'
                      '2. Torque = F × tire_radius (dia/2)\n'
                      '3. HP = (Torque × RPM) / 5252',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'μ (friction) varies with track temperature:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '< 20°C: 0.6-0.8 (cold track)\n'
                      '25-35°C: 1.0-1.2 (good)\n'
                      '40-50°C: 1.2-1.4 (optimal)\n'
                      '> 55°C: decreases (too hot)',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
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

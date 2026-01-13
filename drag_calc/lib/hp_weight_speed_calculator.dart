import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'ad_manager.dart';

enum TrackLength { quarter, eighth, thousand }

enum WeightUnit { kg, lb }

class HpWeightSpeedCalculator extends StatefulWidget {
  const HpWeightSpeedCalculator({super.key});

  @override
  State<HpWeightSpeedCalculator> createState() =>
      _HpWeightSpeedCalculatorState();
}

class _HpWeightSpeedCalculatorState extends State<HpWeightSpeedCalculator> {
  final _hpController = TextEditingController();
  final _weightController = TextEditingController();
  final _speedController = TextEditingController();

  TrackLength _trackLength = TrackLength.quarter;
  WeightUnit _weightUnit = WeightUnit.lb;

  String _result = '';

  @override
  void dispose() {
    _hpController.dispose();
    _weightController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  void _calculate() {
    final hpText = _hpController.text.trim();
    final weightText = _weightController.text.trim();
    final speedText = _speedController.text.trim();

    // Count how many fields are filled
    final filledCount = [
      hpText,
      weightText,
      speedText,
    ].where((s) => s.isNotEmpty).length;

    if (filledCount < 2) {
      setState(() {
        _result = 'Enter any 2 values to calculate the 3rd';
      });
      return;
    }

    if (filledCount == 3) {
      setState(() {
        _result = 'Enter only 2 values (leave one blank to calculate)';
      });
      return;
    }

    try {
      final hp = hpText.isEmpty ? null : double.tryParse(hpText);
      final weight = weightText.isEmpty ? null : double.tryParse(weightText);
      final speed = speedText.isEmpty ? null : double.tryParse(speedText);

      if ((hp != null && hp <= 0) ||
          (weight != null && weight <= 0) ||
          (speed != null && speed <= 0)) {
        setState(() {
          _result = 'All values must be greater than zero';
        });
        return;
      }

      // Convert weight to lbs if needed
      final weightLb = weight == null
          ? null
          : _weightUnit == WeightUnit.kg
          ? weight * 2.20462
          : weight;

      // Base formula for 1/4 mile: MPH = 234 × (HP / Weight_lb)^(1/3)
      // For other distances, scale the speed

      if (hp == null) {
        // Calculate HP from weight and speed
        final scaledSpeed = _scaleSpeedToQuarter(speed!);
        final hpWeightRatio = math.pow(scaledSpeed / 234, 3);
        final calculatedHp = hpWeightRatio * weightLb!;
        setState(() {
          _result = 'HP: ${calculatedHp.toStringAsFixed(1)}';
        });
      } else if (weight == null) {
        // Calculate weight from HP and speed
        final scaledSpeed = _scaleSpeedToQuarter(speed!);
        final hpWeightRatio = math.pow(scaledSpeed / 234, 3);
        final calculatedWeightLb = hp / hpWeightRatio;
        final displayWeight = _weightUnit == WeightUnit.kg
            ? calculatedWeightLb / 2.20462
            : calculatedWeightLb;
        final unit = _weightUnit == WeightUnit.kg ? 'kg' : 'lb';
        setState(() {
          _result = 'Weight: ${displayWeight.toStringAsFixed(1)} $unit';
        });
      } else {
        // Calculate speed from HP and weight
        final quarterMileSpeed =
            234 * math.pow(hp / weightLb!, 1 / 3).toDouble();
        final displaySpeed = _scaleSpeedFromQuarter(quarterMileSpeed);
        setState(() {
          _result = 'Trap Speed: ${displaySpeed.toStringAsFixed(2)} mph';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Invalid input';
      });
    }
  }

  // Scale speed from other distances to 1/4 mile equivalent
  double _scaleSpeedToQuarter(double speed) {
    switch (_trackLength) {
      case TrackLength.quarter:
        return speed;
      case TrackLength.eighth:
        return speed / 0.80; // 1/8 mile is ~80% of 1/4 mile speed
      case TrackLength.thousand:
        return speed / 0.94; // 1000 ft is ~94% of 1/4 mile speed
    }
  }

  // Scale speed from 1/4 mile to selected distance
  double _scaleSpeedFromQuarter(double speed) {
    switch (_trackLength) {
      case TrackLength.quarter:
        return speed;
      case TrackLength.eighth:
        return speed * 0.80;
      case TrackLength.thousand:
        return speed * 0.94;
    }
  }

  String _trackLabel() {
    switch (_trackLength) {
      case TrackLength.quarter:
        return '1/4 Mile';
      case TrackLength.eighth:
        return '1/8 Mile';
      case TrackLength.thousand:
        return '1000 ft';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HP/Weight/Speed Calculator'),
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
            // Track Length Selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Track Length',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<TrackLength>(
                      segments: const [
                        ButtonSegment(
                          value: TrackLength.eighth,
                          label: Text('1/8 Mile'),
                        ),
                        ButtonSegment(
                          value: TrackLength.thousand,
                          label: Text('1000 ft'),
                        ),
                        ButtonSegment(
                          value: TrackLength.quarter,
                          label: Text('1/4 Mile'),
                        ),
                      ],
                      selected: {_trackLength},
                      onSelectionChanged: (Set<TrackLength> newSelection) {
                        setState(() {
                          _trackLength = newSelection.first;
                          _result = '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Instructions
            const Card(
              color: Colors.blue,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Enter any 2 values to calculate the 3rd',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // HP Input
            TextField(
              controller: _hpController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Horsepower (HP)',
                border: OutlineInputBorder(),
                suffixText: 'hp',
              ),
              onChanged: (_) => setState(() => _result = ''),
            ),
            const SizedBox(height: 12),

            // Weight Input with Unit Toggle
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Vehicle Weight',
                      border: const OutlineInputBorder(),
                      suffixText: _weightUnit == WeightUnit.kg ? 'kg' : 'lb',
                    ),
                    onChanged: (_) => setState(() => _result = ''),
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
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Speed Input
            TextField(
              controller: _speedController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Trap Speed',
                border: OutlineInputBorder(),
                suffixText: 'mph',
              ),
              onChanged: (_) => setState(() => _result = ''),
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
                      Text(
                        'Result for ${_trackLabel()}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                      'Formula',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'MPH = 234 × (HP / Weight)^(1/3)',
                      style: TextStyle(fontFamily: 'monospace', fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Based on 1/4 mile trap speed, scaled for other distances',
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

import 'package:flutter/material.dart';
import 'ad_manager.dart';
import 'dart:math' as math;

class WindSpeedCalculator extends StatefulWidget {
  const WindSpeedCalculator({super.key});

  @override
  State<WindSpeedCalculator> createState() => _WindSpeedCalculatorState();
}

enum SpeedUnit { mph, kmh }

enum AreaUnit { sqFt, sqM }

class _WindSpeedCalculatorState extends State<WindSpeedCalculator> {
  final _formKey = GlobalKey<FormState>();

  // Inputs
  SpeedUnit _speedUnit = SpeedUnit.mph;
  AreaUnit _areaUnit = AreaUnit.sqFt;
  final _baselineEtCtrl = TextEditingController();
  final _baselineMphCtrl = TextEditingController();
  final _windSpeedCtrl = TextEditingController(text: '0');
  final _cdCtrl = TextEditingController(text: '0.35'); // typical Cd
  final _frontalAreaCtrl = TextEditingController(text: '25'); // sq ft typical
  final _weightCtrl = TextEditingController();
  final _horsepowerCtrl =
      TextEditingController(); // optional HP for advanced calc

  // Results
  double? _adjustedEt;
  double? _adjustedMph;
  double? _adjustedEtWithPower; // considering HP compensation
  double? _adjustedMphWithPower;
  double? _timeDifference;
  double? _speedDifference;

  @override
  void dispose() {
    _baselineEtCtrl.dispose();
    _baselineMphCtrl.dispose();
    _windSpeedCtrl.dispose();
    _cdCtrl.dispose();
    _frontalAreaCtrl.dispose();
    _weightCtrl.dispose();
    _horsepowerCtrl.dispose();
    super.dispose();
  }

  double _mphToKmh(double mph) => mph * 1.609344;
  double _kmhToMph(double kmh) => kmh / 1.609344;
  double _sqMToSqFt(double sqM) => sqM * 10.7639;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final baselineEt = double.parse(_baselineEtCtrl.text);
    final baselineMphInput = double.parse(_baselineMphCtrl.text);
    final windSpeedInput = double.parse(_windSpeedCtrl.text);
    final cd = double.parse(_cdCtrl.text);
    final frontalAreaInput = double.parse(_frontalAreaCtrl.text);
    final weight = double.parse(_weightCtrl.text); // lb

    // Convert to mph if needed
    final baselineMph = _speedUnit == SpeedUnit.kmh
        ? _kmhToMph(baselineMphInput)
        : baselineMphInput;
    final windMph = _speedUnit == SpeedUnit.kmh
        ? _kmhToMph(windSpeedInput)
        : windSpeedInput;

    // Convert frontal area to sq ft if needed
    final frontalArea = _areaUnit == AreaUnit.sqM
        ? _sqMToSqFt(frontalAreaInput)
        : frontalAreaInput;

    // Dead zone: winds under 3 mph are negligible (measurement noise, natural variation)
    const windDeadZone = 3.0; // mph
    final effectiveWindMph = windMph.abs() < windDeadZone ? 0.0 : windMph;

    // Aerodynamic drag force: F = 0.5 × Cd × ρ × A × V²
    // ρ (air density) ≈ 0.002377 slugs/ft³ at sea level
    // Positive wind = headwind (slows down), negative = tailwind (speeds up)

    // Simplified approximation:
    // Speed change ≈ (wind × correction_factor)
    // ET change ≈ (speed_change / avg_speed) × baseline_ET

    const airDensity = 0.002377; // slugs/ft³

    // Drag at baseline: F_baseline = 0.5 × Cd × ρ × A × V²
    final dragBaseline =
        0.5 *
        cd *
        airDensity *
        frontalArea *
        math.pow(baselineMph * 1.467, 2); // mph to ft/s

    // With headwind, effective speed increases drag
    // With tailwind, effective speed decreases drag
    final effectiveSpeed = baselineMph + effectiveWindMph;
    final dragWithWind =
        0.5 *
        cd *
        airDensity *
        frontalArea *
        math.pow(effectiveSpeed * 1.467, 2);

    // Force difference
    final dragDifference = dragWithWind - dragBaseline;

    // Approximate speed loss/gain (simplified physics)
    // More drag = slower trap speed
    // Reduced empirical factor for more realistic results
    final rawSpeedChange =
        -(dragDifference / (weight * 0.002)); // reduced from 0.0005

    // Non-linear scaling: reduce impact across all wind speeds
    final windMagnitude = effectiveWindMph.abs();
    final scaleFactor = windMagnitude < 15
        ? 0.3 +
              (windMagnitude / 50) // 30-60% effect for 0-15mph
        : 0.6; // 60% effect even above 15mph (wind never has full "theoretical" impact)

    final speedChange = rawSpeedChange * scaleFactor;

    final adjustedMph = baselineMph + speedChange;

    // ET change: headwind increases ET, tailwind decreases
    // Reduced coefficient for more realistic ET impact
    final etChange = -speedChange * 0.010; // reduced from 0.015
    final adjustedEt = baselineEt + etChange;

    // Advanced: Consider HP compensation
    double? adjustedMphWithPower;
    double? adjustedEtWithPower;

    if (_horsepowerCtrl.text.isNotEmpty) {
      final hp = double.tryParse(_horsepowerCtrl.text);
      if (hp != null && hp > 0) {
        // Power available to overcome additional drag
        // HP determines how much speed loss can be compensated
        // Higher HP/weight ratio = better ability to maintain speed
        final hpPerLb = hp / weight;

        // Compensation factor: more HP relative to weight = less speed loss
        // Typical drag car: 0.3-0.5 HP/lb
        // High-power car (>0.4 HP/lb) can partially compensate for headwind
        final compensationFactor = math.min(
          hpPerLb * 0.5,
          0.7,
        ); // cap at 70% compensation

        // Compensated speed change (less severe than pure aerodynamic)
        final compensatedSpeedChange = speedChange * (1 - compensationFactor);
        adjustedMphWithPower = baselineMph + compensatedSpeedChange;

        // ET also improves with power compensation
        final compensatedEtChange = -compensatedSpeedChange * 0.015;
        adjustedEtWithPower = baselineEt + compensatedEtChange;
      }
    }

    setState(() {
      _adjustedMph = adjustedMph;
      _adjustedEt = adjustedEt;
      _adjustedMphWithPower = adjustedMphWithPower;
      _adjustedEtWithPower = adjustedEtWithPower;
      _speedDifference = speedChange;
      _timeDifference = etChange;
    });
  }

  String? _reqNum(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final x = double.tryParse(v);
    if (x == null || !x.isFinite) return 'Enter a valid number';
    return null;
  }

  String? _reqPosNum(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final x = double.tryParse(v);
    if (x == null || !x.isFinite || x <= 0) return 'Enter a positive number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wind Speed V ET/MPH')),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: SafeArea(child: AdBanner()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Calculate how wind affects your ET and trap speed',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16),

            // Speed unit toggle
            Row(
              children: [
                const Text('Speed units:'),
                const SizedBox(width: 12),
                SegmentedButton<SpeedUnit>(
                  segments: const [
                    ButtonSegment(value: SpeedUnit.mph, label: Text('mph')),
                    ButtonSegment(value: SpeedUnit.kmh, label: Text('km/h')),
                  ],
                  selected: {_speedUnit},
                  onSelectionChanged: (s) =>
                      setState(() => _speedUnit = s.first),
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Text(
              'Baseline Performance (no wind)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _baselineEtCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Baseline ET (seconds)',
                      hintText: 'e.g. 11.5',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _reqPosNum,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _baselineMphCtrl,
                    decoration: InputDecoration(
                      labelText:
                          'Baseline trap speed (${_speedUnit == SpeedUnit.mph ? 'mph' : 'km/h'})',
                      hintText: _speedUnit == SpeedUnit.mph
                          ? 'e.g. 120'
                          : 'e.g. 193',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _reqPosNum,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            const Text(
              'Wind & Vehicle Parameters',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _windSpeedCtrl,
              decoration: InputDecoration(
                labelText:
                    'Wind speed (${_speedUnit == SpeedUnit.mph ? 'mph' : 'km/h'})',
                hintText: 'Positive = headwind, negative = tailwind',
                helperText: 'e.g. 10 for 10mph headwind, -5 for 5mph tailwind',
              ),
              keyboardType: TextInputType.number,
              validator: _reqNum,
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Vehicle weight (lb)',
                      hintText: 'e.g. 3300',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _reqPosNum,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _horsepowerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Horsepower (optional)',
                      hintText: 'e.g. 1500',
                      helperText: 'For power compensation',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Drag coefficient (Cd)',
                      hintText: '0.25-0.45 typical',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _reqPosNum,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'What is Drag Coefficient (Cd)?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Cd measures how aerodynamic your vehicle is. Lower = more streamlined.\n'
                      '• 0.25-0.30: Very aerodynamic (modern sports cars, EVs)\n'
                      '• 0.30-0.35: Aerodynamic (modern sedans)\n'
                      '• 0.35-0.40: Average (most street cars)\n'
                      '• 0.40-0.50+: Less aerodynamic (trucks, older cars)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Frontal area with unit toggle
            Row(
              children: [
                const Text('Frontal area units:'),
                const SizedBox(width: 12),
                SegmentedButton<AreaUnit>(
                  segments: const [
                    ButtonSegment(value: AreaUnit.sqFt, label: Text('sq ft')),
                    ButtonSegment(value: AreaUnit.sqM, label: Text('m²')),
                  ],
                  selected: {_areaUnit},
                  onSelectionChanged: (s) =>
                      setState(() => _areaUnit = s.first),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _frontalAreaCtrl,
              decoration: InputDecoration(
                labelText:
                    'Frontal area (${_areaUnit == AreaUnit.sqFt ? 'sq ft' : 'm²'})',
                hintText: _areaUnit == AreaUnit.sqFt ? 'e.g. 25' : 'e.g. 2.3',
                helperText: _areaUnit == AreaUnit.sqFt
                    ? 'Typical: 20-25 sports car, 25-30 sedan, 30-35 truck'
                    : 'Typical: 1.9-2.3 sports car, 2.3-2.8 sedan, 2.8-3.3 truck',
              ),
              keyboardType: TextInputType.number,
              validator: _reqPosNum,
            ),
            const SizedBox(height: 8),
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'What is Frontal Area?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'The cross-sectional area of your car as seen from the front.\n'
                      'Approximate: Vehicle width × height (from front view)\n'
                      'Example: 6 ft wide × 4.5 ft tall ≈ 27 sq ft (2.5 m²)',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  AdManager.showInterstitial(onDismissed: _calculate),
              icon: const Icon(Icons.air),
              label: const Text('Calculate Wind Effect'),
            ),

            if (_adjustedMph != null && _adjustedEt != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Adjusted Performance (with wind)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Adjusted ET:',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${_adjustedEt!.toStringAsFixed(3)} s',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_timeDifference != null) ...[
                        Text(
                          '  (${_timeDifference! >= 0 ? '+' : ''}${_timeDifference!.toStringAsFixed(3)} s)',
                          style: TextStyle(
                            fontSize: 14,
                            color: _timeDifference! >= 0
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Adjusted trap speed:',
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            '${_adjustedMph!.toStringAsFixed(1)} mph',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (_speedUnit == SpeedUnit.kmh)
                        Text(
                          '  (${_mphToKmh(_adjustedMph!).toStringAsFixed(1)} km/h)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      if (_speedDifference != null) ...[
                        Text(
                          '  (${_speedDifference! >= 0 ? '+' : ''}${_speedDifference!.toStringAsFixed(1)} mph)',
                          style: TextStyle(
                            fontSize: 14,
                            color: _speedDifference! >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Show HP-compensated results if HP was provided
              if (_adjustedMphWithPower != null &&
                  _adjustedEtWithPower != null) ...[
                const SizedBox(height: 12),
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.electric_bolt,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'With Power Compensation',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'High-power engines can partially compensate for wind resistance',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Compensated ET:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${_adjustedEtWithPower!.toStringAsFixed(3)} s',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Compensated speed:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${_adjustedMphWithPower!.toStringAsFixed(1)} mph',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (_speedUnit == SpeedUnit.kmh)
                          Text(
                            '  (${_mphToKmh(_adjustedMphWithPower!).toStringAsFixed(1)} km/h)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Note:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '• Headwind (+) slows you down, increases ET\n'
                        '• Tailwind (-) speeds you up, decreases ET\n'
                        '• Effects are approximate and vary by vehicle aerodynamics',
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

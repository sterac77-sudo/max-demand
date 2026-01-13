import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home_screen.dart';
import 'ad_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdManager.initialize();
  runApp(const DragCalcApp());
}

class DragCalcApp extends StatelessWidget {
  const DragCalcApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag Racing Toolbox',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const HomeScreen(),
    );
  }
}

enum WeightUnit { kg, lb }

enum TrackLength { eighth, thousand, quarter }

class DragCalcScreen extends StatefulWidget {
  const DragCalcScreen({super.key});

  @override
  State<DragCalcScreen> createState() => _DragCalcScreenState();
}

class _DragCalcScreenState extends State<DragCalcScreen> {
  final _formKey = GlobalKey<FormState>();

  // Inputs
  WeightUnit _unit = WeightUnit.kg;
  TrackLength _track = TrackLength.quarter;
  final _weightCtrl = TextEditingController();
  final _hpCtrl = TextEditingController(); // flywheel HP
  final _tireDiaCtrl = TextEditingController(); // inches
  final _diffCtrl = TextEditingController();
  int _gears = 4; // 2..6
  final List<TextEditingController> _gearCtrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final _shiftRpmCtrl = TextEditingController(text: '6500');

  // Results
  double? _etSeconds;
  double? _trapMph;
  List<double>? _gearSpeedsMph; // at shift RPM

  @override
  void dispose() {
    _weightCtrl.dispose();
    _hpCtrl.dispose();
    _tireDiaCtrl.dispose();
    _diffCtrl.dispose();
    _shiftRpmCtrl.dispose();
    for (final c in _gearCtrls) c.dispose();
    super.dispose();
  }

  // Conversions & formulas
  double _kgToLb(double kg) => kg * 2.2046226218;
  double _mphToKmh(double mph) => mph * 1.609344;

  // ET (s) using common approximation with weight (lb) & flywheel HP
  double _predictET(double weightLb, double hp) {
    if (weightLb <= 0 || hp <= 0) return double.nan;
    return 6.290 * math.pow(weightLb / hp, 1 / 3).toDouble();
  }

  // Trap speed (mph)
  double _predictTrapMph(double weightLb, double hp) {
    if (weightLb <= 0 || hp <= 0) return double.nan;
    return 234.0 * math.pow(hp / weightLb, 1 / 3).toDouble();
  }

  // Scale quarter-mile ET/MPH to other track lengths (approximate)
  double _scaleEt(double etQuarter) {
    switch (_track) {
      case TrackLength.quarter:
        return etQuarter;
      case TrackLength.eighth:
        // Common conversion: 1/8 ≈ 0.64 × 1/4 ET (varies by combo)
        return etQuarter * 0.64;
      case TrackLength.thousand:
        // 1000 ft ≈ 0.91 × 1/4 ET (approximate)
        return etQuarter * 0.91;
    }
  }

  double _scaleTrapMph(double mphQuarter) {
    switch (_track) {
      case TrackLength.quarter:
        return mphQuarter;
      case TrackLength.eighth:
        // Common conversion: 1/8 MPH ≈ 0.80 × 1/4 MPH
        return mphQuarter * 0.80;
      case TrackLength.thousand:
        // 1000 ft MPH ≈ 0.94 × 1/4 MPH
        return mphQuarter * 0.94;
    }
  }

  String _trackLabel() {
    switch (_track) {
      case TrackLength.quarter:
        return '1/4 mile';
      case TrackLength.eighth:
        return '1/8 mile';
      case TrackLength.thousand:
        return '1000 ft';
    }
  }

  // Speed at RPM for each gear (mph), tire diameter in inches
  // mph = (RPM * tireDiaIn) / (gearRatio * diffRatio * 336)
  double _speedAtRpmMph({
    required int rpm,
    required double tireDiaIn,
    required double gearRatio,
    required double diffRatio,
  }) {
    if (rpm <= 0 || tireDiaIn <= 0 || gearRatio <= 0 || diffRatio <= 0) {
      return double.nan;
    }
    return (rpm * tireDiaIn) / (gearRatio * diffRatio * 336.0);
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final weightInput = double.parse(_weightCtrl.text);
    final weightLb = _unit == WeightUnit.kg
        ? _kgToLb(weightInput)
        : weightInput;
    final hp = double.parse(_hpCtrl.text);
    final tireDia = double.parse(_tireDiaCtrl.text);
    final diff = double.parse(_diffCtrl.text);
    final rpm = int.parse(_shiftRpmCtrl.text);

    final et = _predictET(weightLb, hp);
    final trap = _predictTrapMph(weightLb, hp);

    final scaledEt = _scaleEt(et);
    final scaledTrap = _scaleTrapMph(trap);

    final ratios = _gearCtrls
        .take(_gears)
        .map((c) => double.tryParse(c.text) ?? 0)
        .toList(growable: false);
    final speeds = ratios
        .map(
          (r) => _speedAtRpmMph(
            rpm: rpm,
            tireDiaIn: tireDia,
            gearRatio: r,
            diffRatio: diff,
          ),
        )
        .toList(growable: false);

    setState(() {
      _etSeconds = scaledEt;
      _trapMph = scaledTrap;
      _gearSpeedsMph = speeds;
    });
  }

  String? _reqNum(String? v) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final x = double.tryParse(v);
    if (x == null || !x.isFinite || x <= 0) return 'Enter a positive number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ET/MPH Calculator')),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: SafeArea(child: AdBanner()),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Track length selector
            Row(
              children: [
                const Text('Track length:'),
                const SizedBox(width: 12),
                SegmentedButton<TrackLength>(
                  segments: const [
                    ButtonSegment(
                      value: TrackLength.eighth,
                      label: Text('1/8 mile'),
                    ),
                    ButtonSegment(
                      value: TrackLength.thousand,
                      label: Text('1000 ft'),
                    ),
                    ButtonSegment(
                      value: TrackLength.quarter,
                      label: Text('1/4 mile'),
                    ),
                  ],
                  selected: {_track},
                  onSelectionChanged: (s) => setState(() => _track = s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Units toggle
            Row(
              children: [
                const Text('Weight units:'),
                const SizedBox(width: 12),
                SegmentedButton<WeightUnit>(
                  segments: const [
                    ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                    ButtonSegment(value: WeightUnit.lb, label: Text('lb')),
                  ],
                  selected: {_unit},
                  onSelectionChanged: (s) => setState(() => _unit = s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Inputs
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightCtrl,
                    decoration: InputDecoration(
                      labelText:
                          'Vehicle weight (${_unit == WeightUnit.kg ? 'kg' : 'lb'})',
                      hintText: _unit == WeightUnit.kg
                          ? 'e.g. 1500'
                          : 'e.g. 3300',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _reqNum,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _hpCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Flywheel HP',
                      hintText: 'e.g. 400',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _reqNum,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _tireDiaCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tire diameter (inches)',
                      hintText: 'e.g. 28',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _reqNum,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _diffCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Diff ratio',
                      hintText: 'e.g. 3.73',
                    ),
                    keyboardType: TextInputType.number,
                    validator: _reqNum,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Gears + ratios
            Row(
              children: [
                const Text('Gears:'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _gears,
                  items: [2, 3, 4, 5, 6]
                      .map((g) => DropdownMenuItem(value: g, child: Text('$g')))
                      .toList(),
                  onChanged: (g) => setState(() => _gears = g ?? 4),
                ),
                const Spacer(),
                SizedBox(
                  width: 160,
                  child: TextFormField(
                    controller: _shiftRpmCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Shift RPM',
                      hintText: 'e.g. 6500',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final msg = _reqNum(v);
                      if (msg != null) return msg;
                      final val = double.parse(v!);
                      if (val < 1000 || val > 12000) return '1000-12000 RPM';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: List.generate(_gears, (i) {
                return SizedBox(
                  width: 120,
                  child: TextFormField(
                    controller: _gearCtrls[i],
                    decoration: InputDecoration(
                      labelText: 'Gear ${i + 1} ratio',
                      hintText: i == 0 ? 'e.g. 2.97' : null,
                    ),
                    keyboardType: TextInputType.number,
                    validator: _reqNum,
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () =>
                  AdManager.showInterstitial(onDismissed: _calculate),
              icon: const Icon(Icons.speed),
              label: const Text('Calculate'),
            ),

            const SizedBox(height: 24),
            if (_etSeconds != null && _etSeconds!.isFinite)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Predictions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'ET (${_trackLabel()}): ${_etSeconds!.toStringAsFixed(2)} s',
                      ),
                      if (_trapMph != null && _trapMph!.isFinite) ...[
                        Text(
                          'Trap speed (${_trackLabel()}): ${_trapMph!.toStringAsFixed(1)} mph'
                          '  (${_mphToKmh(_trapMph!).toStringAsFixed(1)} km/h)',
                        ),
                      ],
                    ],
                  ),
                ),
              ),

            if (_gearSpeedsMph != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Per-gear speed at shift RPM',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (int i = 0; i < _gearSpeedsMph!.length; i++)
                        Text(
                          'Gear ${i + 1}: '
                          '${_gearSpeedsMph![i].isFinite ? _gearSpeedsMph![i].toStringAsFixed(1) : '--'} mph'
                          '  (${_gearSpeedsMph![i].isFinite ? _mphToKmh(_gearSpeedsMph![i]).toStringAsFixed(1) : '--'} km/h)',
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

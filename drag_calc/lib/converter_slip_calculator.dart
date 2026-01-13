import 'package:flutter/material.dart';
import 'ad_manager.dart';

class ConverterSlipCalculator extends StatefulWidget {
  const ConverterSlipCalculator({super.key});

  @override
  State<ConverterSlipCalculator> createState() =>
      _ConverterSlipCalculatorState();
}

class _ConverterSlipCalculatorState extends State<ConverterSlipCalculator> {
  // Input now expects tyre DIAMETER in inches (we will derive circumference internally)
  final _tyreDiameterCtrl = TextEditingController();
  final _diffRatioCtrl = TextEditingController();
  final _transRatioCtrl = TextEditingController();
  final _mphCtrl = TextEditingController();
  final _rpmCtrl = TextEditingController();

  String _trackLength = '1/4 mile';
  String _result = '';

  void _calculate() {
    setState(() {
      _result = '';
    });

    try {
      final tyreDiameter = double.parse(_tyreDiameterCtrl.text.trim());
      final diffRatio = double.parse(_diffRatioCtrl.text.trim());
      final transRatio = double.parse(_transRatioCtrl.text.trim());
      final mph = double.parse(_mphCtrl.text.trim());
      final rpm = double.parse(_rpmCtrl.text.trim());

      if (tyreDiameter <= 0 ||
          diffRatio <= 0 ||
          transRatio <= 0 ||
          mph <= 0 ||
          rpm <= 0) {
        setState(() {
          _result = 'Please enter positive values for all fields.';
        });
        return;
      }

      // We now use standard drag racing formula with tyre DIAMETER:
      // Theoretical RPM = (MPH × Diff Ratio × Trans Ratio × 336) / Tyre Diameter
      // 336 = (60 min/hr × 12 in/ft) / (π × 1) simplified from circumference form.
      // Convert diameter to theoretical RPM directly (no need to compute circumference externally for user).
      final theoreticalRpm = (mph * diffRatio * transRatio * 336.0) / tyreDiameter;

      // Converter slip RPM = Actual Engine RPM - Theoretical Output Shaft RPM
      final slipRpm = rpm - theoreticalRpm;

      // Slip percentage commonly referenced vs theoretical RPM:
      // Slip % = (Actual RPM - Theoretical RPM) / Theoretical RPM × 100
      double slipPercent = (slipRpm / theoreticalRpm) * 100.0;

      // Clamp negative slip (engine RPM below theoretical) to 0 for display.
      final bool wasNegative = slipPercent < 0;
      final displaySlipRpm = slipRpm < 0 ? 0 : slipRpm;
      if (slipPercent < 0) slipPercent = 0;

      // Format distance for display
      String distanceStr = '';
      switch (_trackLength) {
        case '1/4 mile':
          distanceStr = '1/4 Mile (1320 ft)';
          break;
        case '1/8 mile':
          distanceStr = '1/8 Mile (660 ft)';
          break;
        case '1000 ft':
          distanceStr = '1000 ft';
          break;
      }

      setState(() {
        _result = '''
Track Distance: $distanceStr

Input Values:
• Tyre Diameter: ${tyreDiameter.toStringAsFixed(2)} inches
• Diff Ratio: ${diffRatio.toStringAsFixed(2)}:1
• Transmission Ratio: ${transRatio.toStringAsFixed(2)}:1
• Finish Line MPH: ${mph.toStringAsFixed(2)}
• Engine RPM: ${rpm.toStringAsFixed(0)}

Calculated Results:
• Theoretical Output RPM: ${theoreticalRpm.toStringAsFixed(0)} RPM
• Converter Slip (RPM): ${displaySlipRpm.toStringAsFixed(0)} RPM
• Slip Percentage: ${slipPercent.toStringAsFixed(1)}%

${wasNegative ? 'Engine RPM is below theoretical (no slip). Check inputs (tyre diameter, ratios, MPH) for accuracy.' : 'The torque converter is slipping ${displaySlipRpm.toStringAsFixed(0)} RPM at the finish line, which represents ${slipPercent.toStringAsFixed(1)}% slip.'}
${slipPercent > 15 ? '\n⚠️ High slip - may indicate converter inefficiency or need for tighter stall.' : slipPercent < 2 ? '\n✓ Very tight converter, minimal slip.' : '\n✓ Normal converter slip range.'}
''';
      });
    } catch (e) {
      setState(() {
        _result = 'Invalid input: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Converter Slip Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Calculate torque converter slip at the finish line',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          const Text(
            'Track Length',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: '1/4 mile', label: Text('1/4 Mile')),
              ButtonSegment(value: '1/8 mile', label: Text('1/8 Mile')),
              ButtonSegment(value: '1000 ft', label: Text('1000 ft')),
            ],
            selected: {_trackLength},
            onSelectionChanged: (Set<String> selection) {
              setState(() {
                _trackLength = selection.first;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tyreDiameterCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Tyre Diameter (inches)',
              hintText: 'e.g. 34.5',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _diffRatioCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Differential Ratio',
              hintText: 'e.g. 3.73',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _transRatioCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Transmission Gear Ratio',
              hintText: 'e.g. 1.76 (first gear)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mphCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'MPH at Finish Line',
              hintText: 'e.g. 125.5',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _rpmCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Engine RPM at Finish Line',
              hintText: 'e.g. 6500',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              AdManager.showInterstitial(onDismissed: () {
                _calculate();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Calculate',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          if (_result.isNotEmpty)
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _result,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey[200],
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Track length is for reference only\n'
                    '• Enter tyre DIAMETER (circumference derived)\n'
                    '• Use the finish-line gear ratio\n'
                    '• Higher slip % = more converter inefficiency\n'
                    '• Typical slip: 3–10% depending on converter\n'
                    '• 0% means engine RPM below theoretical (check inputs)',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdBanner(),
    );
  }

  @override
  void dispose() {
    _tyreDiameterCtrl.dispose();
    _diffRatioCtrl.dispose();
    _transRatioCtrl.dispose();
    _mphCtrl.dispose();
    _rpmCtrl.dispose();
    super.dispose();
  }
}

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey[300],
      child: const Center(
        child: Text('Ad Space'),
      ),
    );
  }
}

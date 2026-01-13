import 'package:flutter/material.dart';
import 'ad_manager.dart';

enum DiameterUnit { inches, cm }

class MphCalculator extends StatefulWidget {
  const MphCalculator({super.key});

  @override
  State<MphCalculator> createState() => _MphCalculatorState();
}

class _MphCalculatorState extends State<MphCalculator> {
  final _rpmCtrl = TextEditingController();
  final _tireDiameterCtrl = TextEditingController();
  final _transRatioCtrl = TextEditingController(text: '1.0');
  final _diffRatioCtrl = TextEditingController();
  final _slipCtrl = TextEditingController(text: '0');

  DiameterUnit _diameterUnit = DiameterUnit.inches;

  String _mph = '';
  String _tireRpm = '';
  String _notes = '';

  @override
  void dispose() {
    _rpmCtrl.dispose();
    _tireDiameterCtrl.dispose();
    _transRatioCtrl.dispose();
    _diffRatioCtrl.dispose();
    _slipCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _mph = '';
      _tireRpm = '';
      _notes = '';
    });

    try {
      final engineRpm = double.parse(_rpmCtrl.text.trim());
      final tireDiameter = double.parse(_tireDiameterCtrl.text.trim());
      final transRatio = double.parse(_transRatioCtrl.text.trim());
      final diffRatio = double.parse(_diffRatioCtrl.text.trim());
      final slipPct = double.parse(_slipCtrl.text.trim());

      if (engineRpm <= 0 ||
          tireDiameter <= 0 ||
          transRatio <= 0 ||
          diffRatio <= 0) {
        setState(() => _notes = 'Please enter positive values for all fields.');
        return;
      }

      // Convert tire diameter to inches if needed
      final tireDiaInches = _diameterUnit == DiameterUnit.inches
          ? tireDiameter
          : tireDiameter / 2.54;

      // Tire circumference in inches
      final circumference = 3.14159 * tireDiaInches;

      // Tire revs per mile
      final tireRevsPerMile = 63360.0 / circumference; // 63360 inches per mile

      // Adjust engine RPM for converter slip
      // If slip is 10%, converter output is 90% of engine RPM
      final slipFactor = (100.0 - slipPct.clamp(0.0, 100.0)) / 100.0;
      final converterOutputRpm = engineRpm * slipFactor;

      // Overall drive ratio = transmission × differential
      final overallRatio = transRatio * diffRatio;

      // Tire RPM = converter output RPM / overall drive ratio
      final calculatedTireRpm = converterOutputRpm / overallRatio;

      // MPH = tire RPM × 60 / tire revs per mile
      final mph = (calculatedTireRpm * 60.0) / tireRevsPerMile;

      setState(() {
        _mph = mph.toStringAsFixed(2);
        _tireRpm = calculatedTireRpm.toStringAsFixed(0);
        _notes = slipPct > 0
            ? 'Converter slip ${slipPct.toStringAsFixed(1)}% applied (output RPM: ${converterOutputRpm.toStringAsFixed(0)}). Overall drive ratio: ${overallRatio.toStringAsFixed(2)}:1'
            : 'No converter slip (1:1 coupling assumed). Overall drive ratio: ${overallRatio.toStringAsFixed(2)}:1';
      });
    } catch (e) {
      setState(() {
        _notes = 'Invalid input: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MPH Calculator'),
        backgroundColor: Colors.blue.shade700,
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
            Card(
              color: Colors.blue[50],
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Calculate vehicle speed (MPH) from engine RPM, tire size, transmission gear ratio, differential (rear) ratio, and torque converter slip.\n\n'
                  'Overall drive ratio = transmission ratio × differential ratio.\n'
                  'Converter slip reduces effective RPM to the transmission input (e.g., 10% slip means converter outputs 90% of engine RPM).\n'
                  'Set slip to 0% for direct-drive or locked converter.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Engine RPM
            TextField(
              controller: _rpmCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Engine RPM',
                hintText: 'e.g. 6000',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Tire diameter with unit toggle
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tireDiameterCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Tire Diameter',
                      hintText: 'e.g. 28',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<DiameterUnit>(
                  segments: const [
                    ButtonSegment(
                      value: DiameterUnit.inches,
                      label: Text('in'),
                    ),
                    ButtonSegment(value: DiameterUnit.cm, label: Text('cm')),
                  ],
                  selected: {_diameterUnit},
                  onSelectionChanged: (s) =>
                      setState(() => _diameterUnit = s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transmission ratio and differential ratio
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _transRatioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Transmission Ratio',
                      hintText: 'e.g. 1.0 (direct), 2.5 (1st)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _diffRatioCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Differential Ratio',
                      hintText: 'e.g. 3.73',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Converter slip
            TextField(
              controller: _slipCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Converter Slip (%)',
                hintText: 'e.g. 10 (0 = locked)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  AdManager.showInterstitial(onDismissed: _calculate),
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
            if (_mph.isNotEmpty)
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Results',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _row('Vehicle Speed (MPH):', _mph),
                      _row('Tire RPM:', _tireRpm),
                      if (_notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _notes,
                          style: const TextStyle(
                            fontSize: 12,
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

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

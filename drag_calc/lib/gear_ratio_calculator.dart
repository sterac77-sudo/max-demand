import 'package:flutter/material.dart';
import 'ad_manager.dart';

enum DiameterUnit { inches, cm }

class GearRatioCalculator extends StatefulWidget {
  const GearRatioCalculator({super.key});

  @override
  State<GearRatioCalculator> createState() => _GearRatioCalculatorState();
}

class _GearRatioCalculatorState extends State<GearRatioCalculator> {
  final _tireDiameterCtrl = TextEditingController();
  final _mphCtrl = TextEditingController();
  final _rpmCtrl = TextEditingController();
  final _transGearCtrl = TextEditingController(text: '1.0');
  final _slipCtrl = TextEditingController(text: '0');

  DiameterUnit _diameterUnit = DiameterUnit.inches;

  String _rearGearRatio = '';
  String _overallRatio = '';
  String _notes = '';

  @override
  void dispose() {
    _tireDiameterCtrl.dispose();
    _mphCtrl.dispose();
    _rpmCtrl.dispose();
    _transGearCtrl.dispose();
    _slipCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _rearGearRatio = '';
      _overallRatio = '';
      _notes = '';
    });

    try {
      final tireDiameter = double.parse(_tireDiameterCtrl.text.trim());
      final mph = double.parse(_mphCtrl.text.trim());
      final rpm = double.parse(_rpmCtrl.text.trim());
      final transGear = double.parse(_transGearCtrl.text.trim());
      final slipPct = double.parse(_slipCtrl.text.trim());

      if (tireDiameter <= 0 || mph <= 0 || rpm <= 0 || transGear <= 0) {
        setState(
          () => _notes =
              'Please enter positive values for tire diameter, MPH, RPM, and transmission gear.',
        );
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

      // Tire RPM at given MPH
      final tireRpm = tireRevsPerMile * mph / 60.0;

      // Adjust engine RPM for converter slip
      // If slip is 10%, converter output is 90% of engine RPM
      final slipFactor = (100.0 - slipPct.clamp(0.0, 100.0)) / 100.0;
      final converterOutputRpm = rpm * slipFactor;

      // Rear gear ratio = (converter output RPM) / (tire RPM)
      final rearGear = converterOutputRpm / tireRpm;

      // Overall drive ratio = transmission gear × rear gear
      final overallRatio = transGear * rearGear;

      setState(() {
        _rearGearRatio = rearGear.toStringAsFixed(2);
        _overallRatio = overallRatio.toStringAsFixed(2);
        _notes = slipPct > 0
            ? 'Converter slip ${slipPct.toStringAsFixed(1)}% applied (output RPM: ${converterOutputRpm.toStringAsFixed(0)}).'
            : 'No converter slip (1:1 coupling assumed).';
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
        title: const Text('Gear Ratio Calculator'),
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
                  'Calculate rear gear ratio and overall drive ratio from vehicle speed, engine RPM, tire size, transmission gear, and torque converter slip.\n\n'
                  'Converter slip reduces effective RPM to the transmission input (e.g., 10% slip means converter outputs 90% of engine RPM).\n'
                  'Set slip to 0% for direct-drive or locked converter.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
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

            // MPH and RPM
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mphCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Vehicle Speed (MPH)',
                      hintText: 'e.g. 100',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
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
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Transmission gear and converter slip
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _transGearCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Transmission Gear Ratio',
                      hintText: 'e.g. 1.0 (direct), 2.5 (1st)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
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
                ),
              ],
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
            if (_rearGearRatio.isNotEmpty)
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
                      _row('Rear Gear Ratio:', '$_rearGearRatio:1'),
                      _row('Overall Drive Ratio:', '$_overallRatio:1'),
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

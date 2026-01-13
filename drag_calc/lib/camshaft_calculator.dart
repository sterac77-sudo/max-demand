import 'package:flutter/material.dart';
import 'ad_manager.dart';

class CamshaftCalculator extends StatefulWidget {
  const CamshaftCalculator({super.key});

  @override
  State<CamshaftCalculator> createState() => _CamshaftCalculatorState();
}

class _CamshaftCalculatorState extends State<CamshaftCalculator> {
  final _intakeDurationController = TextEditingController();
  final _exhaustDurationController = TextEditingController();
  final _lsaController = TextEditingController();
  final _intakeCenterlineController = TextEditingController();

  String _ivoResult = '';
  String _ivcResult = '';
  String _evoResult = '';
  String _evcResult = '';
  String _overlapResult = '';

  @override
  void dispose() {
    _intakeDurationController.dispose();
    _exhaustDurationController.dispose();
    _lsaController.dispose();
    _intakeCenterlineController.dispose();
    super.dispose();
  }

  void _calculate() {
    final intDurText = _intakeDurationController.text.trim();
    final exhDurText = _exhaustDurationController.text.trim();
    final lsaText = _lsaController.text.trim();
    final intCLText = _intakeCenterlineController.text.trim();

    if (intDurText.isEmpty ||
        exhDurText.isEmpty ||
        lsaText.isEmpty ||
        intCLText.isEmpty) {
      setState(() {
        _ivoResult = 'Please fill in all fields';
        _ivcResult = '';
        _evoResult = '';
        _evcResult = '';
        _overlapResult = '';
      });
      return;
    }

    try {
      final intakeDuration = double.parse(intDurText);
      final exhaustDuration = double.parse(exhDurText);
      final lsa = double.parse(lsaText);
      final intakeCenterline = double.parse(intCLText);

      if (intakeDuration <= 0 || exhaustDuration <= 0 || lsa <= 0) {
        setState(() {
          _ivoResult = 'Values must be greater than zero';
          _ivcResult = '';
          _evoResult = '';
          _evcResult = '';
          _overlapResult = '';
        });
        return;
      }

      // Camshaft timing calculations:
      // IVO = (Intake Duration / 2) - Intake Centerline
      // IVC = Intake Centerline + (Intake Duration / 2) - 180
      // Exhaust Centerline = Intake Centerline - LSA
      // EVO = (Exhaust Duration / 2) - 2×(180 - Exhaust Centerline)
      // EVC = 180 - 2×Exhaust Centerline + (Exhaust Duration / 2)
      // Overlap = IVO + EVC (algebraically, considering signs)

      final exhaustCenterline = intakeCenterline - lsa;

      // IVO in degrees relative to TDC (positive = BTDC, negative = ATDC)
      final ivoRaw = (intakeDuration / 2.0) - intakeCenterline;

      // IVC in degrees relative to BDC (positive = ABDC, negative = BBDC)
      final ivcRaw = intakeCenterline + (intakeDuration / 2.0) - 180.0;

      // EVO in degrees relative to BDC (positive = BBDC, negative = ABDC)
      final evoRaw =
          (exhaustDuration / 2.0) - 2.0 * (180.0 - exhaustCenterline);

      // EVC in degrees relative to TDC (positive = ATDC, negative = BTDC)
      final evcRaw = 180.0 - 2.0 * exhaustCenterline + (exhaustDuration / 2.0);

      // Overlap: IVO (as BTDC) + EVC (as ATDC)
      // When IVO is positive, it's BTDC; when EVC is positive, it's ATDC
      final overlap = ivoRaw + evcRaw;

      setState(() {
        // IVO
        if (ivoRaw >= 0) {
          _ivoResult = '${ivoRaw.toStringAsFixed(1)}° BTDC';
        } else {
          _ivoResult = '${ivoRaw.toStringAsFixed(1)}° BTDC ( - indicates ATDC)';
        }

        // IVC
        if (ivcRaw >= 0) {
          _ivcResult = '${ivcRaw.toStringAsFixed(1)}° ABDC';
        } else {
          _ivcResult = '${ivcRaw.toStringAsFixed(1)}° ABDC ( - indicates BBDC)';
        }

        // EVO
        if (evoRaw >= 0) {
          _evoResult = '${evoRaw.toStringAsFixed(1)}° BBDC';
        } else {
          _evoResult = '${evoRaw.toStringAsFixed(1)}° BBDC ( - indicates ABDC)';
        }

        // EVC
        if (evcRaw >= 0) {
          _evcResult = '${evcRaw.toStringAsFixed(1)}° ATDC';
        } else {
          _evcResult = '${evcRaw.toStringAsFixed(1)}° ATDC ( - indicates BTDC)';
        }

        _overlapResult = '${overlap.toStringAsFixed(1)}°';
      });
    } catch (_) {
      setState(() {
        _ivoResult = 'Invalid input';
        _ivcResult = '';
        _evoResult = '';
        _evcResult = '';
        _overlapResult = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camshaft Open/Close'),
        backgroundColor: Colors.purple,
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
                  'Use Advertised Durations - usually at .006" lift\n'
                  'If you use .050" Duration numbers, the opening/close will be at .050" lift\n'
                  'Intake Opens BTDC (ATDC is -) and Exhaust Closes ATDC (BTDC is -)',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _intakeDurationController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Advertised Intake Duration',
                border: OutlineInputBorder(),
                suffixText: '°',
              ),
              onChanged: (_) => setState(() {
                _ivoResult = '';
                _ivcResult = '';
                _evoResult = '';
                _evcResult = '';
                _overlapResult = '';
              }),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _exhaustDurationController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Advertised Exhaust Duration',
                border: OutlineInputBorder(),
                suffixText: '°',
              ),
              onChanged: (_) => setState(() {
                _ivoResult = '';
                _ivcResult = '';
                _evoResult = '';
                _evcResult = '';
                _overlapResult = '';
              }),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _lsaController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'LSA (Lobe Separation Angle)',
                border: OutlineInputBorder(),
                suffixText: '°',
              ),
              onChanged: (_) => setState(() {
                _ivoResult = '';
                _ivcResult = '';
                _evoResult = '';
                _evcResult = '';
                _overlapResult = '';
              }),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _intakeCenterlineController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Intake Centerline',
                border: OutlineInputBorder(),
                suffixText: '°',
              ),
              onChanged: (_) => setState(() {
                _ivoResult = '';
                _ivcResult = '';
                _evoResult = '';
                _evcResult = '';
                _overlapResult = '';
              }),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () =>
                  AdManager.showInterstitial(onDismissed: _calculate),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            if (_ivoResult.isNotEmpty)
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Valve Events',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildEventRow('Intake Open (IVO):', _ivoResult),
                      const SizedBox(height: 8),
                      _buildEventRow('Intake Close (IVC):', _ivcResult),
                      const SizedBox(height: 8),
                      _buildEventRow('Exhaust Open (EVO):', _evoResult),
                      const SizedBox(height: 8),
                      _buildEventRow('Exhaust Close (EVC):', _evcResult),
                      if (_overlapResult.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildEventRow('Overlap:', _overlapResult),
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

  Widget _buildEventRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
      ],
    );
  }
}

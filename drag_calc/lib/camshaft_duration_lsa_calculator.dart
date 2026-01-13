import 'package:flutter/material.dart';
import 'ad_manager.dart';

class CamshaftDurationLsaCalculator extends StatefulWidget {
  const CamshaftDurationLsaCalculator({super.key});

  @override
  State<CamshaftDurationLsaCalculator> createState() =>
      _CamshaftDurationLsaCalculatorState();
}

class _CamshaftDurationLsaCalculatorState
    extends State<CamshaftDurationLsaCalculator> {
  final _ivoController = TextEditingController();
  final _ivcController = TextEditingController();
  final _evoController = TextEditingController();
  final _evcController = TextEditingController();

  String _intakeDuration = '';
  String _exhaustDuration = '';
  String _icl = '';
  String _lsa = '';
  String _ecl = '';
  String _overlap = '';

  @override
  void dispose() {
    _ivoController.dispose();
    _ivcController.dispose();
    _evoController.dispose();
    _evcController.dispose();
    super.dispose();
  }

  void _calculate() {
    final ivoText = _ivoController.text.trim();
    final ivcText = _ivcController.text.trim();
    final evoText = _evoController.text.trim();
    final evcText = _evcController.text.trim();

    if (ivoText.isEmpty ||
        ivcText.isEmpty ||
        evoText.isEmpty ||
        evcText.isEmpty) {
      setState(() {
        _intakeDuration = 'Please fill in all fields';
        _exhaustDuration = '';
        _icl = '';
        _lsa = '';
        _ecl = '';
        _overlap = '';
      });
      return;
    }

    try {
      final ivo = double.parse(ivoText); // ° BTDC (negative indicates ATDC)
      final ivc = double.parse(ivcText); // ° ABDC (negative indicates BBDC)
      final evo = double.parse(evoText); // ° BBDC (negative indicates ABDC)
      final evc = double.parse(evcText); // ° ATDC (negative indicates BTDC)

      // Intake side inversion
      final intakeDuration = ivo + ivc + 180.0; // IDur = IVO + IVC + 180
      final icl = (ivc - ivo + 180.0) / 2.0; // ICL = (IVC - IVO + 180)/2

      // Exhaust side inversion
      final exhaustDuration = evo + evc + 180.0; // EDur = EVO + EVC + 180
      final ecl = (540.0 - evc + evo) / 4.0; // ECL = (540 - EVC + EVO)/4

      // LSA = ICL - ECL
      final lsa = icl - ecl;

      // Overlap as algebraic sum IVO + EVC
      final overlap = ivo + evc;

      setState(() {
        _intakeDuration = '${intakeDuration.toStringAsFixed(1)}°';
        _exhaustDuration = '${exhaustDuration.toStringAsFixed(1)}°';
        _icl = '${icl.toStringAsFixed(1)}°';
        _lsa = '${lsa.toStringAsFixed(1)}°';
        _ecl = '${ecl.toStringAsFixed(1)}°';
        _overlap = '${overlap.toStringAsFixed(1)}°';
      });
    } catch (_) {
      setState(() {
        _intakeDuration = 'Invalid input';
        _exhaustDuration = '';
        _icl = '';
        _lsa = '';
        _ecl = '';
        _overlap = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camshaft Duration/LSA/Lobe Centre'),
        backgroundColor: Colors.teal,
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
                  'Use Advertised Durations - usually at .006" lift for cam cards.\n'
                  'Inputs here are valve events: enter IVO (° BTDC; negative = ATDC), IVC (° ABDC; negative = BBDC),\n'
                  'EVO (° BBDC; negative = ABDC), EVC (° ATDC; negative = BTDC).\n'
                  'Intake Opens BTDC (ATDC is -) and Exhaust Closes ATDC (BTDC is -)',
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Inputs: IVO, IVC, EVO, EVC
            TextField(
              controller: _ivoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'IVO (° BTDC; negative = ATDC)',
                helperText: 'Intake Opens BTDC (ATDC is -)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _clearResults(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _ivcController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'IVC (° ABDC; negative = BBDC)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _clearResults(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _evoController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'EVO (° BBDC; negative = ABDC)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _clearResults(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _evcController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'EVC (° ATDC; negative = BTDC)',
                helperText: 'Exhaust Closes ATDC (BTDC is -)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => _clearResults(),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () =>
                  AdManager.showInterstitial(onDismissed: _calculate),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),

            if (_intakeDuration.isNotEmpty)
              Card(
                color: Colors.teal[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calculated Specs',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _row('Intake Duration:', _intakeDuration),
                      const SizedBox(height: 8),
                      _row('Exhaust Duration:', _exhaustDuration),
                      const SizedBox(height: 8),
                      _row('Intake Centerline (ICL):', _icl),
                      const SizedBox(height: 8),
                      _row('Exhaust Centerline (ECL):', _ecl),
                      const SizedBox(height: 8),
                      _row('LSA (Lobe Separation Angle):', _lsa),
                      const SizedBox(height: 8),
                      _row('Overlap:', _overlap),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _clearResults() {
    setState(() {
      _intakeDuration = '';
      _exhaustDuration = '';
      _icl = '';
      _lsa = '';
      _ecl = '';
      _overlap = '';
    });
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 220,
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

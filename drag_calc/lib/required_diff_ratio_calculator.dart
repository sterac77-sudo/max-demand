import 'package:flutter/material.dart';
import 'ad_manager.dart';

class RequiredDiffRatioCalculator extends StatefulWidget {
  const RequiredDiffRatioCalculator({super.key});

  @override
  State<RequiredDiffRatioCalculator> createState() =>
      _RequiredDiffRatioCalculatorState();
}

class _RequiredDiffRatioCalculatorState
    extends State<RequiredDiffRatioCalculator> {
  final _rpmCtrl = TextEditingController();
  final _mphCtrl = TextEditingController();
  final _tyreDiameterCtrl = TextEditingController();

  String _result = '';

  void _calculate() {
    setState(() {
      _result = '';
    });

    try {
      final rpm = double.parse(_rpmCtrl.text.trim());
      final mph = double.parse(_mphCtrl.text.trim());
      final tyreDiameter = double.parse(_tyreDiameterCtrl.text.trim());

      if (rpm <= 0 || mph <= 0 || tyreDiameter <= 0) {
        setState(() {
          _result = 'Please enter positive values for all fields.';
        });
        return;
      }

      // Calculate tyre circumference in inches
      final tyreCircum = 3.14159265359 * tyreDiameter;

      // Formula: Diff Ratio = (RPM × Tyre Circumference) / (MPH × 1056)
      // Where 1056 = feet per mile (5280) / 5 (conversion factor)
      final diffRatio = (rpm * tyreCircum) / (mph * 1056.0);

      // Calculate what MPH would be with common diff ratios
      final commonRatios = [2.73, 3.08, 3.23, 3.42, 3.55, 3.73, 3.90, 4.10, 4.30, 4.56, 4.88];
      final closestRatio = commonRatios.reduce((a, b) => 
        (a - diffRatio).abs() < (b - diffRatio).abs() ? a : b
      );
      
      final mphWithClosest = (rpm * tyreCircum) / (closestRatio * 1056.0);
      final rpmWithClosest = (mph * closestRatio * 1056.0) / tyreCircum;

      setState(() {
        _result = '''
Input Values:
• Engine RPM: ${rpm.toStringAsFixed(0)}
• Vehicle MPH: ${mph.toStringAsFixed(2)}
• Tyre Diameter: ${tyreDiameter.toStringAsFixed(2)} inches

Calculated Results:
• Tyre Circumference: ${tyreCircum.toStringAsFixed(2)} inches
• Required Diff Ratio: ${diffRatio.toStringAsFixed(2)}:1

Closest Common Ratio:
• ${closestRatio.toStringAsFixed(2)}:1
• With this ratio at ${rpm.toStringAsFixed(0)} RPM: ${mphWithClosest.toStringAsFixed(2)} MPH
• To reach ${mph.toStringAsFixed(2)} MPH: ${rpmWithClosest.toStringAsFixed(0)} RPM needed

Common Differential Ratios:
${commonRatios.map((ratio) {
  final mphAtRatio = (rpm * tyreCircum) / (ratio * 1056.0);
  return '• ${ratio.toStringAsFixed(2)}:1 → ${mphAtRatio.toStringAsFixed(2)} MPH at ${rpm.toStringAsFixed(0)} RPM';
}).join('\n')}
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
        title: const Text('Required Diff Ratio Calculator'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Calculate the differential ratio needed for target RPM and MPH',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rpmCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Engine RPM',
              hintText: 'e.g. 6500',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _mphCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Target MPH',
              hintText: 'e.g. 125.5',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _tyreDiameterCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Tyre Diameter (inches)',
              hintText: 'e.g. 28.5',
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
          const Card(
            color: Colors.grey,
            child: Padding(
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
                    '• This assumes direct drive (1:1 transmission ratio)\n'
                    '• For geared applications, multiply result by gear ratio\n'
                    '• Higher diff ratio = more acceleration, lower top speed\n'
                    '• Lower diff ratio = less acceleration, higher top speed\n'
                    '• Tyre diameter affects effective gearing significantly',
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
    _rpmCtrl.dispose();
    _mphCtrl.dispose();
    _tyreDiameterCtrl.dispose();
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

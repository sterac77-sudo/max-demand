import 'package:flutter/material.dart';
import 'cubic_inch_calculator.dart';
import 'compression_ratio_calculator.dart';
import 'piston_speed_calculator.dart';
import 'camshaft_calculator.dart';
import 'camshaft_duration_lsa_calculator.dart';
import 'methanol_injection_calculator.dart';
import 'total_engine_calculator.dart';

class EngineCalculatorsScreen extends StatelessWidget {
  const EngineCalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Engine Calculators'),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.green[50],
            child: ListTile(
              leading: const Icon(Icons.engineering, color: Colors.green),
              title: const Text('Total Engine Calculator'),
              subtitle: const Text('Displacement, geometry, dynamic CR, speeds'),
              trailing: const Icon(Icons.chevron_right, color: Colors.green),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TotalEngineCalculator()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green[50],
            child: ListTile(
              leading: const Icon(Icons.straighten, color: Colors.green),
              title: const Text('Cubic Inch Displacement'),
              subtitle: const Text('Bore, stroke, and cylinders (ci & cc)'),
              trailing: const Icon(Icons.chevron_right, color: Colors.green),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CubicInchCalculator()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green[50],
            child: ListTile(
              leading: const Icon(Icons.oil_barrel, color: Colors.green),
              title: const Text('Mechanical FI (Methanol)'),
              subtitle: const Text('Pump, nozzles, jets, pressures'),
              trailing: const Icon(Icons.chevron_right, color: Colors.green),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const MethanolInjectionCalculator(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green[50],
            child: ListTile(
              leading: const Icon(Icons.tune, color: Colors.green),
              title: const Text('Compression Ratio'),
              subtitle: const Text('Bore, stroke, head cc, gasket, deck'),
              trailing: const Icon(Icons.chevron_right, color: Colors.green),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CompressionRatioCalculator(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green[50],
            child: ListTile(
              leading: const Icon(Icons.speed, color: Colors.green),
              title: const Text('Piston Speed'),
              subtitle: const Text('Mean and max piston speed'),
              trailing: const Icon(Icons.chevron_right, color: Colors.green),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PistonSpeedCalculator(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green[50],
            child: ListTile(
              leading: const Icon(Icons.timeline, color: Colors.green),
              title: const Text('Camshaft Open/Close'),
              subtitle: const Text('Valve timing events and overlap'),
              trailing: const Icon(Icons.chevron_right, color: Colors.green),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CamshaftCalculator()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.green[50],
            child: ListTile(
              leading: const Icon(Icons.timeline, color: Colors.green),
              title: const Text('Camshaft Duration/LSA/Lobe Centre'),
              subtitle: const Text('Reverse: durations, centers, and LSA'),
              trailing: const Icon(Icons.chevron_right, color: Colors.green),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CamshaftDurationLsaCalculator(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

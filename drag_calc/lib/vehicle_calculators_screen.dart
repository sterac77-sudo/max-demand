import 'package:flutter/material.dart';
import 'main.dart' show DragCalcScreen;
import 'wind_speed_calculator.dart';
import 'hp_weight_speed_calculator.dart';
import 'power_to_track_calculator.dart';
import 'hp_from_60ft_calculator.dart';
import 'gear_ratio_calculator.dart';
import 'mph_calculator.dart';
import 'converter_slip_calculator.dart';
import 'required_diff_ratio_calculator.dart';

class VehicleCalculatorsScreen extends StatelessWidget {
  const VehicleCalculatorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle / Track Calculators'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.speed, color: Colors.blue),
              title: const Text('ET/MPH Calculator'),
              subtitle: const Text('ET and trap speed plus per-gear speeds'),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DragCalcScreen())),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.air, color: Colors.blue),
              title: const Text('Wind Speed V ET/MPH'),
              subtitle: const Text('Calculate wind effect on performance'),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const WindSpeedCalculator()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.calculate, color: Colors.blue),
              title: const Text('HP/Weight/Speed'),
              subtitle: const Text('Enter any 2 values to calculate the 3rd'),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const HpWeightSpeedCalculator(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.flash_on, color: Colors.blue),
              title: const Text('Power to Track'),
              subtitle: const Text('Usable HP at launch based on traction'),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PowerToTrackCalculator(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.timer, color: Colors.blue),
              title: const Text("HP from 60' ET"),
              subtitle: const Text('Estimate HP from 60-foot time'),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HpFrom60ftCalculator()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.settings, color: Colors.blue),
              title: const Text('Gear Ratio Calculator'),
              subtitle: const Text('Calculate rear and overall gear ratios'),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GearRatioCalculator()),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.speed_outlined, color: Colors.blue),
              title: const Text('MPH Calculator'),
              subtitle: const Text(
                'Calculate vehicle speed from RPM and gearing',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const MphCalculator())),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.transform, color: Colors.blue),
              title: const Text('Converter Slip Calculator'),
              subtitle: const Text(
                'Calculate torque converter slip at finish line',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ConverterSlipCalculator(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.precision_manufacturing, color: Colors.blue),
              title: const Text('Required Diff Ratio'),
              subtitle: const Text(
                'Calculate differential ratio from RPM, MPH, and tyre size',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RequiredDiffRatioCalculator(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

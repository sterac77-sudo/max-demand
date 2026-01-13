import 'package:flutter/material.dart';
import 'vehicle_calculators_screen.dart';
import 'engine_calculators_screen.dart';
import 'data_log_screen.dart';
import 'saved_data_logs_screen.dart';
import 'engine_spec_entry_screen.dart';
import 'saved_engine_specs_screen.dart';
import 'ad_manager.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Drag Racing Toolbox')),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: SafeArea(child: AdBanner()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero graphic banner with gradient and racing theme
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1a237e),
                  Color(0xFFd32f2f),
                  Color(0xFFff6f00),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern with racing stripes
                Positioned.fill(
                  child: CustomPaint(painter: _RacingStripesPainter()),
                ),
                // Center content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.flash_on,
                            color: Colors.yellowAccent,
                            size: 40,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.sports_motorsports,
                            color: Colors.white,
                            size: 50,
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.flash_on,
                            color: Colors.yellowAccent,
                            size: 40,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'DRAG RACING TOOLBOX',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Powered by InTolerance Racing',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.blue[50],
            child: ListTile(
              leading: const Icon(Icons.directions_car, color: Colors.blue),
              title: const Text('Vehicle / Track Calculators'),
              subtitle: const Text(
                'ET/MPH, wind, HP/weight/speed, traction, 60\' HP',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.blue),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const VehicleCalculatorsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.green[50],
            child: ListTile(
              leading: const Icon(Icons.build, color: Colors.green),
              title: const Text('Engine Calculators'),
              subtitle: const Text(
                'CID, compression, piston speed, cam events',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.green),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EngineCalculatorsScreen(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.orange[50],
            child: ListTile(
              leading: const Icon(Icons.notes, color: Colors.orange),
              title: const Text('Data Log'),
              subtitle: const Text(
                'Track info, timing data, weather, tune notes',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.orange),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const DataLogScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.deepPurple[50],
            child: ListTile(
              leading: const Icon(Icons.folder_open, color: Colors.deepPurple),
              title: const Text('View Saved Data Logs'),
              subtitle: const Text('Access your saved pass data and history'),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.deepPurple,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SavedDataLogsScreen()),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.teal[50],
            child: ListTile(
              leading: const Icon(Icons.engineering, color: Colors.teal),
              title: const Text('Engine Specs Data'),
              subtitle: const Text(
                'Record detailed engine specifications',
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.teal),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const EngineSpecEntryScreen())),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.cyan[50],
            child: ListTile(
              leading: const Icon(Icons.storage, color: Colors.cyan),
              title: const Text('View Saved Engine Specs'),
              subtitle: const Text('Access your saved engine data'),
              trailing: const Icon(
                Icons.chevron_right,
                color: Colors.cyan,
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SavedEngineSpecsScreen()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for racing stripes pattern
class _RacingStripesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw diagonal racing stripes
    for (double i = -size.height; i < size.width + size.height; i += 40) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }

    // Add some speed lines
    final speedPaint = Paint()
      ..color = Colors.yellowAccent.withOpacity(0.15)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (double y = 20; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width * 0.3, y), speedPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

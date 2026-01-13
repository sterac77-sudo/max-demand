import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/data_log_entry.dart';

class DataLogDetailScreen extends StatelessWidget {
  final DataLogEntry log;

  const DataLogDetailScreen({super.key, required this.log});

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingRow(String label, String? et, String? mph) {
    if ((et == null || et.isEmpty) && (mph == null || mph.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text('ET: ${et ?? "—"}')),
          Expanded(child: Text('MPH: ${mph ?? "—"}')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMMM d, yyyy').format(log.date);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Log Details'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Track Info Header Card
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.trackName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.tag, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text('Pass #${log.passNumber}'),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(dateStr),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(log.time),
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.straighten,
                          size: 16,
                          color: Colors.black54,
                        ),
                        const SizedBox(width: 4),
                        Text(log.trackLength),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Timing Data Section
            _buildSectionHeader('Timing Data', Icons.timer, Colors.blue),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildTimingRow('60 ft', log.et60ft, log.mph60ft),
                    _buildTimingRow('330 ft', log.et330ft, log.mph330ft),
                    if (log.trackLength == '1/4 Mile' ||
                        log.trackLength == '1000 ft')
                      _buildTimingRow('660 ft', log.et660ft, log.mph660ft),
                    if (log.trackLength == '1000 ft')
                      _buildTimingRow('1000 ft', log.et1000ft, log.mph1000ft),
                    if (log.trackLength == '1/4 Mile')
                      _buildTimingRow(
                        '1/4 Mile',
                        log.etQuarterMile,
                        log.mphQuarterMile,
                      ),
                    if (log.trackLength == '1/8 Mile')
                      _buildTimingRow(
                        '1/8 Mile',
                        log.etEighthMile,
                        log.mphEighthMile,
                      ),
                  ],
                ),
              ),
            ),

            // Weather Section
            if (_hasWeatherData())
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Weather Conditions',
                    Icons.wb_sunny,
                    Colors.amber,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Air Temperature',
                            log.airTemp != null && log.airTemp!.isNotEmpty
                                ? '${log.airTemp}°F'
                                : null,
                          ),
                          _buildInfoRow(
                            'Track Temperature',
                            log.trackTemp != null && log.trackTemp!.isNotEmpty
                                ? '${log.trackTemp}°F'
                                : null,
                          ),
                          _buildInfoRow(
                            'Density Altitude',
                            log.densityAltitude != null &&
                                    log.densityAltitude!.isNotEmpty
                                ? '${log.densityAltitude} ft'
                                : null,
                          ),
                          _buildInfoRow(
                            'Humidity',
                            log.humidity != null && log.humidity!.isNotEmpty
                                ? '${log.humidity}%'
                                : null,
                          ),
                          _buildInfoRow(
                            'Wind Speed',
                            log.windSpeed != null && log.windSpeed!.isNotEmpty
                                ? '${log.windSpeed} mph'
                                : null,
                          ),
                          _buildInfoRow('Wind Direction', log.windDirection),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            // Tune Up Notes Section
            if (log.tuneUpNotes != null && log.tuneUpNotes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    'Tune Up Notes',
                    Icons.note,
                    Colors.green,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        log.tuneUpNotes!,
                        style: const TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  bool _hasWeatherData() {
    return (log.airTemp != null && log.airTemp!.isNotEmpty) ||
        (log.trackTemp != null && log.trackTemp!.isNotEmpty) ||
        (log.densityAltitude != null && log.densityAltitude!.isNotEmpty) ||
        (log.humidity != null && log.humidity!.isNotEmpty) ||
        (log.windSpeed != null && log.windSpeed!.isNotEmpty) ||
        (log.windDirection != null && log.windDirection!.isNotEmpty);
  }
}

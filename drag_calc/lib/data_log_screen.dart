import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/data_log_entry.dart';
import 'services/data_log_storage.dart';

class DataLogScreen extends StatefulWidget {
  const DataLogScreen({super.key});

  @override
  State<DataLogScreen> createState() => _DataLogScreenState();
}

class _DataLogScreenState extends State<DataLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storage = DataLogStorage();

  // Track Info
  final _trackNameController = TextEditingController();
  final _passNumberController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _trackLength = '1/4 Mile';

  // Timing Data Controllers
  final _60ftETController = TextEditingController();
  final _60ftMPHController = TextEditingController();
  final _330ftETController = TextEditingController();
  final _330ftMPHController = TextEditingController();
  final _660ftETController = TextEditingController();
  final _660ftMPHController = TextEditingController();
  final _1000ftETController = TextEditingController();
  final _1000ftMPHController = TextEditingController();
  final _quarterMileETController = TextEditingController();
  final _quarterMileMPHController = TextEditingController();
  final _eighthMileETController = TextEditingController();
  final _eighthMileMPHController = TextEditingController();

  // Weather Data Controllers
  final _airTempController = TextEditingController();
  final _trackTempController = TextEditingController();
  final _densityAltitudeController = TextEditingController();
  final _humidityController = TextEditingController();
  final _windSpeedController = TextEditingController();
  final _windDirectionController = TextEditingController();

  // Notes
  final _tuneUpNotesController = TextEditingController();

  @override
  void dispose() {
    _trackNameController.dispose();
    _passNumberController.dispose();
    _60ftETController.dispose();
    _60ftMPHController.dispose();
    _330ftETController.dispose();
    _330ftMPHController.dispose();
    _660ftETController.dispose();
    _660ftMPHController.dispose();
    _1000ftETController.dispose();
    _1000ftMPHController.dispose();
    _quarterMileETController.dispose();
    _quarterMileMPHController.dispose();
    _eighthMileETController.dispose();
    _eighthMileMPHController.dispose();
    _airTempController.dispose();
    _trackTempController.dispose();
    _densityAltitudeController.dispose();
    _humidityController.dispose();
    _windSpeedController.dispose();
    _windDirectionController.dispose();
    _tuneUpNotesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Widget _buildTimingSection() {
    if (_trackLength == '1/4 Mile') {
      return Column(
        children: [
          _buildTimingRow('60 ft', _60ftETController, _60ftMPHController),
          _buildTimingRow('330 ft', _330ftETController, _330ftMPHController),
          _buildTimingRow('660 ft', _660ftETController, _660ftMPHController),
          _buildTimingRow(
            '1/4 Mile',
            _quarterMileETController,
            _quarterMileMPHController,
          ),
        ],
      );
    } else if (_trackLength == '1000 ft') {
      return Column(
        children: [
          _buildTimingRow('60 ft', _60ftETController, _60ftMPHController),
          _buildTimingRow('330 ft', _330ftETController, _330ftMPHController),
          _buildTimingRow('660 ft', _660ftETController, _660ftMPHController),
          _buildTimingRow('1000 ft', _1000ftETController, _1000ftMPHController),
        ],
      );
    } else {
      // 1/8 Mile
      return Column(
        children: [
          _buildTimingRow('60 ft', _60ftETController, _60ftMPHController),
          _buildTimingRow('330 ft', _330ftETController, _330ftMPHController),
          _buildTimingRow(
            '1/8 Mile',
            _eighthMileETController,
            _eighthMileMPHController,
          ),
        ],
      );
    }
  }

  Widget _buildTimingRow(
    String label,
    TextEditingController etController,
    TextEditingController mphController,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: TextFormField(
              controller: etController,
              decoration: const InputDecoration(
                labelText: 'ET (sec)',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: mphController,
              decoration: const InputDecoration(
                labelText: 'MPH',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? suffix,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
        keyboardType: keyboardType ?? TextInputType.text,
        inputFormatters:
            keyboardType == const TextInputType.numberWithOptions(decimal: true)
            ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))]
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Log'),
        backgroundColor: Colors.orange,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Track Info Section
            _buildSectionHeader(
              'Track Information',
              Icons.location_on,
              Colors.orange,
            ),
            _buildTextField('Track Name', _trackNameController),
            _buildTextField(
              'Pass Number',
              _passNumberController,
              keyboardType: TextInputType.number,
            ),

            // Date and Time
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_selectedDate.month}/${_selectedDate.day}/${_selectedDate.year}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.calendar_today, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedTime.format(context),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const Icon(Icons.access_time, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Track Length Selection
            DropdownButtonFormField<String>(
              value: _trackLength,
              decoration: const InputDecoration(
                labelText: 'Track Length',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: const [
                DropdownMenuItem(value: '1/4 Mile', child: Text('1/4 Mile')),
                DropdownMenuItem(value: '1000 ft', child: Text('1000 ft')),
                DropdownMenuItem(value: '1/8 Mile', child: Text('1/8 Mile')),
              ],
              onChanged: (value) {
                setState(() {
                  _trackLength = value!;
                });
              },
            ),

            // Timing Data Section
            _buildSectionHeader('Timing Data', Icons.timer, Colors.blue),
            _buildTimingSection(),

            // Weather Section
            _buildSectionHeader(
              'Weather Conditions',
              Icons.wb_sunny,
              Colors.amber,
            ),
            _buildTextField(
              'Air Temperature',
              _airTempController,
              suffix: '°F',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _buildTextField(
              'Track Temperature',
              _trackTempController,
              suffix: '°F',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _buildTextField(
              'Density Altitude',
              _densityAltitudeController,
              suffix: 'ft',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _buildTextField(
              'Humidity',
              _humidityController,
              suffix: '%',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _buildTextField(
              'Wind Speed',
              _windSpeedController,
              suffix: 'mph',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            _buildTextField('Wind Direction', _windDirectionController),

            // Tune Up Notes Section
            _buildSectionHeader('Tune Up Notes', Icons.note, Colors.green),
            TextFormField(
              controller: _tuneUpNotesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Add tune up notes, observations, changes made...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
              maxLines: 5,
              keyboardType: TextInputType.multiline,
            ),

            const SizedBox(height: 24),

            // Save Button
            ElevatedButton.icon(
              onPressed: () async {
                if (_trackNameController.text.isEmpty ||
                    _passNumberController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter track name and pass number'),
                    ),
                  );
                  return;
                }

                // Create data log entry
                final entry = DataLogEntry(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  trackName: _trackNameController.text,
                  passNumber: _passNumberController.text,
                  date: _selectedDate,
                  time: _selectedTime.format(context),
                  trackLength: _trackLength,
                  et60ft: _60ftETController.text,
                  mph60ft: _60ftMPHController.text,
                  et330ft: _330ftETController.text,
                  mph330ft: _330ftMPHController.text,
                  et660ft: _660ftETController.text,
                  mph660ft: _660ftMPHController.text,
                  et1000ft: _1000ftETController.text,
                  mph1000ft: _1000ftMPHController.text,
                  etQuarterMile: _quarterMileETController.text,
                  mphQuarterMile: _quarterMileMPHController.text,
                  etEighthMile: _eighthMileETController.text,
                  mphEighthMile: _eighthMileMPHController.text,
                  airTemp: _airTempController.text,
                  trackTemp: _trackTempController.text,
                  densityAltitude: _densityAltitudeController.text,
                  humidity: _humidityController.text,
                  windSpeed: _windSpeedController.text,
                  windDirection: _windDirectionController.text,
                  tuneUpNotes: _tuneUpNotesController.text,
                );

                // Save to storage
                await _storage.saveDataLog(entry);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data log saved successfully!'),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.save),
              label: const Text('Save Data Log'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

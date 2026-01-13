class DataLogEntry {
  final String id;
  final String trackName;
  final String passNumber;
  final DateTime date;
  final String time;
  final String trackLength;
  
  // Timing data
  final String? et60ft;
  final String? mph60ft;
  final String? et330ft;
  final String? mph330ft;
  final String? et660ft;
  final String? mph660ft;
  final String? et1000ft;
  final String? mph1000ft;
  final String? etQuarterMile;
  final String? mphQuarterMile;
  final String? etEighthMile;
  final String? mphEighthMile;
  
  // Weather data
  final String? airTemp;
  final String? trackTemp;
  final String? densityAltitude;
  final String? humidity;
  final String? windSpeed;
  final String? windDirection;
  
  // Notes
  final String? tuneUpNotes;

  DataLogEntry({
    required this.id,
    required this.trackName,
    required this.passNumber,
    required this.date,
    required this.time,
    required this.trackLength,
    this.et60ft,
    this.mph60ft,
    this.et330ft,
    this.mph330ft,
    this.et660ft,
    this.mph660ft,
    this.et1000ft,
    this.mph1000ft,
    this.etQuarterMile,
    this.mphQuarterMile,
    this.etEighthMile,
    this.mphEighthMile,
    this.airTemp,
    this.trackTemp,
    this.densityAltitude,
    this.humidity,
    this.windSpeed,
    this.windDirection,
    this.tuneUpNotes,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trackName': trackName,
      'passNumber': passNumber,
      'date': date.toIso8601String(),
      'time': time,
      'trackLength': trackLength,
      'et60ft': et60ft,
      'mph60ft': mph60ft,
      'et330ft': et330ft,
      'mph330ft': mph330ft,
      'et660ft': et660ft,
      'mph660ft': mph660ft,
      'et1000ft': et1000ft,
      'mph1000ft': mph1000ft,
      'etQuarterMile': etQuarterMile,
      'mphQuarterMile': mphQuarterMile,
      'etEighthMile': etEighthMile,
      'mphEighthMile': mphEighthMile,
      'airTemp': airTemp,
      'trackTemp': trackTemp,
      'densityAltitude': densityAltitude,
      'humidity': humidity,
      'windSpeed': windSpeed,
      'windDirection': windDirection,
      'tuneUpNotes': tuneUpNotes,
    };
  }

  // Create from JSON
  factory DataLogEntry.fromJson(Map<String, dynamic> json) {
    return DataLogEntry(
      id: json['id'],
      trackName: json['trackName'],
      passNumber: json['passNumber'],
      date: DateTime.parse(json['date']),
      time: json['time'],
      trackLength: json['trackLength'],
      et60ft: json['et60ft'],
      mph60ft: json['mph60ft'],
      et330ft: json['et330ft'],
      mph330ft: json['mph330ft'],
      et660ft: json['et660ft'],
      mph660ft: json['mph660ft'],
      et1000ft: json['et1000ft'],
      mph1000ft: json['mph1000ft'],
      etQuarterMile: json['etQuarterMile'],
      mphQuarterMile: json['mphQuarterMile'],
      etEighthMile: json['etEighthMile'],
      mphEighthMile: json['mphEighthMile'],
      airTemp: json['airTemp'],
      trackTemp: json['trackTemp'],
      densityAltitude: json['densityAltitude'],
      humidity: json['humidity'],
      windSpeed: json['windSpeed'],
      windDirection: json['windDirection'],
      tuneUpNotes: json['tuneUpNotes'],
    );
  }
}

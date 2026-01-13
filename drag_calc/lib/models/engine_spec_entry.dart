class EngineSpecEntry {
  final String id;
  final DateTime timestamp;
  final String engineName;

  // Block & Bottom End
  final String blockType;
  final String cid;
  final String boreSize;
  final String stroke;
  final String crankSpecs;
  final String rodType;
  final String rodLength;
  final String pistonType;
  final String pistonDiameter;
  final String compressionRatio;
  final String mainBearingSize;
  final String mainBearingClearance;
  final String bigEndBearingSize;
  final String bigEndBearingClearance;

  // Head & Valvetrain
  final String headType;
  final String inletValveLength;
  final String inletValveDia;
  final String exhaustValveLength;
  final String exhaustValveDia;
  final String rockerRatio;
  final String springPressure;
  final String springInstalledHeight;
  final String valveLashInlet;
  final String valveLashExhaust;
  final String pushrodLength;
  final String lifterType;
  final String lifterDia;
  final String lifterLength;

  // Cam Timing (expanded)
  final String camSpecs; // general notes
  final String advertisedDurationIntake;
  final String advertisedDurationExhaust;
  final String duration050Intake;
  final String duration050Exhaust;
  final String duration050; // generic field
  final String lobeCenter;
  final String installedIntakeCenterline;
  final String lobeLift;
  final String rockerArmRatio;
  final String theoreticalLift;
  final String actualLift;
  final String valveLiftIntake;
  final String valveLiftExhaust;
  final String lobeSeparation;
  final String intakeCenterline;
  final String exhaustCenterline;

  // Ignition Timing
  final String ignitionPeakTiming;
  final String ignitionTimingCurve;
  final String ignitionIdleTiming;

  // Induction Type
  final String inductionType; // 'Natural', 'Forced'
  final String naturalType; // 'Carby', 'EFI'
  
  // Natural Aspiration Specs
  final String carbySpecs;
  final String efiSpecs;

  // Forced Induction
  final String forcedType; // 'Supercharged', 'Turbo'
  final String forcedSpecs;

  // Mechanical Fuel Injection (for Forced)
  final String numHatNozzles;
  final String numHeadNozzles;
  final String mainPill;
  final String returnPill;
  final String pumpSizerPill;
  final String leanOutPill;
  final String returnPoppetPsi;

  final String notes;

  EngineSpecEntry({
    required this.id,
    required this.timestamp,
    required this.engineName,
    this.blockType = '',
    this.cid = '',
    this.boreSize = '',
    this.stroke = '',
    this.crankSpecs = '',
    this.rodType = '',
    this.rodLength = '',
    this.pistonType = '',
    this.pistonDiameter = '',
    this.compressionRatio = '',
    this.mainBearingSize = '',
    this.mainBearingClearance = '',
    this.bigEndBearingSize = '',
    this.bigEndBearingClearance = '',
    this.headType = '',
    this.inletValveLength = '',
    this.inletValveDia = '',
    this.exhaustValveLength = '',
    this.exhaustValveDia = '',
    this.rockerRatio = '',
    this.springPressure = '',
    this.springInstalledHeight = '',
    this.valveLashInlet = '',
    this.valveLashExhaust = '',
    this.pushrodLength = '',
    this.lifterType = '',
    this.lifterDia = '',
    this.lifterLength = '',
    this.camSpecs = '',
    this.advertisedDurationIntake = '',
    this.advertisedDurationExhaust = '',
    this.duration050Intake = '',
    this.duration050Exhaust = '',
    this.duration050 = '',
    this.lobeCenter = '',
    this.installedIntakeCenterline = '',
    this.lobeLift = '',
    this.rockerArmRatio = '',
    this.theoreticalLift = '',
    this.actualLift = '',
    this.valveLiftIntake = '',
    this.valveLiftExhaust = '',
    this.lobeSeparation = '',
    this.intakeCenterline = '',
    this.exhaustCenterline = '',
    this.ignitionPeakTiming = '',
    this.ignitionTimingCurve = '',
    this.ignitionIdleTiming = '',
    this.inductionType = 'Natural',
    this.naturalType = 'Carby',
    this.carbySpecs = '',
    this.efiSpecs = '',
    this.forcedType = 'Supercharged',
    this.forcedSpecs = '',
    this.numHatNozzles = '',
    this.numHeadNozzles = '',
    this.mainPill = '',
    this.returnPill = '',
    this.pumpSizerPill = '',
    this.leanOutPill = '',
    this.returnPoppetPsi = '',
    this.notes = '',
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'engineName': engineName,
        'blockType': blockType,
        'cid': cid,
        'boreSize': boreSize,
        'stroke': stroke,
        'crankSpecs': crankSpecs,
        'rodType': rodType,
        'rodLength': rodLength,
        'pistonType': pistonType,
        'pistonDiameter': pistonDiameter,
        'compressionRatio': compressionRatio,
        'mainBearingSize': mainBearingSize,
        'mainBearingClearance': mainBearingClearance,
        'bigEndBearingSize': bigEndBearingSize,
        'bigEndBearingClearance': bigEndBearingClearance,
        'headType': headType,
        'inletValveLength': inletValveLength,
        'inletValveDia': inletValveDia,
        'exhaustValveLength': exhaustValveLength,
        'exhaustValveDia': exhaustValveDia,
        'rockerRatio': rockerRatio,
        'springPressure': springPressure,
        'springInstalledHeight': springInstalledHeight,
        'valveLashInlet': valveLashInlet,
        'valveLashExhaust': valveLashExhaust,
        'pushrodLength': pushrodLength,
        'lifterType': lifterType,
        'lifterDia': lifterDia,
        'lifterLength': lifterLength,
        'camSpecs': camSpecs,
        'advertisedDurationIntake': advertisedDurationIntake,
        'advertisedDurationExhaust': advertisedDurationExhaust,
        'duration050Intake': duration050Intake,
        'duration050Exhaust': duration050Exhaust,
        'duration050': duration050,
        'lobeCenter': lobeCenter,
        'installedIntakeCenterline': installedIntakeCenterline,
        'lobeLift': lobeLift,
        'rockerArmRatio': rockerArmRatio,
        'theoreticalLift': theoreticalLift,
        'actualLift': actualLift,
        'valveLiftIntake': valveLiftIntake,
        'valveLiftExhaust': valveLiftExhaust,
        'lobeSeparation': lobeSeparation,
        'intakeCenterline': intakeCenterline,
        'exhaustCenterline': exhaustCenterline,
        'ignitionPeakTiming': ignitionPeakTiming,
        'ignitionTimingCurve': ignitionTimingCurve,
        'ignitionIdleTiming': ignitionIdleTiming,
        'inductionType': inductionType,
        'naturalType': naturalType,
        'carbySpecs': carbySpecs,
        'efiSpecs': efiSpecs,
        'forcedType': forcedType,
        'forcedSpecs': forcedSpecs,
        'numHatNozzles': numHatNozzles,
        'numHeadNozzles': numHeadNozzles,
        'mainPill': mainPill,
        'returnPill': returnPill,
        'pumpSizerPill': pumpSizerPill,
        'leanOutPill': leanOutPill,
        'returnPoppetPsi': returnPoppetPsi,
        'notes': notes,
      };

  factory EngineSpecEntry.fromJson(Map<String, dynamic> json) =>
      EngineSpecEntry(
        id: json['id'] as String,
        timestamp: DateTime.parse(json['timestamp'] as String),
        engineName: json['engineName'] as String? ?? '',
        blockType: json['blockType'] as String? ?? '',
        cid: json['cid'] as String? ?? '',
        boreSize: json['boreSize'] as String? ?? '',
        stroke: json['stroke'] as String? ?? '',
        crankSpecs: json['crankSpecs'] as String? ?? '',
        rodType: json['rodType'] as String? ?? '',
        rodLength: json['rodLength'] as String? ?? '',
        pistonType: json['pistonType'] as String? ?? '',
        pistonDiameter: json['pistonDiameter'] as String? ?? '',
        compressionRatio: json['compressionRatio'] as String? ?? '',
        mainBearingSize: json['mainBearingSize'] as String? ?? '',
        mainBearingClearance: json['mainBearingClearance'] as String? ?? '',
        bigEndBearingSize: json['bigEndBearingSize'] as String? ?? '',
        bigEndBearingClearance: json['bigEndBearingClearance'] as String? ?? '',
        headType: json['headType'] as String? ?? '',
        inletValveLength: json['inletValveLength'] as String? ?? '',
        inletValveDia: json['inletValveDia'] as String? ?? '',
        exhaustValveLength: json['exhaustValveLength'] as String? ?? '',
        exhaustValveDia: json['exhaustValveDia'] as String? ?? '',
        rockerRatio: json['rockerRatio'] as String? ?? '',
        springPressure: json['springPressure'] as String? ?? '',
        springInstalledHeight: json['springInstalledHeight'] as String? ?? '',
        valveLashInlet: json['valveLashInlet'] as String? ?? (json['tappetGapInlet'] as String? ?? ''),
        valveLashExhaust: json['valveLashExhaust'] as String? ?? (json['tappetGapExhaust'] as String? ?? ''),
        pushrodLength: json['pushrodLength'] as String? ?? '',
        lifterType: json['lifterType'] as String? ?? '',
        lifterDia: json['lifterDia'] as String? ?? '',
        lifterLength: json['lifterLength'] as String? ?? '',
        camSpecs: json['camSpecs'] as String? ?? '',
        advertisedDurationIntake: json['advertisedDurationIntake'] as String? ?? '',
        advertisedDurationExhaust: json['advertisedDurationExhaust'] as String? ?? '',
        duration050Intake: json['duration050Intake'] as String? ?? '',
        duration050Exhaust: json['duration050Exhaust'] as String? ?? '',
        duration050: json['duration050'] as String? ?? '',
        lobeCenter: json['lobeCenter'] as String? ?? '',
        installedIntakeCenterline: json['installedIntakeCenterline'] as String? ?? '',
        lobeLift: json['lobeLift'] as String? ?? '',
        rockerArmRatio: json['rockerArmRatio'] as String? ?? '',
        theoreticalLift: json['theoreticalLift'] as String? ?? '',
        actualLift: json['actualLift'] as String? ?? '',
        valveLiftIntake: json['valveLiftIntake'] as String? ?? '',
        valveLiftExhaust: json['valveLiftExhaust'] as String? ?? '',
        lobeSeparation: json['lobeSeparation'] as String? ?? '',
        intakeCenterline: json['intakeCenterline'] as String? ?? '',
        exhaustCenterline: json['exhaustCenterline'] as String? ?? '',
        ignitionPeakTiming: json['ignitionPeakTiming'] as String? ?? '',
        ignitionTimingCurve: json['ignitionTimingCurve'] as String? ?? '',
        ignitionIdleTiming: json['ignitionIdleTiming'] as String? ?? '',
        inductionType: json['inductionType'] as String? ?? 'Natural',
        naturalType: json['naturalType'] as String? ?? 'Carby',
        carbySpecs: json['carbySpecs'] as String? ?? '',
        efiSpecs: json['efiSpecs'] as String? ?? '',
        forcedType: json['forcedType'] as String? ?? 'Supercharged',
        forcedSpecs: json['forcedSpecs'] as String? ?? '',
        numHatNozzles: json['numHatNozzles'] as String? ?? '',
        numHeadNozzles: json['numHeadNozzles'] as String? ?? '',
        mainPill: json['mainPill'] as String? ?? '',
        returnPill: json['returnPill'] as String? ?? '',
        pumpSizerPill: json['pumpSizerPill'] as String? ?? '',
        leanOutPill: json['leanOutPill'] as String? ?? '',
        returnPoppetPsi: json['returnPoppetPsi'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
      );
}

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'models/engine_spec_entry.dart';
import 'services/engine_spec_storage.dart';

class EngineSpecEntryScreen extends StatefulWidget {
  final EngineSpecEntry? existingEntry;

  const EngineSpecEntryScreen({super.key, this.existingEntry});

  @override
  State<EngineSpecEntryScreen> createState() => _EngineSpecEntryScreenState();
}

class _EngineSpecEntryScreenState extends State<EngineSpecEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _engineNameCtrl = TextEditingController();
  final _blockTypeCtrl = TextEditingController();
  final _cidCtrl = TextEditingController();
  final _boreSizeCtrl = TextEditingController();
  final _strokeCtrl = TextEditingController();
  final _crankSpecsCtrl = TextEditingController();
  final _rodTypeCtrl = TextEditingController();
  final _rodLengthCtrl = TextEditingController();
  final _pistonTypeCtrl = TextEditingController();
  final _pistonDiameterCtrl = TextEditingController();
  final _compressionRatioCtrl = TextEditingController();
  final _mainBearingSizeCtrl = TextEditingController();
  final _mainBearingClearanceCtrl = TextEditingController();
  final _bigEndBearingSizeCtrl = TextEditingController();
  final _bigEndBearingClearanceCtrl = TextEditingController();
  final _headTypeCtrl = TextEditingController();
  final _inletValveLengthCtrl = TextEditingController();
  final _inletValveDiaCtrl = TextEditingController();
  final _exhaustValveLengthCtrl = TextEditingController();
  final _exhaustValveDiaCtrl = TextEditingController();
  final _rockerRatioCtrl = TextEditingController();
  final _springPressureCtrl = TextEditingController();
  final _springInstalledHeightCtrl = TextEditingController();
  final _valveLashInletCtrl = TextEditingController();
  final _valveLashExhaustCtrl = TextEditingController();
  final _pushrodLengthCtrl = TextEditingController();
  final _lifterTypeCtrl = TextEditingController();
  final _lifterDiaCtrl = TextEditingController();
  final _lifterLengthCtrl = TextEditingController();
  final _camSpecsCtrl = TextEditingController();
  final _advDurIntakeCtrl = TextEditingController();
  final _advDurExhaustCtrl = TextEditingController();
  final _dur050IntakeCtrl = TextEditingController();
  final _dur050ExhaustCtrl = TextEditingController();
  final _dur050Ctrl = TextEditingController();
  final _lobeCenterCtrl = TextEditingController();
  final _installedIclCtrl = TextEditingController();
  final _lobeLiftCtrl = TextEditingController();
  final _rockerArmRatioCtrl = TextEditingController();
  final _theoreticalLiftCtrl = TextEditingController();
  final _actualLiftCtrl = TextEditingController();
  final _liftIntakeCtrl = TextEditingController();
  final _liftExhaustCtrl = TextEditingController();
  final _lsaCtrl = TextEditingController();
  final _iclCtrl = TextEditingController();
  final _eclCtrl = TextEditingController();
  final _ignPeakCtrl = TextEditingController();
  final _ignCurveCtrl = TextEditingController();
  final _ignIdleCtrl = TextEditingController();
  final _carbySpecsCtrl = TextEditingController();
  final _efiSpecsCtrl = TextEditingController();
  final _forcedSpecsCtrl = TextEditingController();
  final _numHatNozzlesCtrl = TextEditingController();
  final _numHeadNozzlesCtrl = TextEditingController();
  final _mainPillCtrl = TextEditingController();
  final _returnPillCtrl = TextEditingController();
  final _pumpSizerPillCtrl = TextEditingController();
  final _leanOutPillCtrl = TextEditingController();
  final _returnPoppetPsiCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _inductionType = 'Natural';
  String _naturalType = 'Carby';
  String _forcedType = 'Supercharged';

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _loadExistingEntry();
    }
  }

  void _loadExistingEntry() {
    final entry = widget.existingEntry!;
    _engineNameCtrl.text = entry.engineName;
    _blockTypeCtrl.text = entry.blockType;
    _cidCtrl.text = entry.cid;
    _boreSizeCtrl.text = entry.boreSize;
    _strokeCtrl.text = entry.stroke;
    _crankSpecsCtrl.text = entry.crankSpecs;
    _rodTypeCtrl.text = entry.rodType;
    _rodLengthCtrl.text = entry.rodLength;
    _pistonTypeCtrl.text = entry.pistonType;
    _pistonDiameterCtrl.text = entry.pistonDiameter;
    _compressionRatioCtrl.text = entry.compressionRatio;
    _mainBearingSizeCtrl.text = entry.mainBearingSize;
    _mainBearingClearanceCtrl.text = entry.mainBearingClearance;
    _bigEndBearingSizeCtrl.text = entry.bigEndBearingSize;
    _bigEndBearingClearanceCtrl.text = entry.bigEndBearingClearance;
    _headTypeCtrl.text = entry.headType;
    _inletValveLengthCtrl.text = entry.inletValveLength;
    _inletValveDiaCtrl.text = entry.inletValveDia;
    _exhaustValveLengthCtrl.text = entry.exhaustValveLength;
    _exhaustValveDiaCtrl.text = entry.exhaustValveDia;
    _rockerRatioCtrl.text = entry.rockerRatio;
    _springPressureCtrl.text = entry.springPressure;
    _springInstalledHeightCtrl.text = entry.springInstalledHeight;
    _valveLashInletCtrl.text = entry.valveLashInlet;
    _valveLashExhaustCtrl.text = entry.valveLashExhaust;
    _pushrodLengthCtrl.text = entry.pushrodLength;
    _lifterTypeCtrl.text = entry.lifterType;
    _lifterDiaCtrl.text = entry.lifterDia;
    _lifterLengthCtrl.text = entry.lifterLength;
    _camSpecsCtrl.text = entry.camSpecs;
    _advDurIntakeCtrl.text = entry.advertisedDurationIntake;
    _advDurExhaustCtrl.text = entry.advertisedDurationExhaust;
    _dur050IntakeCtrl.text = entry.duration050Intake;
    _dur050ExhaustCtrl.text = entry.duration050Exhaust;
    _dur050Ctrl.text = entry.duration050;
    _lobeCenterCtrl.text = entry.lobeCenter;
    _installedIclCtrl.text = entry.installedIntakeCenterline;
    _lobeLiftCtrl.text = entry.lobeLift;
    _rockerArmRatioCtrl.text = entry.rockerArmRatio;
    _theoreticalLiftCtrl.text = entry.theoreticalLift;
    _actualLiftCtrl.text = entry.actualLift;
    _liftIntakeCtrl.text = entry.valveLiftIntake;
    _liftExhaustCtrl.text = entry.valveLiftExhaust;
    _lsaCtrl.text = entry.lobeSeparation;
    _iclCtrl.text = entry.intakeCenterline;
    _eclCtrl.text = entry.exhaustCenterline;
    _ignPeakCtrl.text = entry.ignitionPeakTiming;
    _ignCurveCtrl.text = entry.ignitionTimingCurve;
    _ignIdleCtrl.text = entry.ignitionIdleTiming;
    _carbySpecsCtrl.text = entry.carbySpecs;
    _efiSpecsCtrl.text = entry.efiSpecs;
    _forcedSpecsCtrl.text = entry.forcedSpecs;
    _numHatNozzlesCtrl.text = entry.numHatNozzles;
    _numHeadNozzlesCtrl.text = entry.numHeadNozzles;
    _mainPillCtrl.text = entry.mainPill;
    _returnPillCtrl.text = entry.returnPill;
    _pumpSizerPillCtrl.text = entry.pumpSizerPill;
    _leanOutPillCtrl.text = entry.leanOutPill;
    _returnPoppetPsiCtrl.text = entry.returnPoppetPsi;
    _notesCtrl.text = entry.notes;
    setState(() {
      _inductionType = entry.inductionType;
      _naturalType = entry.naturalType;
      _forcedType = entry.forcedType;
    });
  }

  Future<void> _saveEntry() async {
    if (_engineNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an engine name')),
      );
      return;
    }

    final entry = EngineSpecEntry(
      id: widget.existingEntry?.id ?? const Uuid().v4(),
      timestamp: widget.existingEntry?.timestamp ?? DateTime.now(),
      engineName: _engineNameCtrl.text.trim(),
      blockType: _blockTypeCtrl.text.trim(),
      cid: _cidCtrl.text.trim(),
      boreSize: _boreSizeCtrl.text.trim(),
      stroke: _strokeCtrl.text.trim(),
      crankSpecs: _crankSpecsCtrl.text.trim(),
      rodType: _rodTypeCtrl.text.trim(),
      rodLength: _rodLengthCtrl.text.trim(),
      pistonType: _pistonTypeCtrl.text.trim(),
      pistonDiameter: _pistonDiameterCtrl.text.trim(),
      compressionRatio: _compressionRatioCtrl.text.trim(),
      mainBearingSize: _mainBearingSizeCtrl.text.trim(),
      mainBearingClearance: _mainBearingClearanceCtrl.text.trim(),
      bigEndBearingSize: _bigEndBearingSizeCtrl.text.trim(),
      bigEndBearingClearance: _bigEndBearingClearanceCtrl.text.trim(),
      headType: _headTypeCtrl.text.trim(),
      inletValveLength: _inletValveLengthCtrl.text.trim(),
      inletValveDia: _inletValveDiaCtrl.text.trim(),
      exhaustValveLength: _exhaustValveLengthCtrl.text.trim(),
      exhaustValveDia: _exhaustValveDiaCtrl.text.trim(),
      rockerRatio: _rockerRatioCtrl.text.trim(),
      springPressure: _springPressureCtrl.text.trim(),
      springInstalledHeight: _springInstalledHeightCtrl.text.trim(),
      valveLashInlet: _valveLashInletCtrl.text.trim(),
      valveLashExhaust: _valveLashExhaustCtrl.text.trim(),
      pushrodLength: _pushrodLengthCtrl.text.trim(),
      lifterType: _lifterTypeCtrl.text.trim(),
      lifterDia: _lifterDiaCtrl.text.trim(),
      lifterLength: _lifterLengthCtrl.text.trim(),
      camSpecs: _camSpecsCtrl.text.trim(),
      advertisedDurationIntake: _advDurIntakeCtrl.text.trim(),
      advertisedDurationExhaust: _advDurExhaustCtrl.text.trim(),
      duration050Intake: _dur050IntakeCtrl.text.trim(),
      duration050Exhaust: _dur050ExhaustCtrl.text.trim(),
      duration050: _dur050Ctrl.text.trim(),
      lobeCenter: _lobeCenterCtrl.text.trim(),
      installedIntakeCenterline: _installedIclCtrl.text.trim(),
      lobeLift: _lobeLiftCtrl.text.trim(),
      rockerArmRatio: _rockerArmRatioCtrl.text.trim(),
      theoreticalLift: _theoreticalLiftCtrl.text.trim(),
      actualLift: _actualLiftCtrl.text.trim(),
      valveLiftIntake: _liftIntakeCtrl.text.trim(),
      valveLiftExhaust: _liftExhaustCtrl.text.trim(),
      lobeSeparation: _lsaCtrl.text.trim(),
      intakeCenterline: _iclCtrl.text.trim(),
      exhaustCenterline: _eclCtrl.text.trim(),
      ignitionPeakTiming: _ignPeakCtrl.text.trim(),
      ignitionTimingCurve: _ignCurveCtrl.text.trim(),
      ignitionIdleTiming: _ignIdleCtrl.text.trim(),
      inductionType: _inductionType,
      naturalType: _naturalType,
      carbySpecs: _carbySpecsCtrl.text.trim(),
      efiSpecs: _efiSpecsCtrl.text.trim(),
      forcedType: _forcedType,
      forcedSpecs: _forcedSpecsCtrl.text.trim(),
      numHatNozzles: _numHatNozzlesCtrl.text.trim(),
      numHeadNozzles: _numHeadNozzlesCtrl.text.trim(),
      mainPill: _mainPillCtrl.text.trim(),
      returnPill: _returnPillCtrl.text.trim(),
      pumpSizerPill: _pumpSizerPillCtrl.text.trim(),
      leanOutPill: _leanOutPillCtrl.text.trim(),
      returnPoppetPsi: _returnPoppetPsiCtrl.text.trim(),
      notes: _notesCtrl.text.trim(),
    );

    if (widget.existingEntry != null) {
      await EngineSpecStorage.update(entry);
    } else {
      await EngineSpecStorage.add(entry);
    }

    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingEntry != null ? 'Edit Engine Specs' : 'New Engine Specs',
        ),
        backgroundColor: Colors.green,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField('Engine Name *', _engineNameCtrl, hint: 'e.g., 427 LS'),
            
            _buildSectionHeader('Block & Bottom End'),
            _buildTextField('Block Type', _blockTypeCtrl, hint: 'e.g., Cast iron, Aluminum'),
            _buildTextField('CID', _cidCtrl, hint: 'e.g., 427'),
            _buildTextField('Bore Size', _boreSizeCtrl, hint: 'e.g., 4.125"'),
            _buildTextField('Stroke', _strokeCtrl, hint: 'e.g., 3.75"'),
            _buildTextField('Crank Specs', _crankSpecsCtrl, maxLines: 2, hint: 'e.g., Forged steel, offset ground'),
            _buildTextField('Rod Type', _rodTypeCtrl, hint: 'e.g., H-beam, I-beam'),
            _buildTextField('Rod Length', _rodLengthCtrl, hint: 'e.g., 6.125"'),
            _buildTextField('Piston Type', _pistonTypeCtrl, hint: 'e.g., Forged, Hypereutectic'),
            _buildTextField('Piston Diameter', _pistonDiameterCtrl, hint: 'e.g., 4.125"'),
            _buildTextField('Compression Ratio', _compressionRatioCtrl, hint: 'e.g., 10.5:1'),
            _buildTextField('Main Bearing Size', _mainBearingSizeCtrl, hint: 'e.g., 2.45"'),
            _buildTextField('Main Bearing Clearance', _mainBearingClearanceCtrl, hint: 'e.g., 0.0025"'),
            _buildTextField('Big End Bearing Size', _bigEndBearingSizeCtrl, hint: 'e.g., 2.10"'),
            _buildTextField('Big End Bearing Clearance', _bigEndBearingClearanceCtrl, hint: 'e.g., 0.002"'),

            _buildSectionHeader('Head & Valvetrain'),
            _buildTextField('Head Type', _headTypeCtrl, hint: 'e.g., Aluminum rectangle port'),
            _buildTextField('Inlet Valve Length', _inletValveLengthCtrl, hint: 'e.g., 5.05"'),
            _buildTextField('Inlet Valve Diameter', _inletValveDiaCtrl, hint: 'e.g., 2.19"'),
            _buildTextField('Exhaust Valve Length', _exhaustValveLengthCtrl, hint: 'e.g., 5.00"'),
            _buildTextField('Exhaust Valve Diameter', _exhaustValveDiaCtrl, hint: 'e.g., 1.88"'),
            _buildTextField('Rocker Ratio', _rockerRatioCtrl, hint: 'e.g., 1.7:1'),
            _buildTextField('Spring Pressure', _springPressureCtrl, hint: 'e.g., 130 lbs @ 1.8"'),
            _buildTextField('Spring Installed Height', _springInstalledHeightCtrl, hint: 'e.g., 1.850"'),
            _buildTextField('Valve Lash Inlet', _valveLashInletCtrl, hint: 'e.g., 0.022"'),
            _buildTextField('Valve Lash Exhaust', _valveLashExhaustCtrl, hint: 'e.g., 0.026"'),
            _buildTextField('Pushrod Length', _pushrodLengthCtrl, hint: 'e.g., 7.80"'),
            _buildTextField('Lifter Type', _lifterTypeCtrl, hint: 'e.g., Hydraulic, Solid'),
            _buildTextField('Lifter Diameter', _lifterDiaCtrl, hint: 'e.g., 0.842"'),
            _buildTextField('Lifter Length', _lifterLengthCtrl, hint: 'e.g., 2.10"'),

            _buildSectionHeader('Cam Timing'),
            _buildTextField('Cam Specs (General)', _camSpecsCtrl, maxLines: 3, hint: 'Notes: manufacturer, type'),
            Row(children:[
              Expanded(child:_buildTextField('Adv Dur Intake', _advDurIntakeCtrl, hint:'e.g. 290°')),
              const SizedBox(width:8),
              Expanded(child:_buildTextField('Adv Dur Exhaust', _advDurExhaustCtrl, hint:'e.g. 300°')),
            ]),
            Row(children:[
              Expanded(child:_buildTextField('Dur @ .050 Intake', _dur050IntakeCtrl, hint:'e.g. 240°')),
              const SizedBox(width:8),
              Expanded(child:_buildTextField('Dur @ .050 Exhaust', _dur050ExhaustCtrl, hint:'e.g. 248°')),
            ]),
            _buildTextField('Duration @ 0.050"', _dur050Ctrl, hint:'e.g. 244°'),
            _buildTextField('Lobe Center', _lobeCenterCtrl, hint:'e.g. 108°'),
            _buildTextField('Installed @ Intake Centerline', _installedIclCtrl, hint:'e.g. 104°'),
            _buildTextField('Lobe Lift', _lobeLiftCtrl, hint:'e.g. .400"'),
            _buildTextField('Rocker Arm Ratio', _rockerArmRatioCtrl, hint:'e.g. 1.7:1'),
            _buildTextField('Theoretical Lift', _theoreticalLiftCtrl, hint:'e.g. .680"'),
            _buildTextField('Actual Lift', _actualLiftCtrl, hint:'e.g. .660"'),
            Row(children:[
              Expanded(child:_buildTextField('Valve Lift Intake', _liftIntakeCtrl, hint:'e.g. .680"')),
              const SizedBox(width:8),
              Expanded(child:_buildTextField('Valve Lift Exhaust', _liftExhaustCtrl, hint:'e.g. .660"')),
            ]),
            Row(children:[
              Expanded(child:_buildTextField('Lobe Separation', _lsaCtrl, hint:'e.g. 108°')),
              const SizedBox(width:8),
              Expanded(child:_buildTextField('Intake Centerline', _iclCtrl, hint:'e.g. 104°')),
            ]),
            _buildTextField('Exhaust Centerline', _eclCtrl, hint:'e.g. 112°'),

            _buildSectionHeader('Ignition Timing'),
            Row(children:[
              Expanded(child:_buildTextField('Peak Timing', _ignPeakCtrl, hint:'e.g. 32° total')),
              const SizedBox(width:8),
              Expanded(child:_buildTextField('Idle Timing', _ignIdleCtrl, hint:'e.g. 14°')),
            ]),
            _buildTextField('Timing Curve', _ignCurveCtrl, maxLines:2, hint:'e.g. 14° idle → 32° @ 2800 rpm'),

            _buildSectionHeader('Induction System'),
            const Text('Induction Type:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'Natural', label: Text('Natural')),
                ButtonSegment(value: 'Forced', label: Text('Forced')),
              ],
              selected: {_inductionType},
              onSelectionChanged: (Set<String> selection) {
                setState(() {
                  _inductionType = selection.first;
                });
              },
            ),

            if (_inductionType == 'Natural') ...[
              const SizedBox(height: 12),
              const Text('Natural Aspiration Type:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Carby', label: Text('Carby')),
                  ButtonSegment(value: 'EFI', label: Text('EFI')),
                ],
                selected: {_naturalType},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _naturalType = selection.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              if (_naturalType == 'Carby')
                _buildTextField('Carby Specs', _carbySpecsCtrl, maxLines: 3, hint: 'e.g., Holley 750 DP, jetting, etc.')
              else
                _buildTextField('EFI Specs', _efiSpecsCtrl, maxLines: 3, hint: 'e.g., Port injection, fuel pressure, etc.'),
            ],

            if (_inductionType == 'Forced') ...[
              const SizedBox(height: 12),
              const Text('Forced Induction Type:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Supercharged', label: Text('Supercharged')),
                  ButtonSegment(value: 'Turbo', label: Text('Turbo')),
                ],
                selected: {_forcedType},
                onSelectionChanged: (Set<String> selection) {
                  setState(() {
                    _forcedType = selection.first;
                  });
                },
              ),
              const SizedBox(height: 12),
              _buildTextField('Forced Induction Specs', _forcedSpecsCtrl, maxLines: 3, 
                hint: 'e.g., Blower size, boost level, pulley ratio'),

              _buildSectionHeader('Mechanical Fuel Injection'),
              _buildTextField('Number of Hat Nozzles', _numHatNozzlesCtrl, hint: 'e.g., 8'),
              _buildTextField('Number of Head Nozzles', _numHeadNozzlesCtrl, hint: 'e.g., 8'),
              _buildTextField('Main Pill', _mainPillCtrl, hint: 'e.g., 0.045"'),
              _buildTextField('Return Pill', _returnPillCtrl, hint: 'e.g., 0.028"'),
              _buildTextField('Pump Sizer Pill', _pumpSizerPillCtrl, hint: 'e.g., 0.035"'),
              _buildTextField('Lean Out Pill', _leanOutPillCtrl, hint: 'e.g., 0.022"'),
              _buildTextField('Return Poppet PSI', _returnPoppetPsiCtrl, hint: 'e.g., 45 psi'),
            ],

            _buildSectionHeader('Notes'),
            _buildTextField('Additional Notes', _notesCtrl, maxLines: 4, 
              hint: 'Any additional information...'),

            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveEntry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.existingEntry != null ? 'Update Engine Specs' : 'Save Engine Specs',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _engineNameCtrl.dispose();
    _blockTypeCtrl.dispose();
    _cidCtrl.dispose();
    _boreSizeCtrl.dispose();
    _strokeCtrl.dispose();
    _crankSpecsCtrl.dispose();
    _rodTypeCtrl.dispose();
    _rodLengthCtrl.dispose();
    _pistonTypeCtrl.dispose();
    _pistonDiameterCtrl.dispose();
    _compressionRatioCtrl.dispose();
    _mainBearingSizeCtrl.dispose();
    _mainBearingClearanceCtrl.dispose();
    _bigEndBearingSizeCtrl.dispose();
    _bigEndBearingClearanceCtrl.dispose();
    _headTypeCtrl.dispose();
    _inletValveLengthCtrl.dispose();
    _inletValveDiaCtrl.dispose();
    _exhaustValveLengthCtrl.dispose();
    _exhaustValveDiaCtrl.dispose();
    _rockerRatioCtrl.dispose();
    _springPressureCtrl.dispose();
    _springInstalledHeightCtrl.dispose();
    _valveLashInletCtrl.dispose();
    _valveLashExhaustCtrl.dispose();
    _pushrodLengthCtrl.dispose();
    _lifterTypeCtrl.dispose();
    _lifterDiaCtrl.dispose();
    _lifterLengthCtrl.dispose();
    _camSpecsCtrl.dispose();
    _advDurIntakeCtrl.dispose();
    _advDurExhaustCtrl.dispose();
    _dur050IntakeCtrl.dispose();
    _dur050ExhaustCtrl.dispose();
    _dur050Ctrl.dispose();
    _lobeCenterCtrl.dispose();
    _installedIclCtrl.dispose();
    _lobeLiftCtrl.dispose();
    _rockerArmRatioCtrl.dispose();
    _theoreticalLiftCtrl.dispose();
    _actualLiftCtrl.dispose();
    _liftIntakeCtrl.dispose();
    _liftExhaustCtrl.dispose();
    _lsaCtrl.dispose();
    _iclCtrl.dispose();
    _eclCtrl.dispose();
    _ignPeakCtrl.dispose();
    _ignCurveCtrl.dispose();
    _ignIdleCtrl.dispose();
    _carbySpecsCtrl.dispose();
    _efiSpecsCtrl.dispose();
    _forcedSpecsCtrl.dispose();
    _numHatNozzlesCtrl.dispose();
    _numHeadNozzlesCtrl.dispose();
    _mainPillCtrl.dispose();
    _returnPillCtrl.dispose();
    _pumpSizerPillCtrl.dispose();
    _leanOutPillCtrl.dispose();
    _returnPoppetPsiCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'models/engine_spec_entry.dart';

class EngineSpecDetailScreen extends StatelessWidget {
  final EngineSpecEntry entry;

  const EngineSpecDetailScreen({super.key, required this.entry});

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      color: Colors.green[50],
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM dd, yyyy - HH:mm').format(entry.timestamp);

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.engineName),
        backgroundColor: Colors.green,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Saved: $dateStr',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          _buildSection('Block & Bottom End', [
            _buildField('Block Type', entry.blockType),
            _buildField('CID', entry.cid),
            _buildField('Bore Size', entry.boreSize),
            _buildField('Stroke', entry.stroke),
            _buildField('Crank Specs', entry.crankSpecs),
            _buildField('Rod Type', entry.rodType),
            _buildField('Rod Length', entry.rodLength),
            _buildField('Piston Type', entry.pistonType),
            _buildField('Piston Diameter', entry.pistonDiameter),
            _buildField('Compression Ratio', entry.compressionRatio),
            _buildField('Main Bearing Size', entry.mainBearingSize),
            _buildField('Main Bearing Clearance', entry.mainBearingClearance),
            _buildField('Big End Bearing Size', entry.bigEndBearingSize),
            _buildField('Big End Bearing Clearance', entry.bigEndBearingClearance),
          ]),

          _buildSection('Head & Valvetrain', [
            _buildField('Head Type', entry.headType),
            _buildField('Inlet Valve Length', entry.inletValveLength),
            _buildField('Inlet Valve Diameter', entry.inletValveDia),
            _buildField('Exhaust Valve Length', entry.exhaustValveLength),
            _buildField('Exhaust Valve Diameter', entry.exhaustValveDia),
            _buildField('Rocker Ratio', entry.rockerRatio),
            _buildField('Spring Pressure', entry.springPressure),
            _buildField('Spring Installed Height', entry.springInstalledHeight),
            _buildField('Valve Lash Inlet', entry.valveLashInlet),
            _buildField('Valve Lash Exhaust', entry.valveLashExhaust),
            _buildField('Pushrod Length', entry.pushrodLength),
            _buildField('Lifter Type', entry.lifterType),
            _buildField('Lifter Diameter', entry.lifterDia),
            _buildField('Lifter Length', entry.lifterLength),
          ]),

          _buildSection('Cam Timing', [
            _buildField('Cam Specs', entry.camSpecs),
            _buildField('Adv Duration Intake', entry.advertisedDurationIntake),
            _buildField('Adv Duration Exhaust', entry.advertisedDurationExhaust),
            _buildField('Duration @ .050 Intake', entry.duration050Intake),
            _buildField('Duration @ .050 Exhaust', entry.duration050Exhaust),
            _buildField('Duration @ 0.050"', entry.duration050),
            _buildField('Lobe Center', entry.lobeCenter),
            _buildField('Installed @ Intake Centerline', entry.installedIntakeCenterline),
            _buildField('Lobe Lift', entry.lobeLift),
            _buildField('Rocker Arm Ratio', entry.rockerArmRatio),
            _buildField('Theoretical Lift', entry.theoreticalLift),
            _buildField('Actual Lift', entry.actualLift),
            _buildField('Valve Lift Intake', entry.valveLiftIntake),
            _buildField('Valve Lift Exhaust', entry.valveLiftExhaust),
            _buildField('Lobe Separation', entry.lobeSeparation),
            _buildField('Intake Centerline', entry.intakeCenterline),
            _buildField('Exhaust Centerline', entry.exhaustCenterline),
          ]),

          _buildSection('Ignition Timing', [
            _buildField('Peak Timing', entry.ignitionPeakTiming),
            _buildField('Idle Timing', entry.ignitionIdleTiming),
            _buildField('Timing Curve', entry.ignitionTimingCurve),
          ]),

          _buildSection('Induction System', [
            _buildField('Induction Type', entry.inductionType),
            if (entry.inductionType == 'Natural') ...[
              _buildField('Natural Type', entry.naturalType),
              if (entry.naturalType == 'Carby')
                _buildField('Carby Specs', entry.carbySpecs)
              else
                _buildField('EFI Specs', entry.efiSpecs),
            ],
            if (entry.inductionType == 'Forced') ...[
              _buildField('Forced Type', entry.forcedType),
              _buildField('Forced Induction Specs', entry.forcedSpecs),
            ],
          ]),

          if (entry.inductionType == 'Forced' && 
              (entry.numHatNozzles.isNotEmpty || 
               entry.numHeadNozzles.isNotEmpty ||
               entry.mainPill.isNotEmpty ||
               entry.returnPill.isNotEmpty ||
               entry.pumpSizerPill.isNotEmpty ||
               entry.leanOutPill.isNotEmpty ||
               entry.returnPoppetPsi.isNotEmpty))
            _buildSection('Mechanical Fuel Injection', [
              _buildField('Hat Nozzles', entry.numHatNozzles),
              _buildField('Head Nozzles', entry.numHeadNozzles),
              _buildField('Main Pill', entry.mainPill),
              _buildField('Return Pill', entry.returnPill),
              _buildField('Pump Sizer Pill', entry.pumpSizerPill),
              _buildField('Lean Out Pill', entry.leanOutPill),
              _buildField('Return Poppet PSI', entry.returnPoppetPsi),
            ]),

          if (entry.notes.isNotEmpty)
            _buildSection('Notes', [
              Text(entry.notes),
            ]),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

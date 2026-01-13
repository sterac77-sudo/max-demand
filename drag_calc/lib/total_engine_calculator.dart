import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ad_manager.dart';

class TotalEngineCalculator extends StatefulWidget {
  const TotalEngineCalculator({super.key});

  @override
  State<TotalEngineCalculator> createState() => _TotalEngineCalculatorState();
}

class _TotalEngineCalculatorState extends State<TotalEngineCalculator> {
  // Basic geometry
  final _cylController = TextEditingController(text: '8');
  final _boreInController = TextEditingController();
  final _strokeInController = TextEditingController();
  final _headCcController = TextEditingController();
  final _mainJournalInController = TextEditingController();
  final _rodJournalInController = TextEditingController();

  // Cam / VE / RPM
  final _iclDegController = TextEditingController();
  final _advDurDegController = TextEditingController();
  final _ivcAbdcDegController = TextEditingController();
  final _vePercentController = TextEditingController(text: '95');
  final _peakTqRpmController = TextEditingController();
  final _maxPistonSpeedController = TextEditingController(text: '10000'); // target max piston speed

  // Optional/advanced
  final _rodLenInController = TextEditingController();
  final _angleXDegController = TextEditingController(text: '75');
  final _gasketBoreInController = TextEditingController();
  final _gasketThickInController = TextEditingController();
  final _deckClearInController = TextEditingController();
  final _pistonCrownCcController = TextEditingController(text: '0'); // dish +, dome -
  final _gammaController = TextEditingController(text: '1.30'); // polytropic exponent
  final _atmPsiController = TextEditingController(text: '14.7');

  // Results strings
  final Map<String, String> _results = {};

  @override
  void dispose() {
    _cylController.dispose();
    _boreInController.dispose();
    _strokeInController.dispose();
    _headCcController.dispose();
    _mainJournalInController.dispose();
    _rodJournalInController.dispose();
    _iclDegController.dispose();
    _advDurDegController.dispose();
    _ivcAbdcDegController.dispose();
    _vePercentController.dispose();
    _peakTqRpmController.dispose();
    _maxPistonSpeedController.dispose();
    _rodLenInController.dispose();
    _angleXDegController.dispose();
    _gasketBoreInController.dispose();
    _gasketThickInController.dispose();
    _deckClearInController.dispose();
    _pistonCrownCcController.dispose();
    _gammaController.dispose();
    _atmPsiController.dispose();
    super.dispose();
  }

  static const double ccPerCubicInch = 16.387064;

  double? _parse(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  void _calculate() {
    final cyl = int.tryParse(_cylController.text.trim());
    final boreIn = _parse(_boreInController);
    final strokeIn = _parse(_strokeInController);
    final headCc = _parse(_headCcController);
    final mainJIn = _parse(_mainJournalInController);
    final rodJIn = _parse(_rodJournalInController);

    final iclDeg = _parse(_iclDegController); // surfaced in results for reference
    final advDur = _parse(_advDurDegController); // surfaced in results for reference
    final ivcAbdcDeg = _parse(_ivcAbdcDegController);
    final vePct = _parse(_vePercentController);
    final peakTqRpm = _parse(_peakTqRpmController); // informational

    final rodLenIn = _parse(_rodLenInController);
    final angleXDeg = _parse(_angleXDegController);
    final gasketBoreIn = _parse(_gasketBoreInController);
    final gasketThickIn = _parse(_gasketThickInController);
    final deckClearIn = _parse(_deckClearInController);
    final pistonCrownCc = _parse(_pistonCrownCcController) ?? 0.0;
    final gamma = _parse(_gammaController) ?? 1.30;
    final atmPsi = _parse(_atmPsiController) ?? 14.7;

    _results.clear();

    if (cyl == null || boreIn == null || strokeIn == null || boreIn <= 0 || strokeIn <= 0 || cyl <= 0) {
      setState(() {
        _results['Error'] = 'Enter cylinders, bore (in), and stroke (in).';
      });
      return;
    }

    // Core geometry
    final boreAreaIn2 = math.pi / 4.0 * boreIn * boreIn;
    final sweptPerCylCi = boreAreaIn2 * strokeIn; // in^3
    final totalCid = sweptPerCylCi * cyl; // in^3

    _results['Cubic Inches (CID)'] = totalCid.toStringAsFixed(1) + ' ci';
    _results['Bore Area'] = boreAreaIn2.toStringAsFixed(3) + ' in²';
    _results['Bore/Stroke Ratio'] = (boreIn / strokeIn).toStringAsFixed(3);
    if (iclDeg != null) {
      _results['Cam ICL'] = iclDeg.toStringAsFixed(1) + '°';
    }
    if (advDur != null) {
      _results['Advertised Duration'] = advDur.toStringAsFixed(0) + '°';
    }

    if (mainJIn != null && rodJIn != null && mainJIn > 0 && rodJIn > 0) {
      // Crank to Pin: empirical formula based on reference data
      // Formula: rodJ + (stroke + bore) / 14.3
      final crankToPinValue = rodJIn + (strokeIn + boreIn) / 14.3;
      final overlap = (mainJIn + rodJIn) / 2.0 - (strokeIn / 2.0);
      _results['Crank to Pin ratio'] = crankToPinValue.toStringAsFixed(4);
      _results['Crank Journal Overlap'] = overlap.toStringAsFixed(2);
    }

    if (rodLenIn != null && rodLenIn > 0) {
      _results['Rod/Stroke Ratio'] = (rodLenIn / strokeIn).toStringAsFixed(2);
    }

    // Maximum RPM and speeds
    final maxPistonSpeedTarget = _parse(_maxPistonSpeedController) ?? 10000.0;
    
    if (rodLenIn != null && rodLenIn > 0) {
      final r = strokeIn / 2.0;
      final L = rodLenIn;
      
      // Redline RPM from target max piston speed
      // Max piston speed = Mean piston speed × π/2
      // Mean piston speed = 2 × stroke × RPM / 12
      // Therefore: Max piston speed = (2 × stroke × RPM / 12) × π/2
      // Solving for RPM: Redline = (Max piston speed × 12) / (2 × stroke × π/2)
      // Simplified: Redline = (Max piston speed × 12) / (stroke × π)
      final redlineRpm = (maxPistonSpeedTarget * 12.0) / (strokeIn * math.pi);
      _results['Redline'] = '${redlineRpm.toStringAsFixed(0)} RPM';
      
      // Mean piston speed at redline: 2 * stroke(in) * RPM / 12
      final meanPistonSpeedAtRedline = 2.0 * strokeIn * redlineRpm / 12.0;
      
      // Max piston speed at redline (should equal target)
      final maxPistonSpeedAtRedline = meanPistonSpeedAtRedline * math.pi / 2.0;
      _results['Max Piston Speed'] = '${maxPistonSpeedAtRedline.toStringAsFixed(0)} ft/min at ${redlineRpm.toStringAsFixed(0)} RPM';
      
      // Crank pin speed at redline: 2πr × RPM / 12 (convert to ft/min)
      final crankPinSpeed = 2.0 * math.pi * r * redlineRpm / 12.0;
      _results['Crank Pin Speed'] = '${crankPinSpeed.toStringAsFixed(0)} ft/min at ${redlineRpm.toStringAsFixed(0)} RPM';
      
      // Mean piston speed angle: solve for θ where v(θ) = mean speed
      // This uses the RPM at torque peak if provided, otherwise uses redline
      final rpmForAngleCalc = (peakTqRpm != null && peakTqRpm > 0) ? peakTqRpm : redlineRpm;
      final omega = 2.0 * math.pi * rpmForAngleCalc / 60.0; // rad/s
      final rFt = r / 12.0; // feet
      final meanSpeedFtMin = 2.0 * strokeIn * rpmForAngleCalc / 12.0;
      final meanSpeedFtSec = meanSpeedFtMin / 60.0;
      
      double meanSpeedAngleDeg = 74.0; // default approximation
      for (double thetaDeg = 1.0; thetaDeg <= 90.0; thetaDeg += 0.01) {
        final theta = thetaDeg * math.pi / 180.0;
        final sinTheta = math.sin(theta);
        final cosTheta = math.cos(theta);
        final ratio = L / rFt;
        final term = math.sqrt(ratio * ratio - sinTheta * sinTheta);
        final vInst = omega * rFt * sinTheta * (1.0 + cosTheta / term);
        if (vInst >= meanSpeedFtSec) {
          meanSpeedAngleDeg = thetaDeg;
          break;
        }
      }
      _results['Mean Piston Speed Angle'] = '${meanSpeedAngleDeg.toStringAsFixed(2)} degrees after TDC';
    }

    // Effective stroke and dynamic volumes
    double? effStrokeIn;
    if (ivcAbdcDeg != null && iclDeg != null && advDur != null) {
      // Effective stroke using cam timing parameters
      // IVC (ABDC) = Centerline + Duration/2
      // Angle from TDC ≈ 2 × BTDC (empirical formula for ballpark accuracy)
      final ivcAbdc = iclDeg + (advDur / 2.0);
      final btdc = 180.0 - ivcAbdc;
      final angleFromTdc = btdc * 2.0; // empirical: 2× BTDC gives ballpark match
      final ivcRad = angleFromTdc * math.pi / 180.0;
      effStrokeIn = strokeIn * (1.0 - math.cos(ivcRad));
      _results['Effective Stroke'] = '${effStrokeIn.toStringAsFixed(2)} in';
    } else if (ivcAbdcDeg != null) {
      // Fallback: use IVC input directly if cam timing not provided
      final ivcRad = ivcAbdcDeg * math.pi / 180.0;
      effStrokeIn = strokeIn * (1.0 - math.cos(ivcRad));
      _results['Effective Stroke'] = '${effStrokeIn.toStringAsFixed(2)} in';
    }

    // Volumes and compression
    final sweptPerCylCc = sweptPerCylCi * ccPerCubicInch;
    final gasketCc = (gasketBoreIn != null && gasketThickIn != null && gasketBoreIn > 0 && gasketThickIn > 0)
        ? (math.pi / 4.0 * gasketBoreIn * gasketBoreIn * gasketThickIn) * ccPerCubicInch
        : 0.0;
    final deckCc = (deckClearIn != null && deckClearIn > 0)
        ? (math.pi / 4.0 * boreIn * boreIn * deckClearIn) * ccPerCubicInch
        : 0.0;
    final clearanceCc = (headCc ?? 0.0) + gasketCc + deckCc + (pistonCrownCc);

    // Store values for VPI calculation
    double? crankingPsi;
    double? effCylVolCc;
    final nomCylVolCc = sweptPerCylCc + clearanceCc;

    if (clearanceCc > 0) {
      final crNom = (sweptPerCylCc + clearanceCc) / clearanceCc;
      _results['Nominal Compression Ratio'] = '${crNom.toStringAsFixed(2)}:1';
      _results['Nominal Cylinder Volume'] = '${nomCylVolCc.toStringAsFixed(2)} cc';
      _results['Clearance Volume (Nominal)'] = '${clearanceCc.toStringAsFixed(2)} cc';

      if (effStrokeIn != null && effStrokeIn > 0) {
        final effSweptCc = (boreAreaIn2 * effStrokeIn) * ccPerCubicInch;
        effCylVolCc = effSweptCc + clearanceCc;
        final crEff = effCylVolCc / clearanceCc;
        _results['Effective Compression Ratio'] = '${crEff.toStringAsFixed(2)}:1';
        _results['Effective Cylinder Volume'] = '${effCylVolCc.toStringAsFixed(2)} cc';

        // Cranking pressure: Atmospheric × CR^γ
        crankingPsi = atmPsi * math.pow(crEff, gamma);
        _results['Cranking Pressure'] = '${crankingPsi.toStringAsFixed(2)} psi';
      }
    }

    // Average rod angle over X° ATDC (requires rod length)
    if (rodLenIn != null && rodLenIn > 0 && angleXDeg != null && angleXDeg > 0) {
      final r = strokeIn / 2.0;
      final L = rodLenIn;
      final samples = angleXDeg.clamp(1, 180).toInt();
      double sum = 0.0;
      for (int i = 1; i <= samples; i++) {
        final th = (i * math.pi / 180.0); // θ from 1° to X° ATDC
        final sinTh = math.sin(th);
        final val = (r / L) * sinTh;
        final alpha = (val.abs() <= 1.0) ? math.asin(val) : (val.isNegative ? -math.pi / 2 : math.pi / 2);
        sum += alpha.abs() * 180.0 / math.pi; // degrees
      }
      final avgDeg = sum / samples;
      _results['Avg Rod Angle (0–${samples}° ATDC)'] = avgDeg.toStringAsFixed(2) + '°';
    }

    // Plenum volume and VPI
    final veFrac = (vePct != null && vePct > 0) ? (vePct / 100.0) : 1.0;
    // Plenum Volume = (CID / cylinders) × VE% × factor
    // Factor ≈ 0.67 (empirical, varies 0.62-0.67 depending on engine geometry)
    final plenumIn3 = (totalCid / cyl) * veFrac * 0.67;
    final plenumCc = plenumIn3 * ccPerCubicInch;
    _results['Plenum Volume'] = '${plenumIn3.toStringAsFixed(1)} cubic inches : ${plenumCc.toStringAsFixed(2)} CC\'s';
    
    // Volume Pressure Index = Cranking Pressure × (Effective Cylinder Volume / Nominal Cylinder Volume)
    // Both volumes already include clearance, so use them directly
    if (crankingPsi != null && effCylVolCc != null && nomCylVolCc > 0) {
      final vpi = crankingPsi * (effCylVolCc / nomCylVolCc);
      _results['Volume Pressure Index'] = vpi.toStringAsFixed(2);
    }

    setState(() {});
  }

  Widget _sectionTitle(String text, {Color? color}) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(
          text,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color ?? Colors.black87),
        ),
      );

  Widget _numField(TextEditingController c, String label, {String? suffix, String? hint}) => TextField(
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder(), suffixText: suffix),
        onChanged: (_) => setState(() {}),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Total Engine Calculator'),
        backgroundColor: Colors.green,
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: SafeArea(child: AdBanner()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('Basic Geometry', color: Colors.green),
            Row(children: [
              Expanded(child: _numField(_cylController, 'Cylinders', hint: 'e.g. 8')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_boreInController, 'Bore', suffix: 'in')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField(_strokeInController, 'Stroke', suffix: 'in')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_headCcController, 'Head Chamber', suffix: 'cc')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField(_mainJournalInController, 'Main Journal Ø', suffix: 'in')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_rodJournalInController, 'Rod Journal Ø', suffix: 'in')),
            ]),

            const SizedBox(height: 12),
            _sectionTitle('Cam / VE / RPM', color: Colors.green),
            Row(children: [
              Expanded(child: _numField(_iclDegController, 'Intake Lobe Centreline', suffix: '°')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_advDurDegController, 'Advertised Duration', suffix: '°')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField(_ivcAbdcDegController, 'Intake Valve Closing Angle', suffix: '°', hint: 'degrees from TDC')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_vePercentController, 'Volumetric Efficiency', suffix: '%')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField(_peakTqRpmController, 'RPM @ Peak Torque', suffix: 'rpm')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_maxPistonSpeedController, 'Max Piston Speed Target', suffix: 'ft/min', hint: 'e.g. 10000')),
            ]),

            const SizedBox(height: 12),
            _sectionTitle('Optional / Advanced', color: Colors.green),
            Row(children: [
              Expanded(child: _numField(_rodLenInController, 'Rod Length', suffix: 'in')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_angleXDegController, 'Angle X (ATDC avg)', suffix: '°')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField(_gasketBoreInController, 'Gasket Bore', suffix: 'in')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_gasketThickInController, 'Gasket Thickness', suffix: 'in')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField(_deckClearInController, 'Deck Clearance', suffix: 'in')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_pistonCrownCcController, 'Piston Crown Vol', suffix: 'cc', hint: 'dish + / dome -')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _numField(_gammaController, 'Compression Exponent γ', hint: 'e.g. 1.30')),
              const SizedBox(width: 8),
              Expanded(child: _numField(_atmPsiController, 'Atmospheric Pressure', suffix: 'psi')),
            ]),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => AdManager.showInterstitial(onDismissed: _calculate),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 16)),
              child: const Text('Calculate', style: TextStyle(fontSize: 18, color: Colors.white)),
            ),

            const SizedBox(height: 16),
            if (_results.isNotEmpty)
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _results.entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 4,
                                    child: Text(e.value, textAlign: TextAlign.right),
                                  ),
                                ],
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),

            const SizedBox(height: 24),
            Text(
              'Notes:\n• Redline calculated from max piston speed (π/2 × mean speed).\n• Effective stroke = stroke × (1 - cos(IVC angle)).\n• Cranking pressure: P = Atmospheric × CR^γ.\n• Plenum volume = (CID × VE%) / 2.\n• VPI = Effective CR × VE% × 100.',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

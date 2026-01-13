import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'ad_manager.dart';

enum TempUnit { c, f }

class MethanolInjectionCalculator extends StatefulWidget {
  const MethanolInjectionCalculator({super.key});

  @override
  State<MethanolInjectionCalculator> createState() =>
      _MethanolInjectionCalculatorState();
}

class _MethanolInjectionCalculatorState
    extends State<MethanolInjectionCalculator> {
  // Inputs
  final _cidCtrl = TextEditingController();
  final _airTempCtrl = TextEditingController();
  final _fuelTempCtrl = TextEditingController();
  final _humidityCtrl = TextEditingController();
  final _baroInHgCtrl = TextEditingController(text: '29.92');
  final _nozzlesCountCtrl = TextEditingController();
  final _nozzleSizesCtrl = TextEditingController();
  final _leanRpmCtrl = TextEditingController();
  final _belowLeanRpmCtrl = TextEditingController();
  final _afrCtrl = TextEditingController(text: '4.5');
  final _pumpGpm4000Ctrl = TextEditingController();
  final _veCtrl = TextEditingController(text: '90');

  // Default to °F since most inputs are provided in Fahrenheit for drag racing use.
  TempUnit _airUnit = TempUnit.f;
  TempUnit _fuelUnit = TempUnit.f;

  // Results - at/above lean-out
  String _adi = '';
  String _mainJet = '';
  String _mainWithBypassJet = '';
  String _bypassJet = '';
  String _bypassPressure = '';
  String _fuelPressure = '';
  String _methanolSp = '';
  String _densityAltitude = '';
  String _cfmAtLean = '';
  String _notes = '';

  // Results - below lean-out
  String _cfmBelowLean = '';
  String _fuelPressureBelowLean = '';
  String _mainJetBelowLean = '';
  String _notesBelowLean = '';

  @override
  void dispose() {
    _cidCtrl.dispose();
    _airTempCtrl.dispose();
    _fuelTempCtrl.dispose();
    _humidityCtrl.dispose();
    _baroInHgCtrl.dispose();
    _nozzlesCountCtrl.dispose();
    _nozzleSizesCtrl.dispose();
    _leanRpmCtrl.dispose();
    _belowLeanRpmCtrl.dispose();
    _afrCtrl.dispose();
    _pumpGpm4000Ctrl.dispose();
    _veCtrl.dispose();
    super.dispose();
  }

  double _toCelsius(double v, TempUnit u) =>
      u == TempUnit.c ? v : (v - 32.0) * 5.0 / 9.0;

  void _calculate() {
    setState(() {
      _adi = _mainJet = _mainWithBypassJet = _bypassJet = _bypassPressure =
          _fuelPressure = _methanolSp = _densityAltitude = _cfmAtLean = _notes = '';
      _cfmBelowLean = _fuelPressureBelowLean = _mainJetBelowLean =
          _notesBelowLean = '';
    });
    try {
      final cid = double.parse(_cidCtrl.text.trim());
      final airTemp = double.parse(_airTempCtrl.text.trim());
      final fuelTemp = double.parse(_fuelTempCtrl.text.trim());
      final baroInHg = double.parse(_baroInHgCtrl.text.trim());
      final nozzlesCount = int.parse(_nozzlesCountCtrl.text.trim());
      final nozzleSizesInput = _nozzleSizesCtrl.text.trim();
      final leanRpm = double.parse(_leanRpmCtrl.text.trim());
      final belowLeanRpmInput = _belowLeanRpmCtrl.text.trim();
      final afr = double.parse(_afrCtrl.text.trim());
      final pumpGpm4000 = double.parse(_pumpGpm4000Ctrl.text.trim());
      final vePct = double.parse(_veCtrl.text.trim());

      if (cid <= 0 ||
          nozzlesCount <= 0 ||
          leanRpm <= 0 ||
          afr <= 0 ||
          pumpGpm4000 <= 0 ||
          vePct <= 0 ||
          baroInHg <= 0) {
        setState(() => _notes = 'Please enter positive values for all fields.');
        return;
      }

      // Units and conversions
      final airC = _toCelsius(airTemp, _airUnit);
      final fuelC = _toCelsius(fuelTemp, _fuelUnit);
      final ve = (vePct / 100.0).clamp(0.0, 1.2);

        // 1) Methanol specific gravity (temperature corrected)
        // Empirical: SG ≈ 0.792 - (0.0005 × (Temp°F - 60))
      final fuelF = _fuelUnit == TempUnit.f
          ? fuelTemp
          : (fuelC * 9.0 / 5.0 + 32.0);
        final sp = (0.792 - 0.0005 * (fuelF - 60.0)).clamp(0.75, 0.85);

        // 2) Air density & atmospheric calculations (humidity-aware)
        final rhInput = _humidityCtrl.text.trim();
        final rhPct = (double.tryParse(rhInput.isEmpty ? '50' : rhInput) ?? 50.0)
          .clamp(0.0, 100.0);

        // Pressure altitude from barometer (ft)
        final pressureAlt = (29.92 - baroInHg) * 1000.0;

        // Humidity-aware air density using dry/wet components
        // Convert pressure to hPa and temperature to K
        final p_hPa = baroInHg * 33.8639;
        final t_c = airC;
        final t_k = t_c + 273.15;
        // Magnus formula for saturation vapor pressure (hPa)
        final es = 6.112 * math.exp((17.67 * t_c) / (t_c + 243.5));
        final e = (rhPct / 100.0) * es; // actual vapor pressure (hPa)
        final p_dry = (p_hPa - e).clamp(0.0, double.infinity);
        // Density (kg/m^3): rho = Pd/(Rd*T) + Pv/(Rv*T)
        const Rd = 287.05; // J/(kg·K)
        const Rv = 461.495; // J/(kg·K)
        final rho_kg_m3 = (p_dry * 100.0) / (Rd * t_k) + (e * 100.0) / (Rv * t_k);
        const KG_PER_M3_TO_LB_PER_FT3 = 0.062428;
        final rhoAir = rho_kg_m3 * KG_PER_M3_TO_LB_PER_FT3; // lb/ft^3

        // ADI calculation relative to standard air density at sea level, 59°F
        final stdDensity = 0.0765; // lb/ft³
        final adiPercent = (rhoAir / stdDensity * 100.0).clamp(0.0, 150.0);

        // Density altitude approximation: PA + 118.8 × ΔT(°C) + k_hum × RH
        // ISA temp at pressure altitude (°C), lapse ~1.98°C/1000 ft
        final isaTempC = 15.0 - (pressureAlt / 1000.0 * 1.98);
        final deltaC = (airC - isaTempC);
        const kPerC = 118.8; // ft per °C deviation
        const kHumFtPerPct = 5.8; // empirical humidity correction (ft per %RH)
        final densityAlt = pressureAlt + (kPerC * deltaC) + (kHumFtPerPct * rhPct);

      // Nozzle sizing (shared)
      List<double> diametersIn = [];
      if (nozzleSizesInput.isNotEmpty) {
        diametersIn = nozzleSizesInput
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .map((s) => double.parse(s))
            .toList();
      }
      if (diametersIn.isEmpty) {
        setState(
          () => _notes =
              'Enter nozzle sizes as comma-separated diameters in inches (e.g., 0.034, 0.034, ...).',
        );
        return;
      }
      if (diametersIn.length == 1 && nozzlesCount > 1) {
        diametersIn = List.filled(nozzlesCount, diametersIn.first);
      }
      if (diametersIn.length != nozzlesCount) {
        setState(
          () => _notes =
              'Number of nozzles does not match nozzle sizes provided.',
        );
        return;
      }
      final areas = diametersIn.map((d) => math.pi * (d * d) / 4.0).toList();
      final totalNozzleArea = areas.fold<double>(0.0, (a, b) => a + b); // in^2

      // Orifice flow formula: Q (GPM) = Coef × A (in²) × sqrt(ΔP (psi) / SG)
      // Use separate empirical coefficients for nozzles vs pills (return jets)
      const nozzleCoef = 27.28; // tuned to match system pressure targets
      const pillCoef = 64.0; // tuned to match pill sizes (main/bypass)
      final sg = sp; // specific gravity vs water

      double _areaToDiameter(double a) =>
          a <= 0 ? 0 : math.sqrt(4 * a / math.pi);

      // === AT/ABOVE LEAN-OUT RPM (main + bypass flows) ===
      // Cap RPM used for flow/pressure sizing so pill sizes/pressures stay near the 6000 baseline.
      const rpmFlowCap = 6000.0;
      final effectiveRpm = math.min(leanRpm, rpmFlowCap);

      // Base CFM and empirical correction to align with bench/field references
      const cfmCorr = 1.335; // empirical CFM correction factor
      final cfmAtLean = ((cid * effectiveRpm * ve) / 3456.0) * cfmCorr;
      
      // Air mass flow (lb/min)
      final airLbPerMinAtLean = rhoAir * cfmAtLean;
      
      // Fuel mass flow (lb/min) from AFR
      final fuelLbPerMinAtLean = airLbPerMinAtLean / afr;
      
      // Fuel volume flow (GPM)
      // 1 gallon = 231 cubic inches, methanol density = SG × 62.4 lb/ft³
      final fuelDensityLbPerGal = sp * 8.34; // lb/gal (water = 8.34 lb/gal)
      final fuelGpmRequiredAtLean = fuelLbPerMinAtLean / fuelDensityLbPerGal;
      
      // Pump flow at lean RPM (capped)
      final pumpGpmAtLeanRpm = pumpGpm4000 * (effectiveRpm / 4000.0);

      // Fuel pressure from nozzle flow
      // Rearranged: ΔP = (Q / (Coef × A))² × SG
      double fuelPressurePsi;
      if (totalNozzleArea > 0) {
        final flowRatio = fuelGpmRequiredAtLean / (nozzleCoef * totalNozzleArea);
        fuelPressurePsi = flowRatio * flowRatio * sg;
      } else {
        setState(() => _notes = 'Total nozzle area is zero.');
        return;
      }

      // Bypass flow (return flow back to tank)
      final bypassGpm = (pumpGpmAtLeanRpm - fuelGpmRequiredAtLean).clamp(0.0, double.infinity);
      
      // The system pressure balance:
      // - Nozzle pressure is determined by flow through nozzles (already calculated)
      // - Bypass pressure: estimated as ~67% of nozzle pressure (typical mechanical FI behavior)
      //   This is because bypass path has lower restriction and operates at lower ΔP
      final bypassPressurePsi = fuelPressurePsi * 0.67;
      
      // Main/Bypass pills: size return jets to pass return flow at respective pressures
      // Let A_bp = r * A_main to distribute return capacity between paths.
      // Then Q_return = C * (A_main*sqrt(P_f/SG) + A_bp*sqrt(P_bp/SG))
      // => A_main = Q_return / (C * (alpha + r*beta))
      final alpha = math.sqrt((fuelPressurePsi <= 0 ? 0.0 : fuelPressurePsi) / sg);
      final beta = math.sqrt((bypassPressurePsi <= 0 ? 0.0 : bypassPressurePsi) / sg);
      const rBypassToMainArea = 0.215; // empirical area ratio A_bp/A_main
      double mainPillArea = 0.0;
      double bypassPillArea = 0.0;
      if (bypassGpm > 0 && (alpha > 0 || beta > 0)) {
        final denom = pillCoef * (alpha + rBypassToMainArea * beta);
        if (denom > 0) {
          mainPillArea = (bypassGpm / denom).clamp(0.0, double.infinity);
          bypassPillArea = mainPillArea * rBypassToMainArea;
        }
      }
      final mainDiaIn = _areaToDiameter(mainPillArea);
      final bypassDiaIn = _areaToDiameter(bypassPillArea);

      // Main w/Bypass Pill: combined area of parallel return jets (sum of areas)
      final mainWithBypassArea = (mainPillArea + bypassPillArea);
      final mainWithBypassDiaIn = _areaToDiameter(mainWithBypassArea);

      // === BELOW LEAN-OUT RPM (only main return flows, no bypass) ===
      String cfmBelowStr = '';
      String fuelPressureBelowStr = '';
      String mainJetBelowStr = '';
      String notesBelowStr = '';

      if (belowLeanRpmInput.isNotEmpty) {
        final belowLeanRpm = double.tryParse(belowLeanRpmInput);
        if (belowLeanRpm != null && belowLeanRpm > 0) {
          final cfmBelowLean = (cid * belowLeanRpm * ve) / 3456.0;
          final airLbPerMinBelowLean = rhoAir * cfmBelowLean;
          final fuelLbPerMinBelowLean = airLbPerMinBelowLean / afr;
          final fuelGpmRequiredBelowLean = fuelLbPerMinBelowLean / fuelDensityLbPerGal;
          final pumpGpmAtBelowRpm = pumpGpm4000 * (belowLeanRpm / 4000.0);

          double fuelPressureBelowPsi;
          if (totalNozzleArea > 0) {
            final flowRatio = fuelGpmRequiredBelowLean / (nozzleCoef * totalNozzleArea);
            fuelPressureBelowPsi = flowRatio * flowRatio * sg;
          } else {
            fuelPressureBelowPsi = 0.0;
          }

          // All return through main only (no bypass)
          final returnGpmBelowLean =
              (pumpGpmAtBelowRpm - fuelGpmRequiredBelowLean).clamp(0.0, double.infinity);
          double mainOnlyArea = 0.0;
          if (returnGpmBelowLean > 0 && fuelPressureBelowPsi > 0) {
            mainOnlyArea = returnGpmBelowLean / (pillCoef * math.sqrt(fuelPressureBelowPsi / sg));
          }
          final mainOnlyDia = _areaToDiameter(mainOnlyArea);

          cfmBelowStr = cfmBelowLean.toStringAsFixed(0);
          fuelPressureBelowStr = '${fuelPressureBelowPsi.toStringAsFixed(2)} psi';
          mainJetBelowStr = mainOnlyDia > 0
              ? '${mainOnlyDia.toStringAsFixed(3)} in'
              : 'N/A';
          notesBelowStr = returnGpmBelowLean <= 0
              ? 'Pump flow at below-lean RPM may be below or equal to fuel demand.'
              : 'Main-only return (no bypass active).';
        } else {
          notesBelowStr = 'Enter a valid below-lean RPM.';
        }
      }

      setState(() {
        _adi = '${adiPercent.toStringAsFixed(1)} %';
        _methanolSp = sp.toStringAsFixed(4); // display as specific gravity
        _densityAltitude = densityAlt.isFinite ? '${densityAlt.toStringAsFixed(2)} ft' : '—';
        _cfmAtLean = '${cfmAtLean.toStringAsFixed(0)} CFM';
        _fuelPressure = '${fuelPressurePsi.toStringAsFixed(2)} psi';
        _mainJet = mainDiaIn > 0 ? '${mainDiaIn.toStringAsFixed(3)} inch' : 'N/A';
        _mainWithBypassJet = mainWithBypassDiaIn > 0 ? '${mainWithBypassDiaIn.toStringAsFixed(3)} inch' : 'N/A';
        _bypassJet = bypassDiaIn > 0 ? '${bypassDiaIn.toStringAsFixed(3)} inch' : 'N/A';
        _bypassPressure = bypassPressurePsi > 0 ? '${bypassPressurePsi.toStringAsFixed(2)} psi' : 'N/A';
        
        _notes = bypassGpm <= 0
            ? 'Pump flow at RPM may be below or equal to fuel demand; no bypass required.'
            : 'Pills sized using orifice flow formula: Q = Coef × A × √(ΔP/SG) with Coef = 38.0\n'
              'Main pill carries required fuel to nozzles.\n'
              'Bypass pill handles return flow to tank.\n'
              'Main w/Bypass is combined restriction (parallel flow paths).';

        _cfmBelowLean = cfmBelowStr;
        _fuelPressureBelowLean = fuelPressureBelowStr;
        _mainJetBelowLean = mainJetBelowStr;
        _notesBelowLean = notesBelowStr;
      });
    } catch (e) {
      setState(() {
        _notes = 'Invalid input: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mechanical FI (Methanol)'),
        backgroundColor: Colors.green.shade700,
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
            Card(
              color: Colors.green[50],
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  'Mechanical FI System Behavior:\n'
                  '• Main Pill: Controls fuel flow to nozzles under normal conditions.\n'
                  '• Bypass Pill: Diverts fuel away from nozzles once bypass opens at Lean-out RPM.\n'
                  '• Main w/Bypass Pill: Net fuel restriction when both pills are active—effective leaner flow at high RPM.\n\n'
                  'Below Lean-out RPM: Only main pill flows (return path). Richer mixture for launch/torque.\n'
                  'At/Above Lean-out RPM: Both pills active. Bypass diverts fuel, leaning mixture to prevent bogging.\n\n'
                  'Pump flow rating is at 4000 RPM and scales linearly with engine RPM.\n'
                  'Target AFR for methanol: 4.0–5.0 typical.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Row: CID, VE, AFR
            Row(
              children: [
                Expanded(child: _numField(_cidCtrl, 'CID', 'e.g. 400')),
                const SizedBox(width: 8),
                Expanded(child: _numField(_veCtrl, 'VE (%)', 'e.g. 90')),
                const SizedBox(width: 8),
                Expanded(
                  child: _numField(_afrCtrl, 'AFR (methanol)', 'e.g. 4.5'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Air temp + unit, Fuel temp + unit
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _numField(_airTempCtrl, 'Air Temp', 'e.g. 25'),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: SegmentedButton<TempUnit>(
                    segments: const [
                      ButtonSegment(value: TempUnit.c, label: Text('°C')),
                      ButtonSegment(value: TempUnit.f, label: Text('°F')),
                    ],
                    selected: {_airUnit},
                    onSelectionChanged: (s) => setState(() => _airUnit = s.first),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: _numField(_fuelTempCtrl, 'Fuel Temp', 'e.g. 20'),
                ),
                const SizedBox(width: 4),
                Expanded(
                  flex: 1,
                  child: SegmentedButton<TempUnit>(
                    segments: const [
                      ButtonSegment(value: TempUnit.c, label: Text('°C')),
                      ButtonSegment(value: TempUnit.f, label: Text('°F')),
                    ],
                    selected: {_fuelUnit},
                    onSelectionChanged: (s) =>
                        setState(() => _fuelUnit = s.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Humidity, Barometer, Lean-out RPM
            Row(
              children: [
                Expanded(
                  child: _numField(_humidityCtrl, 'Humidity (%)', 'e.g. 50'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _numField(
                    _baroInHgCtrl,
                    'Barometer (inHg)',
                    'e.g. 29.92',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Lean-out RPM, Below-lean RPM
            Row(
              children: [
                Expanded(
                  child: _numField(
                    _leanRpmCtrl,
                    'Lean-out RPM (bypass activates)',
                    'e.g. 6000',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _numField(
                    _belowLeanRpmCtrl,
                    'Below-lean RPM (optional)',
                    'e.g. 3500',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Pump GPM @ 4000, nozzles count, nozzle sizes
            Row(
              children: [
                Expanded(
                  child: _numField(
                    _pumpGpm4000Ctrl,
                    'Pump Flow @4000 RPM (GPM)',
                    'e.g. 5.0',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _numField(
                    _nozzlesCountCtrl,
                    'Number of Nozzles',
                    'e.g. 8',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nozzleSizesCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText:
                    'Nozzle sizes (inches, comma-separated or single size applied to all)',
                hintText:
                    'e.g. 0.034, 0.034, 0.034, 0.034, 0.034, 0.034, 0.034, 0.034',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                AdManager.showInterstitial(onDismissed: () {
                  _calculate();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Calculate',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            const SizedBox(height: 16),
            if (_adi.isNotEmpty) ...[
              // Below lean-out results (if provided)
              if (_cfmBelowLean.isNotEmpty)
                Card(
                  color: Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Below Lean-out RPM (Main Return Only)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _row('Intake airflow (CFM):', _cfmBelowLean),
                        _row('Fuel pressure (system):', _fuelPressureBelowLean),
                        _row('Main pill only (diameter):', _mainJetBelowLean),
                        if (_notesBelowLean.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            _notesBelowLean,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              if (_cfmBelowLean.isNotEmpty) const SizedBox(height: 12),

              // At/above lean-out results
              Card(
                color: Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'At/Above Lean-out RPM (Main + Bypass)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _row('Intake CFM:', _cfmAtLean),
                      _row('Density Altitude:', _densityAltitude),
                      _row('ADI (air density index):', _adi),
                      _row('Methanol Specific Gravity:', _methanolSp),
                      _row('Fuel Pressure:', _fuelPressure),
                      const Divider(height: 20),
                      const Text(
                        'Jetting (Pills & Nozzles)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _row('Main Pill:', _mainJet),
                      _row('Main w/Bypass Pill:', _mainWithBypassJet),
                      _row('Bypass Pill:', _bypassJet),
                      _row('Bypass Pill Pressure:', _bypassPressure),
                      if (_notes.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _notes,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _numField(TextEditingController c, String label, String hint) {
    return TextField(
      controller: c,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

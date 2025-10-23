import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'phase_input_field.dart';
import 'motor_dialog.dart';
import 'lift_motor_dialog.dart';
import 'spa_pool_dialog.dart';
import 'appliance_dialog.dart';
import 'socket_outlet_dialog.dart';
import 'analytics.dart';

// Private enum for UI action routing (top-level)
enum _DialogAction {
  none,
  showLift,
  showMotor,
  showSpaPool,
  showAppliance,
  showApplianceGroupC,
  showSocketsOver10A,
  showNotApplicable,
  showInfoOnly,
}

class LoadEntryScreen extends StatefulWidget {
  const LoadEntryScreen({super.key});

  @override
  State<LoadEntryScreen> createState() => _LoadEntryScreenState();
}

class _LoadEntryScreenState extends State<LoadEntryScreen> {
  final _diversityController = TextEditingController(text: '1.0');
  final _phaseControllers = List.generate(3, (_) => TextEditingController());
  final _resultPhaseControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  // Project metadata
  final _companyController = TextEditingController();
  final _siteAddressController = TextEditingController();
  final _projectNumberController = TextEditingController();
  double? _totalP1;
  double? _totalP2;
  double? _totalP3;
  // Popup guard for C1 → Blocks → I group max check
  bool _iMaxExceededShown = false;
  // C2 → B(i): volts prompt storage per phase
  final List<double?> _c2B1VoltsPerPhase = List<double?>.filled(3, null);
  final List<bool> _c2B1VoltsAskedPerPhase = List<bool>.filled(3, false);

  // Menus: Installation type and sub-categories (simplified restore)
  final List<String> _installationTypes = const ['C1', 'C2'];
  final Map<String, List<String>> _subCategories = const {
    'C1': [
      'Single Domestic or Individual living unit per phase',
      'Blocks of living units',
    ],
    'C2': [
      'Residential institutes, hotels, boarding houses, hospitals, motels',
      'Factories, shops, stores, offices, schools, churches',
    ],
  };
  // Block options appear when C1 → Blocks of living units
  final List<String> _blockOptions = const [
    '2 to 5 living units per phase',
    '6 to 20 living units per phase',
    '21 or more living units per phase',
  ];
  // Load groups and sub-options per installation type (expanded from legacy map)
  final Map<String, Map<String, List<String>>> _loadTypes = const {
    'C1': {
      'A: Lights': [
        'i) Lighting (Except load group H below d,e,f)',
        'ii) Outdoor lighting exceeding a total of 1000 W f,g',
      ],
      'B: Socket-outlets': [
        'i) Socket-outlets not exceeding 10 A; permanently connected electrical equipment not exceeding 10 A and not included in other load groups',
        'ii) One or more 15 A socket-outlets (excluding those for groups C, D, E, F, G, L)',
        'iii) One or more 20 A socket-outlets (excluding those for groups C, D, E, F, G, L)',
      ],
      'C: Ranges, cooking appliances, laundry equipment': [
        'Ranges, cooking appliances, laundry equipment or socket-outlets rated at more than 10 A for the connection thereof',
      ],
      'D: Fixed space heating or airconditioning': [
        'Fixed space heating or airconditioning equipment, saunas or socket-outlets rated at more than 10 A for the connection thereof',
      ],
      'E: Instantaneous water heaters': ['Instantaneous water heaters'],
      'F: Storage water heaters': ['Storage water heaters'],
      'G: Spa and swimming pool heaters': ['Spa and swimming pool heaters'],
      'H: Communal lighting': ['Communal lighting'],
      'I: Socket-outlets not included in groups J and M': [
        'Socket-outlets not included in groups J and M; permanently connected electrical equipment not exceeding 10 A',
      ],
      'J: Heating and AC': [
        'i) Clothes dryers, water heaters, self-heating washing machines, wash boilers',
        'ii) Heating and airconditioning equipment',
        'iii) Spa and swimming pool heaters',
      ],
      'K: Lifts': ['Lifts'],
      'L: Motors': ['Motors'],
      'M: Appliances': ['Appliances'],
    },
    'C2': {
      'A: Lighting': ['Lighting other than in load group F b,c'],
      'B: Socket-outlets': [
        'i) Socket-outlets not exceeding 10 A other than those in B(ii) c,e',
        'ii) Socket-outlets not exceeding 10 A in buildings or portions of buildings provided with permanently installed heating or cooling equipment or both c,d,e',
        'iii) Socket-outlets exceeding 10 A c,e',
      ],
      'C: Appliances for cooking, heating and cooling': [
        'Appliances for cooking, heating and cooling, including instantaneous water heaters, but not appliances included in groups D and J below',
      ],
      'D: Motors': ['Motors other than in E and F below'],
      'E: Lifts': ['Lifts'],
      'F: Fuel dispensing units': ['i) Motors', 'ii) Lighting'],
      'G: Swimming pools, spas, saunas, thermal storage heaters, space heaters and similar': [
        'Swimming pools, spas, saunas, thermal storage heaters, space heaters and similar',
      ],
      'H: Welding machines': ['Welding machines'],
      'J: X-ray equipment': ['X-ray equipment'],
      'K: Other': ['By assessment'],
    },
  };
  String? _selectedInstallationType;
  String? _selectedSubCategory;
  String? _selectedBlockOption;
  String? _selectedLoadType;
  String? _selectedLoadSubOption;
  final List<_LoadEntry> _loadEntries = [];

  // Decide which dialog (if any) to show based on current selections
  _DialogAction _actionForSelection() {
    final t = _selectedLoadType;
    final s = _selectedLoadSubOption;
    final inst = _selectedInstallationType;
    final subcat = _selectedSubCategory;

    // If nothing selected yet, no dialog
    if (inst == null || t == null) return _DialogAction.none;

    if (inst == 'C1') {
      // Explicitly no dialog for Single Domestic B(i) points entry
      final isSingleDomestic =
          subcat == 'Single Domestic or Individual living unit per phase';
      // For Single Domestic, groups H, I, and J(i/ii/iii) are Not Applicable
      if (isSingleDomestic) {
        final isGroupH = t == 'H: Communal lighting';
        final isGroupI =
            t == 'I: Socket-outlets not included in groups J and M';
        final isGroupJ = t == 'J: Heating and AC';
        if (isGroupH || isGroupI || isGroupJ) {
          return _DialogAction.showNotApplicable;
        }
      }
      if (isSingleDomestic &&
          t == 'B: Socket-outlets' &&
          s ==
              'i) Socket-outlets not exceeding 10 A; permanently connected electrical equipment not exceeding 10 A and not included in other load groups') {
        return _DialogAction.none;
      }

      // No dialog for 20 A socket-outlets (iii) in C1
      if (t == 'B: Socket-outlets' &&
          s ==
              'iii) One or more 20 A socket-outlets (excluding those for groups C, D, E, F, G, L)') {
        return _DialogAction.none;
      }

      if (t == 'D: Motors') return _DialogAction.showMotor;
      if (t == 'E: Lifts') return _DialogAction.showLift;
      if (t == 'G: Pools etc') return _DialogAction.showSpaPool;
      if (t == 'G: Spa and swimming pool heaters') {
        return _DialogAction.showSpaPool;
      }
      if (t == 'J: Heating and AC' &&
          (s?.contains('Spa and swimming pool heaters') ?? false)) {
        return _DialogAction.showSpaPool;
      }

      if (t == 'M: Appliances') return _DialogAction.showInfoOnly;

      // Sockets: treat 20 A and 'exceeding 10 A' (but not 'not exceeding') as dialog-driven
      if (t == 'B: Socket-outlets') {
        final has20A = s?.contains('20 A socket-outlets') == true;
        final hasExceeding10 = s?.contains('exceeding 10 A') == true;
        final hasNotExceeding = s?.contains('not exceeding') == true;
        if ((has20A &&
                s !=
                    'iii) One or more 20 A socket-outlets (excluding those for groups C, D, E, F, G, L)') ||
            (hasExceeding10 && !hasNotExceeding)) {
          return _DialogAction.showSocketsOver10A;
        }
      }

      return _DialogAction.none;
    }

    if (inst == 'C2') {
      if (t == 'D: Motors') return _DialogAction.showMotor;
      if (t == 'E: Lifts') return _DialogAction.showLift;
      if (t ==
          'G: Swimming pools, spas, saunas, thermal storage heaters, space heaters and similar') {
        // For C2 G: straight-through, no popup
        return _DialogAction.none;
      }
      if (t == 'M: Appliances') return _DialogAction.showAppliance;
      if (t == 'F: Fuel dispensing units') {
        if ((s ?? '').startsWith('i)')) return _DialogAction.showMotor;
        return _DialogAction.none; // (ii) Lighting is straight-through entry
      }
      if (t == 'C: Appliances for cooking, heating and cooling')
        return _DialogAction.showApplianceGroupC;

      if (t == 'B: Socket-outlets') {
        // Only 'exceeding 10 A' sockets in C2 require dialog-driven entry
        final hasExceeding = s?.contains('exceeding 10 A') == true;
        final hasNotExceeding = s?.contains('not exceeding') == true;
        if (hasExceeding && !hasNotExceeding)
          return _DialogAction.showSocketsOver10A;
      }

      return _DialogAction.none;
    }

    return _DialogAction.none;
  }

  Future<void> _onPhaseTap(int phase) async {
    final action = _actionForSelection();
    switch (action) {
      case _DialogAction.showLift:
        final result = await showDialog<LiftMotorConfig>(
          context: context,
          builder: (_) => const LiftMotorDialog(),
        );
        if (result != null) {
          double total;
          // C1 → K: Lifts and C2 → E: Lifts — largest×1.25 + next largest×0.75 + remainder×0.5
          if ((_selectedInstallationType == 'C1' &&
                  _selectedLoadType == 'K: Lifts') ||
              (_selectedInstallationType == 'C2' &&
                  _selectedLoadType == 'E: Lifts')) {
            final largest = result.largestLiftMotorAmps;
            final adds = List<double>.from(result.additionalLiftAmps);
            if (adds.isEmpty) {
              total = 1.25 * largest;
            } else {
              final sorted = List<double>.from(adds)
                ..sort((a, b) => b.compareTo(a));
              final nextLargest = sorted.first;
              final remainder = (sorted.length > 1)
                  ? sorted.skip(1).fold(0.0, (a, b) => a + b)
                  : 0.0;
              total = 1.25 * largest + 0.75 * nextLargest + 0.5 * remainder;
            }
          } else {
            // Default/other contexts: previous rule (largest + 25% of others)
            total =
                result.largestLiftMotorAmps +
                result.additionalLiftAmps.fold(0.0, (a, b) => a + b) * 0.25;
          }
          _setPhaseFromDialog(phase, total);
        }
        break;
      case _DialogAction.showMotor:
        final result = await showDialog<MotorConfig>(
          context: context,
          builder: (_) => const MotorDialog(),
        );
        if (result != null) {
          final largest = result.largestMotorAmps;
          final rest = result.additionalMotorAmps;

          double total;
          // C2 → F(i): Fuel dispensing units → Motors: 100% highest + 50% second-highest + 25% remainder
          if (_selectedInstallationType == 'C2' &&
              _selectedLoadType == 'F: Fuel dispensing units' &&
              (_selectedLoadSubOption ?? '').startsWith('i)')) {
            if (rest.isEmpty) {
              total = largest;
            } else {
              final maxAdditional = rest.reduce((a, b) => a > b ? a : b);
              final sumAdditional = rest.fold<double>(0.0, (a, b) => a + b);
              final others = sumAdditional - maxAdditional;
              total = largest + 0.5 * maxAdditional + 0.25 * others;
            }
          } else if (_selectedInstallationType == 'C2' &&
              _selectedLoadType == 'D: Motors') {
            final isResidential =
                _selectedSubCategory ==
                'Residential institutes, hotels, boarding houses, hospitals, motels';
            final isFactories =
                _selectedSubCategory ==
                'Factories, shops, stores, offices, schools, churches';

            if (isResidential) {
              // Residential: full load of highest + 50% of remainder
              final remainder = rest.fold<double>(0.0, (a, b) => a + b);
              total = largest + 0.5 * remainder;
            } else if (isFactories) {
              // Factories: 100% highest + 75% second highest + 50% remainder
              if (rest.isEmpty) {
                total = largest;
              } else {
                // Identify the second-highest from the additional motors
                final maxAdditional = rest.reduce((a, b) => a > b ? a : b);
                final sumAdditional = rest.fold<double>(0.0, (a, b) => a + b);
                final others = sumAdditional - maxAdditional;
                total = largest + 0.75 * maxAdditional + 0.5 * others;
              }
            } else {
              // Default fallback if subcategory not set properly
              final remainder = rest.fold<double>(0.0, (a, b) => a + b);
              total = largest + 0.5 * remainder;
            }
          } else {
            // C1 → L: Motors: largest × 1.0 + 50% of all remaining motors
            final remainder = rest.fold<double>(0.0, (a, b) => a + b);
            total = largest + 0.5 * remainder;
          }
          _setPhaseFromDialog(phase, total);
        }
        break;
      case _DialogAction.showSpaPool:
        final result = await showDialog<SpaPoolConfig>(
          context: context,
          builder: (_) => const SpaPoolDialog(),
        );
        if (result != null) {
          // Compute: 75% of largest spa + 75% of largest pool + 25% of the remainder (spa+pool)
          double largestSpa = 0.0;
          double largestPool = 0.0;
          double sumSpa = 0.0;
          double sumPool = 0.0;

          if (result.spaHeaters.isNotEmpty) {
            largestSpa = result.spaHeaters.reduce((a, b) => a > b ? a : b);
            sumSpa = result.spaHeaters.fold(0.0, (a, b) => a + b);
          }
          if (result.poolHeaters.isNotEmpty) {
            largestPool = result.poolHeaters.reduce((a, b) => a > b ? a : b);
            sumPool = result.poolHeaters.fold(0.0, (a, b) => a + b);
          }

          final remainder =
              (sumSpa - largestSpa).clamp(0.0, double.infinity) +
              (sumPool - largestPool).clamp(0.0, double.infinity);
          final total =
              0.75 * largestSpa + 0.75 * largestPool + 0.25 * remainder;
          _setPhaseFromDialog(phase, total);
        }
        break;
      case _DialogAction.showAppliance:
        final val = await _promptForAmps('Appliance Current (A)');
        if (val != null) _setPhaseFromDialog(phase, val);
        break;
      case _DialogAction.showApplianceGroupC:
        {
          final isResidential =
              _selectedSubCategory ==
              'Residential institutes, hotels, boarding houses, hospitals, motels';
          final isFactories =
              _selectedSubCategory ==
              'Factories, shops, stores, offices, schools, churches';
          final result = await showDialog<ApplianceConfig>(
            context: context,
            builder: (_) => const ApplianceDialog(),
          );
          if (result != null) {
            final largest = result.largestApplianceAmps;
            final remainder = result.additionalApplianceAmps.fold<double>(
              0.0,
              (a, b) => a + b,
            );
            final factor = isResidential ? 0.5 : (isFactories ? 0.75 : 0.5);
            final total = largest + factor * remainder;
            _setPhaseFromDialog(phase, total);
          }
        }
        break;
      case _DialogAction.showSocketsOver10A:
        {
          final isC2 = _selectedInstallationType == 'C2';
          final isSockets = _selectedLoadType == 'B: Socket-outlets';
          final isResidential =
              _selectedSubCategory ==
              'Residential institutes, hotels, boarding houses, hospitals, motels';
          final isFactories =
              _selectedSubCategory ==
              'Factories, shops, stores, offices, schools, churches';
          final isExceeding10 = (_selectedLoadSubOption ?? '').contains(
            'exceeding 10 A',
          );
          // For C2 Residential/Factories B(iii): show multi-input dialog and compute largest + X% of remainder
          if (isC2 &&
              isSockets &&
              isExceeding10 &&
              (isResidential || isFactories)) {
            final result = await showDialog<SocketOutletConfig>(
              context: context,
              builder: (_) => const SocketOutletDialog(),
            );
            if (result != null) {
              final largest = result.largestSocketAmps;
              final remainder = result.additionalSocketAmps.fold<double>(
                0.0,
                (a, b) => a + b,
              );
              final factor = isResidential
                  ? 0.5
                  : 0.75; // Residential=50%, Factories=75%
              final total = largest + factor * remainder;
              _setPhaseFromDialog(phase, total);
            }
          } else {
            // Default single-value entry
            final val = await _promptForAmps('Socket-outlet exceeding 10A (A)');
            if (val != null) _setPhaseFromDialog(phase, val);
          }
        }
        break;
      case _DialogAction.showNotApplicable:
        await showDialog<void>(
          context: context,
          builder: (_) => const AlertDialog(
            title: Text('Not Applicable'),
            content: Text(
              'This load group is not applicable for Single Domestic.',
            ),
          ),
        );
        break;
      case _DialogAction.showInfoOnly:
        {
          final isSingleDomestic =
              _selectedSubCategory ==
              'Single Domestic or Individual living unit per phase';
          final msg = isSingleDomestic
              ? 'Connected load less than 5A N/A. Connected load greater than 5A by assessment'
              : 'Connected load less than 10A N/A. Connected load greater than 10A by assessment';
          await showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Information'),
              content: Text(msg),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
        break;
      case _DialogAction.none:
        // no-op, manual entry is enabled
        break;
    }
  }

  Future<double?> _promptForAmps(String title) async {
    final ctrl = TextEditingController();
    try {
      return await showDialog<double>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Amps'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text);
                Navigator.of(context).pop(v);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }

  Future<double?> _promptForVolts({
    double? initial,
    String title = 'Supply Voltage (V)',
  }) async {
    final ctrl = TextEditingController(text: (initial ?? 240).toString());
    try {
      return await showDialog<double>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Volts'),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final v = double.tryParse(ctrl.text);
                Navigator.of(context).pop(v);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      ctrl.dispose();
    }
  }

  void _setPhaseFromDialog(int phase, double amps) {
    setState(() {
      final idx = phase - 1;
      _phaseControllers[idx].text = amps.toStringAsFixed(2);
    });
    _calculateDemand();
  }

  void _saveLoadEntry() {
    // Ensure results are up to date
    _calculateDemand();
    double p1 = double.tryParse(_resultPhaseControllers[0].text) ?? 0.0;
    double p2 = double.tryParse(_resultPhaseControllers[1].text) ?? 0.0;
    double p3 = double.tryParse(_resultPhaseControllers[2].text) ?? 0.0;

    final group = _selectedLoadType ?? 'Unspecified';
    final detail = _selectedLoadSubOption ?? '';
    final name = group.isNotEmpty
        ? '$group ${_loadEntries.length + 1}'
        : 'Load ${_loadEntries.length + 1}';

    setState(() {
      _loadEntries.add(
        _LoadEntry(
          name: name,
          installationType: _selectedInstallationType,
          subCategory: _selectedSubCategory,
          blockOption: _selectedBlockOption,
          group: group,
          detail: detail,
          phase1: p1,
          phase2: p2,
          phase3: p3,
        ),
      );

      // Clear fields for next load: keep installation context, reset load-specific fields
      for (var c in _phaseControllers) {
        c.clear();
      }
      for (var c in _resultPhaseControllers) {
        c.clear();
      }
      _selectedLoadType = null;
      _selectedLoadSubOption = null;
    });
  }

  void _computeMaximumDemand() {
    double p1 = 0.0, p2 = 0.0, p3 = 0.0;
    for (final e in _loadEntries) {
      p1 += e.phase1;
      p2 += e.phase2;
      p3 += e.phase3;
    }
    setState(() {
      _totalP1 = p1;
      _totalP2 = p2;
      _totalP3 = p3;
    });
  }

  void _clearMaximumDemand() {
    setState(() {
      _totalP1 = null;
      _totalP2 = null;
      _totalP3 = null;
    });
  }

  @override
  void dispose() {
    _removeDemandListeners();
    _diversityController.dispose();
    _companyController.dispose();
    _siteAddressController.dispose();
    _projectNumberController.dispose();
    for (var controller in _phaseControllers) {
      controller.dispose();
    }
    for (var controller in _resultPhaseControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _calculateDemand() {
    final diversity = double.tryParse(_diversityController.text) ?? 1.0;

    // Path-specific: C1 → Single Domestic → A: Lights → (i) Lighting ...
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType == 'A: Lights' &&
        _selectedLoadSubOption ==
            'i) Lighting (Except load group H below d,e,f)') {
      for (var i = 0; i < 3; i++) {
        final points = int.tryParse(_phaseControllers[i].text) ?? 0;
        double demandA = 0.0;
        if (points > 0) {
          if (points <= 20) {
            demandA = 3.0;
          } else {
            final extra = points - 20;
            final blocks = (extra + 19) ~/ 20; // ceil(extra/20)
            demandA = 3.0 + blocks * 2.0;
          }
        }
        _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
      }
      return;
    }

    // Path-specific: C1 → Single Domestic → A: Lights → (ii) Lighting – 75% connected load
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType == 'A: Lights' &&
        _selectedLoadSubOption ==
            'ii) Outdoor lighting exceeding a total of 1000 W f,g') {
      for (var i = 0; i < 3; i++) {
        final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
        _resultPhaseControllers[i].text = (amps * 0.75).toStringAsFixed(2);
      }
      return;
    }

    // Path-specific: C2 → J: X-ray equipment — 50% of entered amps
    if (_selectedInstallationType == 'C2' &&
        _selectedLoadType == 'J: X-ray equipment') {
      for (var i = 0; i < 3; i++) {
        final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
        _resultPhaseControllers[i].text = (amps / 2.0).toStringAsFixed(2);
      }
      return;
    }

    // Path-specific: C2 → A: Lighting (Residential) — 75% of entered amps
    if (_selectedInstallationType == 'C2' &&
        _selectedLoadType == 'A: Lighting' &&
        _selectedSubCategory ==
            'Residential institutes, hotels, boarding houses, hospitals, motels') {
      for (var i = 0; i < 3; i++) {
        final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
        _resultPhaseControllers[i].text = (amps * 0.75).toStringAsFixed(2);
      }
      return;
    }

    // Path-specific: C1 → Single Domestic → B: Socket-outlets → (i) Points-based rule
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'i) Socket-outlets not exceeding 10 A; permanently connected electrical equipment not exceeding 10 A and not included in other load groups') {
      for (var i = 0; i < 3; i++) {
        final points = int.tryParse(_phaseControllers[i].text) ?? 0;
        double demandA = 0.0;
        if (points > 0) {
          if (points <= 20) {
            demandA = 10.0;
          } else {
            final extra = points - 20;
            final blocks = (extra + 19) ~/ 20; // ceil(extra/20)
            demandA = 10.0 + blocks * 5.0;
          }
        }
        _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
      }
      return;
    }

    // Path-specific: C1 → Single Domestic → D: Fixed space heating or airconditioning — 75% of entered amps
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType == 'D: Fixed space heating or airconditioning' &&
        _selectedLoadSubOption ==
            'Fixed space heating or airconditioning equipment, saunas or socket-outlets rated at more than 10 A for the connection thereof') {
      for (var i = 0; i < 3; i++) {
        final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
        _resultPhaseControllers[i].text = (amps * 0.75).toStringAsFixed(2);
      }
      return;
    }

    // Path-specific: C1 → Single Domestic → C: Ranges, cooking appliances, laundry equipment → 0.5 × entered A
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType ==
            'C: Ranges, cooking appliances, laundry equipment' &&
        _selectedLoadSubOption ==
            'Ranges, cooking appliances, laundry equipment or socket-outlets rated at more than 10 A for the connection thereof') {
      for (var i = 0; i < 3; i++) {
        final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
        _resultPhaseControllers[i].text = (amps * 0.5).toStringAsFixed(2);
      }
      return;
    }

    // Path-specific: C1 → Single Domestic → E: Instantaneous water heaters → 0.333 × entered A
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType == 'E: Instantaneous water heaters' &&
        _selectedLoadSubOption == 'Instantaneous water heaters') {
      for (var i = 0; i < 3; i++) {
        final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
        _resultPhaseControllers[i].text = (amps * 0.333).toStringAsFixed(3);
      }
      return;
    }

    // Path-specific: C1 → Single Domestic → F: Storage water heaters → 1.0 × entered A
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType == 'F: Storage water heaters' &&
        _selectedLoadSubOption == 'Storage water heaters') {
      for (var i = 0; i < 3; i++) {
        final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
        _resultPhaseControllers[i].text = (amps * 1.0).toStringAsFixed(2);
      }
      return;
    }

    // Path-specific: C2 → B: Socket-outlets points-based rules
    if (_selectedInstallationType == 'C2' &&
        _selectedLoadType == 'B: Socket-outlets') {
      final isFactories =
          _selectedSubCategory ==
          'Factories, shops, stores, offices, schools, churches';
      final isResidential =
          _selectedSubCategory ==
          'Residential institutes, hotels, boarding houses, hospitals, motels';

      // Factories/Offices/Schools/Churches → B(i): 1000 W for first point, +750 W per additional point; divide by Volts
      if (isFactories &&
          _selectedLoadSubOption ==
              'i) Socket-outlets not exceeding 10 A other than those in B(ii) c,e') {
        // Read points for all phases
        final ptsVals = List<int>.generate(
          3,
          (i) => int.tryParse(_phaseControllers[i].text) ?? 0,
        );
        // Prompt per-phase only if that phase has points and voltage is not set
        for (var i = 0; i < 3; i++) {
          final pts = ptsVals[i];
          if (pts > 0 &&
              _c2B1VoltsPerPhase[i] == null &&
              !_c2B1VoltsAskedPerPhase[i]) {
            _c2B1VoltsAskedPerPhase[i] = true;
            final idx = i;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final v = await _promptForVolts(
                initial: _c2B1VoltsPerPhase[idx],
                title: 'Supply Voltage (V) - Phase ${idx + 1}',
              );
              setState(() {
                _c2B1VoltsPerPhase[idx] = (v != null && v > 0) ? v : null;
                _c2B1VoltsAskedPerPhase[idx] = false;
              });
              _calculateDemand();
            });
          }
        }
        // Compute results using per-phase volts
        for (var i = 0; i < 3; i++) {
          final pts = ptsVals[i];
          final volts = _c2B1VoltsPerPhase[i];
          double amps = 0.0;
          if (pts > 0 && volts != null && volts > 0) {
            final watts = 1000.0 + (pts - 1) * 750.0;
            amps = watts / volts;
          }
          _resultPhaseControllers[i].text = amps.toStringAsFixed(2);
        }
        return;
      }

      // Factories/Offices/Schools/Churches → B(ii): 1000 W for first point, +100 W per additional; divide by per-phase Volts
      if (isFactories &&
          _selectedLoadSubOption ==
              'ii) Socket-outlets not exceeding 10 A in buildings or portions of buildings provided with permanently installed heating or cooling equipment or both c,d,e') {
        final ptsVals = List<int>.generate(
          3,
          (i) => int.tryParse(_phaseControllers[i].text) ?? 0,
        );
        for (var i = 0; i < 3; i++) {
          final pts = ptsVals[i];
          if (pts > 0 &&
              _c2B1VoltsPerPhase[i] == null &&
              !_c2B1VoltsAskedPerPhase[i]) {
            _c2B1VoltsAskedPerPhase[i] = true;
            final idx = i;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final v = await _promptForVolts(
                initial: _c2B1VoltsPerPhase[idx],
                title: 'Supply Voltage (V) - Phase ${idx + 1}',
              );
              setState(() {
                _c2B1VoltsPerPhase[idx] = (v != null && v > 0) ? v : null;
                _c2B1VoltsAskedPerPhase[idx] = false;
              });
              _calculateDemand();
            });
          }
        }
        for (var i = 0; i < 3; i++) {
          final pts = ptsVals[i];
          final volts = _c2B1VoltsPerPhase[i];
          double amps = 0.0;
          if (pts > 0 && volts != null && volts > 0) {
            final watts = 1000.0 + (pts - 1) * 100.0;
            amps = watts / volts;
          }
        }
        return;
      }

      // Residential/Hotels → B(ii): 1000 W for first point, +100 W per additional; divide by per-phase Volts
      if (isResidential &&
          _selectedLoadSubOption ==
              'ii) Socket-outlets not exceeding 10 A in buildings or portions of buildings provided with permanently installed heating or cooling equipment or both c,d,e') {
        final ptsVals = List<int>.generate(
          3,
          (i) => int.tryParse(_phaseControllers[i].text) ?? 0,
        );
        for (var i = 0; i < 3; i++) {
          final pts = ptsVals[i];
          if (pts > 0 &&
              _c2B1VoltsPerPhase[i] == null &&
              !_c2B1VoltsAskedPerPhase[i]) {
            _c2B1VoltsAskedPerPhase[i] = true;
            final idx = i;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final v = await _promptForVolts(
                initial: _c2B1VoltsPerPhase[idx],
                title: 'Supply Voltage (V) - Phase ${idx + 1}',
              );
              setState(() {
                _c2B1VoltsPerPhase[idx] = (v != null && v > 0) ? v : null;
                _c2B1VoltsAskedPerPhase[idx] = false;
              });
              _calculateDemand();
            });
          }
        }
        for (var i = 0; i < 3; i++) {
          final pts = ptsVals[i];
          final volts = _c2B1VoltsPerPhase[i];
          double amps = 0.0;
          if (pts > 0 && volts != null && volts > 0) {
            final watts = 1000.0 + (pts - 1) * 100.0;
            amps = watts / volts;
          }
          _resultPhaseControllers[i].text = amps.toStringAsFixed(2);
        }
        return;
      }

      // Residential/Hotels → B(i): 1000 W for first point, +400 W per additional point; divide by Volts
      if (isResidential &&
          _selectedLoadSubOption ==
              'i) Socket-outlets not exceeding 10 A other than those in B(ii) c,e') {
        // Read points for all phases
        final ptsVals = List<int>.generate(
          3,
          (i) => int.tryParse(_phaseControllers[i].text) ?? 0,
        );
        // Prompt per-phase only if that phase has points and voltage is not set
        for (var i = 0; i < 3; i++) {
          final pts = ptsVals[i];
          if (pts > 0 &&
              _c2B1VoltsPerPhase[i] == null &&
              !_c2B1VoltsAskedPerPhase[i]) {
            _c2B1VoltsAskedPerPhase[i] = true;
            final idx = i;
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final v = await _promptForVolts(
                initial: _c2B1VoltsPerPhase[idx],
                title: 'Supply Voltage (V) - Phase ${idx + 1}',
              );
              setState(() {
                _c2B1VoltsPerPhase[idx] = (v != null && v > 0) ? v : null;
                _c2B1VoltsAskedPerPhase[idx] = false;
              });
              _calculateDemand();
            });
          }
        }
        // Compute results using per-phase volts
        for (var i = 0; i < 3; i++) {
          final pts = ptsVals[i];
          final volts = _c2B1VoltsPerPhase[i];
          double amps = 0.0;
          if (pts > 0 && volts != null && volts > 0) {
            final watts = 1000.0 + (pts - 1) * 400.0;
            amps = watts / volts;
          }
          _resultPhaseControllers[i].text = amps.toStringAsFixed(2);
        }
        return;
      }
    }

    // Path-specific: C2 → G: Swimming pools, spas, saunas, thermal storage heaters, space heaters and similar — pass-through
    if (_selectedInstallationType == 'C2' &&
        _selectedLoadType ==
            'G: Swimming pools, spas, saunas, thermal storage heaters, space heaters and similar') {
      for (var i = 0; i < 3; i++) {
        final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
        _resultPhaseControllers[i].text = amps.toStringAsFixed(2);
      }
      return;
    }

    // Path-specific: C2 → H: Welding machines/Communal lighting — pass-through
    if (_selectedInstallationType == 'C2' &&
        _selectedLoadType == 'H: Welding machines') {
      for (var i = 0; i < 3; i++) {
        final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
        _resultPhaseControllers[i].text = amps.toStringAsFixed(2);
      }
      return;
    }

    // ---------------- C1 → Blocks of living units formulas ----------------
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedBlockOption != null) {
      final block = _selectedBlockOption!;

      // A: Lights → ii) Outdoor lighting... (No assessment required for blocks)
      if (_selectedLoadType == 'A: Lights' &&
          _selectedLoadSubOption ==
              'ii) Outdoor lighting exceeding a total of 1000 W f,g') {
        for (var i = 0; i < 3; i++) {
          _resultPhaseControllers[i].text = 0.0.toStringAsFixed(2);
        }
        return;
      }

      // A: Lights → i) Lighting (Except load group H below d,e,f)
      if (_selectedLoadType == 'A: Lights' &&
          _selectedLoadSubOption ==
              'i) Lighting (Except load group H below d,e,f)') {
        for (var i = 0; i < 3; i++) {
          final units = int.tryParse(_phaseControllers[i].text) ?? 0;
          double demandA = 0.0;
          if (block == '2 to 5 living units per phase') {
            // Constant 6 A unless the entered units are 0, then 0 A
            demandA = (units <= 0) ? 0.0 : 6.0;
          } else if (block == '6 to 20 living units per phase') {
            // Use entered units directly (cap at 20), so values below 6 still vary
            final u = units.clamp(1, 20);
            // 5 A for the first unit, then +0.25 A per additional unit thereafter
            demandA = u <= 0 ? 0.0 : 5.0 + (u - 1) * 0.25;
          } else if (block == '21 or more living units per phase') {
            // Treat input as units u (could be >= 21)
            final u = units < 0 ? 0 : units;
            demandA = u * 0.5;
          }
          _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
        }
        return;
      }

      // B: Socket-outlets → i) Socket-outlets not exceeding 10 A ...
      if (_selectedLoadType == 'B: Socket-outlets' &&
          _selectedLoadSubOption ==
              'i) Socket-outlets not exceeding 10 A; permanently connected electrical equipment not exceeding 10 A and not included in other load groups') {
        for (var i = 0; i < 3; i++) {
          final units = int.tryParse(_phaseControllers[i].text) ?? 0;
          double demandA = 0.0;
          if (block == '2 to 5 living units per phase') {
            if (units <= 0) {
              demandA = 0.0;
            } else {
              final u = units.clamp(1, 5);
              demandA =
                  10.0 +
                  (u - 1) * 5.0; // 10 A for first unit, +5 A per additional
            }
          } else if (block == '6 to 20 living units per phase') {
            if (units <= 0) {
              demandA = 0.0; // Empty or 0 input should yield 0 A
            } else {
              final u = units.clamp(6, 20);
              demandA =
                  15.0 +
                  (u - 6) *
                      3.75; // 15 A for first 6 units, +3.75 A each thereafter
            }
          } else if (block == '21 or more living units per phase') {
            if (units <= 0) {
              demandA = 0.0; // Empty or 0 input should yield 0 A
            } else {
              final u = units < 21 ? 21 : units;
              demandA =
                  50.0 +
                  (u - 21) *
                      1.9; // 50 A for first 21 units, +1.9 A each thereafter
            }
          }
          _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
        }
        return;
      }

      // C: Ranges, cooking appliances, laundry equipment → blocks
      if (_selectedLoadType ==
              'C: Ranges, cooking appliances, laundry equipment' &&
          _selectedLoadSubOption ==
              'Ranges, cooking appliances, laundry equipment or socket-outlets rated at more than 10 A for the connection thereof') {
        for (var i = 0; i < 3; i++) {
          final units = int.tryParse(_phaseControllers[i].text) ?? 0;
          double demandA = 0.0;
          if (block == '2 to 5 living units per phase') {
            // Constant 15 A unless input empty/0 -> 0 A
            demandA = (units <= 0) ? 0.0 : 15.0;
          } else if (block == '6 to 20 living units per phase' ||
              block == '21 or more living units per phase') {
            // 2.8 A per living unit (0 if units <= 0)
            demandA = (units <= 0) ? 0.0 : units * 2.8;
          }
          _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
        }
        return;
      }

      // D: Fixed space heating or airconditioning (blocks) — 75% of entered amps
      if (_selectedLoadType == 'D: Fixed space heating or airconditioning' &&
          _selectedLoadSubOption ==
              'Fixed space heating or airconditioning equipment, saunas or socket-outlets rated at more than 10 A for the connection thereof') {
        for (var i = 0; i < 3; i++) {
          final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
          _resultPhaseControllers[i].text = (amps * 0.75).toStringAsFixed(2);
        }
        return;
      }

      // E: Instantaneous water heaters (blocks)
      if (_selectedLoadType == 'E: Instantaneous water heaters' &&
          _selectedLoadSubOption == 'Instantaneous water heaters') {
        for (var i = 0; i < 3; i++) {
          final units = int.tryParse(_phaseControllers[i].text) ?? 0;
          double demandA = 0.0;
          if (block == '2 to 5 living units per phase' ||
              block == '6 to 20 living units per phase') {
            demandA = (units <= 0) ? 0.0 : units * 6.0;
          } else if (block == '21 or more living units per phase') {
            if (units <= 0) {
              demandA = 0.0;
            } else {
              final u = units < 21 ? 21 : units;
              demandA =
                  100.0 +
                  (u - 21) * 0.8; // 100 A for first 21 units, +0.8 A thereafter
            }
          }
          _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
        }
        return;
      }

      // I: Socket-outlets not included in groups J and M (blocks) — Points × 2 A, warn if > 15 A
      if (_selectedLoadType ==
              'I: Socket-outlets not included in groups J and M' &&
          _selectedLoadSubOption ==
              'Socket-outlets not included in groups J and M; permanently connected electrical equipment not exceeding 10 A') {
        bool exceeded = false;
        for (var i = 0; i < 3; i++) {
          final pts = int.tryParse(_phaseControllers[i].text) ?? 0;
          final demandA = pts <= 0 ? 0.0 : pts * 2.0;
          if (demandA > 15.0) exceeded = true;
          _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
        }
        // Show a one-time popup if maximum exceeded; reset when below
        if (exceeded && !_iMaxExceededShown) {
          _iMaxExceededShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog<void>(
              context: context,
              builder: (_) => const AlertDialog(
                title: Text('Maximum Exceeded'),
                content: Text('Calculated demand exceeds the maximum of 15 A.'),
              ),
            );
          });
        } else if (!exceeded) {
          _iMaxExceededShown = false;
        }
        return;
      }

      // F: Storage water heaters (blocks)
      if (_selectedLoadType == 'F: Storage water heaters' &&
          _selectedLoadSubOption == 'Storage water heaters') {
        for (var i = 0; i < 3; i++) {
          final units = int.tryParse(_phaseControllers[i].text) ?? 0;
          double demandA = 0.0;
          if (block == '2 to 5 living units per phase' ||
              block == '6 to 20 living units per phase') {
            demandA = (units <= 0) ? 0.0 : units * 6.0;
          } else if (block == '21 or more living units per phase') {
            if (units <= 0) {
              demandA = 0.0;
            } else {
              final u = units < 21 ? 21 : units;
              demandA =
                  100.0 +
                  (u - 21) * 0.8; // align with E: 100 A for first 21 units
            }
          }
          _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
        }
        return;
      }

      // J: Heating and AC (blocks) — i) 0.5 × A, ii) 0.75 × A (spa/pool handled separately)
      if (_selectedLoadType == 'J: Heating and AC') {
        final opt = _selectedLoadSubOption ?? '';
        if (opt.startsWith('i)')) {
          for (var i = 0; i < 3; i++) {
            final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
            _resultPhaseControllers[i].text = (amps * 0.5).toStringAsFixed(2);
          }
          return;
        }
        if (opt.startsWith('ii)')) {
          for (var i = 0; i < 3; i++) {
            final amps = double.tryParse(_phaseControllers[i].text) ?? 0.0;
            _resultPhaseControllers[i].text = (amps * 0.75).toStringAsFixed(2);
          }
          return;
        }
      }
    }

    // C1 → B: Socket-outlets (ii)/(iii) common (Single Domestic or Blocks): add fixed contribution if present
    if (_selectedInstallationType == 'C1' &&
        (_selectedSubCategory ==
                'Single Domestic or Individual living unit per phase' ||
            _selectedSubCategory == 'Blocks of living units') &&
        _selectedLoadType == 'B: Socket-outlets') {
      if (_selectedLoadSubOption ==
          'ii) One or more 15 A socket-outlets (excluding those for groups C, D, E, F, G, L)') {
        for (var i = 0; i < 3; i++) {
          final count = int.tryParse(_phaseControllers[i].text) ?? 0;
          final demandA = count >= 1 ? 10.0 : 0.0;
          _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
        }
        return;
      }
      if (_selectedLoadSubOption ==
          'iii) One or more 20 A socket-outlets (excluding those for groups C, D, E, F, G, L)') {
        for (var i = 0; i < 3; i++) {
          final count = int.tryParse(_phaseControllers[i].text) ?? 0;
          final demandA = count >= 1 ? 15.0 : 0.0;
          _resultPhaseControllers[i].text = demandA.toStringAsFixed(2);
        }
        return;
      }
    }

    // Default: diversity scaling of entered phase currents
    for (var i = 0; i < 3; i++) {
      final currentPhase = double.tryParse(_phaseControllers[i].text) ?? 0.0;
      final result = currentPhase * diversity;
      _resultPhaseControllers[i].text = result.toStringAsFixed(2);
    }
  }

  String _phaseLabelText(int phaseNumber) {
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        ((_selectedLoadType == 'A: Lights' &&
                _selectedLoadSubOption ==
                    'i) Lighting (Except load group H below d,e,f)') ||
            (_selectedLoadType == 'B: Socket-outlets' &&
                _selectedLoadSubOption ==
                    'i) Socket-outlets not exceeding 10 A; permanently connected electrical equipment not exceeding 10 A and not included in other load groups'))) {
      return 'Phase $phaseNumber Points';
    }
    // Blocks: label for A(ii) lighting (No assessment required)
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedLoadType == 'A: Lights' &&
        _selectedLoadSubOption ==
            'ii) Outdoor lighting exceeding a total of 1000 W f,g') {
      return 'No Assessment Required';
    }
    // Blocks: label for A(i) lighting calculation
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedLoadType == 'A: Lights' &&
        _selectedLoadSubOption ==
            'i) Lighting (Except load group H below d,e,f)') {
      if (_selectedBlockOption == '6 to 20 living units per phase') {
        return 'Phase $phaseNumber Number of Living Units';
      }
      return 'Phase $phaseNumber Units';
    }
    // Blocks: label for B(i), C, E, and F should be 'Number of Living Units'
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        ((_selectedLoadType == 'B: Socket-outlets' &&
                _selectedLoadSubOption ==
                    'i) Socket-outlets not exceeding 10 A; permanently connected electrical equipment not exceeding 10 A and not included in other load groups') ||
            _selectedLoadType ==
                'C: Ranges, cooking appliances, laundry equipment' ||
            _selectedLoadType == 'E: Instantaneous water heaters' ||
            _selectedLoadType == 'F: Storage water heaters')) {
      if (_selectedLoadType == 'B: Socket-outlets' ||
          _selectedLoadType ==
              'C: Ranges, cooking appliances, laundry equipment' ||
          _selectedLoadType == 'E: Instantaneous water heaters' ||
          _selectedLoadType == 'F: Storage water heaters') {
        return 'Phase $phaseNumber Number of Living Units';
      }
      return 'Phase $phaseNumber Units';
    }
    // Blocks: Group I uses 'Points'
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedLoadType ==
            'I: Socket-outlets not included in groups J and M') {
      return 'Phase $phaseNumber Points';
    }
    // Show 'Points' for C2 socket-outlet B(i)/(ii) pathways
    if (_selectedInstallationType == 'C2' &&
        _selectedLoadType == 'B: Socket-outlets') {
      if ((_selectedLoadSubOption ?? '').startsWith(
            'i) Socket-outlets not exceeding 10 A',
          ) ||
          (_selectedLoadSubOption ?? '').startsWith(
            'ii) Socket-outlets not exceeding 10 A',
          )) {
        return 'Phase $phaseNumber Points';
      }
    }
    return 'Phase $phaseNumber (A)';
  }

  void _addDemandListeners() {
    for (var controller in _phaseControllers) {
      controller.addListener(_calculateDemand);
    }
    _diversityController.addListener(_calculateDemand);
  }

  void _removeDemandListeners() {
    for (var controller in _phaseControllers) {
      controller.removeListener(_calculateDemand);
    }
    _diversityController.removeListener(_calculateDemand);
  }

  bool _isSingleDomesticBPoints() {
    return _selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'i) Socket-outlets not exceeding 10 A; permanently connected electrical equipment not exceeding 10 A and not included in other load groups';
  }

  String _bPointsPreview(int points) {
    if (points <= 0) return '0.00 A';
    if (points <= 20) return '10.00 A';
    final extra = points - 20;
    final blocks = (extra + 19) ~/ 20; // ceil(extra/20)
    final demand = 10.0 + blocks * 5.0;
    return demand.toStringAsFixed(2) + ' A';
  }

  bool _isBlocksALightsNoAssessment() {
    return _selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedLoadType == 'A: Lights' &&
        _selectedLoadSubOption ==
            'ii) Outdoor lighting exceeding a total of 1000 W f,g';
  }

  @override
  void initState() {
    super.initState();
    _addDemandListeners();
  }

  Future<void> _exportToPdf() async {
    // Track export action (web only; no-op if analytics not configured)
    Analytics.event('export_pdf');
    // Build a PDF report from current load entries and totals
    final doc = pw.Document();

    double totalP1 = 0.0, totalP2 = 0.0, totalP3 = 0.0;
    for (final e in _loadEntries) {
      totalP1 += e.phase1;
      totalP2 += e.phase2;
      totalP3 += e.phase3;
    }

    final now = DateTime.now();
    final company = _companyController.text.trim();
    final siteAddr = _siteAddressController.text.trim();
    final projNo = _projectNumberController.text.trim();

    doc.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(margin: pw.EdgeInsets.all(24)),
        footer: (context) => pw.Center(
          child: pw.Text(
            'Powered by Seaspray Electrical',
            style: pw.TextStyle(fontSize: 8),
          ),
        ),
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Maximum Demand Report',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text('Generated: ${now.toLocal()}'),
              if (company.isNotEmpty) pw.Text('Company: $company'),
              if (siteAddr.isNotEmpty) pw.Text('Site address: $siteAddr'),
              if (projNo.isNotEmpty) pw.Text('Project number: $projNo'),
              if (_selectedInstallationType != null)
                pw.Text('Installation Type: ${_selectedInstallationType!}')
              else
                pw.SizedBox(),
              if (_selectedSubCategory != null)
                pw.Text('Sub-category: ${_selectedSubCategory!}')
              else
                pw.SizedBox(),
              if (_selectedBlockOption != null)
                pw.Text('Block option: ${_selectedBlockOption!}')
              else
                pw.SizedBox(),
              pw.SizedBox(height: 16),

              if (_loadEntries.isEmpty) pw.Text('No loads entered.'),

              if (_loadEntries.isNotEmpty)
                pw.Table.fromTextArray(
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  headers: [
                    'Name',
                    'Group',
                    'Detail',
                    'P1 (A)',
                    'P2 (A)',
                    'P3 (A)',
                  ],
                  data: _loadEntries
                      .map(
                        (e) => [
                          e.name,
                          e.group,
                          e.detail,
                          e.phase1.toStringAsFixed(2),
                          e.phase2.toStringAsFixed(2),
                          e.phase3.toStringAsFixed(2),
                        ],
                      )
                      .toList(),
                  cellAlignment: pw.Alignment.centerLeft,
                ),

              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Totals',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.Text('Phase 1: ${totalP1.toStringAsFixed(2)} A'),
                    pw.Text('Phase 2: ${totalP2.toStringAsFixed(2)} A'),
                    pw.Text('Phase 3: ${totalP3.toStringAsFixed(2)} A'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => await doc.save(),
      name: 'maximum_demand_report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              'Maximum Demand',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 2),
            Text(
              'Seaspray Electrical',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        elevation: 2,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: CustomPaint(
          painter: _LightningPainter(),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Project Details card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Project Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _companyController,
                            decoration: const InputDecoration(
                              labelText: 'Company Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _siteAddressController,
                            decoration: const InputDecoration(
                              labelText: 'Site Address',
                              border: OutlineInputBorder(),
                            ),
                            minLines: 1,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _projectNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Project Number',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Load details card with menus
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Load Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Installation type (C1/C2)
                          DropdownButtonFormField<String>(
                            initialValue: _selectedInstallationType,
                            decoration: const InputDecoration(
                              labelText: 'Installation Type',
                              border: OutlineInputBorder(),
                            ),
                            hint: const Text('Select installation type'),
                            items: _installationTypes
                                .map(
                                  (t) => DropdownMenuItem(
                                    value: t,
                                    child: Text(t),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedInstallationType = val;
                                _selectedSubCategory = null;
                                _selectedBlockOption = null;
                                _selectedLoadType = null;
                                _selectedLoadSubOption = null;
                              });
                            },
                          ),
                          const SizedBox(height: 12),
                          // Sub category
                          if (_selectedInstallationType != null)
                            DropdownButtonFormField<String>(
                              initialValue: _selectedSubCategory,
                              decoration: const InputDecoration(
                                labelText: 'Sub Category',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Select sub category'),
                              items:
                                  (_subCategories[_selectedInstallationType] ??
                                          [])
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedSubCategory = val;
                                  _selectedBlockOption = null;
                                  _selectedLoadType = null;
                                  _selectedLoadSubOption = null;
                                });
                              },
                            ),
                          const SizedBox(height: 12),
                          // Block option only when C1 → Blocks of living units
                          if (_selectedSubCategory == 'Blocks of living units')
                            DropdownButtonFormField<String>(
                              initialValue: _selectedBlockOption,
                              decoration: const InputDecoration(
                                labelText: 'Block Option',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Select block option'),
                              items: _blockOptions
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedBlockOption = val;
                                });
                              },
                            ),
                          const SizedBox(height: 12),
                          // Load group (depends on installation type)
                          if (_selectedInstallationType != null)
                            DropdownButtonFormField<String>(
                              initialValue: _selectedLoadType,
                              decoration: const InputDecoration(
                                labelText: 'Load Group',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Select load group'),
                              items:
                                  (_loadTypes[_selectedInstallationType] ?? {})
                                      .keys
                                      .map(
                                        (k) => DropdownMenuItem(
                                          value: k,
                                          child: Text(k),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedLoadType = val;
                                  _selectedLoadSubOption = null;
                                });
                              },
                            ),
                          const SizedBox(height: 12),
                          // Load sub-option
                          if (_selectedLoadType != null)
                            DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedLoadSubOption,
                              decoration: const InputDecoration(
                                labelText: 'Load Sub-option',
                                border: OutlineInputBorder(),
                              ),
                              hint: const Text('Select sub option'),
                              items:
                                  ((_loadTypes[_selectedInstallationType] ??
                                              {})[_selectedLoadType] ??
                                          [])
                                      .map(
                                        (s) => DropdownMenuItem(
                                          value: s,
                                          child: Text(s),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedLoadSubOption = val;
                                });
                                // Show info popup for C2 → H on selection
                                if (_selectedInstallationType == 'C2' &&
                                    _selectedLoadType ==
                                        'H: Welding machines' &&
                                    _selectedLoadSubOption != null) {
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    showDialog<void>(
                                      context: context,
                                      builder: (_) => const AlertDialog(
                                        title: Text('Information'),
                                        content: Text(
                                          'Refer to paragraph C2 5.2',
                                        ),
                                      ),
                                    );
                                  });
                                }
                              },
                            ),
                          // Removed sub-option helper text under the load sub group box per request
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _diversityController,
                    decoration: const InputDecoration(
                      labelText: 'Diversity Factor',
                      hintText: 'e.g. 0.8',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Phase Current Values (A)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              PhaseInputField(
                                controller: _phaseControllers[0],
                                phaseNumber: 1,
                                phaseLabel: _phaseLabelText(1),
                                readOnly:
                                    (_actionForSelection() !=
                                            _DialogAction.none &&
                                        _actionForSelection() !=
                                            _DialogAction.showInfoOnly) ||
                                    _isBlocksALightsNoAssessment(),
                                onTap:
                                    _actionForSelection() ==
                                        _DialogAction.showInfoOnly
                                    ? () => _onPhaseTap(1)
                                    : (_actionForSelection() !=
                                              _DialogAction.none
                                          ? () => _onPhaseTap(1)
                                          : null),
                              ),
                              const SizedBox(width: 16),
                              PhaseInputField(
                                controller: _phaseControllers[1],
                                phaseNumber: 2,
                                phaseLabel: _phaseLabelText(2),
                                readOnly:
                                    (_actionForSelection() !=
                                            _DialogAction.none &&
                                        _actionForSelection() !=
                                            _DialogAction.showInfoOnly) ||
                                    _isBlocksALightsNoAssessment(),
                                onTap:
                                    _actionForSelection() ==
                                        _DialogAction.showInfoOnly
                                    ? () => _onPhaseTap(2)
                                    : (_actionForSelection() !=
                                              _DialogAction.none
                                          ? () => _onPhaseTap(2)
                                          : null),
                              ),
                              const SizedBox(width: 16),
                              PhaseInputField(
                                controller: _phaseControllers[2],
                                phaseNumber: 3,
                                phaseLabel: _phaseLabelText(3),
                                readOnly:
                                    (_actionForSelection() !=
                                            _DialogAction.none &&
                                        _actionForSelection() !=
                                            _DialogAction.showInfoOnly) ||
                                    _isBlocksALightsNoAssessment(),
                                onTap:
                                    _actionForSelection() ==
                                        _DialogAction.showInfoOnly
                                    ? () => _onPhaseTap(3)
                                    : (_actionForSelection() !=
                                              _DialogAction.none
                                          ? () => _onPhaseTap(3)
                                          : null),
                              ),
                            ],
                          ),
                          if (_isSingleDomesticBPoints()) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Points-based rule: 10 A for 1–20 points; +5 A per additional 20 points or part thereof.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: Colors.black54),
                            ),
                            const SizedBox(height: 4),
                            Builder(
                              builder: (context) {
                                final p1 =
                                    int.tryParse(_phaseControllers[0].text) ??
                                    0;
                                final p2 =
                                    int.tryParse(_phaseControllers[1].text) ??
                                    0;
                                final p3 =
                                    int.tryParse(_phaseControllers[2].text) ??
                                    0;
                                return Text(
                                  'Preview — P1: ${_bPointsPreview(p1)} • P2: ${_bPointsPreview(p2)} • P3: ${_bPointsPreview(p3)}',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.black54),
                                );
                              },
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _saveLoadEntry,
                                  child: const Text('Next Load'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Results',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              for (var i = 0; i < 3; i++) ...[
                                if (i > 0) const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _resultPhaseControllers[i],
                                    decoration: InputDecoration(
                                      labelText: 'Phase ${i + 1} Result (A)',
                                    ),
                                    readOnly: true,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_loadEntries.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Load Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _loadEntries.length,
                              itemBuilder: (context, index) {
                                final e = _loadEntries[index];
                                return ListTile(
                                  title: Text(e.name),
                                  subtitle: Text(
                                    [
                                          e.installationType,
                                          e.subCategory,
                                          e.blockOption,
                                          e.group,
                                          e.detail,
                                        ]
                                        .whereType<String>()
                                        .where((s) => s.isNotEmpty)
                                        .join(' • '),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'P1: ${e.phase1.toStringAsFixed(2)} A\nP2: ${e.phase2.toStringAsFixed(2)} A\nP3: ${e.phase3.toStringAsFixed(2)} A',
                                        textAlign: TextAlign.right,
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        tooltip: 'Delete',
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () {
                                          setState(() {
                                            _loadEntries.removeAt(index);
                                            // Recompute totals if currently shown
                                            if (_totalP1 != null ||
                                                _totalP2 != null ||
                                                _totalP3 != null) {
                                              // Defer to after setState microtask to ensure list updated
                                            }
                                          });
                                          if (_totalP1 != null ||
                                              _totalP2 != null ||
                                              _totalP3 != null) {
                                            _computeMaximumDemand();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: _loadEntries.isEmpty
                                      ? null
                                      : _computeMaximumDemand,
                                  icon: const Icon(Icons.summarize),
                                  label: const Text('Maximum Demand'),
                                ),
                                const SizedBox(width: 12),
                                ElevatedButton.icon(
                                  onPressed: _loadEntries.isEmpty
                                      ? null
                                      : _exportToPdf,
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text('Export PDF'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (_totalP1 != null ||
                      _totalP2 != null ||
                      _totalP3 != null) ...[
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Maximum Demand Total',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: _clearMaximumDemand,
                                  child: const Text('Clear totals'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Phase 1: ${(_totalP1 ?? 0).toStringAsFixed(2)} A',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Phase 2: ${(_totalP2 ?? 0).toStringAsFixed(2)} A',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    'Phase 3: ${(_totalP3 ?? 0).toStringAsFixed(2)} A',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Painter that draws a stylized lightning bolt across the background
class _LightningPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Path for the bolt (zig-zag)
    final Path bolt = Path()
      ..moveTo(width * 0.12, height * 0.08)
      ..lineTo(width * 0.42, height * 0.14)
      ..lineTo(width * 0.32, height * 0.36)
      ..lineTo(width * 0.56, height * 0.33)
      ..lineTo(width * 0.46, height * 0.62)
      ..lineTo(width * 0.72, height * 0.58)
      ..lineTo(width * 0.56, height * 0.92);

    // Glow underlay
    final Paint glow = Paint()
      ..color = const Color(0xFFFFF59D).withOpacity(0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 10);

    // Core stroke
    final Paint core = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFF176), Color(0xFFFFFDE7)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, width, height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Slight outer aura
    final Paint aura = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.outer, 20);

    // Draw order: aura -> glow -> core
    canvas.drawPath(bolt, aura);
    canvas.drawPath(bolt, glow);
    canvas.drawPath(bolt, core);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoadEntry {
  final String name;
  final String? installationType;
  final String? subCategory;
  final String? blockOption;
  final String group;
  final String detail;
  final double phase1;
  final double phase2;
  final double phase3;

  _LoadEntry({
    required this.name,
    required this.installationType,
    required this.subCategory,
    required this.blockOption,
    required this.group,
    required this.detail,
    required this.phase1,
    required this.phase2,
    required this.phase3,
  });
}

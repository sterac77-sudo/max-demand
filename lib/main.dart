import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'load_entry_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MaxDemandCalculatorApp());
}

class MaxDemandCalculatorApp extends StatelessWidget {
  const MaxDemandCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maximum Demand Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        cardColor: Colors.white,
        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
            .copyWith(
              primary: const Color(0xFF1B263B),
              secondary: const Color(0xFFE0E1DD),
            ),
      ),
      home: const LoadEntryScreen(),
    );
  }
}

/*
    final highestCtrl = controllers['highest'] as TextEditingController;
    final secondCtrl = TextEditingController();
    final additionalCountCtrl = controllers['count'] as TextEditingController;
    final List<TextEditingController> additionalCtrls =
        List<TextEditingController>.from(
          controllers['additional'] as List<TextEditingController>,
        );

    double? dialogResult;

    await showDialog<double>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            int cnt = int.tryParse(additionalCountCtrl.text) ?? 0;
            if (cnt < 0) cnt = 0;
            if (cnt != additionalCtrls.length) {
              if (cnt > additionalCtrls.length) {
                for (int i = additionalCtrls.length; i < cnt; i++) {
                  additionalCtrls.add(TextEditingController());
                }
              } else {
                for (int i = additionalCtrls.length - 1; i >= cnt; i--) {
                  additionalCtrls[i].dispose();
                }
                additionalCtrls.removeRange(cnt, additionalCtrls.length);
              }
            }

            double compute() {
              final highest = double.tryParse(highestCtrl.text) ?? 0.0;
              final second = double.tryParse(secondCtrl.text) ?? 0.0;
              double sumAdditional = 0.0;
              for (final c in additionalCtrls)
                sumAdditional += double.tryParse(c.text) ?? 0.0;
              return highest + 0.5 * second + 0.25 * sumAdditional;
            }

            return AlertDialog(
              title: const Text('Motors'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter Motor Amps, Second Motor Amps and additional motors.',
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: highestCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Motor Amps (largest)',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: secondCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Second Motor Amps',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: additionalCountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of Additional Motors',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    for (int i = 0; i < additionalCtrls.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextField(
                          controller: additionalCtrls[i],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Additional Motor ${i + 1} Amps',
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    const SizedBox(height: 12),
                    Text(
                      'Calculated: ${compute().toStringAsFixed(2)} A',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final highest = double.tryParse(highestCtrl.text) ?? 0.0;
                    final second = double.tryParse(secondCtrl.text) ?? 0.0;
                    final additionalVals = additionalCtrls
                        .map((c) => double.tryParse(c.text) ?? 0.0)
                        .toList();
                    final total =
                        highest +
                        0.5 * second +
                        0.25 *
                            additionalVals.fold<double>(0.0, (a, b) => a + b);

                    // Persist into persistent controllers
                    final persistent = _dialogControllers[phase]!;
                    final persistentHighest =
                        persistent['highest'] as TextEditingController;
                    final persistentCount =
                        persistent['count'] as TextEditingController;
                    final persistentAdditional =
                        persistent['additional'] as List<TextEditingController>;

                    final desired = additionalVals.length;
                    if (persistentAdditional.length > desired) {
                      for (
                        int i = desired;
                        i < persistentAdditional.length;
                        i++
                      )
                        persistentAdditional[i].dispose();
                      persistentAdditional.removeRange(
                        desired,
                        persistentAdditional.length,
                      );
                    } else if (persistentAdditional.length < desired) {
                      for (
                        int i = persistentAdditional.length;
                        i < desired;
                        i++
                      )
                        persistentAdditional.add(TextEditingController());
                    }

                    persistentHighest.text = highest.toStringAsFixed(2);
                    persistentCount.text = desired.toString();
                    for (int i = 0; i < desired; i++)
                      persistentAdditional[i].text = additionalVals[i]
                          .toStringAsFixed(2);
                    _dialogControllers[phase]!['additional'] =
                        List<TextEditingController>.from(persistentAdditional);

                    // Persist into MotorConfig for this phase (second motor stored as first additional entry)
                    _motorConfigs[phase] = MotorConfig(
                      largestMotorAmps: highest,
                      additionalMotorAmps: [second, ...additionalVals],
                    );

                    Navigator.of(context).pop(total);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    ).then((val) {
      dialogResult = val;
    });

    if (dialogResult != null) {
      _removeDemandListeners();
      setState(() {
        final formatted = dialogResult!.toStringAsFixed(2);
        int phaseIndex = phase - 1;
        _resultPhaseControllers[phaseIndex].text = formatted;
        _phaseControllers[phaseIndex].text = formatted;
      });
      _addDemandListeners();
      _calculateDemand();
    }
  }

  Future<void> _handleSpaPoolTap(int phase) async {
    if (_selectedInstallationType != 'C1' &&
        _selectedLoadType != 'G: Spa and swimming pool heaters' &&
        _selectedLoadType != 'J: Heating and AC') {
      // Basic guard; handled more fully by action helper
    }
    final SpaPoolConfig? result = await showDialog<SpaPoolConfig>(
      context: context,
      builder: (_) => _SpaPoolDialog(),
    );
    if (result != null) {
      setState(() {
        _spaPoolConfigs[phase] = result;
        final phaseIndex = phase - 1;
        _resultPhaseControllers[phaseIndex].text = result.totalAmps.toStringAsFixed(2);
      });
      _calculateDemand();
    }
  }

  Future<void> _handleLiftMotorTap(int phase) async {
    bool isValidC1Lift =
        _selectedInstallationType == 'C1' &&
        (_selectedSubCategory ==
                'Single Domestic or Individual living unit per phase' ||
            _selectedSubCategory == 'Blocks of living units') &&
        _selectedLoadType == 'K: Lifts' &&
        _selectedLoadSubOption == 'Lifts';

    bool isValidC2Lift =
        _selectedInstallationType == 'C2' &&
        (_selectedSubCategory ==
            'Residential institutes, hotels, boarding houses, hospitals, motels' ||
         _selectedSubCategory ==
            'Factories, shops, stores, offices, schools, churches') &&
        _selectedLoadType == 'E: Lifts' &&
        _selectedLoadSubOption == 'Lifts';

    if (!isValidC1Lift && !isValidC2Lift) return;

    final LiftMotorConfig? result = await showDialog<LiftMotorConfig>(
      context: context,
      builder: (_) => LiftMotorDialog(),
    );
    if (result != null) {
      setState(() {
        _liftMotorConfigs[phase] = result;
      });
      _calculateDemand();
    }
  }

  Future<void> _handleMotorTap(int phase) async {
    if (_selectedInstallationType != 'C1' ||
        !((_selectedSubCategory ==
                    'Single Domestic or Individual living unit per phase' ||
                _selectedSubCategory == 'Blocks of living units') &&
            _selectedLoadType == 'L: Motors' &&
            _selectedLoadSubOption == 'Motors')) {
      return;
    }
    final MotorConfig? result = await showDialog<MotorConfig>(
      context: context,
      builder: (_) => MotorDialog(),
    );
    if (result != null) {
      setState(() {
        _motorConfigs[phase] = result;
      });
      _calculateDemand();
    }
  }

  Future<void> _showApplianceInfo(int phase) async {
    final ampsController = TextEditingController();
    try {
      final result = await showDialog<double>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('M: Appliances'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Connected load 5A or less: No assessment for purpose of maximum demand. Connected load over 5A: By assessment.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ampsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amps'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final val = double.tryParse(ampsController.text);
                Navigator.of(context).pop(val);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      if (result != null) {
        setState(() {
          final formatted = result.toStringAsFixed(2);
          final phaseIndex = phase - 1;
          _resultPhaseControllers[phaseIndex].text = formatted;
        });
        _calculateDemand();
      }
    } finally {
      ampsController.dispose();
    }
  }

  Future<void> _showApplianceInfoBlocks(int phase) async {
    final ampsController = TextEditingController();
    try {
      final result = await showDialog<double>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('M: Appliances'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Connected load 10A or less: No assessment for purpose of maximum demand. Connected load over 10A: By assessment.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ampsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amps'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final val = double.tryParse(ampsController.text);
                Navigator.of(context).pop(val);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (result != null) {
        setState(() {
          final formatted = result.toStringAsFixed(2);
          int phaseIndex = phase - 1;
          _resultPhaseControllers[phaseIndex].text = formatted;
        });
        _calculateDemand();
      }
    } finally {
      ampsController.dispose();
    }
  }

  // Socket dialog widget (kept as a separate widget)
  // Note: This dialog manages its own controllers and disposes them internally
  // Implementation moved earlier in conversation - included here as widget below.
  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildForm(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Max Demand Calculator'),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                    'Calculated Current per Phase (A)',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _resultPhaseControllers[0],
                          decoration: const InputDecoration(
                            labelText: 'Phase 1 (A)',
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _resultPhaseControllers[1],
                          decoration: const InputDecoration(
                            labelText: 'Phase 2 (A)',
                          ),
                          readOnly: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _resultPhaseControllers[2],
                          decoration: const InputDecoration(
                            labelText: 'Phase 3 (A)',
                          ),
                          readOnly: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
                            border: Border(
                              bottom: BorderSide(
                                color: Color(0xFFEEEEEE),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.electric_bolt,
                                color: theme.primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Load Details',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Load name
                        TextFormField(
                          controller: _loadNameController,
                          decoration: const InputDecoration(
                            labelText: 'Load Name',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Installation type
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          value: _selectedInstallationType,
                          hint: const Text('Select installation type'),
                          items: _installationTypes
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(_installationTypeLabels[t] ?? t),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() {
                            _selectedInstallationType = v;
                            _selectedSubCategory = null;
                            _selectedLoadType = null;
                            _selectedLoadSubOption = null;
                          }),
                        ),
                        const SizedBox(height: 12),

                        // Sub category
                        if (_selectedInstallationType != null)
                          DropdownButtonFormField<String>(
                            value: _selectedSubCategory,
                            hint: const Text('Select sub category'),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: (_subCategories[_selectedInstallationType] ?? [])
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8),
                                        child: Text(s, softWrap: true),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() {
                              _selectedSubCategory = v;
                              _selectedBlockOption = null;
                              _selectedLoadType = null;
                              _selectedLoadSubOption = null;
                            }),
                          ),
                        const SizedBox(height: 20),

                        // Block option
                        if (_selectedSubCategory == 'Blocks of living units')
                          DropdownButtonFormField<String>(
                            value: _selectedBlockOption,
                            hint: const Text('Select block option'),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: _blockOptions
                                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                .toList(),
                            onChanged: (v) => setState(() {
                              _selectedBlockOption = v;
                            }),
                          ),
                        const SizedBox(height: 12),

                        // Load type
                        if (_selectedInstallationType != null)
                          DropdownButtonFormField<String>(
                            value: _selectedLoadType,
                            hint: const Text('Select load group'),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: (_loadTypes[_selectedInstallationType] ?? {}).keys
                                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                                .toList(),
                            onChanged: (v) => setState(() {
                              _selectedLoadType = v;
                              _selectedLoadSubOption = null;
                            }),
                          ),
                        const SizedBox(height: 12),

                        // Load sub-option
                        if (_selectedLoadType != null)
                          ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 50),
                            child: DropdownButtonFormField<String>(
                              value: _selectedLoadSubOption,
                              hint: const Text('Select sub option'),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              isExpanded: true,
                              items: ((_loadTypes[_selectedInstallationType] ??
                                          {})[_selectedLoadType] ??
                                      [])
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Container(
                                        padding: const EdgeInsets.only(right: 16),
                                        child: Text(
                                          s,
                                          softWrap: true,
                                          overflow: TextOverflow.visible,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() {
                                _selectedLoadSubOption = v;
                              }),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // Phases row
                        // Phases row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Phase 1
                            Expanded(
                              child: Builder(
                                builder: (ctx) {
                                  final action1 = _actionForCurrentSelection(1);
                                  final readOnly1 = action1 != _DialogAction.none;
                                  return PhaseInputField(
                                    controller: _phaseControllers[0],
                                    phaseNumber: 1,
                                    phaseLabel: _phaseLabel(1),
                                    readOnly: readOnly1,
                                    onTap: readOnly1
                                        ? () async {
                                            switch (action1) {
                                              case _DialogAction.showC2CookingAppliance:
                                                await _showC2CookingApplianceDialog(1);
                                                break;
                                              case _DialogAction.showC2Motors:
                                                await _showFGroupMotorsDialog(1);
                                                break;
                                              case _DialogAction.showC2ResidentialMotors:
                                                await _showC2CookingApplianceDialog(1);
                                                break;
                                              case _DialogAction.showFGroupMotors:
                                                await _showFGroupMotorsDialog(1);
                                                break;
                                              case _DialogAction.showSpaPool:
                                                await _handleSpaPoolTap(1);
                                                break;
                                              case _DialogAction.showLift:
                                                await _handleLiftMotorTap(1);
                                                break;
                                              case _DialogAction.showMotor:
                                                await _handleMotorTap(1);
                                                break;
                                              case _DialogAction.showApplianceSingle:
                                                await _showApplianceInfo(1);
                                                break;
                                              case _DialogAction.showApplianceBlocks:
                                                await _showApplianceInfoBlocks(1);
                                                break;
                                              case _DialogAction.showSocketExceeding10A:
                                                try {
                                                  if (!mounted) return;
                                                  await _showSocketExceeding10ADialog(
                                                    1,
                                                    isFactories: _selectedSubCategory == 'Factories, shops, stores, offices, schools, churches',
                                                  );
                                                } catch (e, st) {
                                                  debugPrint('Open socket dialog error (phase1): $e\n$st');
                                                }
                                                break;
                                              default:
                                                break;
                                            }
                                          }
                                        : null,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Phase 2
                            Expanded(
                              child: Builder(
                                builder: (ctx) {
                                  final action2 = _actionForCurrentSelection(2);
                                  final readOnly2 = action2 != _DialogAction.none;
                                  return PhaseInputField(
                                    controller: _phaseControllers[1],
                                    phaseNumber: 2,
                                    phaseLabel: _phaseLabel(2),
                                    readOnly: readOnly2,
                                    onTap: readOnly2
                                        ? () async {
                                            switch (action2) {
                                              case _DialogAction.showC2CookingAppliance:
                                                await _showC2CookingApplianceDialog(2);
                                                break;
                                              case _DialogAction.showC2Motors:
                                                await _showFGroupMotorsDialog(2);
                                                break;
                                              case _DialogAction.showC2ResidentialMotors:
                                                await _showC2CookingApplianceDialog(2);
                                                break;
                                              case _DialogAction.showFGroupMotors:
                                                await _showFGroupMotorsDialog(2);
                                                break;
                                              case _DialogAction.showSpaPool:
                                                await _handleSpaPoolTap(2);
                                                break;
                                              case _DialogAction.showLift:
                                                await _handleLiftMotorTap(2);
                                                break;
                                              case _DialogAction.showMotor:
                                                await _handleMotorTap(2);
                                                break;
                                              case _DialogAction.showApplianceSingle:
                                                await _showApplianceInfo(2);
                                                break;
                                              case _DialogAction.showApplianceBlocks:
                                                await _showApplianceInfoBlocks(2);
                                                break;
                                              case _DialogAction.showSocketExceeding10A:
                                                try {
                                                  if (!mounted) return;
                                                  await _showSocketExceeding10ADialog(
                                                    2,
                                                    isFactories: _selectedSubCategory == 'Factories, shops, stores, offices, schools, churches',
                                                  );
                                                } catch (e, st) {
                                                  debugPrint('Open socket dialog error (phase2): $e\n$st');
                                                }
                                                break;
                                              default:
                                                break;
                                            }
                                          }
                                        : null,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Phase 3
                            Expanded(
                              child: Builder(
                                builder: (ctx) {
                                  final action3 = _actionForCurrentSelection(3);
                                  final readOnly3 = action3 != _DialogAction.none;
                                  return PhaseInputField(
                                    controller: _phaseControllers[2],
                                    phaseNumber: 3,
                                    phaseLabel: _phaseLabel(3),
                                    readOnly: readOnly3,
                                    onTap: readOnly3
                                        ? () async {
                                            switch (action3) {
                                              case _DialogAction.showC2CookingAppliance:
                                                await _showC2CookingApplianceDialog(3);
                                                break;
                                              case _DialogAction.showC2Motors:
                                                await _showFGroupMotorsDialog(3);
                                                break;
                                              case _DialogAction.showC2ResidentialMotors:
                                                await _showC2CookingApplianceDialog(3);
                                                break;
                                              case _DialogAction.showFGroupMotors:
                                                await _showFGroupMotorsDialog(3);
                                                break;
                                              case _DialogAction.showSpaPool:
                                                await _handleSpaPoolTap(3);
                                                break;
                                              case _DialogAction.showLift:
                                                await _handleLiftMotorTap(3);
                                                break;
                                              case _DialogAction.showMotor:
                                                await _handleMotorTap(3);
                                                break;
                                              case _DialogAction.showApplianceSingle:
                                                await _showApplianceInfo(3);
                                                break;
                                              case _DialogAction.showApplianceBlocks:
                                                await _showApplianceInfoBlocks(3);
                                                break;
                                              case _DialogAction.showSocketExceeding10A:
                                                try {
                                                  if (!mounted) return;
                                                  await _showSocketExceeding10ADialog(
                                                    3,
                                                    isFactories: _selectedSubCategory == 'Factories, shops, stores, offices, schools, churches',
                                                  );
                                                } catch (e, st) {
                                                  debugPrint('Open socket dialog error (phase3): $e\n$st');
                                                }
                                                break;
                                              default:
                                                break;
                                            }
                                          }
                                        : null,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.only(top: 12)),
                    // Diversity
                    TextFormField(
                      controller: _diversityController,
                      decoration: const InputDecoration(
                        labelText: 'Diversity Factor',
                        hintText: 'e.g. 0.8',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                      const Text(
                        'Calculated Current per Phase (A)',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _resultPhaseControllers[0],
                              decoration: const InputDecoration(
                                labelText: 'Phase 1 (A)',
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _resultPhaseControllers[1],
                              decoration: const InputDecoration(
                                labelText: 'Phase 2 (A)',
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _resultPhaseControllers[2],
                              decoration: const InputDecoration(
                                labelText: 'Phase 3 (A)',
                              ),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                    child: ElevatedButton(
                      onPressed: _calculateDemand,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Calculate',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveLoadEntry,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Next Load',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),

                    if (_loadEntries.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Load Summary',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _loadEntries.length,
                        itemBuilder: (ctx, i) {
                          final e = _loadEntries[i];
                          return Card(
                            child: ListTile(
                              title: Text(e.name),
                              subtitle: Text('${e.group} • ${e.detail}'),
                              trailing: Text(
                                'P1: ${e.phase1.toStringAsFixed(2)} A\nP2: ${e.phase2.toStringAsFixed(2)} A\nP3: ${e.phase3.toStringAsFixed(2)} A',
                                textAlign: TextAlign.right,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }  // ------------- demand calculation -------------
  void _calculateDemand() {
    // Many branches; keep defensive parsing
    final p1 = int.tryParse(_phaseControllers[0].text) ?? 0;
    final p2 = int.tryParse(_phaseControllers[1].text) ?? 0;
    final p3 = int.tryParse(_phaseControllers[2].text) ?? 0;
    // Short-circuit for C2 K: By Assessment — entered phase amps are the calculated amps
    if (_selectedInstallationType == 'C2' &&
        _selectedSubCategory ==
            'Residential institutes, hotels, boarding houses, hospitals, motels' &&
        _selectedLoadType == 'K: Other') {
      // <-- match this to your exact K label
      final double suppliedP1 = _parseDoubleOrZero(_phaseControllers[0].text);
      final double suppliedP2 = _parseDoubleOrZero(_phaseControllers[1].text);
      final double suppliedP3 = _parseDoubleOrZero(_phaseControllers[2].text);
      _resultPhaseControllers[0].text = suppliedP1.toStringAsFixed(2);
      _resultPhaseControllers[1].text = suppliedP2.toStringAsFixed(2);
      _resultPhaseControllers[2].text = suppliedP3.toStringAsFixed(2);
      return;
    }
    // Short-circuit for C2 J: X-ray equipment — calculated = entered / 2 (for both residential and factories)
    if (_selectedInstallationType == 'C2' &&
        _selectedLoadType == 'J: X-ray equipment') {
      final double suppliedP1 = _parseDoubleOrZero(_phaseControllers[0].text);
      final double suppliedP2 = _parseDoubleOrZero(_phaseControllers[1].text);
      final double suppliedP3 = _parseDoubleOrZero(_phaseControllers[2].text);
      _resultPhaseControllers[0].text = (suppliedP1 / 2.0).toStringAsFixed(2);
      _resultPhaseControllers[1].text = (suppliedP2 / 2.0).toStringAsFixed(2);
      _resultPhaseControllers[2].text = (suppliedP3 / 2.0).toStringAsFixed(2);
      return;
    }
    // C2, Factories/shops/stores/offices/schools/churches -> B: Socket-outlets (i)
    if (_selectedInstallationType == 'C2' &&
        _selectedSubCategory ==
            'Factories, shops, stores, offices, schools, churches' &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'i) Socket-outlets not exceeding 10 A other than those in B(ii) c,e') {
      double calcPts(int pts) {
        if (pts <= 0) return 0.0;
        if (pts == 1) return 4.167;
        return 4.167 + (pts - 1) * 3.125;
      }

      _resultPhaseControllers[0].text = calcPts(
        (int.tryParse(_phaseControllers[0].text) ?? 0),
      ).toStringAsFixed(3);
      _resultPhaseControllers[1].text = calcPts(
        (int.tryParse(_phaseControllers[1].text) ?? 0),
      ).toStringAsFixed(3);
      _resultPhaseControllers[2].text = calcPts(
        (int.tryParse(_phaseControllers[2].text) ?? 0),
      ).toStringAsFixed(3);
      return;
    }
    // C2, Factories/shops/stores/offices/schools/churches -> B: Socket-outlets (ii)
    if (_selectedInstallationType == 'C2' &&
        _selectedSubCategory ==
            'Factories, shops, stores, offices, schools, churches' &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'ii) Socket-outlets not exceeding 10 A in buildings or portions of buildings provided with permanently installed heating or cooling equipment or both c,d,e') {
      double calcPts(int pts) {
        if (pts <= 0) return 0.0;
        if (pts == 1) return 4.167;
        return 4.167 + (pts - 1) * 0.417;
      }

      for (int i = 0; i < 3; i++) {
        _resultPhaseControllers[i].text = calcPts(
          int.tryParse(_phaseControllers[i].text) ?? 0,
        ).toStringAsFixed(3);
      }
      return;
    }

    // Short-circuit for C2 F(ii) Lighting: entered phase amps are the calculated amps
    if (_isFiiLightingSelected) {
      List<double> suppliedPhases = List.generate(3, (i) =>
          _parseDoubleOrZero(_phaseControllers[i].text));
      
      for (int i = 0; i < 3; i++) {
        _resultPhaseControllers[i].text = suppliedPhases[i].toStringAsFixed(2);
      }
      return;
  } // Short-circuit for C2 G: Swimming pools, spas, saunas, thermal storage heaters, space heaters and similar — entered phase amps are the calculated amps
  if (_selectedInstallationType == 'C2' &&
    _selectedLoadType == 'G: Swimming pools, spas, saunas, thermal storage heaters, space heaters and similar') {
      List<double> suppliedPhases = List.generate(3, (i) =>
          _parseDoubleOrZero(_phaseControllers[i].text));
      
      for (int i = 0; i < 3; i++) {
        _resultPhaseControllers[i].text = suppliedPhases[i].toStringAsFixed(2);
      }
      return;
    }
  // Short-circuit for C2 H: same behaviour as G — entered phase amps are the calculated amps (for both residential and factories)
  if (_selectedInstallationType == 'C2' &&
    _selectedLoadType == 'H: Welding machines' &&
    (_selectedLoadSubOption == 'Welding machines' ||
      _selectedLoadSubOption == null)) {
      List<double> suppliedPhases = List.generate(3, (i) =>
          _parseDoubleOrZero(_phaseControllers[i].text));
      
      for (int i = 0; i < 3; i++) {
        _resultPhaseControllers[i].text = suppliedPhases[i].toStringAsFixed(2);
      }
      return;
    }

    // Early special-case branches that set results and return
    // C2 B(ii)
    if (_selectedInstallationType == 'C2' &&
        _selectedSubCategory ==
            'Residential institutes, hotels, boarding houses, hospitals, motels' &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'ii) Socket-outlets not exceeding 10 A in buildings or portions of buildings provided with permanently installed heating or cooling equipment or both c,d,e') {
      double calc(int pts) {
        if (pts <= 0) return 0.0;
        if (pts == 1) return 4.167;
        return 4.167 + (pts - 1) * 0.417;
      }

      for (int i = 0; i < 3; i++) {
        int points = (i == 0) ? p1 : (i == 1) ? p2 : p3;
        _resultPhaseControllers[i].text = calc(points).toStringAsFixed(3);
      }
      return;
    }

    // C2 B(i)
    if (_selectedInstallationType == 'C2' &&
        _selectedSubCategory ==
            'Residential institutes, hotels, boarding houses, hospitals, motels' &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'i) Socket-outlets not exceeding 10 A other than those in B(ii) c,e') {
      double calc(int pts) {
        if (pts <= 0) return 0.0;
        if (pts == 1) return 4.167;
        return 4.167 + (pts - 1) * 1.667;
      }

      for (int i = 0; i < 3; i++) {
        int points = (i == 0) ? p1 : (i == 1) ? p2 : p3;
        _resultPhaseControllers[i].text = calc(points).toStringAsFixed(3);
      }
      return;
    }

    // C2 A: Lighting
    if (_selectedInstallationType == 'C2' &&
        _selectedSubCategory ==
            'Residential institutes, hotels, boarding houses, hospitals, motels' &&
        _selectedLoadType == 'A: Lighting' &&
        _selectedLoadSubOption == 'Lighting other than in load group F b,c') {
      for (int i = 0; i < 3; i++) {
        double value = (i == 0) ? p1.toDouble() : (i == 1) ? p2.toDouble() : p3.toDouble();
        _resultPhaseControllers[i].text = (value * 0.75).toStringAsFixed(2);
      }
      return;
    }

    // C1 Blocks → J(iii) spa (delegated to spa configs)
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        (_selectedBlockOption == '2 to 5 living units per phase' ||
            _selectedBlockOption == '6 to 20 living units per phase' ||
            _selectedBlockOption == '21 or more living units per phase') &&
        _selectedLoadType == 'J: Heating and AC' &&
        _selectedLoadSubOption == 'iii) Spa and swimming pool heaters') {
      double c1 = 0, c2 = 0, c3 = 0;
      if (_spaPoolConfigs.containsKey(1)) c1 += _spaPoolConfigs[1]!.totalAmps;
      if (_spaPoolConfigs.containsKey(2)) c2 += _spaPoolConfigs[2]!.totalAmps;
      if (_spaPoolConfigs.containsKey(3)) c3 += _spaPoolConfigs[3]!.totalAmps;
      for (int i = 0; i < 3; i++) {
        double value = (i == 0) ? c1 : (i == 1) ? c2 : c3;
        _resultPhaseControllers[i].text = value.toStringAsFixed(2);
      }
      return;
    }

    // C1 Blocks → J(i) clothes dryers etc
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        (_selectedBlockOption == '2 to 5 living units per phase' ||
            _selectedBlockOption == '6 to 20 living units per phase' ||
            _selectedBlockOption == '21 or more living units per phase') &&
        _selectedLoadType == 'J: Heating and AC' &&
        _selectedLoadSubOption ==
            'i) Clothes dryers, water heaters, self-heating washing machines, wash boilers') {
      for (int i = 0; i < 3; i++) {
        double value = (i == 0) ? p1.toDouble() : (i == 1) ? p2.toDouble() : p3.toDouble();
        _resultPhaseControllers[i].text = (value * 0.5).toStringAsFixed(2);
      }
      return;
    }

    // C1 Blocks → I sockets not included in J/M
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        (_selectedBlockOption == '2 to 5 living units per phase' ||
            _selectedBlockOption == '6 to 20 living units per phase' ||
            _selectedBlockOption == '21 or more living units per phase') &&
        _selectedLoadType ==
            'I: Socket-outlets not included in groups J and M' &&
        _selectedLoadSubOption ==
            'Socket-outlets not included in groups J and M; permanently connected electrical equipment not exceeding 10 A') {
      final double v1 = (p1 * 2 > 15) ? 15.0 : (p1 * 2.0);
      final double v2 = (p2 * 2 > 15) ? 15.0 : (p2 * 2.0);
      final double v3 = (p3 * 2 > 15) ? 15.0 : (p3 * 2.0);
      for (int i = 0; i < 3; i++) {
        double value = (i == 0) ? v1 : (i == 1) ? v2 : v3;
        _resultPhaseControllers[i].text = value.toStringAsFixed(2);
      }
      return;
    }

    // C1 Blocks → H communal lighting
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        (_selectedBlockOption == '2 to 5 living units per phase' ||
            _selectedBlockOption == '6 to 20 living units per phase' ||
            _selectedBlockOption == '21 or more living units per phase') &&
        _selectedLoadType == 'H: Communal lighting' &&
        _selectedLoadSubOption == 'Communal lighting') {
      for (int i = 0; i < 3; i++) {
        int value = (i == 0) ? p1 : (i == 1) ? p2 : p3;
        _resultPhaseControllers[i].text = value.toDouble().toStringAsFixed(2);
      }
      return;
    }

    // Initialize accumulators
    double c1 = 0.0;
    double c2 = 0.0;
    double c3 = 0.0;

    // Some group-level additions
    if (_selectedLoadType == 'i) Lighting' ||
        _selectedLoadType == 'A: Lights') {
      c1 += _computeLightingCurrent(p1);
      c2 += _computeLightingCurrent(p2);
      c3 += _computeLightingCurrent(p3);
    }

    if (_selectedLoadType == 'G: Spa and swimming pool heaters') {
      if (_spaPoolConfigs.containsKey(1)) c1 += _spaPoolConfigs[1]!.totalAmps;
      if (_spaPoolConfigs.containsKey(2)) c2 += _spaPoolConfigs[2]!.totalAmps;
      if (_spaPoolConfigs.containsKey(3)) c3 += _spaPoolConfigs[3]!.totalAmps;
    }

    // Lift logic (immediate write and return)
    if (_selectedLoadType == 'K: Lifts' || _selectedLoadType == 'E: Lifts') {
      double calcLift(LiftMotorConfig? config) {
        if (config == null) return 0.0;
        final lifts = [
          config.largestLiftMotorAmps,
          ...config.additionalLiftAmps,
        ];
        if (lifts.isEmpty) return 0.0;
        lifts.sort((a, b) => b.compareTo(a));
        double result = 0.0;
        for (int i = 0; i < lifts.length; i++) {
          if (i == 0)
            result += lifts[i] * 1.25;
          else if (i == 1)
            result += lifts[i] * 0.75;
          else
            result += lifts[i] * 0.5;
        }
        return result;
      }

      for (int i = 0; i < 3; i++) {
        _resultPhaseControllers[i].text = calcLift(
          _liftMotorConfigs[i + 1],
        ).toStringAsFixed(2);
      }
      return;
    }

    // Motor logic (immediate write and return)
    if (_selectedLoadType == 'L: Motors' || _selectedLoadType == 'D: Motors') {
      double calcMotor(MotorConfig? config) {
        if (config == null) return 0.0;
        double result = 0.0;
        
        final isC2Factories = _selectedInstallationType == 'C2' &&
            _selectedSubCategory == 'Factories, shops, stores, offices, schools, churches' &&
            _selectedLoadType == 'D: Motors';
        final isC2Residential = _selectedInstallationType == 'C2' &&
            _selectedSubCategory == 'Residential institutes, hotels, boarding houses, hospitals, motels' &&
            _selectedLoadType == 'D: Motors';
        
        // For C2 Factories path
        if (isC2Factories) {
          // Full load of highest rated motor
          result = config.largestMotorAmps;
          
          // Get all motors including the largest one
          final allMotors = [config.largestMotorAmps, ...config.additionalMotorAmps];
          allMotors.sort((a, b) => b.compareTo(a)); // Sort in descending order
          
          if (allMotors.length >= 2) {
            // Add 75% of second highest motor
            result += allMotors[1] * 0.75;
            
            // Add 50% of all remaining motors
            for (int i = 2; i < allMotors.length; i++) {
              result += allMotors[i] * 0.5;
            }
          }
        } 
        // For C2 Residential/Hotels path
        else if (isC2Residential) {
          // Full load of highest rated motor
          result = config.largestMotorAmps;
          
          // 50% of full load of remainder
          for (final amps in config.additionalMotorAmps) {
            result += amps * 0.5;
          }
        }
        // Default case for other paths
        else {
          result = config.largestMotorAmps;
          for (final amps in config.additionalMotorAmps) {
            result += amps * 0.5;
          }
        }
        return result;
      }

      final p1Result = calcMotor(_motorConfigs[1]);
      final p2Result = calcMotor(_motorConfigs[2]);
      final p3Result = calcMotor(_motorConfigs[3]);

      // Update both the phase controllers and result controllers
      for (int i = 0; i < 3; i++) {
        double result = (i == 0) ? p1Result : (i == 1) ? p2Result : p3Result;
        if (result > 0) _phaseControllers[i].text = result.toStringAsFixed(2);
      }
      
      for (int i = 0; i < 3; i++) {
        double result = (i == 0) ? p1Result : (i == 1) ? p2Result : p3Result;
        _resultPhaseControllers[i].text = result.toStringAsFixed(2);
      }
      return;
    }

    // Apply many C1 blocks/socket/range rules
    // C: ranges 2.8 factor for blocks 6-20 / 21+
    if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        (_selectedBlockOption == '6 to 20 living units per phase' ||
            _selectedBlockOption == '21 or more living units per phase') &&
        _selectedLoadType ==
            'C: Ranges, cooking appliances, laundry equipment' &&
        _selectedLoadSubOption ==
            'Ranges, cooking appliances, laundry equipment or socket-outlets rated at more than 10 A for the connection thereof') {
      c1 += p1 * 2.8;
      c2 += p2 * 2.8;
      c3 += p3 * 2.8;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedBlockOption == '6 to 20 living units per phase' &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'i) Socket-outlets not exceeding 10 A; permanently connected electrical equipment not exceeding 10 A and not included in other load groups') {
      final u1 = p1.clamp(6, 20);
      final u2 = p2.clamp(6, 20);
      final u3 = p3.clamp(6, 20);
      c1 += 15.0 + (u1 - 5) * 3.75;
      c2 += 15.0 + (u2 - 5) * 3.75;
      c3 += 15.0 + (u3 - 5) * 3.75;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedBlockOption == '21 or more living units per phase' &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'i) Socket-outlets not exceeding 10 A; permanently connected electrical equipment not exceeding 10 A and not included in other load groups') {
      final u1 = p1 < 21 ? 21 : p1;
      final u2 = p2 < 21 ? 21 : p2;
      final u3 = p3 < 21 ? 21 : p3;
      c1 += 50.0 + (u1 - 20) * 1.9;
      c2 += 50.0 + (u2 - 20) * 1.9;
      c3 += 50.0 + (u3 - 20) * 1.9;
    } else if (_selectedInstallationType == 'C1' &&
        (_selectedSubCategory ==
                'Single Domestic or Individual living unit per phase' ||
            _selectedSubCategory == 'Blocks of living units') &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'ii) One or more 15 A socket-outlets (excluding those for groups C, D, E, F, G, L)') {
      c1 += (p1 >= 1) ? 10.0 : 0.0;
      c2 += (p2 >= 1) ? 10.0 : 0.0;
      c3 += (p3 >= 1) ? 10.0 : 0.0;
    } else if (_selectedInstallationType == 'C1' &&
        (_selectedSubCategory ==
                'Single Domestic or Individual living unit per phase' ||
            _selectedSubCategory == 'Blocks of living units') &&
        _selectedLoadType == 'B: Socket-outlets' &&
        _selectedLoadSubOption ==
            'iii) One or more 20 A socket-outlets (excluding those for groups C, D, E, F, G, L)') {
      c1 += (p1 >= 1) ? 15.0 : 0.0;
      c2 += (p2 >= 1) ? 15.0 : 0.0;
      c3 += (p3 >= 1) ? 15.0 : 0.0;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType ==
            'C: Ranges, cooking appliances, laundry equipment' &&
        _selectedLoadSubOption ==
            'Ranges, cooking appliances, laundry equipment or socket-outlets rated at more than 10 A for the connection thereof') {
      c1 += p1 * 0.5;
      c2 += p2 * 0.5;
      c3 += p3 * 0.5;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedBlockOption == '2 to 5 living units per phase' &&
        _selectedLoadType == 'A: Lights' &&
        _selectedLoadSubOption ==
            'i) Lighting (Except load group H below d,e,f)') {
      c1 = c2 = c3 = 6.0;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedBlockOption == '6 to 20 living units per phase' &&
        _selectedLoadType == 'A: Lights' &&
        _selectedLoadSubOption ==
            'i) Lighting (Except load group H below d,e,f)') {
      final u1 = p1.clamp(6, 20);
      final u2 = p2.clamp(6, 20);
      final u3 = p3.clamp(6, 20);
      c1 += 5.0 + (u1 - 5) * 0.25;
      c2 += 5.0 + (u2 - 5) * 0.25;
      c3 += 5.0 + (u3 - 5) * 0.25;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedBlockOption == '21 or more living units per phase' &&
        _selectedLoadType == 'A: Lights' &&
        _selectedLoadSubOption ==
            'i) Lighting (Except load group H below d,e,f)') {
      c1 += p1 * 0.5;
      c2 += p2 * 0.5;
      c3 += p3 * 0.5;
    } else if (_selectedInstallationType == 'C1' &&
        (_selectedSubCategory ==
                'Single Domestic or Individual living unit per phase' ||
            _selectedSubCategory == 'Blocks of living units') &&
        _selectedLoadType == 'D: Fixed space heating or airconditioning' &&
        _selectedLoadSubOption ==
            'Fixed space heating or airconditioning equipment, saunas or socket-outlets rated at more than 10 A for the connection thereof') {
      c1 += p1 * 0.75;
      c2 += p2 * 0.75;
      c3 += p3 * 0.75;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType == 'E: Instantaneous water heaters' &&
        _selectedLoadSubOption == 'Instantaneous water heaters') {
      c1 += p1 * 0.333;
      c2 += p2 * 0.333;
      c3 += p3 * 0.333;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        (_selectedBlockOption == '2 to 5 living units per phase' ||
            _selectedBlockOption == '6 to 20 living units per phase') &&
        _selectedLoadType == 'E: Instantaneous water heaters' &&
        _selectedLoadSubOption == 'Instantaneous water heaters') {
      c1 += p1 * 6.0;
      c2 += p2 * 6.0;
      c3 += p3 * 6.0;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedBlockOption == '21 or more living units per phase' &&
        _selectedLoadType == 'E: Instantaneous water heaters' &&
        _selectedLoadSubOption == 'Instantaneous water heaters') {
      final u1 = p1 < 21 ? 21 : p1;
      final u2 = p2 < 21 ? 21 : p2;
      final u3 = p3 < 21 ? 21 : p3;
      c1 += 100.0 + (u1 - 20) * 0.8;
      c2 += 100.0 + (u2 - 20) * 0.8;
      c3 += 100.0 + (u3 - 20) * 0.8;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory ==
            'Single Domestic or Individual living unit per phase' &&
        _selectedLoadType == 'F: Storage water heaters' &&
        _selectedLoadSubOption == 'Storage water heaters' &&
        p1 > 0) {
      c1 += p1 * 1.0;
      c2 += p2 * 1.0;
      c3 += p3 * 1.0;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        (_selectedBlockOption == '2 to 5 living units per phase' ||
            _selectedBlockOption == '6 to 20 living units per phase') &&
        _selectedLoadType == 'F: Storage water heaters' &&
        _selectedLoadSubOption == 'Storage water heaters') {
      final u1 = p1.clamp(2, 20);
      final u2 = p2.clamp(2, 20);
      final u3 = p3.clamp(2, 20);
      c1 = u1 * 6.0;
      c2 = u2 * 6.0;
      c3 = u3 * 6.0;
    } else if (_selectedInstallationType == 'C1' &&
        _selectedSubCategory == 'Blocks of living units' &&
        _selectedBlockOption == '21 or more living units per phase' &&
        _selectedLoadType == 'F: Storage water heaters' &&
        _selectedLoadSubOption == 'Storage water heaters') {
      final u1 = p1 < 21 ? 21 : p1;
      final u2 = p2 < 21 ? 21 : p2;
      final u3 = p3 < 21 ? 21 : p3;
      c1 += 100.0 + (u1 - 20) * 0.8;
      c2 += 100.0 + (u2 - 20) * 0.8;
      c3 += 100.0 + (u3 - 20) * 0.8;
    }

    // If spa configs not provided and points zero, zero their contribution
    if (p1 == 0 && !_spaPoolConfigs.containsKey(1)) c1 = 0.0;
    if (p2 == 0 && !_spaPoolConfigs.containsKey(2)) c2 = 0.0;
    if (p3 == 0 && !_spaPoolConfigs.containsKey(3)) c3 = 0.0;

    // Apply diversity factor at end
    final diversity = _parseDoubleOrZero(_diversityController.text);
    final double finalC1 = c1 * (diversity == 0 ? 1.0 : diversity);
    final double finalC2 = c2 * (diversity == 0 ? 1.0 : diversity);
    final double finalC3 = c3 * (diversity == 0 ? 1.0 : diversity);

    // Respect supplied numeric phase fields if our rules produced zero
    List<double> suppliedPhases = List.generate(3, (i) =>
        _parseDoubleOrZero(_phaseControllers[i].text));

    List<double> finalC = [finalC1, finalC2, finalC3];

    for (int i = 0; i < 3; i++) {
      double out = (finalC[i] > 0) ? finalC[i] : suppliedPhases[i];
      _resultPhaseControllers[i].text = out.toStringAsFixed(2);
    }
  }

  // ------------- Save load entry -------------
  void _saveLoadEntry() {
    final isDialogLoad =
        (_selectedInstallationType == 'C2' &&
            _selectedSubCategory ==
                'Residential institutes, hotels, boarding houses, hospitals, motels' &&
            _selectedLoadType == 'B: Socket-outlets' &&
            _selectedLoadSubOption ==
                'iii) Socket-outlets exceeding 10 A c,e') ||
        (_selectedInstallationType == 'C2' &&
            _selectedSubCategory ==
                'Residential institutes, hotels, boarding houses, hospitals, motels' &&
            _selectedLoadType ==
                'C: Appliances for cooking, heating and cooling' &&
            _selectedLoadSubOption ==
                'Appliances for cooking, heating and cooling, including instantaneous water heaters, but not appliances included in groups D and J below') ||
        (_selectedLoadType == 'G: Spa and swimming pool heaters') ||
        (_selectedLoadType == 'J: Heating and AC' &&
            _selectedLoadSubOption == 'iii) Spa and swimming pool heaters') ||
        (_selectedLoadType == 'K: Lifts') ||
        (_selectedLoadType == 'E: Lifts') ||
        (_selectedLoadType == 'L: Motors') ||
        (_selectedLoadType == 'M: Appliances');

    // If non-dialog load, recalc to ensure results current
    if (!isDialogLoad) _calculateDemand();

    String loadName = _loadNameController.text;
    if (loadName.isEmpty) {
      if (_selectedLoadType != null) {
        loadName = '${_selectedLoadType!} Load ${_loadEntries.length + 1}';
      } else {
        loadName = 'Load ${_loadEntries.length + 1}';
      }
    }

    List<String> phaseValues = List.generate(3, (i) =>
        _resultPhaseControllers[i].text);

    final entry = LoadEntry(
      name: loadName,
      subCategory: _selectedSubCategory ?? '',
      group: _selectedLoadType ?? '',
      detail: _selectedLoadSubOption ?? '',
      phase1: double.tryParse(phaseValues[0]) ?? 0.0,
      phase2: double.tryParse(phaseValues[1]) ?? 0.0,
      phase3: double.tryParse(phaseValues[2]) ?? 0.0,
    );

    setState(() {
      _loadEntries.add(entry);

      _loadNameController.clear();
      for (var controller in _phaseControllers) {
        controller.clear();
      }
      _diversityController.text = '1.0';
      _selectedInstallationType = null;
      _selectedSubCategory = null;
      _selectedBlockOption = null;
      _selectedLoadType = null;
      _selectedLoadSubOption = null;

      for (var controller in _resultPhaseControllers) {
        controller.text = '';
      }
    });
  }

  @override
  void dispose() {
    // Dispose main controllers
    _loadNameController.dispose();
    for (var controller in _phaseControllers) {
      controller.dispose();
    }
    for (var controller in _resultPhaseControllers) {
      controller.dispose();
    }
    _diversityController.dispose();

    // Dispose dialog controllers (per phase)
    for (var phaseControllers in _dialogControllers.values) {
      (phaseControllers['highest'] as TextEditingController).dispose();
      (phaseControllers['count'] as TextEditingController).dispose();
      for (var ctrl
          in phaseControllers['additional'] as List<TextEditingController>) {
        ctrl.dispose();
      }
    }

    // Dispose any controllers that might be in the spa/pool dialog lists if still present
    // (they are owned by the dialog state and disposed there, but double-check safety
    //  by not disposing them here).

    super.dispose();
  }
}

// ─────────────────────────────────────────────────────────────
// Socket exceeding 10A dialog (standalone widget)
class _SocketExceeding10ADialog extends StatefulWidget {
  const _SocketExceeding10ADialog();

  @override
  State<_SocketExceeding10ADialog> createState() =>
      _SocketExceeding10ADialogState();
}

class _SocketExceeding10ADialogState extends State<_SocketExceeding10ADialog> {
  final TextEditingController _ampsController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  List<TextEditingController> _additionalSocketControllers = [];
  double? _result;

  void _updateAdditionalSockets() {
    final qty = int.tryParse(_qtyController.text) ?? 0;
    if (qty < 0) return;
    if (qty != _additionalSocketControllers.length) {
      if (qty > _additionalSocketControllers.length) {
        for (int i = _additionalSocketControllers.length; i < qty; i++) {
          _additionalSocketControllers.add(TextEditingController());
        }
      } else {
        for (int i = _additionalSocketControllers.length - 1; i >= qty; i--) {
          _additionalSocketControllers[i].dispose();
        }
        _additionalSocketControllers = _additionalSocketControllers.sublist(
          0,
          qty,
        );
      }
      setState(() {});
    }
    _calculate();
  }

  void _calculate() {
    final amps = double.tryParse(_ampsController.text) ?? 0.0;
    double total = amps;
    for (final ctrl in _additionalSocketControllers) {
      final val = double.tryParse(ctrl.text) ?? 0.0;
      total += val * 0.5;
    }
    if (amps <= 0) {
      setState(() => _result = 0.0);
      return;
    }
    setState(() => _result = total);
  }

  @override
  void dispose() {
    _ampsController.dispose();
    _qtyController.dispose();
    for (final ctrl in _additionalSocketControllers) ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sockets Exceeding 10A'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _ampsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Highest rated Socket (A)',
              ),
              onChanged: (_) => _updateAdditionalSockets(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Additional Sockets',
              ),
              onChanged: (_) => _updateAdditionalSockets(),
            ),
            const SizedBox(height: 12),
            for (int i = 0; i < _additionalSocketControllers.length; i++) ...[
              TextField(
                controller: _additionalSocketControllers[i],
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Socket Amps ${i + 1}'),
                onChanged: (_) => _calculate(),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            if (_result != null)
              Text(
                'Total Amps: ${_result!.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_result),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
*/
/*

// ─────────────────────────────────────────────────────────────
// Spa/Pool dialog widget
class _SpaPoolDialog extends StatefulWidget {
  @override
  _SpaPoolDialogState createState() => _SpaPoolDialogState();
}

class _SpaPoolDialogState extends State<_SpaPoolDialog> {
  final _largestPoolCtrl = TextEditingController();
  final _largestSpaCtrl = TextEditingController();
  final List<TextEditingController> _additionalPoolCtrls = [];
  final List<TextEditingController> _additionalSpaCtrls = [];

  @override
  void dispose() {
    _largestPoolCtrl.dispose();
    _largestSpaCtrl.dispose();
    for (final c in _additionalPoolCtrls) c.dispose();
    for (final c in _additionalSpaCtrls) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Spa and Pool Configuration'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _largestPoolCtrl,
              decoration: const InputDecoration(
                labelText: 'Largest Pool (Amps)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _largestSpaCtrl,
              decoration: const InputDecoration(
                labelText: 'Largest Spa (Amps)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Number of Additional Pools',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final n = int.tryParse(v) ?? 0;
                setState(() {
                  while (_additionalPoolCtrls.length < n) {
                    _additionalPoolCtrls.add(TextEditingController());
                  }
                  while (_additionalPoolCtrls.length > n) {
                    _additionalPoolCtrls.removeLast().dispose();
                  }
                });
              },
            ),
            ...List.generate(
              _additionalPoolCtrls.length,
              (i) => TextField(
                controller: _additionalPoolCtrls[i],
                decoration: InputDecoration(
                  labelText: 'Additional Pool ${i + 1} (Amps)',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Number of Additional Spas',
              ),
              keyboardType: TextInputType.number,
              onChanged: (v) {
                final n = int.tryParse(v) ?? 0;
                setState(() {
                  while (_additionalSpaCtrls.length < n) {
                    _additionalSpaCtrls.add(TextEditingController());
                  }
                  while (_additionalSpaCtrls.length > n) {
                    _additionalSpaCtrls.removeLast().dispose();
                  }
                });
              },
            ),
            ...List.generate(
              _additionalSpaCtrls.length,
              (i) => TextField(
                controller: _additionalSpaCtrls[i],
                decoration: InputDecoration(
                  labelText: 'Additional Spa ${i + 1} (Amps)',
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final largestPool = double.tryParse(_largestPoolCtrl.text) ?? 0.0;
            final largestSpa = double.tryParse(_largestSpaCtrl.text) ?? 0.0;
            final additionalPools = _additionalPoolCtrls
                .map((c) => double.tryParse(c.text) ?? 0.0)
                .toList();
            final additionalSpas = _additionalSpaCtrls
                .map((c) => double.tryParse(c.text) ?? 0.0)
                .toList();

            final sumAdditionalPools = additionalPools.fold<double>(
              0.0,
              (a, b) => a + b,
            );
            final sumAdditionalSpas = additionalSpas.fold<double>(
              0.0,
              (a, b) => a + b,
            );

            final total =
                0.75 * largestPool +
                0.75 * largestSpa +
                0.25 * (sumAdditionalPools + sumAdditionalSpas);

            Navigator.pop(
              context,
              SpaPoolConfig(totalAmps: double.parse(total.toStringAsFixed(2))),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
*/

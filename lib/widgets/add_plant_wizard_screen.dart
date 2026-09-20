import 'package:flutter/material.dart';

import '../data/add_plant_wizard_analysis.dart';
import '../data/ai_settings_store.dart';
import '../data/plant_search_filters.dart';
import '../data/plant_start_flow.dart';
import '../data/vegetable_repository.dart';
import '../data/wizard_season_plan.dart';
import '../data/wizard_step5_season.dart';
import '../models/add_plant_setup_result.dart';
import '../models/add_plant_wizard_models.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/add_plant_wizard_ui.dart';
import '../widgets/clearable_search_field.dart';
import '../widgets/plant_setup_sheet_ui.dart';
import '../widgets/vegetable_thumbnail.dart';
import '../widgets/wizard_plant_scan_step.dart';

typedef AddPlantWizardResult = AddPlantSetupResult;

enum _WizardStepKind {
  path,
  plant,
  scan,
  approach,
  location,
  sun,
  season,
  overview,
}

/// Opent de volledige toevoeg-wizard (padkeuze + 4–6 vervolgstappen).
Future<AddPlantWizardResult?> showAddPlantWizard(
  BuildContext context, {
  required VegetableRepository repository,
  required AiSettingsStore aiSettings,
  Vegetable? vegetable,
  int startStep = 1,
  VoidCallback? onOpenPlantsTab,
}) {
  return Navigator.of(context).push<AddPlantWizardResult>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => AddPlantWizardScreen(
        repository: repository,
        aiSettings: aiSettings,
        initialVegetable: vegetable,
        initialStep: startStep.clamp(1, kWizardMaxSteps),
        onOpenPlantsTab: onOpenPlantsTab,
      ),
    ),
  );
}

class AddPlantWizardScreen extends StatefulWidget {
  const AddPlantWizardScreen({
    super.key,
    required this.repository,
    required this.aiSettings,
    this.initialVegetable,
    this.initialStep = 1,
    this.onOpenPlantsTab,
  });

  final VegetableRepository repository;
  final AiSettingsStore aiSettings;
  final Vegetable? initialVegetable;
  final int initialStep;
  final VoidCallback? onOpenPlantsTab;

  @override
  State<AddPlantWizardScreen> createState() => _AddPlantWizardScreenState();
}

class _AddPlantWizardScreenState extends State<AddPlantWizardScreen> {
  late final PageController _pageController;
  late int _step;
  final TextEditingController _search = TextEditingController();
  final FocusNode _step1SearchFocus = FocusNode();
  bool _step1SearchDismissed = false;
  bool _step1SearchEngaged = false;
  String? _step1PinnedSearchQuery;

  Vegetable? _vegetable;
  PlantAddIntent? _startPath;
  PlantGrowApproach? _growApproach;
  WizardInitialScan? _initialScan;
  PlantWizardCurrentPhase? _currentPhase;
  DateTime _startDate = DateTime.now();
  WizardGrowLocation? _location;
  WizardSunHours? _sun;
  WizardSeasonDecision? _seasonDecision;

  @override
  void initState() {
    super.initState();
    _vegetable = widget.initialVegetable;
    _step = widget.initialStep.clamp(1, kWizardMaxSteps);
    _pageController = PageController(initialPage: _step - 1);
    _search.addListener(() => setState(() {}));
    _step1SearchFocus.addListener(_onStep1SearchFocusChanged);
  }

  void _onStep1SearchFocusChanged() {
    if (_step1SearchFocus.hasFocus && !_step1SearchEngaged) {
      setState(() => _step1SearchEngaged = true);
    }
  }

  void _engageStep1Search() {
    if (_step1SearchEngaged) return;
    setState(() => _step1SearchEngaged = true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _step1SearchFocus.removeListener(_onStep1SearchFocusChanged);
    _step1SearchFocus.dispose();
    _search.dispose();
    super.dispose();
  }

  bool get _step1ShowNext => _vegetable != null && !_step1SearchEngaged;

  bool get _skipPlantStep =>
      widget.initialVegetable != null && _vegetable != null;

  bool get _isAlreadyHavePath => _startPath == PlantAddIntent.alreadyHave;

  List<_WizardStepKind> _activeSteps() {
    final steps = <_WizardStepKind>[];
    if (!_skipPlantStep) {
      steps.add(_WizardStepKind.plant);
    }
    if (_vegetable == null) return steps;

    steps.add(_WizardStepKind.path);
    if (_startPath == null) return steps;

    if (_isAlreadyHavePath) {
      steps.addAll(const [
        _WizardStepKind.scan,
        _WizardStepKind.location,
        _WizardStepKind.sun,
        _WizardStepKind.overview,
      ]);
    } else {
      steps.addAll(const [
        _WizardStepKind.approach,
        _WizardStepKind.location,
        _WizardStepKind.sun,
      ]);
      if (_needsSeasonStep) steps.add(_WizardStepKind.season);
      steps.add(_WizardStepKind.overview);
    }
    return steps;
  }

  _WizardStepKind get _currentKind {
    final steps = _activeSteps();
    final idx = (_step - 1).clamp(0, steps.length - 1);
    return steps[idx];
  }

  int get _wizardTotalSteps => _activeSteps().length;

  void _resetAfterPathChange(PlantAddIntent path) {
    _startPath = path;
    _growApproach = null;
    _initialScan = null;
    _currentPhase = null;
    _location = null;
    _sun = null;
    _seasonDecision = null;
  }

  void _schedulePageSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_pageController.hasClients) return;
      final index = (_step - 1).clamp(0, _wizardTotalSteps - 1);
      if (_pageController.page?.round() != index) {
        _pageController.jumpToPage(index);
      }
    });
  }

  void _selectStartPath(PlantAddIntent path) {
    setState(() => _resetAfterPathChange(path));
    _schedulePageSync();
  }

  PlantGrowApproach get _resolvedGrowApproach =>
      _growApproach ?? PlantGrowApproach.seed;

  WizardGrowLocation get _resolvedLocation =>
      _location ?? WizardGrowLocation.outdoor;

  WizardSunHours get _resolvedSun => _sun ?? WizardSunHours.normal;

  PlantStartMethod _resolvedPlantStartMethod(Vegetable veg) {
    return plantStartMethodForWizard(
      approach: _resolvedGrowApproach,
      location: _resolvedLocation,
      available: availablePlantStartMethods(veg),
    );
  }

  WizardSeasonAssessment? get _seasonAssessment {
    final veg = _vegetable;
    if (veg == null ||
        _growApproach == null ||
        _location == null ||
        _sun == null) {
      return null;
    }
    return buildWizardSeasonAssessment(
      vegetable: veg,
      approach: _growApproach!,
      location: _location!,
    );
  }

  /// Seizoensstap alleen bij buiten/balkon buiten het juiste venster.
  bool get _needsSeasonStep =>
      !_isAlreadyHavePath && (_seasonAssessment?.showWarning == true);

  void _autoProceedWhenSeasonOk() {
    final assessment = _seasonAssessment;
    if (assessment == null || assessment.showWarning) return;
    _seasonDecision = WizardSeasonDecision.proceedNow;
    _syncStartDateForFinish();
  }

  void _ensureSeasonDecision() {
    final assessment = _seasonAssessment;
    if (assessment == null || _seasonDecision != null) return;
    if (!assessment.showWarning) {
      _seasonDecision = WizardSeasonDecision.proceedNow;
    }
  }

  PlantAddIntent get _resolvedIntent {
    if (_isAlreadyHavePath) return PlantAddIntent.alreadyHave;
    return _seasonDecision == WizardSeasonDecision.waitForSeason
        ? PlantAddIntent.planForSeason
        : PlantAddIntent.startNow;
  }

  GardenPlantProfile get _previewProfile {
    final veg = _vegetable!;
    if (_isAlreadyHavePath) {
      return GardenPlantProfile(
        vegetableId: veg.id,
        plantedAt: _startDate,
        location: _resolvedLocation.gardenLocation,
        sunLevel: _resolvedSun.sunLevel,
        isPlanted: true,
        plantingDateUnknown: true,
        plantStartMethod: PlantStartMethod.plantOutdoors,
      );
    }
    final method = _resolvedPlantStartMethod(veg);
    return GardenPlantProfile(
      vegetableId: veg.id,
      plantedAt: _startDate,
      location: _resolvedLocation.gardenLocation,
      sunLevel: _resolvedSun.sunLevel,
      isPlanted: false,
      plantingDateUnknown: false,
      plantStartMethod: method,
      awaitingOutdoorPlanting: method == PlantStartMethod.preSowIndoors,
    );
  }

  PlantWizardAnalysis? get _analysis {
    final veg = _vegetable;
    if (veg == null || _location == null || _sun == null) return null;
    if (_isAlreadyHavePath) {
      return buildPlantWizardAnalysis(
        vegetable: veg,
        profile: _previewProfile,
        growApproach: null,
        location: _resolvedLocation,
        sunHours: _resolvedSun,
        intent: PlantAddIntent.alreadyHave,
        currentPhase: _currentPhase ??
            PlantWizardCurrentPhase.fromAiPhase(_initialScan?.analysis.phase),
        reference: _startDate,
        existingScanCompleted: _initialScan != null,
        scanAnalysis: _initialScan?.analysis,
      );
    }
    if (_growApproach == null) return null;
    return buildPlantWizardAnalysis(
      vegetable: veg,
      profile: _previewProfile,
      growApproach: _growApproach,
      location: _resolvedLocation,
      sunHours: _resolvedSun,
      intent: _resolvedIntent,
      reference: _startDate,
    );
  }

  String get _intentOverviewLabel => switch (_resolvedIntent) {
        PlantAddIntent.startNow => 'Nu beginnen met planten & zaaien',
        PlantAddIntent.planForSeason => 'Wachten op juiste seizoen',
        PlantAddIntent.alreadyHave => 'Ik heb deze plant al',
      };

  String get _startOverviewLabel {
    if (_resolvedIntent.waitsForSeason) {
      final veg = _vegetable;
      if (veg != null && _growApproach != null) {
        final plan = buildWizardSeasonPlan(
          vegetable: veg,
          approach: _growApproach!,
          waitsForSeason: true,
        );
        return plan.overviewDateLabel;
      }
      return 'Wacht op zaaiseizoen';
    }
    return 'Start nu';
  }

  List<_WizardOverviewChoice> _overviewChoices() {
    final choices = <_WizardOverviewChoice>[
      _WizardOverviewChoice(
        icon: _resolvedIntent.icon,
        label: 'Keuze',
        value: _intentOverviewLabel,
      ),
    ];
    if (_isAlreadyHavePath) {
      final phase = _currentPhase ??
          PlantWizardCurrentPhase.fromAiPhase(_initialScan?.analysis.phase);
      if (phase != null) {
        choices.add(
          _WizardOverviewChoice(
            icon: phase.icon,
            label: 'Fase',
            value: phase.title,
          ),
        );
      }
    } else {
      choices.add(
        _WizardOverviewChoice(
          icon: Icons.calendar_today_rounded,
          label: 'Start',
          value: _startOverviewLabel,
        ),
      );
      if (_growApproach != null) {
        choices.add(
          _WizardOverviewChoice(
            icon: _growApproach!.icon,
            label: 'Kweekmethode',
            value: _growApproach!.summaryLabel,
          ),
        );
      }
    }
    if (_location != null) {
      choices.add(
        _WizardOverviewChoice(
          icon: _location!.icon,
          label: 'Locatie',
          value: _location!.label,
        ),
      );
    }
    if (_sun != null) {
      choices.add(
        _WizardOverviewChoice(
          icon: _sun!.icon,
          label: 'Zonlicht',
          value: _sun!.summaryLabel,
        ),
      );
    }
    return choices;
  }

  bool get _canGoNext {
    if (_currentKind == _WizardStepKind.season) _ensureSeasonDecision();
    if ((_currentKind == _WizardStepKind.sun ||
            _currentKind == _WizardStepKind.overview) &&
        !_isAlreadyHavePath &&
        !_needsSeasonStep) {
      _autoProceedWhenSeasonOk();
    }
    return switch (_currentKind) {
      _WizardStepKind.path => _startPath != null,
      _WizardStepKind.plant => _vegetable != null,
      _WizardStepKind.scan => _initialScan != null,
      _WizardStepKind.approach => _growApproach != null,
      _WizardStepKind.location => _location != null,
      _WizardStepKind.sun => _sun != null,
      _WizardStepKind.season => _seasonDecision != null,
      _WizardStepKind.overview =>
        _analysis != null && (_isAlreadyHavePath || _seasonDecision != null),
    };
  }

  void _goToStep(int step) {
    final steps = _activeSteps();
    final target = step.clamp(1, steps.length);
    final targetKind = steps[target - 1];
    setState(() {
      _step = target;
      if (targetKind.index <= _WizardStepKind.sun.index) {
        _seasonDecision = null;
      } else if (targetKind == _WizardStepKind.overview &&
          !_isAlreadyHavePath &&
          !_needsSeasonStep) {
        _autoProceedWhenSeasonOk();
      }
    });
    final pageIndex = (target - 1).clamp(0, steps.length - 1);
    if (_pageController.hasClients) {
      _pageController.jumpToPage(pageIndex);
    } else {
      _schedulePageSync();
    }
  }

  void _syncStartDateForFinish() {
    final veg = _vegetable;
    final approach = _growApproach;
    if (veg == null || approach == null) return;
    if (_seasonDecision == WizardSeasonDecision.waitForSeason) {
      final plan = seasonPlanForWizardWait(
        vegetable: veg,
        approach: approach,
      );
      _startDate = plan.startDate;
    } else {
      _startDate = DateTime.now();
    }
  }

  void _onBack() {
    if (_step <= 1) return;
    _goToStep(_step - 1);
  }

  void _onNext() {
    if (!_canGoNext) return;
    if (_currentKind == _WizardStepKind.sun &&
        !_isAlreadyHavePath &&
        !_needsSeasonStep) {
      _autoProceedWhenSeasonOk();
    } else if (_currentKind == _WizardStepKind.season) {
      _syncStartDateForFinish();
    }
    if (_step >= _wizardTotalSteps) {
      _finish();
      return;
    }
    _goToStep(_step + 1);
  }

  void _finish() {
    if (!_canGoNext) return;
    _syncStartDateForFinish();
    final veg = _vegetable;
    final location = _location;
    final sun = _sun;
    if (veg == null || location == null || sun == null) return;

    if (_isAlreadyHavePath) {
      final phase = _currentPhase ??
          PlantWizardCurrentPhase.fromAiPhase(_initialScan?.analysis.phase);
      final result = AddPlantSetupResult(
        vegetableId: veg.id,
        plantedAt: _startDate,
        location: location.gardenLocation,
        sunLevel: sun.sunLevel,
        intent: PlantAddIntent.alreadyHave,
        isPlanted: true,
        plantingDateUnknown: true,
        plantStartMethod: PlantStartMethod.plantOutdoors,
        growApproach: PlantGrowApproach.adult,
        currentPhase: phase,
        initialScan: _initialScan,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pop(context, result);
      });
      return;
    }

    final approach = _growApproach;
    if (approach == null || _seasonDecision == null) return;
    final method = _resolvedPlantStartMethod(veg);
    final result = AddPlantSetupResult(
      vegetableId: veg.id,
      plantedAt: _startDate,
      location: location.gardenLocation,
      sunLevel: sun.sunLevel,
      intent: _resolvedIntent,
      isPlanted: false,
      plantingDateUnknown: false,
      plantStartMethod: method,
      growApproach: approach,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.pop(context, result);
    });
  }

  String get _step1EffectiveSearchQuery {
    if (_step1SearchDismissed && _step1PinnedSearchQuery != null) {
      return _step1PinnedSearchQuery!;
    }
    return _search.text.trim();
  }

  List<Vegetable> get _step1Plants {
    final query = _step1EffectiveSearchQuery;
    if (query.isNotEmpty) {
      return searchFilteredPlants(
        repository: widget.repository,
        criteria: const PlantSearchCriteria(),
        searchQuery: query,
      );
    }
    return widget.repository.all;
  }

  String get _step1SectionTitle {
    final query = _step1EffectiveSearchQuery;
    if (query.isNotEmpty) return 'Resultaten';
    return 'Alle planten';
  }

  @override
  Widget build(BuildContext context) {
    final showBack = _step > 1;
    final showNext =
        _currentKind != _WizardStepKind.plant || _step1ShowNext;
    final nextLabel = _currentKind == _WizardStepKind.overview
        ? 'Toevoegen'
        : 'Volgende';
    return Scaffold(
      backgroundColor: TuinierColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 4, 0),
              child: WizardProgressHeader(
                step: _step,
                totalSteps: _wizardTotalSteps,
                onClose: () => Navigator.maybePop(context),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _wizardTotalSteps,
                itemBuilder: (context, index) {
                  return switch (_activeSteps()[index]) {
                    _WizardStepKind.path => _buildStepPath(),
                    _WizardStepKind.plant => _buildStep1(),
                    _WizardStepKind.scan => _buildStepScan(),
                    _WizardStepKind.approach => _buildStep2Approach(),
                    _WizardStepKind.location => _buildStep3Location(),
                    _WizardStepKind.sun => _buildStep4Sun(),
                    _WizardStepKind.season => _buildStep5Season(),
                    _WizardStepKind.overview => _buildStep6Overview(),
                  };
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: WizardNavBar(
                showBack: showBack,
                onBack: showBack ? _onBack : null,
                onNext: _onNext,
                nextLabel: nextLabel,
                nextEnabled: _canGoNext,
                showNext: showNext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepPath() {
    final plantName = _vegetable?.nameNl;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      children: [
        WizardStepTitle(
          title: 'Hoe start je?',
          subtitle: plantName != null
              ? 'Wat is de situatie met je $plantName?'
              : 'Heb je deze plant al staan of ga je net beginnen met kweken?',
        ),
        const SizedBox(height: 20),
        WizardSelectCard(
          title: PlantAddIntent.alreadyHave.title,
          subtitle: PlantAddIntent.alreadyHave.subtitle,
          icon: PlantAddIntent.alreadyHave.icon,
          selected: _startPath == PlantAddIntent.alreadyHave,
          onTap: () => _selectStartPath(PlantAddIntent.alreadyHave),
        ),
        const SizedBox(height: 12),
        WizardSelectCard(
          title: 'Ik wil net beginnen met kweken',
          subtitle:
              'Je hebt nog geen plant of zaad gezet. Je krijgt een stappenplan om te starten — zonder scan.',
          icon: PlantAddIntent.startNow.icon,
          selected: _startPath == PlantAddIntent.startNow,
          onTap: () => _selectStartPath(PlantAddIntent.startNow),
        ),
      ],
    );
  }

  Widget _buildStepScan() {
    final veg = _vegetable;
    if (veg == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return WizardPlantScanStep(
      vegetable: veg,
      previewProfile: _previewProfile,
      aiSettings: widget.aiSettings,
      initialScan: _initialScan,
      onWizardContinue: _advanceFromScanResult,
      onScanReady: (scan) => setState(() {
        _initialScan = scan;
        _currentPhase =
            PlantWizardCurrentPhase.fromAiPhase(scan?.analysis.phase);
      }),
    );
  }

  void _advanceFromScanResult() {
    if (_initialScan == null) return;
    if (_step >= _wizardTotalSteps) {
      _finish();
      return;
    }
    _goToStep(_step + 1);
  }

  Widget _buildStep1() {
    final query = _step1EffectiveSearchQuery;
    final results = _step1Plants;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      children: [
        const WizardStepTitle(
          title: 'Wat wil je toevoegen?',
          subtitle: 'Begin met het kiezen van een plant, of zoek in de Planten-tab.',
        ),
        if (widget.onOpenPlantsTab != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: widget.onOpenPlantsTab,
            icon: const Icon(Icons.local_florist_outlined),
            label: const Text('Alle planten bekijken'),
          ),
        ],
        const SizedBox(height: 16),
        if (!_step1SearchDismissed) ...[
          ClearableSearchField(
            controller: _search,
            focusNode: _step1SearchFocus,
            hintText: 'Zoek een plant...',
            onTap: _engageStep1Search,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          _step1SectionTitle,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        if (query.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            _step1SearchDismissed
                ? 'Voor «$query» · ${results.length} '
                    '${results.length == 1 ? 'plant' : 'planten'}'
                : '${results.length} planten. Scroll om meer te zien',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ] else if (results.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            '${results.length} planten. Scroll om meer te zien',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
        const SizedBox(height: 10),
        ...results.map((v) => _PlantPickRow(
              vegetable: v,
              selected: _vegetable?.id == v.id,
              onTap: () => setState(() {
                final wasSearching = _search.text.trim().isNotEmpty;
                _vegetable = v;
                _startPath = null;
                _growApproach = null;
                _initialScan = null;
                _currentPhase = null;
                _location = null;
                _sun = null;
                _seasonDecision = null;
                _step1SearchEngaged = false;
                _step1SearchFocus.unfocus();
                if (wasSearching) {
                  _step1PinnedSearchQuery = _search.text.trim();
                  _step1SearchDismissed = true;
                }
              }),
            )),
      ],
    );
  }

  Widget _buildStep2Approach() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      children: [
        const WizardStepTitle(
          title: 'Hoe ga je deze plant kweken?',
          subtitle:
              'Kies of je start met zaad, een zaailing of een volwassen plant.',
        ),
        const SizedBox(height: 20),
        for (final approach in PlantGrowApproach.values) ...[
          WizardSelectCard(
            title: approach.title,
            subtitle: approach.subtitle,
            icon: approach.icon,
            selected: _growApproach == approach,
            onTap: () => setState(() {
              _growApproach = approach;
              _seasonDecision = null;
            }),
          ),
          if (approach != PlantGrowApproach.adult) const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildStep3Location() {
    final existingPlant = _isAlreadyHavePath;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      children: [
        WizardStepTitle(
          title: existingPlant
              ? 'Waar staat je plant?'
              : 'Waar wil je de plant of het zaad plaatsen?',
          subtitle: existingPlant
              ? 'Kies waar je plant nu groeit — binnen, kas of buiten.'
              : 'Kies de plek waar je start — binnen, kas of buiten.',
        ),
        const SizedBox(height: 20),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.15,
          children: WizardGrowLocation.values
              .where((loc) => loc != WizardGrowLocation.shed)
              .map((loc) {
            return WizardGridOption(
              label: loc.label,
              icon: loc.icon,
              selected: _location == loc,
              onTap: () => setState(() {
                _location = loc;
                _seasonDecision = null;
              }),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStep4Sun() {
    final existingPlant = _isAlreadyHavePath;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      children: [
        WizardStepTitle(
          title: existingPlant
              ? 'Hoeveel zon krijgt je plant?'
              : 'Hoeveel zon krijgt de plant?',
          subtitle: existingPlant
              ? 'Kies hoeveel zon op de plek waar je plant nu staat.'
              : 'Kies hoeveel zon je plant krijgt, zodat we je daar goed mee kunnen helpen.',
        ),
        const SizedBox(height: 20),
        for (final option in WizardSunHours.values) ...[
          WizardListOption(
            label: option.label,
            icon: option.icon,
            selected: _sun == option,
            onTap: () => setState(() {
              _sun = option;
              _seasonDecision = null;
            }),
          ),
          if (option != WizardSunHours.unknown) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildStep5Season() {
    final veg = _vegetable;
    final approach = _growApproach;
    final location = _location;
    if (veg == null ||
        approach == null ||
        location == null ||
        _sun == null ||
        _seasonAssessment == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final assessment = _seasonAssessment!;
    final t = Theme.of(context);
    final accent = assessment.showWarning
        ? TuinierColors.warning
        : TuinierColors.primary;
    final headingStyle = t.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
      color: TuinierColors.textPrimary,
    );
    final daysLine = assessment.daysHighlight ??
        _wizardSeasonDaysFallback(assessment.daysUntilIdealSeason);
    final showTipDays = assessment.proceedTipDaysLabel != null &&
        assessment.proceedTipDaysLabel != daysLine;

    final proceedTitle = assessment.showWarning
        ? (approach == PlantGrowApproach.seed
            ? (isWizardLocationColdExposed(location)
                ? 'Toch buiten zaaien'
                : 'Toch nu starten')
            : 'Toch buiten planten')
        : 'Nu toevoegen en starten';

    const waitTitle = 'Wachten op juiste seizoen';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      children: [
        const WizardStepTitle(
          title: 'Informatie over het seizoen',
          subtitle:
              'Op basis van je keuzes zie je hoe het seizoen er nu voor staat.',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.28)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              VegetableThumbnail(
                vegetable: veg,
                size: 56,
                borderRadius: 12,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment.headline,
                      style: headingStyle,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assessment.explanation,
                      style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                    if (daysLine != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        daysLine,
                        style: t.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: TuinierColors.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (assessment.showWarning &&
                        assessment.alternativeTip.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Tip om toch door te gaan',
                        style: headingStyle,
                      ),
                      if (showTipDays) ...[
                        const SizedBox(height: 6),
                        Text(
                          assessment.proceedTipDaysLabel!,
                          style: t.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: TuinierColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        assessment.alternativeTip,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: t.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ] else if (assessment.alternativeTip.isNotEmpty &&
                        !assessment.showWarning) ...[
                      const SizedBox(height: 10),
                      Text(
                        assessment.alternativeTip,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: t.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (assessment.showWarning) ...[
          const SizedBox(height: 20),
          Text(
            'Wat wil je doen?',
            style: headingStyle,
          ),
          const SizedBox(height: 12),
          WizardSelectCard(
            title: proceedTitle,
            subtitle:
                'Je start nu, maar de slagingskans is lager buiten het juiste seizoen.',
            icon: Icons.warning_amber_rounded,
            selected: _seasonDecision == WizardSeasonDecision.proceedNow,
            onTap: () => setState(
              () => _seasonDecision = WizardSeasonDecision.proceedNow,
            ),
          ),
          const SizedBox(height: 12),
          WizardSelectCard(
            title: waitTitle,
            subtitle: _wizardWaitSeasonSubtitle(assessment),
            icon: Icons.event_available_rounded,
            selected: _seasonDecision == WizardSeasonDecision.waitForSeason,
            onTap: () => setState(
              () => _seasonDecision = WizardSeasonDecision.waitForSeason,
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          Text(
            'Je kunt op Volgende tikken om je keuzes te bekijken.',
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }

  String? _wizardSeasonDaysFallback(int? days) {
    if (days == null) return null;
    if (days == 0) return 'Het seizoen kan nu beginnen';
    if (days == 1) return 'Het seizoen begint over 1 dag';
    return 'Het seizoen begint over $days dagen';
  }

  String _wizardWaitSeasonSubtitle(WizardSeasonAssessment assessment) {
    final days = assessment.daysUntilIdealSeason;
    if (days != null && days > 0) {
      final timing = days == 1 ? 'Nog 1 dag' : 'Nog $days dagen';
      return '$timing tot het seizoen. Je krijgt een melding wanneer je '
          'kunt starten in de moestuin.';
    }
    return 'Je krijgt een melding wanneer je kunt starten in de moestuin.';
  }

  Widget _buildStep6Overview() {
    final veg = _vegetable;
    final analysis = _analysis;
    if (veg == null || analysis == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final t = Theme.of(context);
    final pageTitleStyle = t.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.w700,
      height: 1.15,
    );
    final sectionHeadingStyle = t.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final cardHeadingStyle = t.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final choices = _overviewChoices();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      children: [
        WizardStepTitle(
          title: 'Overzicht',
          subtitle: 'Controleer je keuzes voordat je de plant toevoegt.',
          titleStyle: pageTitleStyle,
          centerTitle: true,
        ),
        const SizedBox(height: 16),
        _WizardOverviewPlantHeader(
          vegetable: veg,
          choices: choices,
        ),
        const Divider(height: 32),
        _buildWizardAnalyseAndBeginTipsSection(
          analysis: analysis,
          sectionHeadingStyle: sectionHeadingStyle,
          cardHeadingStyle: cardHeadingStyle,
        ),
        const SizedBox(height: 10),
        _buildWizardAiTrackingCard(
          analysis: analysis,
          cardHeadingStyle: cardHeadingStyle,
        ),
        if (analysis.existingPlantContext != null) ...[
          const SizedBox(height: 10),
          PlantSetupSurfaceCard(
            child: WizardInfoRow(
              icon: Icons.document_scanner_outlined,
              title: analysis.existingPlantContext!.seasonStatusLabel,
              body: [
                analysis.existingPlantContext!.seasonDetail,
                analysis.existingPlantContext!.scanGuidance,
                analysis.existingPlantContext!.fruitRecoveryNote,
              ].join('\n\n'),
              tone: WizardInfoTone.tip,
              titleStyle: cardHeadingStyle,
            ),
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildWizardAnalyseAndBeginTipsSection({
    required PlantWizardAnalysis analysis,
    required TextStyle? sectionHeadingStyle,
    required TextStyle? cardHeadingStyle,
  }) {
    final firstSteps = analysis.firstSteps;
    final offSeason = firstSteps.offSeason;
    final harvest = _harvestPeriodLabel(analysis);
    final t = Theme.of(context);
    final bodyStyle = t.textTheme.bodyMedium?.copyWith(
      height: 1.4,
      color: TuinierColors.textPrimary,
    );
    final subtitleStyle = t.textTheme.bodyMedium?.copyWith(
      color: t.colorScheme.onSurfaceVariant,
      height: 1.35,
    );
    final detailStyle = t.textTheme.bodyMedium?.copyWith(
      color: t.colorScheme.onSurfaceVariant,
      height: 1.35,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlantSetupSectionLabel(
          'Analyse & Tips om te beginnen',
          style: sectionHeadingStyle,
        ),
        const SizedBox(height: 4),
        Text(
          'Deze acties helpen je om direct goed van start te gaan.',
          style: subtitleStyle,
        ),
        const SizedBox(height: 10),
        if (offSeason != null && !_isAlreadyHavePath) ...[
          PlantSetupSurfaceCard(
            child: WizardInfoRow(
              icon: Icons.thermostat_rounded,
              title: 'Buiten seizoen',
              body: [
                offSeason.body,
                offSeason.extraTips.map((tip) => '• $tip').join('\n'),
              ].join('\n\n'),
              tone: WizardInfoTone.warning,
              titleStyle: cardHeadingStyle,
            ),
          ),
          const SizedBox(height: 10),
        ],
        PlantSetupSurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: WizardSuccessRing(
                  percent: analysis.successPercent,
                  caption: 'Slagingskans',
                  detail: _wizardSuccessSummary(analysis, harvest),
                  ringSize: 108,
                  stacked: true,
                  captionColor: TuinierColors.primary,
                  captionStyle: cardHeadingStyle?.copyWith(
                    color: TuinierColors.primary,
                  ),
                  detailStyle: detailStyle,
                ),
              ),
              if (firstSteps.steps.isNotEmpty) ...[
                const SizedBox(height: 16),
                Divider(color: TuinierColors.border.withValues(alpha: 0.8)),
                const SizedBox(height: 14),
                Text(
                  'Eerste stappen voor jouw situatie',
                  style: cardHeadingStyle,
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < firstSteps.steps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: TuinierColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: t.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: TuinierColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            firstSteps.steps[i],
                            style: bodyStyle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _wizardSuccessSummary(
    PlantWizardAnalysis analysis,
    String? harvest,
  ) {
    final lines = <String>[
      '${analysis.successPercent}% kans op een goede oogst.',
    ];
    if (harvest != null) {
      lines.add('Oogstperiode: $harvest');
    }
    return lines.join('\n');
  }

  String? _harvestPeriodLabel(PlantWizardAnalysis analysis) {
    final detail = analysis.harvestDetail.trim();
    if (detail.isNotEmpty) return detail;
    final window = analysis.harvestWindow.trim();
    if (window.isEmpty || window == 'Volgt na start') return null;
    return window;
  }

  Widget _buildWizardAiTrackingCard({
    required PlantWizardAnalysis analysis,
    required TextStyle? cardHeadingStyle,
  }) {
    const aiTracks = [
      'Groei & ontwikkeling volgen',
      'Oogst voorspellen',
      'Gezondheid & problemen herkennen',
      'Weer & omgeving analyseren',
      'Persoonlijke tips & taken',
    ];

    final harvest = _harvestPeriodLabel(analysis);
    final waitsForSeason = _resolvedIntent.waitsForSeason;
    final isExisting = _isAlreadyHavePath;

    final intro = isExisting
        ? 'Je plant staat al in je moestuin. De eerste scan is gedaan — de AI '
            'houdt nu je groei bij en kijkt of je plant op schema loopt voor '
            'dit seizoen.'
        : waitsForSeason
            ? 'Je wacht op het juiste seizoen om te starten. Zodra het '
                'seizoen begint kun je zaaien of planten. Daarna maak je '
                'je eerste AI-scan.'
            : 'Na toevoegen start je met kweken. Zodra je plant groeit '
                'maak je je eerste scan met de AI-scanner. Nieuwe groeitips '
                'krijg je telkens wanneer je je plant scant met de AI.';

    final action = isExisting
        ? 'Tik op Toevoegen om je plant te bewaren. Scan regelmatig opnieuw '
            'voor persoonlijke taken en oogstadvies.'
        : waitsForSeason
            ? 'Tik op Toevoegen om te plannen. Je plant komt op niet-actief '
                'te staan tot het seizoen begint. Je krijgt dan een melding. '
                'Je eerste scan maak je zodra je bent begonnen met zaaien of '
                'planten.'
            : 'Tik op Toevoegen en start met kweken. Maak daarna je eerste '
                'scan zodra je plant in de grond staat.';

    final t = Theme.of(context);
    final bodyStyle = t.textTheme.bodySmall?.copyWith(height: 1.4);
    final labelStyle = t.textTheme.labelLarge?.copyWith(
      fontWeight: FontWeight.w700,
    );

    return PlantSetupSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.auto_awesome,
                color: TuinierColors.primary,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Zo houdt de AI je plant bij',
                  style: cardHeadingStyle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(intro, style: bodyStyle),
          if (harvest != null) ...[
            const SizedBox(height: 12),
            Text('Oogstperiode', style: labelStyle),
            const SizedBox(height: 4),
            Text(harvest, style: bodyStyle),
          ],
          const SizedBox(height: 12),
          Text('De AI houdt bij', style: labelStyle),
          const SizedBox(height: 6),
          ...aiTracks.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: TuinierColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item, style: bodyStyle)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text('Wat je nu kunt doen', style: labelStyle),
          const SizedBox(height: 4),
          Text(action, style: bodyStyle),
        ],
      ),
    );
  }
}

class _WizardOverviewChoice {
  const _WizardOverviewChoice({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _WizardOverviewPlantHeader extends StatelessWidget {
  const _WizardOverviewPlantHeader({
    required this.vegetable,
    required this.choices,
  });

  final Vegetable vegetable;
  final List<_WizardOverviewChoice> choices;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Column(
            children: [
              VegetableThumbnail(
                vegetable: vegetable,
                size: 96,
                borderRadius: 14,
              ),
              const SizedBox(height: 8),
              Text(
                vegetable.nameNl,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < choices.length; i++) ...[
                _WizardOverviewMetaLine(
                  icon: choices[i].icon,
                  text: '${choices[i].label}: ${choices[i].value}',
                ),
                if (i < choices.length - 1) const SizedBox(height: 4),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WizardOverviewMetaLine extends StatelessWidget {
  const _WizardOverviewMetaLine({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: t.colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlantPickRow extends StatelessWidget {
  const _PlantPickRow({
    required this.vegetable,
    required this.selected,
    required this.onTap,
  });

  final Vegetable vegetable;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? TuinierColors.scanHover : TuinierColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: selected ? TuinierColors.primary : TuinierColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                VegetableThumbnail(vegetable: vegetable, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vegetable.nameNl,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: selected
                      ? TuinierColors.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/garden_planner_task_store.dart';
import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../data/plant_planner_spacing.dart';
import '../data/plant_season_activation.dart';
import '../data/planting_season_status.dart';
import '../data/vegetable_repository.dart';
import '../data/visual_garden_bed_colors.dart';
import '../data/visual_garden_crop_tasks.dart';
import '../data/visual_garden_geometry.dart';
import '../data/visual_garden_plan_store.dart';
import '../data/visual_garden_smart_plan.dart';
import '../models/add_plant_wizard_models.dart';
import '../models/garden_planner_task.dart';
import '../models/vegetable.dart';
import '../models/visual_garden_plan.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/visual_garden_apply_bed_sheet.dart';
import '../widgets/visual_garden_bed_canvas.dart';
import '../widgets/visual_garden_bed_setup_sheet.dart';
import '../widgets/visual_garden_crop_plans_section.dart';
import '../widgets/visual_garden_dimension_frame.dart';
import '../widgets/visual_garden_next_crop_sheet.dart';
import '../widgets/visual_garden_plant_picker_sheet.dart';

/// Visuele moestuinplanner V1: bakken met hoeken/maten, planten plaatsen.
class MoestuinVisualPlannerScreen extends StatefulWidget {
  const MoestuinVisualPlannerScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    this.taskStore,
    this.store,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenPlannerTaskStore? taskStore;
  final VisualGardenPlanStore? store;

  @override
  State<MoestuinVisualPlannerScreen> createState() =>
      _MoestuinVisualPlannerScreenState();
}

class _MoestuinVisualPlannerScreenState
    extends State<MoestuinVisualPlannerScreen> {
  late final VisualGardenPlanStore _store;
  Vegetable? _pendingPlant;
  String? _selectedPlacementId;
  final List<VisualGardenPlan> _undoStack = [];
  /// Blokkeert ListView-scroll tijdens plant-sleep (zonder setState-vertraging).
  final ValueNotifier<bool> _plantDragLock = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    if (widget.store != null) {
      _store = widget.store!;
      if (!_store.isLoaded) {
        _store.load();
      }
    } else {
      _store = VisualGardenPlanStore();
      _store.load();
    }
    _store.addListener(_onStore);
  }

  @override
  void dispose() {
    _plantDragLock.dispose();
    _store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    if (mounted) setState(() {});
  }

  void _pushUndo() {
    final p = _store.plan;
    if (p == null) return;
    _undoStack.add(
      VisualGardenPlan.fromJson(p.toJson()),
    );
    if (_undoStack.length > 20) _undoStack.removeAt(0);
  }

  Future<void> _undo() async {
    if (_undoStack.isEmpty) return;
    final prev = _undoStack.removeLast();
    await _store.replacePlan(prev);
    setState(() {
      _pendingPlant = null;
      _selectedPlacementId = null;
    });
  }

  Future<void> _createBed() async {
    final n = (_store.plan?.beds.length ?? 0) + 1;
    final result = await showVisualGardenBedSetupSheet(
      context: context,
      suggestedName: 'Moestuinbak $n',
    );
    if (result == null || !mounted) return;

    _pushUndo();
    await _store.addBed(
      VisualGardenBed(
        id: 'bed_${DateTime.now().millisecondsSinceEpoch}',
        name: result.name,
        verticesCm: result.verticesCm,
        wallHeightCm: result.wallHeightCm,
        borderColorValue: result.borderColorValue,
        fillColorValue: result.fillColorValue,
      ),
    );
  }

  Future<void> _addPlant([VisualGardenBed? forBed]) async {
    final bed = forBed ?? _store.selectedBed;
    if (bed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecteer eerst een plantenbak')),
      );
      return;
    }
    _store.selectBed(bed.id);
    final companionIds = [
      for (final p in bed.placements) p.plantId,
    ];
    // Vorig teeltplan (met planten) → filter “na oogst van…” in de kiezer.
    VisualCropPlan? previousPlan;
    final sorted = bed.cropPlansSorted;
    final active = bed.activeCropPlan;
    if (active != null && sorted.length > 1) {
      final i = sorted.indexWhere((p) => p.id == active.id);
      if (i > 0) {
        final prev = sorted[i - 1];
        if (prev.placements.isNotEmpty) previousPlan = prev;
      }
    }
    final outcome = await showVisualGardenPlantPicker(
      context: context,
      repository: widget.repository,
      gardenStore: widget.gardenStore,
      companionSeedIds: companionIds,
      previousCropPlan: previousPlan,
    );
    if (outcome == null || !mounted) return;
    if (outcome.requestSmartPlan) {
      await _runSmartPlan(bed);
      return;
    }
    final plant = outcome.plant;
    if (plant == null) return;
    setState(() {
      _pendingPlant = plant;
      _selectedPlacementId = null;
    });
  }

  Future<void> _runSmartPlan(VisualGardenBed bed) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Slim tuinplan'),
        content: Text(
          'We vullen “${bed.name}” automatisch met passende planten '
          '(combinaties, seizoen en plantafstand). '
          'Bestaande planten blijven staan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2F6B32),
            ),
            child: const Text('Vul bak'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    final latest = _store.selectedBed ?? bed;

    final result = buildSmartGardenPlan(
      bed: latest,
      repository: widget.repository,
    );

    if (result.placements.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geen geschikte planten gevonden voor deze bak'),
        ),
      );
      return;
    }

    _pushUndo();
    for (final p in result.placements) {
      await _store.upsertPlacement(
        latest.id,
        PlantPlacement(
          id:
              'smart_${p.plant.id}_${DateTime.now().microsecondsSinceEpoch}_${p.xCm.toInt()}_${p.yCm.toInt()}',
          plantId: p.plant.id,
          xCm: p.xCm,
          yCm: p.yCm,
          spacingCm: p.spacingCm,
        ),
      );
    }
    if (!mounted) return;
    setState(() {
      _pendingPlant = null;
      _selectedPlacementId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${result.placements.length} planten geplaatst in ${latest.name}',
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    final active = (_store.selectedBed ?? latest).activeCropPlan;
    if (active != null &&
        active.placements.isNotEmpty &&
        widget.taskStore != null) {
      await generateTasksForCropPlan(
        taskStore: widget.taskStore!,
        repository: widget.repository,
        bed: _store.selectedBed ?? latest,
        plan: active,
      );
    }

    final wantSuccession = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Plan voor na de oogst?'),
        content: const Text(
          'Wil je een voorstel voor planten die je na de eerste oogst '
          'kunt zaaien of planten?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Nee'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2F6B32),
            ),
            child: const Text('Ja, toon plan'),
          ),
        ],
      ),
    );
    if (wantSuccession == true && mounted) {
      await showSuccessionPlanSheet(
        context: context,
        plants: result.successionPlants,
        bedName: latest.name,
      );
    }
  }

  Future<void> _openCropPlan(VisualGardenBed bed, VisualCropPlan plan) async {
    await _store.setActiveCropPlan(bed.id, plan.id);
    if (!mounted) return;
    setState(() {
      _pendingPlant = null;
      _selectedPlacementId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Teeltplan “${plan.name}” is actief'),
        duration: const Duration(seconds: 2),
      ),
    );
    if (plan.placements.isNotEmpty && widget.taskStore != null) {
      final n = await generateTasksForCropPlan(
        taskStore: widget.taskStore!,
        repository: widget.repository,
        bed: bed,
        plan: plan,
      );
      if (n > 0 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$n planner-taken bijgewerkt')),
        );
      }
    }
  }

  Future<void> _addCropPlan(
    VisualGardenBed bed, {
    List<PlantPlacement> seedPlacements = const [],
  }) async {
    final sorted = bed.cropPlansSorted;
    final after = sorted.isEmpty ? null : sorted.last;
    final plan = await showCreateCropPlanDialog(
      context: context,
      afterPlan: after,
      planNumber: bed.cropPlans.length + 1,
    );
    if (plan == null || !mounted) return;
    final withSeeds = seedPlacements.isEmpty
        ? plan
        : plan.copyWith(
            placements: [
              for (final p in seedPlacements)
                PlantPlacement(
                  id: 'pl_${DateTime.now().microsecondsSinceEpoch}_${p.plantId}_${p.xCm.toInt()}_${p.yCm.toInt()}',
                  plantId: p.plantId,
                  xCm: p.xCm,
                  yCm: p.yCm,
                  spacingCm: p.spacingCm,
                  createdAt: DateTime.now(),
                ),
            ],
          );
    _pushUndo();
    await _store.addCropPlan(bed.id, withSeeds);
    if (!mounted) return;
    setState(() {
      _pendingPlant = null;
      _selectedPlacementId = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          seedPlacements.isEmpty
              ? '“${withSeeds.name}” toegevoegd — plaats planten in deze lege bak.'
              : '“${withSeeds.name}” toegevoegd met ${seedPlacements.length} '
                  'voorgestelde plant${seedPlacements.length == 1 ? '' : 'en'}.',
        ),
      ),
    );
  }

  Future<void> _deleteCropPlan(
    VisualGardenBed bed,
    VisualCropPlan plan,
  ) async {
    if (bed.cropPlans.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Je hebt minstens één teeltplan nodig')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Teeltplan verwijderen?'),
        content: Text(
          '“${plan.name}” en de planten daarin verdwijnen uit dit plan. '
          'De bak zelf blijft bestaan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: TuinierColors.error),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    _pushUndo();
    await _store.removeCropPlan(bed.id, plan.id);
  }

  Future<void> _suggestNextCrop(VisualGardenBed bed) async {
    final sorted = bed.cropPlansSorted;
    if (sorted.isEmpty) {
      await _addCropPlan(bed);
      return;
    }
    // Eerste / actieve teeltplan: opvolgers met zelfde of kleinere plantzone.
    final previous = sorted.first;
    final result = await showNextCropSheet(
      context: context,
      bed: bed,
      previous: previous,
      repository: widget.repository,
    );
    if (result == null || !result.createPlan || !mounted) return;
    await _addCropPlan(bed, seedPlacements: result.seedPlacements);
  }

  Future<void> _editBed(VisualGardenBed bed) async {
    final result = await showVisualGardenBedSetupSheet(
      context: context,
      existing: bed,
    );
    if (result == null || !mounted) return;

    _pushUndo();
    final updated = bed.copyWith(
      name: result.name,
      verticesCm: result.verticesCm,
      wallHeightCm: result.wallHeightCm,
      borderColorValue: result.borderColorValue,
      fillColorValue: result.fillColorValue,
    );

    var invalid = 0;
    for (final p in updated.placements) {
      final spacing = _spacingForPlant(p.plantId, p.spacingCm);
      final ok = plantFullyInsideBed(
        bed: updated,
        xCm: p.xCm,
        yCm: p.yCm,
        spacingCm: spacing,
      );
      if (!ok) invalid++;
    }
    await _store.updateBed(updated);
    if (!mounted) return;
    if (invalid > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$invalid plant${invalid == 1 ? '' : 'en'} passen niet meer '
            'binnen de nieuwe afmetingen.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmClearPlacements(VisualGardenBed bed) async {
    final count = bed.placements.length;
    if (count == 0) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Alle planten wissen?'),
        content: Text(
          count == 1
              ? 'De plant in “${bed.name}” wordt uit dit teeltplan verwijderd.'
              : 'Alle $count planten in “${bed.name}” worden uit dit '
                  'teeltplan verwijderd.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: TuinierColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Wissen'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _pushUndo();
      await _store.clearPlacements(bed.id);
      if (!mounted) return;
      setState(() {
        _selectedPlacementId = null;
        _pendingPlant = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count == 1
                ? 'Plant gewist uit “${bed.name}”.'
                : '$count planten gewist uit “${bed.name}”.',
          ),
        ),
      );
    }
  }

  Future<void> _confirmDeleteBed(VisualGardenBed bed) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bak verwijderen?'),
        content: Text(
          '“${bed.name}” en alle planten erin worden verwijderd.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: TuinierColors.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      _pushUndo();
      await _store.removeBed(bed.id);
      setState(() {
        if (_pendingPlant != null && _store.selectedBedId != bed.id) {
          // pending blijft alleen als er nog een bak geselecteerd is
        }
        if (_store.selectedBed == null) {
          _pendingPlant = null;
          _selectedPlacementId = null;
        }
      });
    }
  }

  Future<void> _bedMenu(VisualGardenBed bed) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Naam & afmetingen wijzigen'),
              onTap: () => Navigator.pop(ctx, 'edit'),
            ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Plant toevoegen aan tuin'),
              onTap: () => Navigator.pop(ctx, 'plant'),
            ),
            ListTile(
              leading: const Icon(Icons.auto_awesome),
              title: const Text('Slim tuinplan'),
              subtitle: const Text('Vul de bak automatisch'),
              onTap: () => Navigator.pop(ctx, 'smart'),
            ),
            if (bed.placements.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.yard_outlined),
                title: const Text('Selectie opslaan in moestuin'),
                subtitle: const Text(
                  'Planten volgen hun zaai-/plantseizoen',
                ),
                onTap: () => Navigator.pop(ctx, 'apply'),
              ),
            if (bed.placements.isNotEmpty)
              ListTile(
                leading: const Icon(
                  Icons.delete_sweep_outlined,
                  color: TuinierColors.error,
                ),
                title: const Text('Alle planten wissen'),
                subtitle: Text(
                  '${bed.placements.length} plant'
                  '${bed.placements.length == 1 ? '' : 'en'} '
                  'uit dit teeltplan',
                ),
                onTap: () => Navigator.pop(ctx, 'clear'),
              ),
            ListTile(
              leading: const Icon(Icons.copy_outlined),
              title: const Text('Dupliceren'),
              onTap: () => Navigator.pop(ctx, 'dup'),
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: TuinierColors.error),
              title: const Text('Bak verwijderen'),
              onTap: () => Navigator.pop(ctx, 'del'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;
    switch (action) {
      case 'edit':
        await _editBed(bed);
      case 'plant':
        await _addPlant(bed);
      case 'smart':
        await _runSmartPlan(bed);
      case 'apply':
        await _applyBedToMoestuin(bed);
      case 'clear':
        await _confirmClearPlacements(bed);
      case 'dup':
        _pushUndo();
        await _store.duplicateBed(bed.id);
      case 'del':
        await _confirmDeleteBed(bed);
    }
  }

  Future<void> _applyBedToMoestuin(VisualGardenBed bed) async {
    if (bed.placements.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plaats eerst planten in deze bak')),
      );
      return;
    }
    final result = await showApplyVisualBedSheet(
      context: context,
      bed: bed,
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
    );
    if (result == null || !mounted) return;

    if (result.addToAgenda && widget.taskStore != null) {
      final now = DateTime.now();
      for (final id in result.agendaPlantIds) {
        final veg = widget.repository.byId(id);
        if (veg == null) continue;
        final due = plannedSeasonStartDate(
          id,
          types: plantingTaskTypesForGrowApproach(PlantGrowApproach.seed),
          vegetable: veg,
          reference: now,
        );
        await widget.taskStore!.upsert(
          GardenPlannerTask(
            id: 'plan_${now.millisecondsSinceEpoch}_$id',
            title: 'Begin met zaaien: ${veg.nameNl}',
            body: 'Voor moestuin “${result.spaceName}”',
            dueDate: due,
            vegetableId: id,
            priority: GardenPlannerTaskPriority.medium,
            createdAt: now,
          ),
        );
      }
    }

    final parts = <String>[
      '${result.spaceName} is aangemaakt',
    ];
    if (result.addedCount > 0) {
      parts.add(
        result.addedCount == 1
            ? '1 plant toegevoegd'
            : '${result.addedCount} planten toegevoegd',
      );
    }
    if (result.plannedInactiveCount > 0) {
      parts.add(
        '${result.plannedInactiveCount} wachten op het zaai-/plantseizoen',
      );
    }
    if (result.addToAgenda) {
      parts.add('in de planner-agenda gezet');
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(parts.join('. '))),
    );
  }

  double _spacingForPlant(String plantId, double fallback) {
    final catalog =
        widget.repository.byId(plantId)?.spacingCm.toDouble() ?? fallback;
    return plannerSpacingCmFor(plantId, fallbackCm: catalog);
  }

  Set<String> _invalidPlacementIds(VisualGardenBed bed) {
    final ids = <String>{};
    for (final p in bed.placements) {
      final spacing = _spacingForPlant(p.plantId, p.spacingCm);
      final v = checkPlacement(
        bed: bed,
        xCm: p.xCm,
        yCm: p.yCm,
        spacingCm: spacing,
        ignorePlacementId: p.id,
        spacingFor: (id, fb) => _spacingForPlant(id, fb),
      );
      // For stored plants, also check self-inside
      final inside = plantFullyInsideBed(
        bed: bed,
        xCm: p.xCm,
        yCm: p.yCm,
        spacingCm: spacing,
      );
      if (!inside || !v.noOverlap) ids.add(p.id);
    }
    // Mark both sides of overlaps
    for (final p in bed.placements) {
      final spacing = _spacingForPlant(p.plantId, p.spacingCm);
      for (final o in bed.placements) {
        if (o.id == p.id) continue;
        final os = _spacingForPlant(o.plantId, o.spacingCm);
        if (plantZonesOverlap(
          ax: p.xCm,
          ay: p.yCm,
          aSpacing: spacing,
          bx: o.xCm,
          by: o.yCm,
          bSpacing: os,
        )) {
          ids.add(p.id);
          ids.add(o.id);
        }
      }
    }
    return ids;
  }

  @override
  Widget build(BuildContext context) {
    final beds = _store.plan?.beds ?? const <VisualGardenBed>[];
    final selected = _store.selectedBed;

    return Scaffold(
      backgroundColor: VisualGardenBedColors.pageBackground,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'MOESTUINPLANNER',
          style: GoogleFonts.amaticSc(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: VisualGardenBedColors.titleGreen,
            height: 1.05,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: VisualGardenBedColors.titleGreen,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'Ongedaan maken',
            onPressed: _undoStack.isEmpty ? null : _undo,
            icon: const Icon(Icons.undo_rounded),
          ),
          IconButton(
            tooltip: 'Uitleg',
            onPressed: () => showDialog<void>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Moestuinplanner'),
                content: const Text(
                  'Maak bakken met echte maten, kies hout- en aardekleuren, '
                  'en plaats planten op schaal. Klaar? Zet de bak in een '
                  'nieuwe moestuin via het menu.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Ok'),
                  ),
                ],
              ),
            ),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: !_store.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: _PlantDragLockScrollPhysics(locked: _plantDragLock),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
              children: [
                const _HeroHeader(),
                const SizedBox(height: 14),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _ActionCard(
                          kind: _ActionKind.bak,
                          title: 'Bak toevoegen',
                          subtitle: 'Teken een nieuwe bak',
                          onTap: _createBed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionCard(
                          kind: _ActionKind.save,
                          title: 'Planten opslaan in moestuin',
                          subtitle: selected == null
                              ? 'Kies eerst een bak'
                              : selected.placements.isEmpty
                                  ? 'Plaats eerst planten in de bak'
                                  : 'Zet planten uit deze bak in Mijn moestuin',
                          onTap: selected == null ||
                                  selected.placements.isEmpty
                              ? null
                              : () => _applyBedToMoestuin(selected),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_pendingPlant != null && selected != null) ...[
                  const SizedBox(height: 12),
                  _PendingPlantBanner(
                    plantName: _pendingPlant!.nameNl,
                    onCancel: () => setState(() => _pendingPlant = null),
                    onDone: () => setState(() => _pendingPlant = null),
                  ),
                ],
                const SizedBox(height: 18),
                Text(
                  'Mijn tuinplekken',
                  style: GoogleFonts.fraunces(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: VisualGardenBedColors.titleGreen,
                  ),
                ),
                const SizedBox(height: 8),
                _BedChipRow(
                  beds: beds,
                  selectedId: _store.selectedBedId,
                  onSelect: (id) {
                    _store.selectBed(id);
                    setState(() {
                      _selectedPlacementId = null;
                      _pendingPlant = null;
                    });
                  },
                  onAdd: _createBed,
                ),
                const SizedBox(height: 10),
                if (beds.isEmpty)
                  _EmptyState(onCreate: _createBed)
                else if (selected != null)
                  _SelectedBedCard(
                    bed: selected,
                    repository: widget.repository,
                    pendingPlant: _pendingPlant,
                    selectedPlacementId: _selectedPlacementId,
                    conflictIds: _invalidPlacementIds(selected),
                    onEdit: () => _editBed(selected),
                    onDuplicate: () async {
                      _pushUndo();
                      await _store.duplicateBed(selected.id);
                    },
                    onDelete: () => _confirmDeleteBed(selected),
                    onMenu: () => _bedMenu(selected),
                    onAddPlant: () => _addPlant(selected),
                    onClearPlacements: () =>
                        _confirmClearPlacements(selected),
                    onOpenCropPlan: (plan) => _openCropPlan(selected, plan),
                    onAddCropPlan: () => _addCropPlan(selected),
                    onSuggestNextCrop: () => _suggestNextCrop(selected),
                    onDeleteCropPlan: (plan) =>
                        _deleteCropPlan(selected, plan),
                    onSelectPlacement: (id) =>
                        setState(() => _selectedPlacementId = id),
                    onCancelPending: () =>
                        setState(() => _pendingPlant = null),
                    onDeletePlacement: (placementId) async {
                      _pushUndo();
                      await _store.removePlacement(selected.id, placementId);
                      if (!mounted) return;
                      setState(() => _selectedPlacementId = null);
                    },
                    onPlacementChanged: (pl) async {
                      _pushUndo();
                      await _store.upsertPlacement(selected.id, pl);
                    },
                    onPendingPlaced: (pl) async {
                      _pushUndo();
                      await _store.upsertPlacement(selected.id, pl);
                      if (!mounted) return;
                      // Houd dezelfde soort actief zodat je er meteen nog één
                      // van kunt plaatsen (bijv. meerdere aardappelen).
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${widget.repository.byId(pl.plantId)?.nameNl ?? 'Plant'} '
                            'geplaatst. Sleep de volgende of tik ✕ als je klaar bent.',
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    onDragActiveChanged: (active) {
                      _plantDragLock.value = active;
                    },
                  ),
              ],
            ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maak jouw moestuin',
                  style: GoogleFonts.fraunces(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: VisualGardenBedColors.titleGreen,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Teken je bakken, vul de maten in en plaats daarna je planten.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: TuinierColors.textSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 132,
            height: 124,
            child: Image.asset(
              'assets/images/planner/planner_hero_bed.png',
              fit: BoxFit.contain,
              alignment: Alignment.center,
              errorBuilder: (_, __, ___) => const ColoredBox(
                color: VisualGardenBedColors.softGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ActionKind { bak, save }

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final _ActionKind kind;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  String? get _iconAsset => kind == _ActionKind.bak
      ? 'assets/images/planner/planner_icon_bak.png'
      : 'assets/images/planner/planner_icon_plant.png';

  IconData get _fallbackIcon => kind == _ActionKind.bak
      ? Icons.crop_square_rounded
      : Icons.yard_outlined;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final color = enabled
        ? VisualGardenBedColors.titleGreen
        : TuinierColors.textSecondary;
    return Material(
      color: const Color(0xFFF3F4F0),
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: TuinierColors.border.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (kind == _ActionKind.save)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: VisualGardenBedColors.softGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_fallbackIcon, color: color, size: 28),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    _iconAsset!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Icon(
                      _fallbackIcon,
                      color: color,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: color,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.25,
                  color: enabled
                      ? TuinierColors.textSecondary
                      : TuinierColors.textSecondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingPlantBanner extends StatelessWidget {
  const _PendingPlantBanner({
    required this.plantName,
    required this.onCancel,
    required this.onDone,
  });
  final String plantName;
  final VoidCallback onCancel;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: VisualGardenBedColors.softGreen,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          children: [
            const Icon(Icons.touch_app_outlined,
                color: VisualGardenBedColors.titleGreen, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Plaats $plantName met ✓. Je kunt er meerdere van zetten.',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: onDone,
              child: const Text('Klaar'),
            ),
            IconButton(
              tooltip: 'Annuleren',
              onPressed: onCancel,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _BedChipRow extends StatelessWidget {
  const _BedChipRow({
    required this.beds,
    required this.selectedId,
    required this.onSelect,
    required this.onAdd,
  });

  final List<VisualGardenBed> beds;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final bed in beds) ...[
            _BedChip(
              label: bed.name,
              selected: bed.id == selectedId,
              borderColor: bed.borderColor,
              fillColor: bed.fillColor,
              onTap: () => onSelect(bed.id),
            ),
            const SizedBox(width: 8),
          ],
          _NewBedChip(onTap: onAdd),
        ],
      ),
    );
  }
}

class _NewBedChip extends StatelessWidget {
  const _NewBedChip({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: TuinierColors.border,
            radius: 14,
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: 18,
                  color: VisualGardenBedColors.titleGreen,
                ),
                SizedBox(width: 4),
                Text(
                  'Nieuwe plek',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: VisualGardenBedColors.titleGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 5.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

class _BedChip extends StatelessWidget {
  const _BedChip({
    required this.label,
    required this.selected,
    required this.borderColor,
    required this.fillColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color borderColor;
  final Color fillColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? VisualGardenBedColors.chipSelectedFill
          : TuinierColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? VisualGardenBedColors.titleGreen
                  : TuinierColors.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.asset(
                  'assets/images/planner/planner_icon_bak.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: borderColor, width: 3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: VisualGardenBedColors.titleGreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedBedCard extends StatelessWidget {
  const _SelectedBedCard({
    required this.bed,
    required this.repository,
    required this.pendingPlant,
    required this.selectedPlacementId,
    required this.conflictIds,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onMenu,
    required this.onAddPlant,
    required this.onClearPlacements,
    required this.onOpenCropPlan,
    required this.onAddCropPlan,
    required this.onSuggestNextCrop,
    required this.onDeleteCropPlan,
    required this.onSelectPlacement,
    required this.onPlacementChanged,
    required this.onPendingPlaced,
    required this.onCancelPending,
    required this.onDeletePlacement,
    required this.onDragActiveChanged,
  });

  final VisualGardenBed bed;
  final VegetableRepository repository;
  final Vegetable? pendingPlant;
  final String? selectedPlacementId;
  final Set<String> conflictIds;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onMenu;
  final VoidCallback onAddPlant;
  final VoidCallback onClearPlacements;
  final ValueChanged<VisualCropPlan> onOpenCropPlan;
  final VoidCallback onAddCropPlan;
  final VoidCallback onSuggestNextCrop;
  final ValueChanged<VisualCropPlan> onDeleteCropPlan;
  final ValueChanged<String?> onSelectPlacement;
  final ValueChanged<PlantPlacement> onPlacementChanged;
  final ValueChanged<PlantPlacement> onPendingPlaced;
  final VoidCallback onCancelPending;
  final ValueChanged<String> onDeletePlacement;
  final ValueChanged<bool> onDragActiveChanged;

  @override
  Widget build(BuildContext context) {
    final dims =
        '${bed.widthCm.round()} × ${bed.heightCm.round()} cm';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: TuinierColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: VisualGardenBedColors.softGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  'assets/images/planner/planner_icon_bak.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.crop_square_rounded,
                    color: VisualGardenBedColors.titleGreen,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              bed.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: VisualGardenBedColors.titleGreen,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: TuinierColors.textSecondary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dims,
                        style: const TextStyle(
                          fontSize: 12,
                          color: TuinierColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Dupliceren',
                onPressed: onDuplicate,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.copy_outlined, size: 20),
              ),
              IconButton(
                tooltip: 'Verwijderen',
                onPressed: onDelete,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.delete_outline,
                  color: TuinierColors.error,
                  size: 20,
                ),
              ),
              IconButton(
                tooltip: 'Meer',
                onPressed: onMenu,
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.more_vert, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          VisualGardenCropPlansSection(
            bed: bed,
            repository: repository,
            onOpenPlan: onOpenCropPlan,
            onAddPlan: onAddCropPlan,
            onSuggestNext: onSuggestNextCrop,
            onDeletePlan: onDeleteCropPlan,
          ),
          const SizedBox(height: 16),
          Text(
            'Afmetingen',
            style: GoogleFonts.fraunces(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: VisualGardenBedColors.titleGreen,
            ),
          ),
          const SizedBox(height: 8),
          VisualGardenDimensionFrame(
            widthCm: bed.widthCm,
            heightCm: bed.heightCm,
            child: VisualGardenBedCanvas(
              bed: bed,
              repository: repository,
              selected: true,
              pendingPlant: pendingPlant,
              highlightConflictIds: conflictIds,
              selectedPlacementId: selectedPlacementId,
              // Grotere bak op scherm; plantzones blijven op echte cm-schaal.
              maxHeight: (MediaQuery.sizeOf(context).height * 0.42)
                  .clamp(320.0, 480.0),
              onSelectBed: () {},
              onSelectPlacement: onSelectPlacement,
              onPlacementChanged: onPlacementChanged,
              onPendingPlaced: onPendingPlaced,
              onCancelPending: onCancelPending,
              onDeletePlacement: onDeletePlacement,
              onDragActiveChanged: onDragActiveChanged,
            ),
          ),
          if (pendingPlant != null) ...[
            const SizedBox(height: 10),
            Text(
              'Sleep ${pendingPlant!.nameNl} naar de juiste plek en tik ✓',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: VisualGardenBedColors.titleGreen,
              ),
            ),
          ] else if (bed.placements.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '${bed.placements.length} plant${bed.placements.length == 1 ? '' : 'en'} in dit teeltplan',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: TuinierColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onAddPlant,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Plant toevoegen'),
            style: FilledButton.styleFrom(
              backgroundColor: VisualGardenBedColors.titleGreen,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          if (bed.placements.isNotEmpty) ...[
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onClearPlacements,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('Alle planten wissen'),
              style: OutlinedButton.styleFrom(
                foregroundColor: TuinierColors.error,
                side: const BorderSide(color: TuinierColors.error),
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: TuinierColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: TuinierColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.crop_square_rounded,
            size: 48,
            color: VisualGardenBedColors.titleGreen.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nog geen plantenbakken',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: VisualGardenBedColors.titleGreen,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Kies hoeveel hoeken je bak heeft, vul de maten in en '
            'plaats daarna je planten.',
            textAlign: TextAlign.center,
            style: TextStyle(color: TuinierColors.textSecondary),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onCreate,
            style: FilledButton.styleFrom(
              backgroundColor: VisualGardenBedColors.titleGreen,
              minimumSize: const Size(220, 48),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Eerste plantenbak maken'),
          ),
        ],
      ),
    );
  }
}

/// Blokkeert scroll direct bij plant-sleep (leest ValueNotifier zonder rebuild).
class _PlantDragLockScrollPhysics extends ScrollPhysics {
  const _PlantDragLockScrollPhysics({required this.locked, super.parent});

  final ValueNotifier<bool> locked;

  @override
  _PlantDragLockScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _PlantDragLockScrollPhysics(
      locked: locked,
      parent: buildParent(ancestor),
    );
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    if (locked.value) return 0;
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (locked.value) return false;
    return super.shouldAcceptUserOffset(position);
  }
}

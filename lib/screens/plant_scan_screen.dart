import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/ai_settings_store.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_notifications_sync.dart';
import '../data/crop_harvest_kind.dart';
import '../data/garden_plant_schedule.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/garden_notes_store.dart';
import '../data/ai_scan_coach_tasks.dart';
import '../data/plant_photo_ai_service.dart';
import '../data/planting_timing_advice.dart';
import '../data/plant_scan_consistency.dart';
import '../data/plant_scan_persist_policy.dart';
import '../data/plant_scan_photo_store.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import '../widgets/garden_warning_style.dart';
import '../widgets/plant_scan_result_card.dart';
import '../widgets/vegetable_thumbnail.dart';

/// Foto maken → AI beoordeelt groeifase en oogstmoment.
class PlantScanScreen extends StatefulWidget {
  const PlantScanScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.aiSettings,
    required this.scanPrefs,
    required this.notesStore,
    this.initialVegetableId,
    this.initialHarvestProbe = false,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final AiSettingsStore aiSettings;
  final GardenScanPrefsStore scanPrefs;
  final GardenNotesStore notesStore;
  final String? initialVegetableId;
  final bool initialHarvestProbe;

  @override
  State<PlantScanScreen> createState() => _PlantScanScreenState();
}

class _PlantScanScreenState extends State<PlantScanScreen> {
  final _picker = ImagePicker();
  String? _selectedId;
  Uint8List? _imageBytes;
  String? _mimeType;
  bool _analyzing = false;
  String? _error;
  PlantAiAnalysis? _lastResult;
  final _apiKeyController = TextEditingController();
  final _plantSearchController = TextEditingController();
  bool _plantPickerExpanded = false;
  late bool _harvestProbeMode;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialVegetableId;
    _harvestProbeMode = widget.initialHarvestProbe;
    _plantPickerExpanded = widget.initialVegetableId == null;
    _apiKeyController.text = widget.aiSettings.apiKey;
    widget.gardenStore.addListener(_onStoresChanged);
    widget.profileStore.addListener(_onStoresChanged);
    widget.aiSettings.addListener(_onStoresChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickDefaultPlant());
  }

  void _pickDefaultPlant() {
    if (_selectedId != null) return;
    final ids = widget.gardenStore.ids.toList();
    if (ids.isEmpty) return;
    setState(() => _selectedId = ids.first);
  }

  void _onStoresChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.gardenStore.removeListener(_onStoresChanged);
    widget.profileStore.removeListener(_onStoresChanged);
    widget.aiSettings.removeListener(_onStoresChanged);
    _apiKeyController.dispose();
    _plantSearchController.dispose();
    super.dispose();
  }

  List<Vegetable> _filterPlants(List<Vegetable> plants, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return plants;
    return plants.where((v) {
      if (v.nameNl.toLowerCase().contains(q)) return true;
      if (v.family.toLowerCase().contains(q)) return true;
      final latin = v.nameLatin?.toLowerCase();
      if (latin != null && latin.contains(q)) return true;
      return v.keywords.any((k) => k.toLowerCase().contains(q));
    }).toList();
  }

  void _selectPlant(String id) {
    setState(() {
      _selectedId = id;
      _lastResult = null;
      _error = null;
      _plantPickerExpanded = false;
      _plantSearchController.clear();
    });
  }

  List<Vegetable> get _myPlants {
    return widget.gardenStore.ids
        .map(widget.repository.byId)
        .whereType<Vegetable>()
        .toList()
      ..sort((a, b) => a.nameNl.compareTo(b.nameNl));
  }

  Vegetable? get _selected =>
      _selectedId != null ? widget.repository.byId(_selectedId!) : null;

  GardenPlantProfile? get _selectedProfile => _selectedId != null
      ? widget.profileStore.profileFor(_selectedId!)
      : null;

  Future<void> _saveApiKey() async {
    await widget.aiSettings.setApiKey(_apiKeyController.text);
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API-sleutel opgeslagen')),
      );
    }
  }

  Future<void> _reloadLocalApiKey() async {
    await widget.aiSettings.reloadFromLocalFile();
    _apiKeyController.text = widget.aiSettings.apiKey;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleutel opnieuw geladen uit project')),
      );
      setState(() {});
    }
  }

  void _openApiKeySheet() {
    final t = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            0,
            20,
            20 + MediaQuery.paddingOf(ctx).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Gemini API-sleutel',
                style: t.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gratis op aistudio.google.com. De sleutel blijft op je telefoon.',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API-sleutel',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                autocorrect: false,
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _saveApiKey,
                child: const Text('Opslaan'),
              ),
              TextButton(
                onPressed: _reloadLocalApiKey,
                child: const Text('Opnieuw laden uit project'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _mimeType = 'image/jpeg';
        _error = null;
        _lastResult = null;
      });
    } catch (e) {
      setState(() => _error = 'Foto kon niet worden geladen.');
    }
  }

  Future<void> _analyze() async {
    final veg = _selected;
    if (veg == null) {
      setState(() => _error = 'Kies eerst een gewas uit Mijn moestuin.');
      return;
    }
    if (_imageBytes == null) {
      setState(() => _error = 'Maak eerst een foto (ook van grond of zaadbed).');
      return;
    }
    if (!widget.aiSettings.hasApiKey) {
      setState(() => _error = 'Voeg eerst een API-sleutel toe via het tandwiel.');
      _openApiKeySheet();
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
    });

    try {
      await widget.profileStore.ensureProfile(veg.id);
      final profile = widget.profileStore.profileFor(veg.id)!;
      final cal = calendarLabelsFor(veg.id);
      final timing = assessPlantingTiming(vegetable: veg, profile: profile);
      final outsideSeason = !profile.plantingDateUnknown &&
          timing.status != PlantingTimingStatus.onTime &&
          timing.status != PlantingTimingStatus.noCalendar &&
          timing.status != PlantingTimingStatus.unknownDate;
      final daysSince = profile.plantingDateUnknown
          ? null
          : DateTime.now()
              .difference(
                DateTime(
                  profile.plantedAt.year,
                  profile.plantedAt.month,
                  profile.plantedAt.day,
                ),
              )
              .inDays;
      final service = PlantPhotoAiService(apiKey: widget.aiSettings.apiKey);
      final imageFingerprint = fingerprintImageBytes(_imageBytes!);
      final result = await service.analyze(
        imageBytes: _imageBytes!,
        mimeType: _mimeType ?? 'image/jpeg',
        vegetable: veg,
        plantedAt: profile.plantedAt,
        plantingDateUnknown: profile.plantingDateUnknown,
        locationLabel: profile.location.label,
        sunLabel: profile.sunLevel.label,
        outsidePlantingSeason: outsideSeason,
        plantWindowLabel: cal.plant,
        harvestWindowLabel: cal.harvest,
        daysSinceStatedPlantDate: daysSince,
        previousAnalysis: profile.lastAnalysis,
        previousImageFingerprint: profile.lastScanImageFingerprint,
        isFirstScan: profile.lastAnalysis == null,
        isHarvestProbePhoto: _harvestProbeMode,
      );

      final notSavedMessage = scanNotPersistedMessage(result);

      if (notSavedMessage != null) {
        if (mounted) {
          setState(() {
            _lastResult = result;
            _analyzing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(notSavedMessage),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      final photoPath = await PlantScanPhotoStore.saveScanPhoto(
        veg.id,
        _imageBytes!,
      );
      final updated = applyAiScanToProfile(
        profile,
        result,
        weeklyScanIntervalDays: widget.scanPrefs.weeklyScanIntervalDays,
        imageFingerprint: imageFingerprint,
        newScanPhotoPath: photoPath,
      );
      await widget.profileStore.saveProfile(updated);
      await syncGardenNotifications(
        profileStore: widget.profileStore,
        gardenStore: widget.gardenStore,
        repository: widget.repository,
        scanPrefs: widget.scanPrefs,
        notesStore: widget.notesStore,
      );

      if (mounted) {
        final wasProbe = _harvestProbeMode;
        setState(() {
          _lastResult = result;
          _analyzing = false;
          if (wasProbe) _harvestProbeMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasProbe
                  ? 'Proefoogst-scan opgeslagen — bekijk of je kunt oogsten'
                  : 'Scan opgeslagen in je plantgeschiedenis',
            ),
          ),
        );
      }
    } on PlantPhotoAiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _analyzing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Analyse mislukt. Controleer internet en API-sleutel.';
          _analyzing = false;
        });
      }
    }
  }

  Future<void> _addCoachTasksFromAnalysis(PlantAiAnalysis analysis) async {
    final veg = _selected;
    if (veg == null) return;
    final insight = analysis.insight;
    if (insight == null) return;

    var notes = buildCoachNotesFromAnalysis(
      analysis: analysis,
      vegetable: veg,
      scanDate: analysis.scannedAt,
    );
    if (notes.isEmpty) {
      notes = fallbackCoachNotesFromActions(
        insight: insight,
        vegetable: veg,
        scanDate: analysis.scannedAt,
      );
    }
    if (notes.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geen taken om toe te voegen.')),
      );
      return;
    }

    for (final note in notes) {
      await widget.notesStore.upsert(note);
    }
    await syncGardenNotifications(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
      notesStore: widget.notesStore,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${notes.length} ${notes.length == 1 ? 'taak' : 'taken'} toegevoegd aan je kalender',
        ),
      ),
    );
  }

  String? _scanHintForProfile(GardenPlantProfile? profile) {
    if (profile == null || !profile.isPlanted) {
      return 'Markeer de plant als geplant op Mijn moestuin.';
    }
    if (awaitingFirstPhotoScan(profile)) {
      return kFirstScanShortLabel;
    }
    if (needsWeeklyScan(profile)) {
      return 'Wekelijkse scan aanbevolen';
    }
    if (profile.nextScanDue != null) {
      return 'Volgende scan: ${formatDateShortNl(profile.nextScanDue!)}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final plants = _myPlants;
    final profile = _selectedProfile;
    final stored = _selectedId != null
        ? widget.profileStore.profileFor(_selectedId!)?.lastAnalysis
        : null;
    final display = _lastResult ?? stored;
    final hasApiKey = widget.aiSettings.hasApiKey;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('AI-scan'),
        actions: [
          IconButton(
            tooltip: 'API-sleutel',
            onPressed: _openApiKeySheet,
            icon: Badge(
              isLabelVisible: !hasApiKey,
              smallSize: 8,
              child: const Icon(Icons.settings_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          _ScanHeroHeader(hasApiKey: hasApiKey, onApiTap: _openApiKeySheet),
          const SizedBox(height: 20),
          if (plants.isEmpty)
            _EmptyGardenCard(
              onAddHint: 'Voeg groenten toe via Mijn moestuin (+).',
            )
          else ...[
            _CollapsiblePlantPicker(
              plants: plants,
              selectedId: _selectedId,
              expanded: _plantPickerExpanded,
              searchController: _plantSearchController,
              scanHint: _scanHintForProfile(profile),
              onExpandedChanged: (v) =>
                  setState(() => _plantPickerExpanded = v),
              onSearchChanged: (_) => setState(() {}),
              onSelected: _selectPlant,
              filterPlants: _filterPlants,
            ),
            if (profile != null && awaitingFirstPhotoScan(profile)) ...[
              const SizedBox(height: 12),
              const _FirstScanMotivationBanner(),
            ],
            if (_harvestProbeMode) ...[
              const SizedBox(height: 12),
              _HarvestProbeBanner(
                onCancel: () => setState(() => _harvestProbeMode = false),
              ),
            ],
            const SizedBox(height: 20),
            _PhotoCaptureCard(
              imageBytes: _imageBytes,
              analyzing: _analyzing,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
              onAnalyze: _analyze,
              canAnalyze: _imageBytes != null && !_analyzing && hasApiKey,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: _error!),
          ],
          if (display != null) ...[
            const SizedBox(height: 20),
            Text(
              'Laatste resultaat',
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            PlantScanResultCard(
              analysis: display,
              savedToHistory: shouldPersistAiScan(display),
              ornamentalBloomOnly: _selected != null &&
                  isOrnamentalOnlyMoestuinCrop(_selected!),
              edibleBloomDual: _selected != null &&
                  isEdibleMoestuinBloomCrop(_selected!),
            ),
            if (!display.hasCropMismatch &&
                display.insight != null &&
                (display.insight!.coachTasks.isNotEmpty ||
                    display.insight!.recommendedActions.isNotEmpty)) ...[
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => _addCoachTasksFromAnalysis(display),
                icon: const Icon(Icons.event_note_outlined),
                label: const Text('Taken in kalender zetten'),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _CollapsiblePlantPicker extends StatelessWidget {
  const _CollapsiblePlantPicker({
    required this.plants,
    required this.selectedId,
    required this.expanded,
    required this.searchController,
    required this.onExpandedChanged,
    required this.onSearchChanged,
    required this.onSelected,
    required this.filterPlants,
    this.scanHint,
  });

  final List<Vegetable> plants;
  final String? selectedId;
  final bool expanded;
  final TextEditingController searchController;
  final ValueChanged<bool> onExpandedChanged;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onSelected;
  final List<Vegetable> Function(List<Vegetable>, String) filterPlants;
  final String? scanHint;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    Vegetable? selectedVeg;
    if (selectedId != null) {
      for (final v in plants) {
        if (v.id == selectedId) {
          selectedVeg = v;
          break;
        }
      }
    }
    final filtered = filterPlants(plants, searchController.text);
    final hasSearch = searchController.text.trim().isNotEmpty;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => onExpandedChanged(!expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  if (selectedVeg != null) ...[
                    VegetableThumbnail(vegetable: selectedVeg, size: 40),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plant',
                          style: t.textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          selectedVeg?.nameNl ?? 'Kies een plant',
                          style: t.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (!expanded &&
                            scanHint != null &&
                            scanHint!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            scanHint!,
                            maxLines: 3,
                            style: t.textTheme.bodySmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                textInputAction: TextInputAction.search,
                style: t.textTheme.bodyMedium,
                decoration: InputDecoration(
                  hintText: 'Zoek in je moestuin…',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            searchController.clear();
                            onSearchChanged('');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            if (filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                child: Text(
                  'Geen plant gevonden.',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              )
            else if (!hasSearch)
              SizedBox(
                height: 52,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final v = filtered[i];
                    final isSelected = v.id == selectedId;
                    return FilterChip(
                      showCheckmark: false,
                      selected: isSelected,
                      avatar: VegetableThumbnail(vegetable: v, size: 28),
                      label: Text(v.nameNl),
                      labelStyle: t.textTheme.labelLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                      onSelected: (_) => onSelected(v.id),
                    );
                  },
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 2),
                  itemBuilder: (context, i) {
                    final v = filtered[i];
                    final isSelected = v.id == selectedId;
                    return ListTile(
                      dense: true,
                      visualDensity: VisualDensity.compact,
                      leading: VegetableThumbnail(vegetable: v, size: 36),
                      title: Text(
                        v.nameNl,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        v.family,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check_circle, color: cs.primary)
                          : null,
                      selected: isSelected,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      onTap: () => onSelected(v.id),
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _FirstScanMotivationBanner extends StatelessWidget {
  const _FirstScanMotivationBanner();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Material(
      color: GardenWarningStyle.background(cs),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.photo_camera_outlined,
              color: GardenWarningStyle.icon(cs),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                kFirstScanMotivationMessage,
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanHeroHeader extends StatelessWidget {
  const _ScanHeroHeader({
    required this.hasApiKey,
    required this.onApiTap,
  });

  final bool hasApiKey;
  final VoidCallback onApiTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primaryContainer.withValues(alpha: 0.55),
            cs.surfaceContainerHighest.withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome,
              color: cs.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan je plant',
                  style: t.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Foto → groeifase, gezondheid en oogstmoment. '
                  'Vergelijkt met je vorige scan.',
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                if (!hasApiKey) ...[
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: onApiTap,
                    icon: const Icon(Icons.key_outlined, size: 18),
                    label: const Text('API-sleutel instellen'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCaptureCard extends StatelessWidget {
  const _PhotoCaptureCard({
    required this.imageBytes,
    required this.analyzing,
    required this.onCamera,
    required this.onGallery,
    required this.onAnalyze,
    required this.canAnalyze,
  });

  final Uint8List? imageBytes;
  final bool analyzing;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback onAnalyze;
  final bool canAnalyze;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final hasPhoto = imageBytes != null;

    return Material(
      color: cs.surfaceContainerLow,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: hasPhoto
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Material(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: onCamera,
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(
                                Icons.refresh,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 44,
                          color: cs.primary.withValues(alpha: 0.7),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Maak of kies een foto',
                          style: t.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _SourceButton(
                        icon: Icons.photo_camera_outlined,
                        label: 'Camera',
                        onTap: analyzing ? null : onCamera,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _SourceButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Galerij',
                        onTap: analyzing ? null : onGallery,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: canAnalyze ? onAnalyze : null,
                  icon: analyzing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onPrimary,
                          ),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    analyzing ? 'AI analyseert…' : 'Start AI-analyse',
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceButton extends StatelessWidget {
  const _SourceButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Icon(icon, color: cs.primary, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyGardenCard extends StatelessWidget {
  const _EmptyGardenCard({required this.onAddHint});

  final String onAddHint;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.yard_outlined,
            size: 48,
            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Nog geen planten',
            style: t.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            onAddHint,
            textAlign: TextAlign.center,
            style: t.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _HarvestProbeBanner extends StatelessWidget {
  const _HarvestProbeBanner({required this.onCancel});

  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.grass_outlined, color: cs.onTertiaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Proefoogst-scan',
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Normale scan',
                onPressed: onCancel,
                icon: const Icon(Icons.close, size: 20),
              ),
            ],
          ),
          Text(
            'Fotografeer de plant die je net uit de grond trok. '
            'De AI beoordeelt of de wortel of knol oogstrijp is.',
            style: t.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onErrorContainer,
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

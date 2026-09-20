import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/ai_settings_store.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_notifications_sync.dart';
import '../data/crop_harvest_kind.dart';
import '../data/garden_plant_schedule.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/moestuin_pinned_action.dart';
import '../data/insect_scan_store.dart';
import '../data/my_garden_store.dart';
import '../data/weed_scan_store.dart';
import '../widgets/scan_mode_selector.dart';
import '../data/garden_notes_store.dart';
import '../data/ai_scan_coach_tasks.dart';
import '../data/plant_count_scan.dart';
import '../data/plant_multi_scan_service.dart';
import '../data/plant_search_filters.dart';
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
import '../screens/scan_result_screen.dart';
import '../widgets/plant_scan_result_card.dart';
import '../widgets/tuinier_scan_stores_scope.dart';
import '../widgets/vegetable_thumbnail.dart';
import 'scan_hub_types.dart';

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
    this.insectScanStore,
    this.weedScanStore,
    this.initialVegetableId,
    this.initialHarvestProbe = false,
    this.initialScanMode,
    this.initialHubEntry,
    this.plantBrowseFilter,
    this.showHubBack = false,
    this.onBackToHub,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final AiSettingsStore aiSettings;
  final GardenScanPrefsStore scanPrefs;
  final GardenNotesStore notesStore;
  final InsectScanStore? insectScanStore;
  final WeedScanStore? weedScanStore;
  final String? initialVegetableId;
  final bool initialHarvestProbe;
  final ScanSubjectMode? initialScanMode;
  final ScanHubEntry? initialHubEntry;
  final PlantBrowseKind? plantBrowseFilter;
  final bool showHubBack;
  final VoidCallback? onBackToHub;

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
  String? _lastScanPhotoPath;
  final _apiKeyController = TextEditingController();
  final _plantSearchController = TextEditingController();
  bool _plantPickerExpanded = false;
  late bool _harvestProbeMode;
  ScanSubjectMode _scanMode = ScanSubjectMode.plant;
  int _plantCountInput = 1;
  bool _plantCountConfirmed = false;
  List<Uint8List?> _sessionPhotos = [];
  int _currentPhotoSlot = 0;

  InsectScanStore get _insectScanStore =>
      widget.insectScanStore ??
      TuinierScanStoresScope.of(context).insectScanStore;

  WeedScanStore get _weedScanStore =>
      widget.weedScanStore ?? TuinierScanStoresScope.of(context).weedScanStore;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialVegetableId;
    _harvestProbeMode = widget.initialHarvestProbe;
    _scanMode = widget.initialScanMode ?? ScanSubjectMode.plant;
    _plantPickerExpanded = widget.initialVegetableId == null;
    _apiKeyController.text = widget.aiSettings.apiKey;
    widget.gardenStore.addListener(_onStoresChanged);
    widget.profileStore.addListener(_onStoresChanged);
    widget.aiSettings.addListener(_onStoresChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _pickDefaultPlant());
  }

  void _pickDefaultPlant() {
    if (widget.initialVegetableId != null &&
        widget.gardenStore.contains(widget.initialVegetableId!)) {
      if (_selectedId != widget.initialVegetableId) {
        setState(() {
          _selectedId = widget.initialVegetableId;
          _resetMultiScanSession();
        });
      }
      return;
    }

    final plants = _myPlants;
    if (plants.isEmpty) {
      if (_selectedId != null) {
        setState(() {
          _selectedId = null;
          _resetMultiScanSession();
        });
      }
      return;
    }
    if (_selectedId == null || !plants.any((v) => v.id == _selectedId)) {
      setState(() {
        _selectedId = plants.first.id;
        _resetMultiScanSession();
      });
    }
  }

  void _onStoresChanged() {
    if (mounted && !_analyzing) _pickDefaultPlant();
  }

  void _pauseStoreListeners() {
    widget.gardenStore.removeListener(_onStoresChanged);
    widget.profileStore.removeListener(_onStoresChanged);
  }

  void _resumeStoreListeners() {
    widget.gardenStore.addListener(_onStoresChanged);
    widget.profileStore.addListener(_onStoresChanged);
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
      _resetMultiScanSession();
    });
  }

  void _resetMultiScanSession() {
    final stored = _selectedProfile?.plantCount;
    _plantCountInput = (stored != null && stored > 0) ? stored : 1;
    _plantCountConfirmed = false;
    _sessionPhotos = [];
    _currentPhotoSlot = 0;
    _imageBytes = null;
    _mimeType = null;
    _error = null;
  }

  List<ScanPhotoSlot> get _photoSlots =>
      scanPhotoSlotsForPlantCount(_plantCountInput);

  bool get _usesMultiPlantScan =>
      _scanMode == ScanSubjectMode.plant &&
      !_harvestProbeMode &&
      widget.initialVegetableId == null;

  /// Scan geopend via hub, taak of plantkaart — geen modus-wisselaar.
  bool get _isDirectEntryScan =>
      widget.showHubBack ||
      widget.initialVegetableId != null ||
      widget.initialHarvestProbe ||
      widget.initialHubEntry != null;

  bool get _allSessionPhotosCaptured {
    if (!_usesMultiPlantScan || !_plantCountConfirmed) return false;
    final slots = _photoSlots;
    if (_sessionPhotos.length < slots.length) return false;
    return _sessionPhotos.take(slots.length).every((p) => p != null);
  }

  Uint8List? get _currentSlotBytes {
    if (_currentPhotoSlot < _sessionPhotos.length) {
      return _sessionPhotos[_currentPhotoSlot];
    }
    return null;
  }

  List<Vegetable> get _myPlants {
    final plants = widget.gardenStore.ids
        .map(widget.repository.byId)
        .whereType<Vegetable>()
        .where((v) {
          final profile = widget.profileStore.profileFor(v.id);
          if (profile == null ||
              !profile.isPlanted ||
              !profile.isMoestuinActive) {
            return false;
          }
          final filter = widget.plantBrowseFilter;
          if (filter == null) return true;
          return browseKindForPlant(v.id) == filter;
        })
        .toList();

    final targetId = widget.initialVegetableId;
    if (targetId != null &&
        widget.gardenStore.contains(targetId) &&
        !plants.any((v) => v.id == targetId)) {
      final veg = widget.repository.byId(targetId);
      final profile = widget.profileStore.profileFor(targetId);
      if (veg != null && profile != null) {
        plants.add(veg);
      }
    }

    plants.sort((a, b) => a.nameNl.compareTo(b.nameNl));
    return plants;
  }

  bool get _canScanSelected {
    final profile = _selectedProfile;
    if (profile == null) return false;
    if (widget.initialVegetableId != null &&
        _selectedId == widget.initialVegetableId) {
      return widget.gardenStore.contains(_selectedId!);
    }
    return profile.isPlanted && profile.isMoestuinActive;
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
        if (_usesMultiPlantScan && _plantCountConfirmed) {
          while (_sessionPhotos.length <= _currentPhotoSlot) {
            _sessionPhotos.add(null);
          }
          _sessionPhotos[_currentPhotoSlot] = bytes;
          _imageBytes = bytes;
        } else {
          _imageBytes = bytes;
        }
        _mimeType = 'image/jpeg';
        _error = null;
        _lastResult = null;
      });
    } catch (e) {
      setState(() => _error = 'Foto kon niet worden geladen.');
    }
  }

  void _confirmPlantCount() {
    final slots = scanPhotoSlotsForPlantCount(_plantCountInput);
    final pendingPhoto = _imageBytes;
    setState(() {
      _plantCountConfirmed = true;
      _sessionPhotos = List<Uint8List?>.filled(slots.length, null);
      if (pendingPhoto != null) {
        _sessionPhotos[0] = pendingPhoto;
      }
      _currentPhotoSlot = 0;
      _imageBytes = _sessionPhotos.isNotEmpty ? _sessionPhotos[0] : null;
      _error = null;
      _lastResult = null;
    });
    if (pendingPhoto != null && slots.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _analyze();
      });
    }
  }

  void _goToNextPhotoSlot() {
    final slots = _photoSlots;
    if (_currentSlotBytes == null) {
      setState(() => _error = 'Maak eerst een foto voor deze plant.');
      return;
    }
    if (_currentPhotoSlot >= slots.length - 1) return;
    setState(() {
      _currentPhotoSlot++;
      _imageBytes = _currentSlotBytes;
      _error = null;
    });
  }

  void _goToPreviousPhotoSlot() {
    if (_currentPhotoSlot <= 0) return;
    setState(() {
      _currentPhotoSlot--;
      _imageBytes = _currentSlotBytes;
      _error = null;
    });
  }

  void _changePlantCount() {
    setState(() {
      _plantCountConfirmed = false;
      _sessionPhotos = [];
      _currentPhotoSlot = 0;
      _imageBytes = null;
      _error = null;
    });
  }

  Future<void> _analyzeWeed() async {
    if (_imageBytes == null) {
      setState(() => _error = 'Maak eerst een foto van het onkruid.');
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
      _lastResult = null;
    });

    final spaceId =
        widget.gardenStore.activeSpace?.id ?? 'tuin_default';

    await _weedScanStore.addEntry(
      WeedScanEntry(
        id: 'weed_${DateTime.now().millisecondsSinceEpoch}',
        tuinSpaceId: spaceId,
        nameNl: 'Onkruid (scan)',
        impact: WeedImpact.neutral,
        summary:
            'Onkruid-AI volgt in een volgende update. Entry staat in je logboek.',
        scannedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    setState(() => _analyzing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Onkruid opgeslagen in Inzicht. Volledige herkenning komt later.',
        ),
      ),
    );
  }

  Future<void> _analyzeInsect() async {
    if (_imageBytes == null) {
      setState(() => _error = 'Maak eerst een foto van het insect.');
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
      _lastResult = null;
    });

    final spaceId =
        widget.gardenStore.activeSpace?.id ?? 'tuin_default';

    await _insectScanStore.addEntry(
      InsectScanEntry(
        id: 'ins_${DateTime.now().millisecondsSinceEpoch}',
        tuinSpaceId: spaceId,
        nameNl: 'Insect (scan)',
        benefit: InsectBenefit.neutral,
        summary:
            'Insecten-AI volgt in een volgende update. Entry staat in je logboek.',
        scannedAt: DateTime.now(),
      ),
    );

    if (!mounted) return;
    setState(() => _analyzing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Insect opgeslagen in Inzicht. Volledige herkenning komt later.',
        ),
      ),
    );
  }

  void _syncCurrentSlotFromImageBytes() {
    if (!_usesMultiPlantScan || !_plantCountConfirmed || _imageBytes == null) {
      return;
    }
    while (_sessionPhotos.length <= _currentPhotoSlot) {
      _sessionPhotos.add(null);
    }
    _sessionPhotos[_currentPhotoSlot] ??= _imageBytes;
  }

  List<Uint8List> _snapshotMultiScanPhotos() {
    _syncCurrentSlotFromImageBytes();
    final slots = _photoSlots;
    final photos = <Uint8List>[];
    for (var i = 0; i < slots.length; i++) {
      Uint8List? bytes;
      if (i < _sessionPhotos.length) {
        bytes = _sessionPhotos[i];
      }
      if (bytes == null && i == _currentPhotoSlot) {
        bytes = _imageBytes;
      }
      if (bytes != null) {
        photos.add(Uint8List.fromList(bytes));
      }
    }
    return photos;
  }

  Future<void> _analyze() async {
    if (_scanMode == ScanSubjectMode.insect) {
      await _analyzeInsect();
      return;
    }
    if (_scanMode == ScanSubjectMode.weed) {
      await _analyzeWeed();
      return;
    }

    final veg = _selected;
    if (veg == null) {
      setState(() => _error = 'Kies eerst een gewas uit Mijn moestuin.');
      return;
    }
    final profile = widget.profileStore.profileFor(veg.id);
    if (profile == null || !profile.isPlanted || !profile.isMoestuinActive) {
      setState(() {
        _error =
            'Markeer de plant eerst als gezaaid of geplant op Mijn moestuin.';
        _analyzing = false;
      });
      return;
    }
    if (_usesMultiPlantScan) {
      _syncCurrentSlotFromImageBytes();
      if (!_plantCountConfirmed) {
        setState(() => _error = 'Geef eerst aan hoeveel planten je hebt.');
        return;
      }
      if (!_allSessionPhotosCaptured) {
        setState(() => _error = 'Maak eerst alle benodigde foto\'s.');
        return;
      }
    } else if (_imageBytes == null) {
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

    final multiScanPhotos = _usesMultiPlantScan && _plantCountConfirmed
        ? _snapshotMultiScanPhotos()
        : null;
    final singlePhotoBytes =
        !_usesMultiPlantScan && _imageBytes != null
            ? Uint8List.fromList(_imageBytes!)
            : null;

    _pauseStoreListeners();
    try {
      await widget.profileStore.ensureProfile(veg.id);
      final profile = widget.profileStore.profileFor(veg.id)!;
      final previousAnalysis = profile.lastAnalysis;
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
      final mime = _mimeType ?? 'image/jpeg';

      late final PlantAiAnalysis result;
      late final Uint8List photoToSave;
      late final String imageFingerprint;

      if (_usesMultiPlantScan) {
        final slots = _photoSlots;
        final photos = multiScanPhotos ?? _snapshotMultiScanPhotos();
        if (photos.length < slots.length) {
          throw PlantPhotoAiException(
            'Maak eerst alle benodigde foto\'s.',
          );
        }
        if (photos.isEmpty) {
          throw PlantPhotoAiException(
            'Geen foto\'s om te analyseren. Kies opnieuw een foto.',
          );
        }
        final multi = await runMultiPlantScan(
          service: service,
          photos: photos,
          slots: slots,
          plantCount: _plantCountInput,
          vegetable: veg,
          profile: profile,
          mimeType: mime,
          plantWindowLabel: cal.plant,
          harvestWindowLabel: cal.harvest,
          outsidePlantingSeason: outsideSeason,
          daysSinceStatedPlantDate: daysSince,
        );
        result = multi.analysis;
        photoToSave = photos[multi.bestPhotoIndex];
        imageFingerprint = fingerprintImageBytes(photoToSave);
      } else {
        photoToSave = singlePhotoBytes ?? _imageBytes!;
        imageFingerprint = fingerprintImageBytes(photoToSave);
        result = await service.analyze(
          imageBytes: photoToSave,
          mimeType: mime,
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
      }

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
        photoToSave,
      );
      var updated = applyAiScanToProfile(
        profile,
        result,
        weeklyScanIntervalDays: widget.scanPrefs.weeklyScanIntervalDays,
        vegetable: veg,
        imageFingerprint: imageFingerprint,
        newScanPhotoPath: photoPath,
      );
      if (_usesMultiPlantScan) {
        updated = updated.copyWith(plantCount: _plantCountInput);
      }
      updated = syncPinnedMoestuinAction(
        profile: updated,
        vegetable: veg,
        scanPrefs: widget.scanPrefs,
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
          _lastScanPhotoPath = photoPath;
          _analyzing = false;
          if (wasProbe) _harvestProbeMode = false;
        });
        if (_usesMultiPlantScan) {
          final slots = _photoSlots;
          _sessionPhotos = List<Uint8List?>.filled(slots.length, null);
          _currentPhotoSlot = 0;
          _imageBytes = null;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasProbe
                  ? 'Proefoogst-scan opgeslagen · bekijk of je kunt oogsten'
                  : _usesMultiPlantScan
                      ? 'Scan opgeslagen · mooiste plant staat op je moestuin-kaart'
                      : 'Scan opgeslagen in je plantgeschiedenis',
            ),
          ),
        );
        if (scanResultSupportsFullPage(result)) {
          await openScanResultScreen(
            context,
            analysis: result,
            vegetable: veg,
            previousAnalysis: previousAnalysis,
            onNewScan: () => Navigator.of(context).pop(),
          );
        }
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
    } finally {
      _resumeStoreListeners();
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
      return 'Markeer de plant eerst als gezaaid of geplant op Mijn moestuin.';
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
        leading: widget.showHubBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackToHub,
              )
            : null,
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
          if (!_isDirectEntryScan) ...[
            const SizedBox(height: 12),
            ScanModeSelector(
              mode: _scanMode,
              onChanged: (m) => setState(() {
                _scanMode = m;
                _error = null;
              }),
            ),
          ],
          if (widget.gardenStore.activeSpace != null) ...[
            const SizedBox(height: 8),
            Text(
              'Moestuin: ${widget.gardenStore.activeSpace!.name}',
              style: t.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (widget.initialHubEntry == ScanHubEntry.plantDisease) ...[
            const _ScanContextBanner(
              icon: Icons.coronavirus_outlined,
              title: 'Plant ziekte scannen',
              body:
                  'Richt de camera op zieke bladeren, vlekken, schimmel of '
                  'beschadigd weefsel op je plant.',
            ),
            const SizedBox(height: 16),
          ],
          if (_scanMode == ScanSubjectMode.insect ||
              _scanMode == ScanSubjectMode.weed) ...[
            if (_scanMode == ScanSubjectMode.weed) ...[
              const _ScanContextBanner(
                icon: Icons.grass_outlined,
                title: 'Onkruid scannen',
                body:
                    'Maak een foto van ongewenste planten in je tuin om te '
                    'leren wat het is en wat je ermee kunt doen.',
              ),
              const SizedBox(height: 16),
            ],
            _PhotoCaptureCard(
              imageBytes: _imageBytes,
              analyzing: _analyzing,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
              onAnalyze: _analyze,
              canAnalyze: _imageBytes != null && !_analyzing,
            ),
          ] else if (plants.isEmpty)
            _EmptyGardenCard(
              onAddHint: widget.gardenStore.isEmpty
                  ? 'Voeg planten toe via Mijn moestuin (+).'
                  : 'Markeer eerst je planten als gezaaid of geplant op Mijn moestuin.',
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
            if (_usesMultiPlantScan && !_plantCountConfirmed) ...[
              _PlantCountCard(
                plantName: _selected?.nameNl ?? 'dit gewas',
                count: _plantCountInput,
                imageBytes: _imageBytes,
                analyzing: _analyzing,
                onCamera: () => _pickImage(ImageSource.camera),
                onGallery: () => _pickImage(ImageSource.gallery),
                onDecrement: _plantCountInput > 1
                    ? () => setState(() => _plantCountInput--)
                    : null,
                onIncrement: _plantCountInput < 99
                    ? () => setState(() => _plantCountInput++)
                    : null,
                onConfirm: _confirmPlantCount,
              ),
            ] else if (_usesMultiPlantScan && _plantCountConfirmed) ...[
              _MultiPlantScanCard(
                plantCount: _plantCountInput,
                slots: _photoSlots,
                currentSlot: _currentPhotoSlot,
                sessionPhotos: _sessionPhotos,
                imageBytes: _currentSlotBytes ?? _imageBytes,
                analyzing: _analyzing,
                onCamera: () => _pickImage(ImageSource.camera),
                onGallery: () => _pickImage(ImageSource.gallery),
                onPrevious: _currentPhotoSlot > 0 ? _goToPreviousPhotoSlot : null,
                onNext: _currentPhotoSlot < _photoSlots.length - 1
                    ? _goToNextPhotoSlot
                    : null,
                onChangeCount: _changePlantCount,
                onAnalyze: _analyze,
                canAnalyze:
                    _canScanSelected &&
                    _allSessionPhotosCaptured &&
                    !_analyzing &&
                    hasApiKey,
              ),
            ] else
              _PhotoCaptureCard(
                imageBytes: _imageBytes,
                analyzing: _analyzing,
                onCamera: () => _pickImage(ImageSource.camera),
                onGallery: () => _pickImage(ImageSource.gallery),
                onAnalyze: _analyze,
                canAnalyze: _canScanSelected &&
                    _imageBytes != null &&
                    !_analyzing &&
                    hasApiKey,
              ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(message: _error!),
          ],
          if (display != null) ...[
            if (scanResultSupportsFullPage(display))
              _ScanResultOpenBanner(
                vegetableName: _selected?.nameNl ?? 'Plant',
                onOpen: () => openScanResultScreen(
                  context,
                  analysis: display,
                  vegetable: _selected,
                  previousAnalysis: _lastResult != null &&
                          stored != null &&
                          stored.scannedAt != display.scannedAt
                      ? stored
                      : null,
                  onNewScan: () {
                    setState(() {
                      _lastResult = null;
                      _imageBytes = null;
                      _error = null;
                    });
                  },
                ),
              )
            else
              PlantScanResultCard(
                analysis: display,
                vegetable: _selected,
                previousAnalysis: _lastResult != null &&
                        stored != null &&
                        stored.scannedAt != _lastResult!.scannedAt
                    ? stored
                    : null,
                scanPhotoPath:
                    _lastScanPhotoPath ?? profile?.lastScanPhotoPath,
                onNewScan: () {
                  setState(() {
                    _lastResult = null;
                    _imageBytes = null;
                    _error = null;
                  });
                },
                savedToHistory: shouldPersistAiScan(display),
                ornamentalBloomOnly: _selected != null &&
                    isOrnamentalOnlyMoestuinCrop(_selected!),
                edibleBloomDual: _selected != null &&
                    isEdibleMoestuinBloomCrop(_selected!),
              ),
            if (!display.hasCropMismatch &&
                display.insight != null &&
                (_selectedId == null ||
                    widget.profileStore
                            .profileFor(_selectedId!)
                            ?.isMoestuinActive ==
                        true) &&
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

class _ScanContextBanner extends StatelessWidget {
  const _ScanContextBanner({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Material(
      color: cs.primaryContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: cs.primary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: t.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    body,
                    style: t.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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

class _PlantCountCard extends StatelessWidget {
  const _PlantCountCard({
    required this.plantName,
    required this.count,
    required this.imageBytes,
    required this.analyzing,
    required this.onCamera,
    required this.onGallery,
    required this.onDecrement,
    required this.onIncrement,
    required this.onConfirm,
  });

  final String plantName;
  final int count;
  final Uint8List? imageBytes;
  final bool analyzing;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final hasPhoto = imageBytes != null;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasPhoto)
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.memory(imageBytes!, fit: BoxFit.cover),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Hoeveel $plantName heb je?',
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  multiScanIntroText(count),
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: onDecrement,
                      icon: const Icon(Icons.remove),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '$count',
                        style: t.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton.filledTonal(
                      onPressed: onIncrement,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: analyzing ? null : onConfirm,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    count <= 5
                        ? 'Start · $count ${count == 1 ? 'foto' : 'foto\'s'}'
                        : 'Start · 5 foto\'s (steekproef)',
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

class _MultiPlantScanCard extends StatelessWidget {
  const _MultiPlantScanCard({
    required this.plantCount,
    required this.slots,
    required this.currentSlot,
    required this.sessionPhotos,
    required this.imageBytes,
    required this.analyzing,
    required this.onCamera,
    required this.onGallery,
    this.onPrevious,
    this.onNext,
    required this.onChangeCount,
    required this.onAnalyze,
    required this.canAnalyze,
  });

  final int plantCount;
  final List<ScanPhotoSlot> slots;
  final int currentSlot;
  final List<Uint8List?> sessionPhotos;
  final Uint8List? imageBytes;
  final bool analyzing;
  final VoidCallback onCamera;
  final VoidCallback onGallery;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback onChangeCount;
  final VoidCallback onAnalyze;
  final bool canAnalyze;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final slot = slots[currentSlot];
    final capturedCount =
        sessionPhotos.take(slots.length).where((p) => p != null).length;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foto ${currentSlot + 1} van ${slots.length}',
                        style: t.textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slot.label,
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (plantCount > 5) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$plantCount planten · $capturedCount van ${slots.length} klaar',
                          style: t.textTheme.bodySmall?.copyWith(
                            color: cs.primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                TextButton(
                  onPressed: analyzing ? null : onChangeCount,
                  child: const Text('Aantal'),
                ),
              ],
            ),
          ),
          AspectRatio(
            aspectRatio: 4 / 3,
            child: imageBytes != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(imageBytes!, fit: BoxFit.cover),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Material(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            onTap: analyzing ? null : onCamera,
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
                    margin: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.6),
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
                          'Losse foto van deze plant',
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
                Row(
                  children: [
                    if (onPrevious != null)
                      OutlinedButton(
                        onPressed: analyzing ? null : onPrevious,
                        child: const Text('Vorige'),
                      ),
                    const Spacer(),
                    if (onNext != null)
                      FilledButton.tonal(
                        onPressed:
                            imageBytes != null && !analyzing ? onNext : null,
                        child: const Text('Volgende foto'),
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
                    analyzing
                        ? 'AI analyseert ${slots.length} foto\'s…'
                        : 'Analyseer alle foto\'s',
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

class _ScanResultOpenBanner extends StatelessWidget {
  const _ScanResultOpenBanner({
    required this.vegetableName,
    required this.onOpen,
  });

  final String vegetableName;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFECFDF5),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF15803D),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scanresultaat · $vegetableName',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Bekijk taken, plantinfo en observaties',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
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

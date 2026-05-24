import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/ai_settings_store.dart';
import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../data/garden_notifications_sync.dart';
import '../data/garden_plant_schedule.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/plant_photo_ai_service.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
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
    this.initialVegetableId,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final AiSettingsStore aiSettings;
  final GardenScanPrefsStore scanPrefs;
  final String? initialVegetableId;

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
  bool _showKeyField = false;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.initialVegetableId;
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
    super.dispose();
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

  Future<void> _saveApiKey() async {
    await widget.aiSettings.setApiKey(_apiKeyController.text);
    if (mounted) {
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
      setState(() => _error = 'Maak eerst een foto van de plant.');
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
    });

    try {
      await widget.profileStore.ensureProfile(veg.id);
      final profile = widget.profileStore.profileFor(veg.id)!;
      final service = PlantPhotoAiService(apiKey: widget.aiSettings.apiKey);
      final result = await service.analyze(
        imageBytes: _imageBytes!,
        mimeType: _mimeType ?? 'image/jpeg',
        vegetable: veg,
        plantedAt: profile.plantedAt,
        locationLabel: profile.location.label,
        sunLabel: profile.sunLevel.label,
      );

      final updated = applyAiScanToProfile(
        profile,
        result,
        weeklyScanIntervalDays: widget.scanPrefs.weeklyScanIntervalDays,
      );
      await widget.profileStore.saveProfile(updated);
      await syncGardenNotifications(
        profileStore: widget.profileStore,
        gardenStore: widget.gardenStore,
        repository: widget.repository,
        scanPrefs: widget.scanPrefs,
      );

      if (mounted) {
        setState(() {
          _lastResult = result;
          _analyzing = false;
        });
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

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final plants = _myPlants;
    final stored = _selectedId != null
        ? widget.profileStore.profileFor(_selectedId!)?.lastAnalysis
        : null;
    final display = _lastResult ?? stored;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant scan'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            'Maak een foto van je plant. De AI schat de groeifase en wanneer je kunt oogsten — accurater dan handmatig aanvinken.',
            style: t.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          if (!widget.aiSettings.hasApiKey) ...[
            Material(
              color: t.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gemini API-sleutel nodig',
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Gratis aan te maken op aistudio.google.com → API key. '
                      'De sleutel blijft op je telefoon.',
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API-sleutel',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      obscureText: true,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _saveApiKey,
                      child: const Text('Sleutel opslaan'),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            TextButton(
              onPressed: () => setState(() => _showKeyField = !_showKeyField),
              child: Text(_showKeyField ? 'API-sleutel verbergen' : 'API-sleutel wijzigen'),
            ),
            if (_showKeyField) ...[
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API-sleutel',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _saveApiKey,
                child: const Text('Opslaan'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _reloadLocalApiKey,
                child: const Text('Sleutel opnieuw laden uit project'),
              ),
              const SizedBox(height: 12),
            ],
          ],
          if (plants.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'Voeg eerst groenten toe in Mijn moestuin.',
                style: t.textTheme.bodyLarge?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            )
          else ...[
            Text('Gewas', style: t.textTheme.labelLarge),
            const SizedBox(height: 8),
            ...plants.map((v) {
              final selected = v.id == _selectedId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: selected
                      ? t.colorScheme.primaryContainer
                      : t.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => setState(() {
                      _selectedId = v.id;
                      _lastResult = null;
                      _error = null;
                    }),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          VegetableThumbnail(vegetable: v, size: 40),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              v.nameNl,
                              style: t.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle, color: t.colorScheme.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            if (_imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 160,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.photo_camera_outlined,
                  size: 48,
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _analyzing
                        ? null
                        : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Camera'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _analyzing
                        ? null
                        : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Galerij'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _analyzing || _imageBytes == null ? null : _analyze,
              icon: _analyzing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(_analyzing ? 'Analyseren…' : 'Analyseer foto'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.error,
              ),
            ),
          ],
          if (display != null) ...[
            const SizedBox(height: 20),
            _AnalysisCard(analysis: display),
          ],
        ],
      ),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard({required this.analysis});

  final PlantAiAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Material(
      color: t.colorScheme.primaryContainer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resultaat',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              analysis.phaseLabel,
              style: t.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (analysis.daysUntilHarvest != null)
              Text(
                analysis.phase == PlantAiPhase.ripe
                    ? 'Nu oogsten'
                    : 'Geschatte oogst over ±${analysis.daysUntilHarvest} dagen',
                style: t.textTheme.bodyLarge,
              ),
            Text(
              'Venster: ${analysis.harvestWindowLabel}',
              style: t.textTheme.bodyMedium,
            ),
            Text(
              'Betrouwbaarheid: ${analysis.confidencePercent}%',
              style: t.textTheme.labelLarge?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(analysis.advice),
            if (analysis.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...analysis.warnings.map(
                (w) => Text(
                  '⚠ $w',
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

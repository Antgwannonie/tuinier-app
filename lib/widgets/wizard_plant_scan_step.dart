import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/ai_settings_store.dart';
import '../data/plant_photo_ai_service.dart';
import '../data/plant_scan_persist_policy.dart';
import '../data/wizard_plant_scan_analyze.dart';
import '../models/add_plant_setup_result.dart';
import '../models/add_plant_wizard_models.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import '../screens/scan_result_screen.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/vegetable_thumbnail.dart';
import 'add_plant_wizard_ui.dart';
import 'plant_setup_sheet_ui.dart';

/// Stap 3 in de wizard bij «ik heb deze plant al»: inline AI-plantscan.
class WizardPlantScanStep extends StatefulWidget {
  const WizardPlantScanStep({
    super.key,
    required this.vegetable,
    required this.previewProfile,
    required this.aiSettings,
    required this.onScanReady,
    this.onWizardContinue,
    this.initialScan,
  });

  final Vegetable vegetable;
  final GardenPlantProfile previewProfile;
  final AiSettingsStore aiSettings;
  final ValueChanged<WizardInitialScan?> onScanReady;
  final VoidCallback? onWizardContinue;
  final WizardInitialScan? initialScan;

  @override
  State<WizardPlantScanStep> createState() => _WizardPlantScanStepState();
}

class _WizardPlantScanStepState extends State<WizardPlantScanStep> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _apiKeyController = TextEditingController();

  Uint8List? _imageBytes;
  PlantAiAnalysis? _analysis;
  bool _analyzing = false;
  String? _error;
  bool _persistable = false;

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = widget.aiSettings.apiKey;
    _restoreFromInitial(widget.initialScan);
  }

  @override
  void didUpdateWidget(covariant WizardPlantScanStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialScan != oldWidget.initialScan) {
      _restoreFromInitial(widget.initialScan);
    }
  }

  void _restoreFromInitial(WizardInitialScan? scan) {
    if (scan == null) return;
    _imageBytes = scan.photoBytes;
    _analysis = scan.analysis;
    _persistable = shouldPersistAiScan(scan.analysis);
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
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
        _analysis = null;
        _persistable = false;
        _error = null;
      });
      widget.onScanReady(null);
    } catch (_) {
      setState(() => _error = 'Foto kon niet worden geladen.');
    }
  }

  Future<void> _saveApiKey() async {
    await widget.aiSettings.setApiKey(_apiKeyController.text);
    if (mounted) Navigator.pop(context);
    setState(() {});
  }

  void _openApiKeySheet() {
    final t = Theme.of(context);
    _apiKeyController.text = widget.aiSettings.apiKey;
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
            ],
          ),
        );
      },
    );
  }

  Future<void> _analyze() async {
    if (_imageBytes == null) {
      setState(() => _error = 'Maak eerst een foto van je plant.');
      return;
    }
    if (!widget.aiSettings.hasApiKey) {
      setState(() => _error = 'Voeg eerst een API-sleutel toe.');
      _openApiKeySheet();
      return;
    }

    setState(() {
      _analyzing = true;
      _error = null;
    });

    try {
      final result = await analyzeWizardPlantScan(
        apiKey: widget.aiSettings.apiKey,
        vegetable: widget.vegetable,
        previewProfile: widget.previewProfile,
        imageBytes: _imageBytes!,
      );
      final persistable = shouldPersistAiScan(result);
      final initialScan = WizardInitialScan(
        analysis: result,
        photoBytes: _imageBytes!,
      );

      if (!mounted) return;
      setState(() {
        _analysis = result;
        _analyzing = false;
        _persistable = persistable;
        if (!persistable) {
          _error = scanNotPersistedMessage(result);
        }
      });

      if (persistable) {
        widget.onScanReady(initialScan);
        await _openScanResult(result);
      } else {
        widget.onScanReady(null);
      }
    } on PlantPhotoAiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _analyzing = false;
      });
      widget.onScanReady(null);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Analyse mislukt. Controleer internet en API-sleutel.';
        _analyzing = false;
      });
      widget.onScanReady(null);
    }
  }

  Future<void> _openScanResult(PlantAiAnalysis analysis) async {
    if (!mounted || !scanResultSupportsFullPage(analysis)) return;
    await openScanResultScreen(
      context,
      analysis: analysis,
      vegetable: widget.vegetable,
      wizardMode: true,
      onWizardContinue: widget.onWizardContinue == null
          ? null
          : () {
              Navigator.of(context).pop();
              widget.onWizardContinue!();
            },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final hasApiKey = widget.aiSettings.hasApiKey;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      children: [
        const WizardStepTitle(
          title: 'Scan nu je plant',
          subtitle:
              'Maak een foto en laat onze AI kijken. Zo weten we precies in welke fase je plant zit.',
        ),
        const SizedBox(height: 16),
        _WizardScanHeroCard(vegetable: widget.vegetable),
        const SizedBox(height: 16),
        if (!hasApiKey) ...[
          PlantSetupSurfaceCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.key_rounded, color: TuinierColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'API-sleutel nodig voor de scan',
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Voeg je gratis Gemini-sleutel toe om de AI-scan te starten.',
                        style: t.textTheme.bodySmall?.copyWith(height: 1.35),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _openApiKeySheet,
                        child: const Text('Sleutel toevoegen'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        _WizardScanCaptureCard(
          imageBytes: _imageBytes,
          analyzing: _analyzing,
          onCamera: () => _pickImage(ImageSource.camera),
          onGallery: () => _pickImage(ImageSource.gallery),
          onAnalyze: _analyze,
          canAnalyze: _imageBytes != null && !_analyzing && hasApiKey,
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(
            _error!,
            style: t.textTheme.bodySmall?.copyWith(
              color: TuinierColors.warning,
              height: 1.35,
            ),
          ),
        ],
        if (_analysis != null && _persistable) ...[
          const SizedBox(height: 16),
          _WizardScanResultBanner(
            onTap: () => _openScanResult(_analysis!),
          ),
          const SizedBox(height: 8),
          Text(
            'Je scanresultaat opent automatisch. Gebruik «Volgende» onderaan om verder te gaan met de stappen.',
            style: t.textTheme.bodySmall?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _WizardScanResultBanner extends StatelessWidget {
  const _WizardScanResultBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFECFDF5),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF86EFAC)),
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_awesome, color: Color(0xFF15803D)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Scanresultaat bekijken',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
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

class _WizardScanHeroCard extends StatelessWidget {
  const _WizardScanHeroCard({required this.vegetable});

  final Vegetable vegetable;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            TuinierColors.primary.withValues(alpha: 0.14),
            TuinierColors.scanHover.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TuinierColors.border),
      ),
      child: Row(
        children: [
          VegetableThumbnail(vegetable: vegetable, size: 56, borderRadius: 12),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      size: 18,
                      color: TuinierColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'AI kijkt mee',
                      style: t.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TuinierColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Fotografeer ${vegetable.nameNl} duidelijk van voren: blad, stengel en eventuele bloei of vruchten.',
                  style: t.textTheme.bodySmall?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardScanCaptureCard extends StatelessWidget {
  const _WizardScanCaptureCard({
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
                      Image.memory(imageBytes!, fit: BoxFit.cover),
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
                    color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.document_scanner_outlined,
                          size: 48,
                          color: TuinierColors.primary.withValues(alpha: 0.75),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Nog geen foto',
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
                      child: _WizardScanSourceButton(
                        icon: Icons.photo_camera_outlined,
                        label: 'Camera',
                        onTap: analyzing ? null : onCamera,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _WizardScanSourceButton(
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
                    analyzing ? 'AI bekijkt je plant…' : 'Laat AI je plant bekijken',
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

class _WizardScanSourceButton extends StatelessWidget {
  const _WizardScanSourceButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

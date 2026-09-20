import 'package:flutter/material.dart';

import '../data/vegetable_repository.dart';
import '../data/visual_garden_bed_colors.dart';
import '../data/visual_garden_crop_suggest.dart';
import '../data/visual_garden_geometry.dart';
import '../models/vegetable.dart';
import '../models/visual_garden_plan.dart';
import '../theme/tuinier_colors.dart';
import 'vegetable_thumbnail.dart';

class NextCropSheetResult {
  const NextCropSheetResult({
    required this.createPlan,
    this.seedPlacements = const [],
  });

  final bool createPlan;
  final List<PlantPlacement> seedPlacements;
}

/// Bottom sheet: uitleg + bakpreview + suggesties (zelfde/kleinere afmetingen).
Future<NextCropSheetResult?> showNextCropSheet({
  required BuildContext context,
  required VisualGardenBed bed,
  required VisualCropPlan previous,
  required VegetableRepository repository,
}) {
  return showModalBottomSheet<NextCropSheetResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => _NextCropSheet(
      bed: bed,
      previous: previous,
      repository: repository,
    ),
  );
}

class _NextCropSheet extends StatefulWidget {
  const _NextCropSheet({
    required this.bed,
    required this.previous,
    required this.repository,
  });

  final VisualGardenBed bed;
  final VisualCropPlan previous;
  final VegetableRepository repository;

  @override
  State<_NextCropSheet> createState() => _NextCropSheetState();
}

class _NextCropSheetState extends State<_NextCropSheet> {
  late final DateTime _availableFrom;
  late final double _maxSpacing;
  late final List<NextCropSuggestion> _suggestions;
  late final Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _availableFrom = bedAvailableAfterPlan(
      plan: widget.previous,
      repository: widget.repository,
    );
    _maxSpacing = maxPlantSpacingCmFromPlan(
      plan: widget.previous,
      repository: widget.repository,
    );
    _suggestions = suggestNextCropPlants(
      previous: widget.previous,
      repository: widget.repository,
      availableFrom: _availableFrom,
      maxSpacingCm: _maxSpacing,
    );
    _selectedIds = {
      for (final s in _suggestions.take(4)) s.plant.id,
    };
  }

  List<Vegetable> get _selectedPlants => [
        for (final s in _suggestions)
          if (_selectedIds.contains(s.plant.id)) s.plant,
      ];

  List<PlantPlacement> get _previewPlacements => previewPlacementsForNextCrop(
        bed: widget.bed,
        plants: _selectedPlants,
      );

  @override
  Widget build(BuildContext context) {
    const monthNames = [
      '',
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];
    final freeMonth = monthNames[_availableFrom.month];
    final height = MediaQuery.sizeOf(context).height * 0.88;

    return SafeArea(
      child: SizedBox(
        height: height,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welke teelt past hierna?',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Na de oogst komt dezelfde bak (of een deel ervan) vrij. '
                'Niet elke plant is tegelijk klaar — kies hier planten die '
                'passen qua seizoen én plantzone. Later kun je bij '
                '“Plant toevoegen” ook filteren op “Na oogst van…” per plant.',
                style: TextStyle(
                  color: TuinierColors.textSecondary,
                  height: 1.35,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: VisualGardenBedColors.softGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Geschatte start rond $freeMonth ${_availableFrom.year} '
                  '(laatste oogst in “${widget.previous.name}”). '
                  'Max. plantzone: ${_maxSpacing.round()} cm — alleen '
                  'passende maten hieronder.',
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                    color: VisualGardenBedColors.titleGreen,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Zelfde bak · volgende teelt',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: VisualGardenBedColors.titleGreen,
                    ),
              ),
              const SizedBox(height: 6),
              _BedPreview(
                bed: widget.bed,
                repository: widget.repository,
                placements: _previewPlacements,
              ),
              const SizedBox(height: 10),
              Text(
                'Tik planten aan om ze in de bakpreview te zetten',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: TuinierColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 6),
              Expanded(
                child: _suggestions.isEmpty
                    ? const Center(
                        child: Text(
                          'Geen passende opvolgers gevonden voor deze '
                          'periode en plantafmetingen.',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.separated(
                        itemCount: _suggestions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final s = _suggestions[i];
                          final selected = _selectedIds.contains(s.plant.id);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _selectedIds.remove(s.plant.id);
                                } else {
                                  _selectedIds.add(s.plant.id);
                                }
                              });
                            },
                            leading: VegetableThumbnail(
                              vegetable: s.plant,
                              size: 40,
                            ),
                            title: Text(
                              s.plant.nameNl,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              s.reason,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Checkbox(
                              value: selected,
                              activeColor: VisualGardenBedColors.titleGreen,
                              onChanged: (v) {
                                setState(() {
                                  if (v == true) {
                                    _selectedIds.add(s.plant.id);
                                  } else {
                                    _selectedIds.remove(s.plant.id);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () {
                  final seeds = _previewPlacements
                      .map(
                        (p) => PlantPlacement(
                          id: 'pl_${DateTime.now().microsecondsSinceEpoch}_${p.plantId}_${p.xCm.toInt()}',
                          plantId: p.plantId,
                          xCm: p.xCm,
                          yCm: p.yCm,
                          spacingCm: p.spacingCm,
                          createdAt: DateTime.now(),
                        ),
                      )
                      .toList();
                  Navigator.pop(
                    context,
                    NextCropSheetResult(
                      createPlan: true,
                      seedPlacements: seeds,
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(
                  _selectedIds.isEmpty
                      ? 'Nieuw leeg teeltplan starten'
                      : 'Teeltplan starten met ${_selectedIds.length} plant'
                          '${_selectedIds.length == 1 ? '' : 'en'}',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6B32),
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BedPreview extends StatelessWidget {
  const _BedPreview({
    required this.bed,
    required this.repository,
    required this.placements,
  });

  final VisualGardenBed bed;
  final VegetableRepository repository;
  final List<PlantPlacement> placements;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: bed.widthCm / bed.heightCm.clamp(1, 9999),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 180),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = BedScale(
              widthCm: bed.widthCm,
              heightCm: bed.heightCm,
              displayWidthPx: constraints.maxWidth - 8,
              displayHeightPx: constraints.maxHeight - 8,
              originPx: const Offset(4, 4),
            );
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: TuinierColors.border),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      painter: _PreviewBedPainter(
                        verticesCm: bed.verticesCm,
                        scale: scale,
                        borderColor: bed.borderColor,
                        fillColor: bed.fillColor,
                      ),
                    ),
                    for (final p in placements)
                      _previewZone(
                        scale: scale,
                        placement: p,
                        vegetable: repository.byId(p.plantId),
                      ),
                    if (placements.isEmpty)
                      const Center(
                        child: Text(
                          'Selecteer planten hieronder',
                          style: TextStyle(
                            fontSize: 12,
                            color: TuinierColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _previewZone({
    required BedScale scale,
    required PlantPlacement placement,
    required Vegetable? vegetable,
  }) {
    final center = scale.cmToPx(placement.xCm, placement.yCm);
    final zone = scale.zoneSizePx(placement.spacingCm);
    final w = zone.width.clamp(28.0, 72.0);
    final h = zone.height.clamp(28.0, 72.0);
    return Positioned(
      left: center.dx - w / 2,
      top: center.dy - h / 2,
      width: w,
      height: h,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: VisualGardenBedColors.softGreen.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: VisualGardenBedColors.titleGreen, width: 1.5),
        ),
        child: vegetable == null
            ? const SizedBox.shrink()
            : VegetableThumbnail(
                vegetable: vegetable,
                size: w < h ? w : h,
                borderRadius: 6,
              ),
      ),
    );
  }
}

class _PreviewBedPainter extends CustomPainter {
  _PreviewBedPainter({
    required this.verticesCm,
    required this.scale,
    required this.borderColor,
    required this.fillColor,
  });

  final List<Offset> verticesCm;
  final BedScale scale;
  final Color borderColor;
  final Color fillColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (verticesCm.length < 3) return;
    final path = Path()
      ..moveTo(
        scale.cmToPx(verticesCm.first.dx, verticesCm.first.dy).dx,
        scale.cmToPx(verticesCm.first.dx, verticesCm.first.dy).dy,
      );
    for (var i = 1; i < verticesCm.length; i++) {
      final p = scale.cmToPx(verticesCm[i].dx, verticesCm[i].dy);
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant _PreviewBedPainter oldDelegate) =>
      oldDelegate.verticesCm != verticesCm ||
      oldDelegate.fillColor != fillColor ||
      oldDelegate.borderColor != borderColor;
}

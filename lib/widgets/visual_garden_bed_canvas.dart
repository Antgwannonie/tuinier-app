import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/plant_planner_spacing.dart';
import '../data/vegetable_repository.dart';
import '../data/visual_garden_bed_colors.dart';
import '../data/visual_garden_geometry.dart';
import '../models/visual_garden_plan.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import 'vegetable_thumbnail.dart';

/// Canvas van één bak: plantzones op schaal, sleep + vinkje om te bevestigen.
class VisualGardenBedCanvas extends StatefulWidget {
  const VisualGardenBedCanvas({
    super.key,
    required this.bed,
    required this.repository,
    required this.selected,
    required this.pendingPlant,
    required this.onSelectBed,
    required this.onPlacementChanged,
    required this.onPendingPlaced,
    required this.onSelectPlacement,
    this.onCancelPending,
    this.onDeletePlacement,
    this.onDragActiveChanged,
    this.selectedPlacementId,
    this.highlightConflictIds = const {},
    this.showChrome = false,
    /// Doelgrootte van de korte zijde van de bak op het scherm (px).
    /// Groter = makkelijker slepen; cm-verhouding bak↔plant blijft gelijk.
    this.maxHeight = 380,
  });

  final VisualGardenBed bed;
  final VegetableRepository repository;
  final bool selected;
  final Vegetable? pendingPlant;
  final VoidCallback onSelectBed;
  final ValueChanged<PlantPlacement> onPlacementChanged;
  final ValueChanged<PlantPlacement> onPendingPlaced;
  final ValueChanged<String?> onSelectPlacement;
  final VoidCallback? onCancelPending;
  final ValueChanged<String>? onDeletePlacement;
  /// true terwijl de gebruiker een plant versleept (parent kan scroll blokkeren).
  final ValueChanged<bool>? onDragActiveChanged;
  final String? selectedPlacementId;
  final Set<String> highlightConflictIds;
  final bool showChrome;
  final double maxHeight;

  @override
  State<VisualGardenBedCanvas> createState() => _VisualGardenBedCanvasState();
}

class _VisualGardenBedCanvasState extends State<VisualGardenBedCanvas> {
  static const _labelPad = 12.0;
  /// Extra ruimte boven/onder zodat ✓ / prullenbak buiten de bak nog klikbaar zijn.
  static const _controlPad = 52.0;

  final _canvasKey = GlobalKey();

  String? _draggingId;
  Offset? _dragCm;
  double? _dragSpacing;
  PlacementValidity? _dragValidity;
  Offset? _pendingCm;
  /// Vingerpositie (lokaal op canvas) tijdens slepen — plant zweeft erboven.
  Offset? _fingerLocal;
  int _lastValidityMs = 0;
  /// Startpunt van de huidige aanraking (om tik vs sleep te onderscheiden).
  Offset? _pointerDownGlobal;
  bool _movedBeyondSlop = false;

  double _spacingFor(String plantId, double fallback) {
    final catalog =
        widget.repository.byId(plantId)?.spacingCm.toDouble() ?? fallback;
    return plannerSpacingCmFor(plantId, fallbackCm: catalog);
  }

  double _spacingForVegetable(Vegetable plant) {
    return plannerSpacingCmForVegetable(plant);
  }

  BedScale _scale(Size size) {
    final innerW = math.max(size.width - _labelPad * 2, 1.0);
    final innerH =
        math.max(size.height - _labelPad * 2 - _controlPad * 2, 1.0);
    return BedScale(
      widthCm: widget.bed.widthCm,
      heightCm: widget.bed.heightCm,
      displayWidthPx: innerW,
      displayHeightPx: innerH,
      originPx: const Offset(_labelPad, _labelPad + _controlPad),
    );
  }

  Offset? _localFromGlobal(Offset global) {
    final box = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.globalToLocal(global);
  }

  Offset _defaultPendingSpot() {
    final bed = widget.bed;
    final spacing = widget.pendingPlant != null
        ? _spacingForVegetable(widget.pendingPlant!)
        : 25.0;
    // Zoek een vrije plek; anders midden.
    for (final candidate in [
      Offset(bed.widthCm * 0.35, bed.heightCm * 0.35),
      Offset(bed.widthCm * 0.65, bed.heightCm * 0.35),
      Offset(bed.widthCm * 0.35, bed.heightCm * 0.65),
      Offset(bed.widthCm * 0.65, bed.heightCm * 0.65),
      Offset(bed.widthCm / 2, bed.heightCm / 2),
    ]) {
      final v = checkPlacement(
        bed: bed,
        xCm: candidate.dx,
        yCm: candidate.dy,
        spacingCm: spacing,
        ignorePlacementId: null,
        spacingFor: _spacingFor,
      );
      if (v.isValid) return candidate;
    }
    return Offset(bed.widthCm / 2, bed.heightCm / 2);
  }

  void _ensurePendingPosition() {
    if (widget.pendingPlant == null) {
      _pendingCm = null;
      return;
    }
    _pendingCm ??= _defaultPendingSpot();
  }

  void _setDragActive(bool active) {
    widget.onDragActiveChanged?.call(active);
  }

  void _beginPlantDrag({
    required String dragId,
    required double xCm,
    required double yCm,
    required double spacing,
    required bool isPending,
    required Offset globalPosition,
  }) {
    widget.onSelectBed();
    if (isPending) {
      widget.onSelectPlacement(null);
    } else {
      widget.onSelectPlacement(dragId);
    }
    final local = _localFromGlobal(globalPosition);
    setState(() {
      _draggingId = dragId;
      _dragCm = Offset(xCm, yCm);
      _dragSpacing = spacing;
      _fingerLocal = local;
      _lastValidityMs = 0;
      _pointerDownGlobal = globalPosition;
      _movedBeyondSlop = false;
    });
    _setDragActive(true);
  }

  void _finishPlantDrag({
    required String dragId,
    required String plantId,
    required double spacing,
    required bool isPending,
  }) {
    final moved = _movedBeyondSlop;
    if (moved) {
      _onDragEnd(
        dragId: dragId,
        plantId: plantId,
        spacing: spacing,
        isPending: isPending,
      );
    } else {
      // Korte tik zonder sleep: selectie behouden / pending gefocust houden.
      setState(() {
        _draggingId = null;
        _dragCm = null;
        _dragSpacing = null;
        _dragValidity = null;
        _fingerLocal = null;
        _pointerDownGlobal = null;
        _movedBeyondSlop = false;
      });
    }
    _setDragActive(false);
  }

  void _cancelPlantDrag() {
    setState(() {
      _draggingId = null;
      _dragCm = null;
      _dragSpacing = null;
      _dragValidity = null;
      _fingerLocal = null;
      _pointerDownGlobal = null;
      _movedBeyondSlop = false;
    });
    _setDragActive(false);
  }

  void _onDragUpdate({
    required Offset global,
    required Size canvasSize,
    required String dragId,
    required double spacing,
  }) {
    final down = _pointerDownGlobal;
    if (down != null && !_movedBeyondSlop) {
      const slop = 10.0;
      if ((global - down).distance > slop) {
        _movedBeyondSlop = true;
      }
    }
    // Pas na echte sleepbeweging de plant meenemen (voorkomt jump bij tik).
    if (!_movedBeyondSlop) {
      setState(() => _fingerLocal = _localFromGlobal(global));
      return;
    }

    final local = _localFromGlobal(global);
    if (local == null) return;
    // Plant zweeft iets boven de vinger, goed zichtbaar tijdens slepen.
    const liftPx = 56.0;
    final plantLocal = Offset(local.dx, local.dy - liftPx);
    final cm = _scale(canvasSize).pxToCm(plantLocal);
    final x = cm.dx.clamp(0.0, widget.bed.widthCm);
    final y = cm.dy.clamp(0.0, widget.bed.heightCm);

    // Positie altijd updaten; validity iets minder vaak voor soepeler sleep.
    final now = DateTime.now().millisecondsSinceEpoch;
    final shouldCheckValidity =
        _dragValidity == null || now - _lastValidityMs > 40;
    PlacementValidity? validity = _dragValidity;
    if (shouldCheckValidity) {
      validity = checkPlacement(
        bed: widget.bed,
        xCm: x,
        yCm: y,
        spacingCm: spacing,
        ignorePlacementId: dragId == '_pending' ? null : dragId,
        spacingFor: _spacingFor,
      );
      _lastValidityMs = now;
    }

    setState(() {
      _draggingId = dragId;
      _dragCm = Offset(x, y);
      _dragSpacing = spacing;
      if (validity != null) _dragValidity = validity;
      _fingerLocal = local;
      if (dragId == '_pending') {
        _pendingCm = Offset(x, y);
      }
    });
  }

  void _onDragEnd({
    required String dragId,
    required String plantId,
    required double spacing,
    required bool isPending,
  }) {
    final pos = _dragCm;
    final validity = _dragValidity;
    if (!isPending &&
        pos != null &&
        validity != null &&
        validity.isValid) {
      final existing =
          widget.bed.placements.firstWhere((p) => p.id == dragId);
      widget.onPlacementChanged(
        existing.copyWith(xCm: pos.dx, yCm: pos.dy, spacingCm: spacing),
      );
    }
    setState(() {
      _draggingId = null;
      _dragCm = null;
      _dragSpacing = null;
      _dragValidity = null;
      _fingerLocal = null;
      _pointerDownGlobal = null;
      _movedBeyondSlop = false;
    });
  }

  void _confirmPending() {
    final plant = widget.pendingPlant;
    final pos = _pendingCm;
    if (plant == null || pos == null) return;
    final spacing = _spacingForVegetable(plant);
    final validity = checkPlacement(
      bed: widget.bed,
      xCm: pos.dx,
      yCm: pos.dy,
      spacingCm: spacing,
      ignorePlacementId: null,
      spacingFor: _spacingFor,
    );
    if (!validity.isValid) return;
    final now = DateTime.now();
    widget.onPendingPlaced(
      PlantPlacement(
        id: 'pl_${now.microsecondsSinceEpoch}_${math.Random().nextInt(9999)}',
        plantId: plant.id,
        xCm: pos.dx,
        yCm: pos.dy,
        spacingCm: spacing,
        createdAt: now,
      ),
    );
    // Houd dezelfde soort klaar voor nog een plant; zoek meteen een vrije plek.
    setState(() {
      _pendingCm = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.pendingPlant == null) return;
      setState(() {
        _pendingCm = _defaultPendingSpot();
      });
    });
  }

  void _lockSelectedPlacement() {
    widget.onSelectPlacement(null);
  }

  @override
  void didUpdateWidget(covariant VisualGardenBedCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pendingPlant == null) {
      _pendingCm = null;
      _draggingId = null;
      _dragCm = null;
      _dragValidity = null;
    } else if (widget.pendingPlant?.id != oldWidget.pendingPlant?.id) {
      _pendingCm = _defaultPendingSpot();
      _draggingId = null;
      _dragCm = null;
      _dragValidity = null;
    } else if (widget.pendingPlant != null &&
        widget.bed.placements.length != oldWidget.bed.placements.length) {
      // Na plaatsen van dezelfde soort: nieuwe vrije startpositie.
      _pendingCm = _defaultPendingSpot();
    }
  }

  /// Schermgrootte van de bak: korte zijde ≈ [maxHeight], zodat slepen
  /// makkelijker is. Breedte/hoogte in cm blijven leidend voor plantzones.
  Size _displayInnerSize(double availableWidth) {
    final bed = widget.bed;
    final wCm = math.max(bed.widthCm, 1.0);
    final hCm = math.max(bed.heightCm, 1.0);
    final shortCm = math.min(wCm, hCm);
    final longCm = math.max(wCm, hCm);

    // Korte zijde groter op het scherm; lange zijde mag scrollen.
    final targetShort = widget.maxHeight;
    var pxPerCm = targetShort / shortCm;
    // Voorkom extreem brede/hoge canvas (bijv. 30×300 cm).
    final maxLongPx = widget.maxHeight * 2.4;
    if (longCm * pxPerCm > maxLongPx) {
      pxPerCm = maxLongPx / longCm;
    }
    // Niet kleiner dan beschikbaar breedte als die al ruim genoeg is.
    final fitW = math.max(availableWidth - _labelPad * 2, 1.0);
    final fitPxPerCm = fitW / wCm;
    if (fitPxPerCm > pxPerCm && hCm * fitPxPerCm <= widget.maxHeight * 1.15) {
      pxPerCm = fitPxPerCm;
    }

    return Size(wCm * pxPerCm, hCm * pxPerCm);
  }

  @override
  Widget build(BuildContext context) {
    _ensurePendingPosition();

    final body = LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth;
        final inner = _displayInnerSize(maxW);
        final totalW = inner.width + _labelPad * 2;
        final totalH = inner.height + _labelPad * 2 + _controlPad * 2;
        final canvas = SizedBox(
          key: _canvasKey,
          width: totalW,
          height: totalH,
          child: Listener(
            behavior: HitTestBehavior.translucent,
            onPointerMove: (e) {
              final id = _draggingId;
              final spacing = _dragSpacing;
              if (id == null || spacing == null) return;
              _onDragUpdate(
                global: e.position,
                canvasSize: Size(totalW, totalH),
                dragId: id,
                spacing: spacing,
              );
            },
            child: _canvas(Size(totalW, totalH)),
          ),
        );
        return Column(
          children: [
            if (totalW > maxW)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: _draggingId != null
                    ? const NeverScrollableScrollPhysics()
                    : null,
                child: canvas,
              )
            else
              Center(child: canvas),
            if (_dragValidity != null &&
                !_dragValidity!.isValid &&
                _draggingId != null) ...[
              const SizedBox(height: 6),
              Text(
                !_dragValidity!.insideBed
                    ? 'Deze plant past hier niet volledig.'
                    : 'Deze planten staan te dicht op elkaar.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: TuinierColors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );

    if (!widget.showChrome) {
      return GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () {
          // Alleen deselecteren bij tik op lege ruimte; knoppen buiten de
          // bak-polygoon blijven via _controlPad gewoon klikbaar.
          widget.onSelectBed();
          widget.onSelectPlacement(null);
        },
        child: body,
      );
    }

    return GestureDetector(
      onTap: widget.onSelectBed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: TuinierColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.selected
                ? TuinierColors.primary
                : TuinierColors.border,
            width: widget.selected ? 2 : 1,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: body,
      ),
    );
  }

  bool get _pendingIsValid {
    final plant = widget.pendingPlant;
    final pos = _pendingCm;
    if (plant == null || pos == null) return false;
    return checkPlacement(
      bed: widget.bed,
      xCm: pos.dx,
      yCm: pos.dy,
      spacingCm: _spacingForVegetable(plant),
      ignorePlacementId: null,
      spacingFor: _spacingFor,
    ).isValid;
  }

  Widget _canvas(Size size) {
    final scale = _scale(size);
    final bed = widget.bed;
    final pendingPos = _pendingCm;
    final selectedId = widget.selectedPlacementId;
    PlantPlacement? selectedPlacement;
    for (final p in bed.placements) {
      if (p.id == selectedId) {
        selectedPlacement = p;
        break;
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        CustomPaint(
          size: size,
          painter: _PolygonBedPainter(
            verticesCm: bed.verticesCm,
            scale: scale,
            borderColor: bed.borderColor,
            fillColor: bed.fillColor,
            widthCm: bed.widthCm,
            depthCm: bed.heightCm,
            edgeLengthsCm: bed.edgeLengthsCm,
          ),
        ),
        // Niet-geselecteerde planten onderaan.
        for (final p in bed.placements)
          if (_draggingId != p.id && p.id != selectedId)
            _zone(
              canvasSize: size,
              scale: scale,
              plantId: p.plantId,
              xCm: p.xCm,
              yCm: p.yCm,
              spacing: _spacingFor(p.plantId, p.spacingCm),
              dragId: p.id,
              isPending: false,
              forcedValid: !widget.highlightConflictIds.contains(p.id),
              selected: false,
            ),
        // Geselecteerde plant + knoppen boven andere planten.
        if (selectedPlacement != null && _draggingId != selectedPlacement.id)
          _zone(
            canvasSize: size,
            scale: scale,
            plantId: selectedPlacement.plantId,
            xCm: selectedPlacement.xCm,
            yCm: selectedPlacement.yCm,
            spacing: _spacingFor(
              selectedPlacement.plantId,
              selectedPlacement.spacingCm,
            ),
            dragId: selectedPlacement.id,
            isPending: false,
            forcedValid:
                !widget.highlightConflictIds.contains(selectedPlacement.id),
            selected: true,
          ),
        if (_draggingId != null && _dragCm != null && _dragSpacing != null)
          _zone(
            canvasSize: size,
            scale: scale,
            plantId: _draggingId == '_pending'
                ? widget.pendingPlant!.id
                : bed.placements
                    .firstWhere((e) => e.id == _draggingId)
                    .plantId,
            xCm: _dragCm!.dx,
            yCm: _dragCm!.dy,
            spacing: _dragSpacing!,
            dragId: _draggingId!,
            isPending: _draggingId == '_pending',
            forcedValid: _dragValidity?.isValid ?? false,
            selected: true,
          )
        else if (widget.pendingPlant != null && pendingPos != null)
          _zone(
            canvasSize: size,
            scale: scale,
            plantId: widget.pendingPlant!.id,
            xCm: pendingPos.dx,
            yCm: pendingPos.dy,
            spacing: _spacingForVegetable(widget.pendingPlant!),
            dragId: '_pending',
            isPending: true,
            forcedValid: _pendingIsValid,
            selected: true, // pending altijd sleepbaar zonder extra tik
          ),
      ],
    );
  }

  Widget _zone({
    required Size canvasSize,
    required BedScale scale,
    required String plantId,
    required double xCm,
    required double yCm,
    required double spacing,
    required String dragId,
    required bool isPending,
    required bool forcedValid,
    required bool selected,
  }) {
    final zone = scale.zoneSizePx(spacing);
    final zoneW = math.max(zone.width, 44.0);
    final zoneH = math.max(zone.height, 44.0);
    final hit = math.max(math.max(zoneW, zoneH), 72.0);
    // Pending-plant: ✓ altijd zichtbaar (ook buiten de bak via _controlPad).
    final showControls =
        (selected || isPending) && _draggingId != dragId;
    // Knoppenrij = 2×44 + 8; ruim genoeg tegen RIGHT OVERFLOW
    const controlsW = 104.0;
    final boxW = math.max(hit, showControls ? controlsW : hit);
    const controlH = 48.0;
    const lift = 56.0; // plant zweeft boven vinger tijdens sleep
    final center = (_draggingId == dragId && _fingerLocal != null)
        ? Offset(_fingerLocal!.dx, _fingerLocal!.dy - lift)
        : scale.cmToPx(xCm, yCm);
    final color = forcedValid ? TuinierColors.success : TuinierColors.error;
    final veg = widget.repository.byId(plantId);
    final totalH = hit + (showControls ? controlH : 0);
    final top = center.dy - hit / 2 - (showControls ? controlH : 0);

    return Positioned(
      left: center.dx - boxW / 2,
      top: top,
      width: boxW,
      height: totalH,
      child: Column(
        children: [
          if (showControls)
            SizedBox(
              height: controlH,
              width: boxW,
              child: Center(
                child: SizedBox(
                  width: controlsW,
                  height: controlH,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PlantActionButton(
                        icon: Icons.delete_outline_rounded,
                        color: TuinierColors.error,
                        tooltip: 'Verwijderen',
                        onTap: () {
                          if (isPending) {
                            widget.onCancelPending?.call();
                            setState(() {
                              _pendingCm = null;
                            });
                          } else {
                            widget.onDeletePlacement?.call(dragId);
                          }
                        },
                      ),
                      const SizedBox(width: 12),
                      _PlantActionButton(
                        icon: Icons.check_rounded,
                        color: forcedValid
                            ? VisualGardenBedColors.titleGreen
                            : TuinierColors.textSecondary,
                        tooltip: isPending ? 'Hier plaatsen' : 'Klaar',
                        onTap: (!forcedValid && isPending)
                            ? null
                            : () {
                                if (isPending) {
                                  _confirmPending();
                                } else {
                                  _lockSelectedPlacement();
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: (e) {
                _beginPlantDrag(
                  dragId: dragId,
                  xCm: xCm,
                  yCm: yCm,
                  spacing: spacing,
                  isPending: isPending,
                  globalPosition: e.position,
                );
              },
              onPointerMove: (e) {
                if (_draggingId != dragId) return;
                _onDragUpdate(
                  global: e.position,
                  canvasSize: canvasSize,
                  dragId: dragId,
                  spacing: spacing,
                );
              },
              onPointerUp: (_) {
                if (_draggingId != dragId) return;
                _finishPlantDrag(
                  dragId: dragId,
                  plantId: plantId,
                  spacing: spacing,
                  isPending: isPending,
                );
              },
              onPointerCancel: (_) {
                if (_draggingId != dragId) return;
                _cancelPlantDrag();
              },
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: zoneW,
                  height: zoneH,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: selected ? 0.22 : 0.1),
                    border: Border.all(
                      color: selected
                          ? VisualGardenBedColors.titleGreen
                          : color,
                      width: selected ? 3 : 2,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: veg == null
                      ? Icon(
                          Icons.eco_rounded,
                          color: color,
                          size: math.min(zoneW, zoneH) * 0.45,
                        )
                      : VegetableThumbnail(
                          vegetable: veg,
                          size: math.min(zoneW, zoneH),
                          borderRadius: 8,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantActionButton extends StatelessWidget {
  const _PlantActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Ink(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.45), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}

class _PolygonBedPainter extends CustomPainter {
  _PolygonBedPainter({
    required this.verticesCm,
    required this.scale,
    required this.borderColor,
    required this.fillColor,
    required this.widthCm,
    required this.depthCm,
    required this.edgeLengthsCm,
  });

  final List<Offset> verticesCm;
  final BedScale scale;
  final Color borderColor;
  final Color fillColor;
  final double widthCm;
  final double depthCm;
  final List<double> edgeLengthsCm;

  @override
  void paint(Canvas canvas, Size size) {
    if (verticesCm.length < 3) return;
    final path = Path();
    final first = scale.cmToPx(verticesCm.first.dx, verticesCm.first.dy);
    path.moveTo(first.dx, first.dy);
    for (var i = 1; i < verticesCm.length; i++) {
      final p = scale.cmToPx(verticesCm[i].dx, verticesCm[i].dy);
      path.lineTo(p.dx, p.dy);
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    canvas.save();
    canvas.clipPath(path);
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..strokeWidth = 1;
    const stepCm = 25.0;
    for (var x = 0.0; x <= widthCm + 0.1; x += stepCm) {
      canvas.drawLine(
        scale.cmToPx(x, 0),
        scale.cmToPx(x, depthCm),
        gridPaint,
      );
    }
    for (var y = 0.0; y <= depthCm + 0.1; y += stepCm) {
      canvas.drawLine(
        scale.cmToPx(0, y),
        scale.cmToPx(widthCm, y),
        gridPaint,
      );
    }
    canvas.restore();

    canvas.drawPath(
      path,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _PolygonBedPainter old) =>
      old.verticesCm != verticesCm ||
      old.scale.displayWidthPx != scale.displayWidthPx ||
      old.borderColor != borderColor ||
      old.fillColor != fillColor ||
      old.edgeLengthsCm != edgeLengthsCm;
}

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/visual_garden_bed_colors.dart';
import '../data/visual_garden_geometry.dart';
import '../models/visual_garden_plan.dart';
import '../theme/tuinier_colors.dart';

class BedSetupResult {
  const BedSetupResult({
    required this.name,
    required this.verticesCm,
    this.wallHeightCm = 20,
    this.borderColorValue = VisualGardenBedColors.defaultBorderArgb,
    this.fillColorValue = VisualGardenBedColors.defaultFillArgb,
  });

  final String name;
  final List<Offset> verticesCm;
  final double wallHeightCm;
  final int borderColorValue;
  final int fillColorValue;
}

/// Bak aanmaken/bewerken — layout volgens moestuinbak-generator mockup.
Future<BedSetupResult?> showVisualGardenBedSetupSheet({
  required BuildContext context,
  VisualGardenBed? existing,
  String? suggestedName,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  return Navigator.of(context).push<BedSetupResult>(
    MaterialPageRoute(
      builder: (_) => VisualGardenBedSetupPage(
        existing: existing,
        suggestedName: suggestedName,
      ),
    ),
  );
}

enum _BedShape { rectangle, square, circle, oval, polygon }

class VisualGardenBedSetupPage extends StatefulWidget {
  const VisualGardenBedSetupPage({
    super.key,
    this.existing,
    this.suggestedName,
  });

  final VisualGardenBed? existing;
  final String? suggestedName;

  @override
  State<VisualGardenBedSetupPage> createState() =>
      _VisualGardenBedSetupPageState();
}

class _VisualGardenBedSetupPageState extends State<VisualGardenBedSetupPage> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _lengthCtrl;
  late final TextEditingController _widthCtrl;
  late List<TextEditingController> _sideCtrls;
  late int _corners;
  late int _wallHeightCm;
  late _BedShape _shape;
  int? _selectedEdge;
  final _scrollCtrl = ScrollController();
  Timer? _previewDebounce;
  int _previewTick = 0;

  static const _borderArgb = VisualGardenBedColors.defaultBorderArgb;
  static const _fillArgb = VisualGardenBedColors.defaultFillArgb;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(
      text: widget.existing?.name ?? widget.suggestedName ?? 'Moestuinbak 1',
    );
    _wallHeightCm = (widget.existing?.wallHeightCm ?? 20).round().clamp(5, 200);

    final existing = widget.existing;
    if (existing != null && existing.verticesCm.length >= 3) {
      _corners = existing.verticesCm.length.clamp(3, 12);
      final edges = existing.edgeLengthsCm;
      _sideCtrls = [
        for (var i = 0; i < _corners; i++)
          TextEditingController(
            text: (i < edges.length ? edges[i] : 100).round().toString(),
          ),
      ];
      final isRect = _corners == 4 &&
          edges.length == 4 &&
          (edges[0] - edges[2]).abs() < 1 &&
          (edges[1] - edges[3]).abs() < 1;
      final isSquare = isRect && (edges[0] - edges[1]).abs() < 1;
      if (isSquare) {
        _shape = _BedShape.square;
      } else if (isRect) {
        _shape = _BedShape.rectangle;
      } else {
        _shape = _BedShape.polygon;
      }
      _lengthCtrl = TextEditingController(
        text: (isRect ? edges[0] : edges.first).round().toString(),
      );
      _widthCtrl = TextEditingController(
        text: (isRect ? edges[1] : edges.first).round().toString(),
      );
    } else {
      _corners = 4;
      _shape = _BedShape.rectangle;
      _sideCtrls = [
        for (var i = 0; i < 4; i++) TextEditingController(text: '100'),
      ];
      _lengthCtrl = TextEditingController(text: '200');
      _widthCtrl = TextEditingController(text: '100');
    }
  }

  @override
  void dispose() {
    _previewDebounce?.cancel();
    _nameCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _scrollCtrl.dispose();
    for (final c in _sideCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _schedulePreviewRefresh() {
    _previewDebounce?.cancel();
    _previewDebounce = Timer(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      setState(() => _previewTick++);
    });
  }

  double get _lengthCm =>
      double.tryParse(_lengthCtrl.text.replaceAll(',', '.')) ?? 100;
  double get _widthCm =>
      double.tryParse(_widthCtrl.text.replaceAll(',', '.')) ?? 100;

  void _setShape(_BedShape shape) {
    setState(() {
      _shape = shape;
      if (shape == _BedShape.rectangle || shape == _BedShape.square) {
        _corners = 4;
        _ensureSideCount(4);
        _selectedEdge = null;
        if (shape == _BedShape.square) {
          _widthCtrl.text = _lengthCtrl.text;
        }
      } else if (shape == _BedShape.circle) {
        _widthCtrl.text = _lengthCtrl.text;
        _selectedEdge = 0;
      } else if (shape == _BedShape.oval) {
        _selectedEdge = 0;
      } else {
        _selectedEdge = null;
      }
      _previewTick++;
    });
  }

  void _ensureSideCount(int n) {
    while (_sideCtrls.length < n) {
      _sideCtrls.add(TextEditingController(text: '100'));
    }
    while (_sideCtrls.length > n) {
      _sideCtrls.removeLast().dispose();
    }
  }

  void _setCornerCount(int n) {
    final next = n.clamp(3, 12);
    setState(() {
      _corners = next;
      _selectedEdge = null;
      _ensureSideCount(next);
      if (next == 4 &&
          (_shape == _BedShape.polygon ||
              _shape == _BedShape.circle ||
              _shape == _BedShape.oval)) {
        _shape = _BedShape.rectangle;
      } else if (next != 4) {
        _shape = _BedShape.polygon;
      }
      _previewTick++;
    });
  }

  void _selectEdge(int index) => setState(() => _selectedEdge = index);

  void _nudgeHeight(int delta) {
    setState(() {
      _wallHeightCm = (_wallHeightCm + delta).clamp(5, 200);
    });
  }

  List<Offset> _previewVertices() {
    // ignore: unused_local_variable
    final _ = _previewTick;
    switch (_shape) {
      case _BedShape.rectangle:
        return buildRectangleCm(lengthCm: _lengthCm, widthCm: _widthCm);
      case _BedShape.square:
        return buildRectangleCm(lengthCm: _lengthCm, widthCm: _lengthCm);
      case _BedShape.circle:
        return buildEllipseCm(
          widthCm: _lengthCm,
          heightCm: _lengthCm,
          segments: 24,
        );
      case _BedShape.oval:
        return buildEllipseCm(
          widthCm: _lengthCm,
          heightCm: _widthCm,
          segments: 24,
        );
      case _BedShape.polygon:
        final sides = <double>[
          for (final c in _sideCtrls.take(_corners))
            double.tryParse(c.text.replaceAll(',', '.')) ?? 100,
        ];
        return buildPolygonFromSideLengthsCm(sides);
    }
  }

  List<String> _edgeLabels(List<Offset> verts) {
    if (_shape == _BedShape.circle) {
      final d = _lengthCtrl.text.trim().isEmpty ? '?' : _lengthCtrl.text;
      return ['Ø $d cm'];
    }
    if (_shape == _BedShape.oval) {
      final L = _lengthCtrl.text.trim().isEmpty ? '?' : _lengthCtrl.text;
      final W = _widthCtrl.text.trim().isEmpty ? '?' : _widthCtrl.text;
      return ['Ø $L × $W cm'];
    }
    if (_shape == _BedShape.rectangle || _shape == _BedShape.square) {
      final L = _lengthCtrl.text.trim().isEmpty ? '?' : _lengthCtrl.text;
      final W = _shape == _BedShape.square
          ? L
          : (_widthCtrl.text.trim().isEmpty ? '?' : _widthCtrl.text);
      return ['$L cm', '$W cm', '$L cm', '$W cm'];
    }
    return [
      for (var i = 0; i < verts.length; i++)
        '${_sideCtrls[i].text.trim().isEmpty ? '?' : _sideCtrls[i].text} cm',
    ];
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geef je bak een naam')),
      );
      return;
    }

    final verts = _previewVertices();
    if (verts.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kon de bakvorm niet maken')),
      );
      return;
    }

    if (_shape == _BedShape.polygon) {
      for (var i = 0; i < _corners; i++) {
        final v = double.tryParse(_sideCtrls[i].text.replaceAll(',', '.'));
        if (v == null || v < 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Vul bij balk ${i + 1} een maat in (≥ 5 cm)'),
            ),
          );
          return;
        }
      }
    } else {
      final L = _lengthCm;
      final W = _shape == _BedShape.square || _shape == _BedShape.circle
          ? L
          : _widthCm;
      if (L < 5 || W < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vul geldige maten in (≥ 5 cm)'),
          ),
        );
        return;
      }
    }

    Navigator.pop(
      context,
      BedSetupResult(
        name: name,
        verticesCm: verts,
        wallHeightCm: _wallHeightCm.toDouble(),
        borderColorValue: _borderArgb,
        fillColorValue: _fillArgb,
      ),
    );
  }

  Future<int?> _pickCustomCorners() async {
    final ctrl = TextEditingController(text: '$_corners');
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Aantal hoeken'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '3 t/m 12',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              final n = int.tryParse(ctrl.text.trim());
              if (n == null || n < 3 || n > 12) return;
              Navigator.pop(ctx, n);
            },
            child: const Text('Ok'),
          ),
        ],
      ),
    );
    ctrl.dispose();
    return result;
  }

  void _showHelp() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Bak maken'),
        content: const Text(
          'Kies een vorm, vul de maten in centimeters in en pas eventueel '
          'het aantal hoeken aan. De bak wordt live getekend.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ok'),
          ),
        ],
      ),
    );
  }

  bool get _isRoundShape =>
      _shape == _BedShape.circle || _shape == _BedShape.oval;

  bool get _showLengthWidthPair =>
      _shape == _BedShape.rectangle ||
      (_shape == _BedShape.polygon && _corners == 4);

  bool get _showSingleSize =>
      _shape == _BedShape.square || _shape == _BedShape.circle;

  bool get _showOvalDiameters => _shape == _BedShape.oval;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final preview = _previewVertices();
    final labels = _edgeLabels(preview);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F4),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.existing == null ? 'Nieuwe bak' : 'Bak bewerken'),
        backgroundColor: const Color(0xFFF5F6F4),
        foregroundColor: TuinierColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Uitleg',
            onPressed: _showHelp,
            icon: const Icon(Icons.help_outline_rounded),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _save,
              child: Text(
                widget.existing == null ? 'Toevoegen' : 'Opslaan',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F6B32),
                ),
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        controller: _scrollCtrl,
        padding: EdgeInsets.fromLTRB(16, 4, 16, 16 + bottomInset),
        children: [
          _HeroBlock(),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Naam van je bak',
            child: TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.eco_outlined,
                  color: TuinierColors.primary.withValues(alpha: 0.85),
                ),
                hintText: 'Moestuinbak 1',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: TuinierColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: TuinierColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: TuinierColors.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Vorm en afmetingen',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ShapeSelector(
                  shape: _shape == _BedShape.polygon
                      ? _BedShape.rectangle
                      : _shape,
                  onSelected: _setShape,
                ),
                const SizedBox(height: 10),
                _CornerSelector(
                  corners: _corners,
                  enabled: !_isRoundShape,
                  onSelected: _setCornerCount,
                  onPickCustom: () async {
                    final custom = await _pickCustomCorners();
                    if (custom != null) _setCornerCount(custom);
                  },
                ),
                const SizedBox(height: 14),
                AspectRatio(
                  aspectRatio: 1.2,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F8F5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: TuinierColors.border),
                    ),
                    child: _BedPreview(
                      vertices: preview,
                      selectedEdge: _isRoundShape ? null : _selectedEdge,
                      edgeLabels: _isRoundShape ? const [] : labels,
                      showCornerNumbers: false,
                      onEdgeTap: _isRoundShape ? null : _selectEdge,
                      roundAxis: _isRoundShape
                          ? _RoundPreviewAxis(
                              lengthLabel: _shape == _BedShape.circle
                                  ? 'Ø ${_lengthCtrl.text.trim().isEmpty ? '?' : _lengthCtrl.text} cm'
                                  : '${_lengthCtrl.text.trim().isEmpty ? '?' : _lengthCtrl.text} cm',
                              widthLabel: _shape == _BedShape.oval
                                  ? '${_widthCtrl.text.trim().isEmpty ? '?' : _widthCtrl.text} cm'
                                  : null,
                              highlight: _shape == _BedShape.oval
                                  ? _selectedEdge
                                  : 0,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                if (_showSingleSize)
                  _MeasureField(
                    label: _shape == _BedShape.circle ? 'Diameter' : 'Zijde',
                    controller: _lengthCtrl,
                    selected: _shape == _BedShape.circle ||
                        _selectedEdge != null,
                    onTap: () => _selectEdge(0),
                    onChanged: (_) {
                      if (_shape == _BedShape.square ||
                          _shape == _BedShape.circle) {
                        _widthCtrl.text = _lengthCtrl.text;
                      }
                      _schedulePreviewRefresh();
                    },
                  )
                else if (_showOvalDiameters) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _MeasureField(
                          label: 'Lengte (diameter)',
                          controller: _lengthCtrl,
                          selected: _selectedEdge == 0,
                          onTap: () => _selectEdge(0),
                          onChanged: (_) {
                            if (_selectedEdge != 0) _selectEdge(0);
                            _schedulePreviewRefresh();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MeasureField(
                          label: 'Breedte (diameter)',
                          controller: _widthCtrl,
                          selected: _selectedEdge == 1,
                          onTap: () => _selectEdge(1),
                          onChanged: (_) {
                            if (_selectedEdge != 1) _selectEdge(1);
                            _schedulePreviewRefresh();
                          },
                        ),
                      ),
                    ],
                  ),
                ] else if (_showLengthWidthPair ||
                    _shape == _BedShape.rectangle) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _MeasureField(
                          label: 'Lengte (balk 1 & 3)',
                          controller: _lengthCtrl,
                          selected:
                              _selectedEdge == 0 || _selectedEdge == 2,
                          onTap: () => _selectEdge(0),
                          onChanged: (_) {
                            if (_selectedEdge != 0 &&
                                _selectedEdge != 2) {
                              _selectEdge(0);
                            }
                            _schedulePreviewRefresh();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _MeasureField(
                          label: 'Breedte (balk 2 & 4)',
                          controller: _widthCtrl,
                          selected:
                              _selectedEdge == 1 || _selectedEdge == 3,
                          onTap: () => _selectEdge(1),
                          onChanged: (_) {
                            if (_selectedEdge != 1 &&
                                _selectedEdge != 3) {
                              _selectEdge(1);
                            }
                            _schedulePreviewRefresh();
                          },
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  for (var i = 0; i < _corners; i++) ...[
                    if (i > 0) const SizedBox(height: 10),
                    _MeasureField(
                      label: 'Balk ${i + 1}',
                      controller: _sideCtrls[i],
                      selected: _selectedEdge == i,
                      onTap: () => _selectEdge(i),
                      onChanged: (_) {
                        if (_selectedEdge != i) _selectEdge(i);
                        _schedulePreviewRefresh();
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Hoogte bakwand',
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F6F1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.yard_outlined,
                    color: Color(0xFFB08968),
                  ),
                ),
                const Spacer(),
                _StepperButton(
                  icon: Icons.remove,
                  onTap: () => _nudgeHeight(-1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '$_wallHeightCm cm',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  onTap: () => _nudgeHeight(1),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 8,
        color: const Color(0xFFF5F6F4),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6B32),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(
                  widget.existing == null
                      ? Icons.add_rounded
                      : Icons.save_outlined,
                  size: 22,
                ),
                label: Text(
                  widget.existing == null
                      ? 'Bak toevoegen'
                      : 'Wijzigingen opslaan',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Maak je moestuinplek',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: VisualGardenBedColors.titleGreen,
                      height: 1.15,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Geef de afmetingen op en wij tekenen de bak voor je.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: TuinierColors.textSecondary,
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/planner/planner_hero_bed.png',
            width: 112,
            height: 100,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              width: 112,
              height: 100,
              color: VisualGardenBedColors.softGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TuinierColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ShapeSelector extends StatelessWidget {
  const _ShapeSelector({
    required this.shape,
    required this.onSelected,
  });

  final _BedShape shape;
  final ValueChanged<_BedShape> onSelected;

  @override
  Widget build(BuildContext context) {
    const items = [
      (_BedShape.rectangle, 'Rechthoek', Icons.rectangle_outlined),
      (_BedShape.square, 'Vierkant', Icons.square_outlined),
      (_BedShape.circle, 'Cirkel', Icons.circle_outlined),
      (_BedShape.oval, 'Ovaal', Icons.crop_landscape_outlined),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _ShapeChip(
              label: items[i].$2,
              icon: items[i].$3,
              selected: shape == items[i].$1,
              onTap: () => onSelected(items[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _CornerSelector extends StatelessWidget {
  const _CornerSelector({
    required this.corners,
    required this.onSelected,
    required this.onPickCustom,
    this.enabled = true,
  });

  final int corners;
  final ValueChanged<int> onSelected;
  final VoidCallback onPickCustom;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    const options = [3, 4, 5, 6, 8];
    final isCustom = !options.contains(corners);
    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(
                child: _ShapeChip(
                  label: '${options[i]}',
                  icon: Icons.polyline_outlined,
                  selected: enabled && corners == options[i],
                  onTap: () => onSelected(options[i]),
                ),
              ),
            ],
            const SizedBox(width: 8),
            Expanded(
              child: _ShapeChip(
                label: isCustom ? '$corners' : '…',
                icon: Icons.more_horiz_rounded,
                selected: enabled && isCustom,
                onTap: onPickCustom,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShapeChip extends StatelessWidget {
  const _ShapeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEEF6EE) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF2F6B32) : TuinierColors.border,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? const Color(0xFF2F6B32)
                    : TuinierColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? const Color(0xFF2F6B32)
                      : TuinierColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasureField extends StatelessWidget {
  const _MeasureField({
    required this.label,
    required this.controller,
    required this.selected,
    required this.onTap,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final bool selected;
  final VoidCallback? onTap;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onTap: onTap,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
      ],
      decoration: InputDecoration(
        labelText: label,
        suffixText: 'cm',
        filled: true,
        fillColor: selected
            ? TuinierColors.primary.withValues(alpha: 0.08)
            : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: selected ? TuinierColors.primary : TuinierColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TuinierColors.primary, width: 1.5),
        ),
      ),
      onChanged: onChanged,
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F6F1),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 20, color: const Color(0xFF2F6B32)),
        ),
      ),
    );
  }
}

class _RoundPreviewAxis {
  const _RoundPreviewAxis({
    required this.lengthLabel,
    this.widthLabel,
    this.highlight,
  });

  final String lengthLabel;
  final String? widthLabel;
  final int? highlight;
}

class _BedPreview extends StatelessWidget {
  const _BedPreview({
    required this.vertices,
    required this.selectedEdge,
    required this.edgeLabels,
    required this.showCornerNumbers,
    required this.onEdgeTap,
    this.roundAxis,
  });

  final List<Offset> vertices;
  final int? selectedEdge;
  final List<String> edgeLabels;
  final bool showCornerNumbers;
  final ValueChanged<int>? onEdgeTap;
  final _RoundPreviewAxis? roundAxis;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        if (vertices.length < 3) return const SizedBox.expand();

        var minX = vertices.first.dx, maxX = vertices.first.dx;
        var minY = vertices.first.dy, maxY = vertices.first.dy;
        for (final v in vertices) {
          minX = math.min(minX, v.dx);
          maxX = math.max(maxX, v.dx);
          minY = math.min(minY, v.dy);
          maxY = math.max(maxY, v.dy);
        }
        final bw = math.max(maxX - minX, 1.0);
        final bh = math.max(maxY - minY, 1.0);
        const pad = 40.0;
        final scale = math.min(
          (size.width - pad * 2) / bw,
          (size.height - pad * 2) / bh,
        );
        final drawW = bw * scale;
        final drawH = bh * scale;
        final originX = (size.width - drawW) / 2;
        final originY = (size.height - drawH) / 2;
        Offset toPx(Offset cm) => Offset(
              originX + (cm.dx - minX) * scale,
              originY + (cm.dy - minY) * scale,
            );
        final pts = [for (final v in vertices) toPx(v)];

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: onEdgeTap == null
              ? null
              : (d) {
                  final local = d.localPosition;
                  var best = -1;
                  var bestDist = 40.0;
                  for (var i = 0; i < pts.length; i++) {
                    final a = pts[i];
                    final b = pts[(i + 1) % pts.length];
                    final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
                    final dist = (local - mid).distance;
                    if (dist < bestDist) {
                      bestDist = dist;
                      best = i;
                    }
                  }
                  if (best >= 0) onEdgeTap!(best);
                },
          child: CustomPaint(
            size: size,
            painter: _BedPreviewPainter(
              points: pts,
              selectedEdge: selectedEdge,
              edgeLabels: edgeLabels,
              showCornerNumbers: showCornerNumbers,
              roundAxis: roundAxis,
              borderColor: const Color(VisualGardenBedColors.defaultBorderArgb),
              fillColor: const Color(VisualGardenBedColors.defaultFillArgb),
            ),
          ),
        );
      },
    );
  }
}

class _BedPreviewPainter extends CustomPainter {
  _BedPreviewPainter({
    required this.points,
    required this.selectedEdge,
    required this.edgeLabels,
    required this.showCornerNumbers,
    required this.borderColor,
    required this.fillColor,
    this.roundAxis,
  });

  final List<Offset> points;
  final int? selectedEdge;
  final List<String> edgeLabels;
  final bool showCornerNumbers;
  final Color borderColor;
  final Color fillColor;
  final _RoundPreviewAxis? roundAxis;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 3) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
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
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..strokeWidth = 1;
    const step = 18.0;
    for (var x = 0.0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
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

    var minX = points.first.dx, maxX = points.first.dx;
    var minY = points.first.dy, maxY = points.first.dy;
    for (final p in points) {
      minX = math.min(minX, p.dx);
      maxX = math.max(maxX, p.dx);
      minY = math.min(minY, p.dy);
      maxY = math.max(maxY, p.dy);
    }
    final cx = (minX + maxX) / 2;
    final cy = (minY + maxY) / 2;

    if (roundAxis != null) {
      _paintDiameterAxis(
        canvas,
        from: Offset(minX, cy),
        to: Offset(maxX, cy),
        label: roundAxis!.lengthLabel,
        selected: roundAxis!.highlight == 0 ||
            (roundAxis!.widthLabel == null && roundAxis!.highlight != 1),
      );
      if (roundAxis!.widthLabel != null) {
        _paintDiameterAxis(
          canvas,
          from: Offset(cx, minY),
          to: Offset(cx, maxY),
          label: roundAxis!.widthLabel!,
          selected: roundAxis!.highlight == 1,
        );
      }
      return;
    }

    for (var i = 0; i < points.length; i++) {
      final a = points[i];
      final b = points[(i + 1) % points.length];
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      var nx = a.dy - b.dy;
      var ny = b.dx - a.dx;
      final len = math.sqrt(nx * nx + ny * ny);
      if (len < 0.001) continue;
      nx /= len;
      ny /= len;
      if (nx * (cx - mid.dx) + ny * (cy - mid.dy) > 0) {
        nx = -nx;
        ny = -ny;
      }
      final selected = selectedEdge == i;
      final label = i < edgeLabels.length ? edgeLabels[i] : '';
      if (label.isEmpty && !selected) continue;

      final labelPos = Offset(mid.dx + nx * 18, mid.dy + ny * 18);
      final dim = Paint()
        ..color = selected
            ? const Color(0xFF2F6B32)
            : const Color(0xFF6B8F6E)
        ..strokeWidth = selected ? 1.6 : 1.1
        ..style = PaintingStyle.stroke;
      canvas.drawLine(mid, labelPos, dim);

      if (label.isEmpty) continue;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: selected
                ? const Color(0xFF2F6B32)
                : const Color(0xFF3F6B42),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            backgroundColor: const Color(0xF2F7F8F4),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, labelPos - Offset(tp.width / 2, tp.height / 2));
    }

    if (showCornerNumbers) {
      for (var i = 0; i < points.length; i++) {
        final p = points[i];
        canvas.drawCircle(p, 11, Paint()..color = const Color(0xFF2F6B32));
        final tp = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
      }
    }
  }

  void _paintDiameterAxis(
    Canvas canvas, {
    required Offset from,
    required Offset to,
    required String label,
    required bool selected,
  }) {
    final color =
        selected ? const Color(0xFF2F6B32) : const Color(0xFF6B8F6E);
    final paint = Paint()
      ..color = color
      ..strokeWidth = selected ? 2 : 1.4
      ..style = PaintingStyle.stroke;
    canvas.drawLine(from, to, paint);

    // End caps
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    final len = math.sqrt(dx * dx + dy * dy);
    if (len > 0.001) {
      final px = -dy / len * 6;
      final py = dx / len * 6;
      canvas.drawLine(
        from + Offset(px, py),
        from - Offset(px, py),
        paint,
      );
      canvas.drawLine(
        to + Offset(px, py),
        to - Offset(px, py),
        paint,
      );
    }

    final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final tp = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: selected ? const Color(0xFF2F6B32) : const Color(0xFF3F6B42),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          backgroundColor: const Color(0xF2F7F8F4),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, mid - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _BedPreviewPainter old) =>
      old.points != points ||
      old.selectedEdge != selectedEdge ||
      old.edgeLabels != edgeLabels ||
      old.showCornerNumbers != showCornerNumbers ||
      old.roundAxis?.lengthLabel != roundAxis?.lengthLabel ||
      old.roundAxis?.widthLabel != roundAxis?.widthLabel ||
      old.roundAxis?.highlight != roundAxis?.highlight;
}

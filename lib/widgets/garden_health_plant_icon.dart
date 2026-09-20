import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../utils/garden_health_image_processor.dart';

/// Plant in de tuingezondheid-cirkel — PNG per score, transparante achtergrond.
class GardenHealthPlantIcon extends StatefulWidget {
  const GardenHealthPlantIcon({
    super.key,
    required this.score,
  });

  final int score;

  @override
  State<GardenHealthPlantIcon> createState() => _GardenHealthPlantIconState();
}

class _GardenHealthPlantIconState extends State<GardenHealthPlantIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Uint8List? _pngBytes;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat();
    _loadPlant();
  }

  @override
  void didUpdateWidget(covariant GardenHealthPlantIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _loadPlant();
    }
  }

  Future<void> _loadPlant() async {
    if (widget.score <= 0) {
      if (!mounted) return;
      setState(() {
        _pngBytes = null;
        _loadError = null;
      });
      return;
    }
    final asset = gardenHealthPlantAsset(widget.score);
    final bytes = await GardenHealthImageProcessor.processedAssetBytes(asset);
    if (!mounted) return;
    setState(() {
      _pngBytes = bytes;
      _loadError = bytes == null ? 'load-failed' : null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : constraints.biggest.shortestSide;
        final t = _controller.value;
        final isEmpty = widget.score <= 0;
        final health = isEmpty ? 0.0 : (widget.score / 100).clamp(0.0, 1.0);
        final sway = isEmpty
            ? math.sin(t * math.pi * 2 * 0.4) * 0.006
            : math.sin(t * math.pi * 2 * 0.55) * 0.012 * (0.25 + health * 0.75);
        final bob = isEmpty
            ? math.sin(t * math.pi * 2 * 0.4) * side * 0.002
            : math.sin(t * math.pi * 2 * 0.55) * side * 0.004 * health;

        final plantScale = isEmpty
            ? 1.12
            : widget.score <= 25
                ? 1.14
                : widget.score <= 45
                    ? 1.13
                    : 1.0;
        final plantPadding = isEmpty
            ? side * 0.02
            : widget.score <= 25
                ? 0.0
                : widget.score <= 45
                    ? 0.0
                    : side * 0.01;

        Widget plant;
        if (isEmpty) {
          plant = CustomPaint(
            painter: _GardenHealthPlantFallbackPainter(
              score: 0,
              t: t,
            ),
          );
        } else if (_pngBytes != null) {
          plant = Image.memory(
            _pngBytes!,
            fit: BoxFit.contain,
            alignment: Alignment.bottomCenter,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          );
        } else if (_loadError != null) {
          plant = CustomPaint(
            painter: _GardenHealthPlantFallbackPainter(
              score: widget.score,
              t: t,
            ),
          );
        } else {
          plant = const SizedBox.shrink();
        }

        return Transform.translate(
          offset: Offset(0, bob),
          child: Transform.rotate(
            angle: sway,
            child: Transform.scale(
              scale: plantScale,
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.all(plantPadding),
                child: plant,
              ),
            ),
          ),
        );
      },
    );
  }
}

String gardenHealthPlantAsset(int score) {
  if (score <= 25) return 'assets/images/garden_health/garden_health_dying.png';
  if (score <= 45) return 'assets/images/garden_health/garden_health_weak.png';
  if (score <= 69) return 'assets/images/garden_health/garden_health_seedling.png';
  if (score <= 84) return 'assets/images/garden_health/garden_health_growing.png';
  return 'assets/images/garden_health/garden_health_flourishing.png';
}

enum _PlantStage { empty, dying, weak, seedling, growing, flourishing }

class _GardenHealthPlantFallbackPainter extends CustomPainter {
  _GardenHealthPlantFallbackPainter({required this.score, required this.t});

  final int score;
  final double t;

  _PlantStage get _stage {
    if (score <= 0) return _PlantStage.empty;
    if (score <= 25) return _PlantStage.dying;
    if (score <= 45) return _PlantStage.weak;
    if (score <= 69) return _PlantStage.seedling;
    if (score <= 84) return _PlantStage.growing;
    return _PlantStage.flourishing;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cx = s * 0.5;
    final baseY = s * 0.82;

    switch (_stage) {
      case _PlantStage.empty:
        _drawSeed(canvas, Offset(cx, baseY), s);
      case _PlantStage.dying:
        _drawSeedling(canvas, Offset(cx, baseY), s, scale: 0.68, angle: 0.92, palette: _dying);
      case _PlantStage.weak:
        _drawSeedling(canvas, Offset(cx, baseY), s, scale: 0.81, angle: 0.5, palette: _weak);
      case _PlantStage.seedling:
        _drawSeedling(canvas, Offset(cx, baseY), s, scale: 0.78, angle: 0.34, palette: _ok);
      case _PlantStage.growing:
        _drawSeedling(canvas, Offset(cx, baseY), s, scale: 0.84, angle: 0.3, palette: _ok);
        _drawLeaves(canvas, Offset(cx, baseY - s * 0.15), s, scale: 0.6, angle: 0.36, palette: _ok);
      case _PlantStage.flourishing:
        _drawSeedling(canvas, Offset(cx, baseY), s, scale: 0.88, angle: 0.28, palette: _ok);
        _drawLeaves(canvas, Offset(cx, baseY - s * 0.13), s, scale: 0.64, angle: 0.32, palette: _ok);
        _drawBloom(canvas, Offset(cx, baseY - s * 0.44), s);
    }
  }

  static const _ok = [Color(0xFF9CCC65), Color(0xFF66BB6A), Color(0xFF388E3C)];
  static const _weak = [Color(0xFFDCE775), Color(0xFFAFB42B), Color(0xFF827717)];
  static const _dying = [Color(0xFFBCAAA4), Color(0xFF8D6E63), Color(0xFF6D4C41)];


  void _drawSeed(Canvas canvas, Offset base, double s) {
    final pulse = 1 + 0.04 * math.sin(t * math.pi * 2 * 0.5);
    final tilt = math.sin(t * math.pi * 2 * 0.35) * 0.08;
    final seedCenter = Offset(base.dx, base.dy - s * 0.24 * pulse);

    // Zachte gloed — wacht op eerste plant.
    canvas.drawCircle(
      seedCenter,
      s * 0.2 * pulse,
      Paint()
        ..color = const Color(0xFFFFF8E1).withValues(alpha: 0.14)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.04),
    );

    // Bodem / aarde.
    final soil = Path()
      ..moveTo(base.dx - s * 0.22, base.dy + s * 0.01)
      ..quadraticBezierTo(
        base.dx,
        base.dy - s * 0.04,
        base.dx + s * 0.22,
        base.dy + s * 0.01,
      );
    canvas.drawPath(
      soil,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF8D6E63).withValues(alpha: 0.45),
            const Color(0xFF5D4037).withValues(alpha: 0.55),
          ],
        ).createShader(Rect.fromLTWH(base.dx - s * 0.22, base.dy - s * 0.05, s * 0.44, s * 0.08)),
    );

    canvas.save();
    canvas.translate(seedCenter.dx, seedCenter.dy);
    canvas.rotate(tilt - 0.12);
    canvas.scale(pulse);

    final seedW = s * 0.17;
    final seedH = s * 0.24;

    // Schaduw onder zaadje.
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, seedH * 0.42), width: seedW * 0.9, height: seedH * 0.18),
      Paint()..color = const Color(0xFF3E2723).withValues(alpha: 0.22),
    );

    // Boonvormig zaadje.
    final seedPath = Path()
      ..moveTo(0, -seedH * 0.48)
      ..quadraticBezierTo(seedW * 0.52, -seedH * 0.18, seedW * 0.42, seedH * 0.12)
      ..quadraticBezierTo(seedW * 0.18, seedH * 0.5, 0, seedH * 0.46)
      ..quadraticBezierTo(-seedW * 0.18, seedH * 0.5, -seedW * 0.42, seedH * 0.12)
      ..quadraticBezierTo(-seedW * 0.52, -seedH * 0.18, 0, -seedH * 0.48)
      ..close();

    final seedBounds = Rect.fromCenter(
      center: Offset.zero,
      width: seedW,
      height: seedH,
    );
    canvas.drawPath(
      seedPath,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment(-0.6, -0.9),
          end: Alignment(0.8, 1),
          colors: [
            Color(0xFFFFF3E0),
            Color(0xFFD7CCC8),
            Color(0xFF8D6E63),
            Color(0xFF5D4037),
          ],
          stops: [0.0, 0.28, 0.62, 1.0],
        ).createShader(seedBounds),
    );

    // Rand voor diepte.
    canvas.drawPath(
      seedPath,
      Paint()
        ..color = const Color(0xFF4E342E).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.008,
    );

    // Adertje in het midden.
    final vein = Path()
      ..moveTo(0, -seedH * 0.34)
      ..quadraticBezierTo(seedW * 0.04, seedH * 0.02, 0, seedH * 0.28);
    canvas.drawPath(
      vein,
      Paint()
        ..color = const Color(0xFF3E2723).withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.01
        ..strokeCap = StrokeCap.round,
    );

    // Hooglicht.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-seedW * 0.14, -seedH * 0.16),
        width: seedW * 0.22,
        height: seedH * 0.14,
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );

    canvas.restore();
  }

  void _drawSeedling(
    Canvas canvas,
    Offset base,
    double s, {
    required double scale,
    required double angle,
    required List<Color> palette,
  }) {
    final stemH = s * 0.32 * scale;
    final top = Offset(base.dx, base.dy - stemH);
    canvas.drawLine(
      base,
      top,
      Paint()
        ..color = palette[2]
        ..strokeWidth = s * 0.032 * scale
        ..strokeCap = StrokeCap.round,
    );
    _drawLeaves(canvas, top, s, scale: scale, angle: angle, palette: palette);
  }

  void _drawLeaves(
    Canvas canvas,
    Offset node,
    double s, {
    required double scale,
    required double angle,
    required List<Color> palette,
  }) {
    _drawLeaf(canvas, node, s, left: true, scale: scale, angle: angle, palette: palette);
    _drawLeaf(canvas, node, s, left: false, scale: scale, angle: angle, palette: palette);
  }

  void _drawLeaf(
    Canvas canvas,
    Offset node,
    double s, {
    required bool left,
    required double scale,
    required double angle,
    required List<Color> palette,
  }) {
    final w = s * 0.14 * scale;
    final h = s * 0.08 * scale;
    canvas.save();
    canvas.translate(node.dx, node.dy);
    canvas.rotate((left ? -1 : 1) * angle);
    final path = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(w * 0.4, -h * 0.55, w * 0.92, -h * 0.06)
      ..quadraticBezierTo(w * 0.45, h * 0.45, 0, 0);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          colors: palette,
        ).createShader(Rect.fromLTWH(0, -h * 0.55, w, h)),
    );
    canvas.restore();
  }

  void _drawBloom(Canvas canvas, Offset c, double s) {
    canvas.drawCircle(c, s * 0.022, Paint()..color = const Color(0xFFE8F5E9));
    for (var i = 0; i < 5; i++) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(i * math.pi * 2 / 5);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(0, -s * 0.026), width: s * 0.03, height: s * 0.044),
        Paint()..color = const Color(0xFFA5D6A7),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _GardenHealthPlantFallbackPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.t != t;
  }
}

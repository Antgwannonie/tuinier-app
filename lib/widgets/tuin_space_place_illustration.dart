import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/tuin_space.dart';

extension TuinSpacePlaceIconAsset on TuinSpacePlace {
  String get iconAsset => switch (this) {
        TuinSpacePlace.outdoor =>
          'assets/images/moestuin_place/place_outdoor.png',
        TuinSpacePlace.balcony =>
          'assets/images/moestuin_place/place_balcony.png',
        TuinSpacePlace.greenhouse =>
          'assets/images/moestuin_place/place_greenhouse.png',
        TuinSpacePlace.indoor =>
          'assets/images/moestuin_place/place_indoor.png',
      };
}

const kTuinSpacePotIconAsset = 'assets/images/moestuin_place/place_pot.png';

class TuinSpacePlaceIllustration extends StatelessWidget {
  const TuinSpacePlaceIllustration({
    super.key,
    required this.place,
    this.size = 40,
  });

  final TuinSpacePlace place;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _PlaceIcon(
      asset: place.iconAsset,
      size: size,
      fallback: _PlaceIconPainter(place: place),
    );
  }
}

class TuinSpacePotIllustration extends StatelessWidget {
  const TuinSpacePotIllustration({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _PlaceIcon(
      asset: kTuinSpacePotIconAsset,
      size: size,
      fallback: const _PotPainter(),
    );
  }
}

class TuinSpaceSproutIllustration extends StatelessWidget {
  const TuinSpaceSproutIllustration({super.key, this.size = 38});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _PlaceIcon(
      asset: kTuinSpacePotIconAsset,
      size: size,
      fallback: const _SproutPainter(),
    );
  }
}

class _PlaceIcon extends StatelessWidget {
  const _PlaceIcon({
    required this.asset,
    required this.size,
    required this.fallback,
  });

  final String asset;
  final double size;
  final CustomPainter fallback;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) =>
            CustomPaint(painter: fallback, size: Size.square(size)),
      ),
    );
  }
}

class _PlaceIconPainter extends CustomPainter {
  const _PlaceIconPainter({required this.place});

  final TuinSpacePlace place;

  @override
  void paint(Canvas canvas, Size size) {
    switch (place) {
      case TuinSpacePlace.outdoor:
        _SunPainter().paint(canvas, size);
      case TuinSpacePlace.balcony:
        _BalconyPainter().paint(canvas, size);
      case TuinSpacePlace.greenhouse:
        _GreenhousePainter().paint(canvas, size);
      case TuinSpacePlace.indoor:
        _IndoorPainter().paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _PlaceIconPainter oldDelegate) =>
      oldDelegate.place != place;
}

class _SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * 0.2;

    final rayPaint = Paint()..color = const Color(0xFFFF9800);
    for (var i = 0; i < 12; i++) {
      final angle = i * math.pi / 6;
      final inner = radius * 1.2;
      final outer = radius * 1.9;
      final path = Path()
        ..moveTo(
          center.dx + math.cos(angle - 0.2) * inner,
          center.dy + math.sin(angle - 0.2) * inner,
        )
        ..lineTo(
          center.dx + math.cos(angle) * outer,
          center.dy + math.sin(angle) * outer,
        )
        ..lineTo(
          center.dx + math.cos(angle + 0.2) * inner,
          center.dy + math.sin(angle + 0.2) * inner,
        )
        ..close();
      canvas.drawPath(path, rayPaint);
    }

    final core = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0xFFFFF59D), Color(0xFFFFD54F)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, core);
    canvas.drawCircle(
      center.translate(-radius * 0.25, -radius * 0.25),
      radius * 0.32,
      Paint()..color = const Color(0xFFFFF9C4).withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BalconyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final railY = h * 0.64;

    final rail = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = h * 0.075
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.06, railY), Offset(w * 0.94, railY), rail);
    for (final x in [0.22, 0.5, 0.78]) {
      canvas.drawLine(
        Offset(w * x, railY),
        Offset(w * x, railY + h * 0.11),
        rail..strokeWidth = h * 0.045,
      );
    }

    final pot = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.3, h * 0.36, w * 0.4, h * 0.3),
      Radius.circular(w * 0.08),
    );
    canvas.drawRRect(
      pot,
      Paint()..color = const Color(0xFF795548),
    );
    _drawLeaves(canvas, Offset(w * 0.5, h * 0.28), h * 0.24);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GreenhousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final base = Rect.fromLTWH(w * 0.1, h * 0.4, w * 0.8, h * 0.48);
    final path = Path()
      ..moveTo(base.left, base.bottom)
      ..lineTo(base.left, base.top + h * 0.1)
      ..quadraticBezierTo(w * 0.5, h * 0.02, base.right, base.top + h * 0.1)
      ..lineTo(base.right, base.bottom)
      ..close();

    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF81D4FA).withValues(alpha: 0.65),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF607D8B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.055,
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.14),
      Offset(w * 0.5, base.bottom),
      Paint()
        ..color = const Color(0xFF607D8B)
        ..strokeWidth = h * 0.04,
    );
    _drawLeaves(canvas, Offset(w * 0.34, h * 0.58), h * 0.13);
    _drawLeaves(canvas, Offset(w * 0.66, h * 0.58), h * 0.13);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IndoorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.12, h * 0.36, w * 0.76, h * 0.52),
        Radius.circular(h * 0.05),
      ),
      Paint()
        ..color = const Color(0xFFBCAAA4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.05,
    );

    final bulb = Offset(w * 0.5, h * 0.2);
    canvas.drawCircle(bulb, h * 0.12, Paint()..color = const Color(0xFFFFEB3B));
    canvas.drawCircle(
      bulb.translate(-h * 0.03, -h * 0.03),
      h * 0.04,
      Paint()..color = const Color(0xFFFFF9C4),
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.34, h * 0.58, w * 0.32, h * 0.24),
        Radius.circular(w * 0.05),
      ),
      Paint()..color = const Color(0xFF795548),
    );
    _drawLeaves(canvas, Offset(w * 0.5, h * 0.48), h * 0.17);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PotPainter extends CustomPainter {
  const _PotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.5, w * 0.48, h * 0.36),
        Radius.circular(w * 0.08),
      ),
      Paint()..color = const Color(0xFF795548),
    );
    _drawLeaves(canvas, Offset(w * 0.5, h * 0.3), h * 0.24);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SproutPainter extends CustomPainter {
  const _SproutPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.16, h * 0.56, w * 0.68, h * 0.3),
      Paint()..color = const Color(0xFF6D4C41),
    );
    canvas.drawLine(
      Offset(w * 0.5, h * 0.56),
      Offset(w * 0.5, h * 0.24),
      Paint()
        ..color = const Color(0xFF558B2F)
        ..strokeWidth = h * 0.05
        ..strokeCap = StrokeCap.round,
    );
    _drawLeaves(canvas, Offset(w * 0.5, h * 0.18), h * 0.2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _drawLeaves(Canvas canvas, Offset center, double radius) {
  const color = Color(0xFF43A047);
  for (final offset in [
    Offset(-radius * 0.55, radius * 0.12),
    Offset(radius * 0.55, radius * 0.12),
    Offset(0, -radius * 0.38),
  ]) {
    canvas.drawOval(
      Rect.fromCenter(
        center: center + offset,
        width: radius * 1.05,
        height: radius * 0.85,
      ),
      Paint()..color = color,
    );
  }
}

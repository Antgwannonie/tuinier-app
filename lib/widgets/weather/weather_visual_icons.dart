import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/garden_weather_dashboard.dart';
import '../../data/weather_service.dart';
import '../../theme/tuinier_colors.dart';

/// Kleurrijk, geanimeerd weericoon — cartoon-stijl met zachte achtergrondcirkel.
class WeatherCodeIcon extends StatelessWidget {
  const WeatherCodeIcon({
    super.key,
    required this.code,
    this.size = 56,
    this.showBackground = false,
    this.isDay = true,
  });

  final int code;
  final double size;
  final bool showBackground;
  final bool isDay;

  @override
  Widget build(BuildContext context) {
    final icon = HomeWeatherBadgeIcon(
      code: code,
      size: showBackground ? size * 0.62 : size,
      isDay: isDay,
    );

    if (!showBackground) return icon;

    final bg = _backgroundForCode(code);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: size >= 40
            ? [
                BoxShadow(
                  color: bg.withValues(alpha: 0.45),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }

  static Color _backgroundForCode(int code) {
    if (code == 0) return const Color(0xFFFEF3C7);
    if (code <= 3) return const Color(0xFFE0F2FE);
    if (code <= 48) return const Color(0xFFF3F4F6);
    if (code <= 57) return const Color(0xFFDBEAFE);
    if (code <= 67) return const Color(0xFFBFDBFE);
    if (code <= 77) return const Color(0xFFE0F2FE);
    if (code <= 86) return const Color(0xFFDBEAFE);
    return const Color(0xFFEDE9FE);
  }

  static List<Color> _gradientForCode(int code) {
    if (code == 0) return [const Color(0xFFFDE68A), const Color(0xFFFBBF24)];
    if (code <= 3) return [const Color(0xFFE0F2FE), const Color(0xFFBAE6FD)];
    if (code <= 48) return [const Color(0xFFF3F4F6), const Color(0xFFE5E7EB)];
    if (code <= 57) return [const Color(0xFFDBEAFE), const Color(0xFF93C5FD)];
    if (code <= 67) return [const Color(0xFFBFDBFE), const Color(0xFF60A5FA)];
    if (code <= 77) return [const Color(0xFFE0F2FE), const Color(0xFF7DD3FC)];
    if (code <= 86) return [const Color(0xFFDBEAFE), const Color(0xFF93C5FD)];
    return [const Color(0xFFEDE9FE), const Color(0xFFC4B5FD)];
  }
}

/// Weericoon voor home — gelaagd, geanimeerd, met meer detail.
class HomeWeatherBadgeIcon extends StatefulWidget {
  const HomeWeatherBadgeIcon({
    super.key,
    required this.code,
    this.size = 48,
    this.isDay = true,
  });

  final int code;
  final double size;
  final bool isDay;

  @override
  State<HomeWeatherBadgeIcon> createState() => _HomeWeatherBadgeIconState();
}

class _HomeWeatherBadgeIconState extends State<HomeWeatherBadgeIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _HomeWeatherArtPainter(
              code: widget.code,
              isDay: widget.isDay,
              t: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _HomeWeatherArtPainter extends CustomPainter {
  _HomeWeatherArtPainter({
    required this.code,
    required this.isDay,
    required this.t,
  });

  final int code;
  final bool isDay;
  final double t;

  bool get _night => !isDay;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final s = size.shortestSide;

    if (code == 0) {
      _night ? _paintClearNight(canvas, center, s) : _paintSun(canvas, center, s);
    } else if (code <= 3) {
      _night
          ? _paintPartlyCloudyNight(canvas, center, s)
          : _paintPartlyCloudy(canvas, center, s);
    } else if (code <= 48) {
      _paintCloudy(canvas, center, s, night: _night);
    } else if (code <= 55) {
      _night
          ? _paintLightRain(canvas, center, s, night: true)
          : _paintSunShowers(canvas, center, s);
    } else if (code <= 67) {
      _paintRain(canvas, center, s, night: _night);
    } else if (code <= 77) {
      _paintSnow(canvas, center, s, night: _night);
    } else if (code <= 82) {
      _night
          ? _paintRain(canvas, center, s, night: true)
          : _paintSunShowers(canvas, center, s, heavy: true);
    } else if (code <= 86) {
      _paintSnow(canvas, center, s, night: _night);
    } else if (code <= 99) {
      _paintStorm(canvas, center, s, night: _night);
    } else {
      _paintCloudy(canvas, center, s, night: _night);
    }
  }

  void _paintSun(Canvas canvas, Offset c, double s) {
    _drawAnimatedSun(canvas, c, s);
  }

  void _paintPartlyCloudy(Canvas canvas, Offset c, double s) {
    _drawAnimatedSun(
      canvas,
      Offset(c.dx - s * 0.14, c.dy - s * 0.16),
      s * 0.72,
    );
    _drawCartoonCloud(
      canvas,
      Offset(c.dx + s * 0.06, c.dy + s * 0.08),
      s * 0.5,
    );
  }

  void _paintClearNight(Canvas canvas, Offset c, double s) {
    _drawStars(canvas, c, s);
    _drawAnimatedMoon(canvas, c, s);
  }

  void _paintPartlyCloudyNight(Canvas canvas, Offset c, double s) {
    _drawAnimatedMoon(
      canvas,
      Offset(c.dx - s * 0.12, c.dy - s * 0.14),
      s * 0.73,
    );
    _drawCartoonCloud(
      canvas,
      Offset(c.dx + s * 0.06, c.dy + s * 0.08),
      s * 0.5,
      night: true,
    );
  }

  double _sin(double v) => math.sin(v * 6.283185307179586);

  /// Klassieke zon — gele kern, oranje stralen, langzaam draaiend.
  void _drawAnimatedSun(Canvas canvas, Offset c, double s) {
    final sunCenter = c;
    final coreR = s * 0.13;
    final pulse = 1 + 0.04 * _sin(t * 1.0);

    canvas.save();
    canvas.translate(sunCenter.dx, sunCenter.dy);
    canvas.rotate(t * 6.283185307179586 * 0.12);
    canvas.scale(pulse);

    const rayCount = 12;
    for (var i = 0; i < rayCount; i++) {
      final wave = 0.9 + 0.1 * _sin(t * 1.4 + i * 0.2);
      final inner = coreR * 0.92;
      final outer = coreR * (1.55 + 0.25 * wave);
      final halfW = coreR * 0.24;
      final ray = Path()
        ..moveTo(-halfW, -inner)
        ..lineTo(0, -outer)
        ..lineTo(halfW, -inner)
        ..close();
      canvas.drawPath(
        ray,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFB020), Color(0xFFFF7A00)],
          ).createShader(Rect.fromLTRB(-halfW, -outer, halfW, -inner)),
      );
      canvas.rotate(6.283185307179586 / rayCount);
    }
    canvas.restore();

    canvas.drawCircle(
      sunCenter,
      coreR,
      Paint()
        ..shader = RadialGradient(
          colors: const [
            Color(0xFFFFF59D),
            Color(0xFFFFD93D),
            Color(0xFFFFB300),
          ],
          stops: const [0.15, 0.65, 1.0],
        ).createShader(Rect.fromCircle(center: sunCenter, radius: coreR)),
    );
    canvas.drawCircle(
      sunCenter.translate(-coreR * 0.25, -coreR * 0.28),
      coreR * 0.22,
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  void _drawAnimatedMoon(Canvas canvas, Offset c, double s) {
    final floatY = _sin(t * 0.55) * s * 0.014;
    final sway = _sin(t * 0.35) * 0.035;
    final moonCenter = Offset(c.dx, c.dy + floatY);
    final r = s * 0.19;
    final pulse = 1 + 0.04 * _sin(t * 0.9);

    // Zachte maangloed — ademend, in lagen.
    for (var i = 3; i >= 1; i--) {
      final glowScale = (1.25 + i * 0.18) * pulse;
      canvas.drawCircle(
        moonCenter,
        r * glowScale,
        Paint()
          ..color = Color.lerp(
            const Color(0xFF6366F1),
            const Color(0xFF93C5FD),
            i / 3,
          )!.withValues(alpha: 0.05 + i * 0.025)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.03 * i),
      );
    }

    canvas.save();
    canvas.translate(moonCenter.dx, moonCenter.dy);
    canvas.rotate(sway);
    canvas.scale(pulse);

    final disc = Rect.fromCircle(center: Offset.zero, radius: r);

    // Donkere rand voor diepte.
    canvas.drawCircle(
      Offset.zero,
      r * 1.02,
      Paint()
        ..color = const Color(0xFF64748B).withValues(alpha: 0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * 0.08),
    );

    // Maanlichaam — warm wit naar koel grijs.
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.28, -0.32),
          radius: 1.05,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF1F5F9),
            Color(0xFFDCE3EE),
            Color(0xFFB8C4D9),
          ],
          stops: [0.08, 0.42, 0.78, 1.0],
        ).createShader(disc),
    );

    canvas.save();
    canvas.clipPath(Path()..addOval(disc));

    // Mare — donkere maanvlakken.
    _drawMoonPatch(canvas, Offset(-r * 0.18, r * 0.04), r * 0.34, r * 0.26, 0.14);
    _drawMoonPatch(canvas, Offset(r * 0.22, -r * 0.08), r * 0.28, r * 0.22, 0.11);
    _drawMoonPatch(canvas, Offset(-r * 0.05, -r * 0.28), r * 0.2, r * 0.16, 0.09);

    // Kraters — verschillende groottes, lichte schaduw + rand.
    _drawCrater(canvas, Offset(-r * 0.34, -r * 0.12), r * 0.13);
    _drawCrater(canvas, Offset(r * 0.28, r * 0.18), r * 0.1);
    _drawCrater(canvas, Offset(r * 0.05, r * 0.3), r * 0.075);
    _drawCrater(canvas, Offset(-r * 0.12, r * 0.22), r * 0.055);
    _drawCrater(canvas, Offset(r * 0.38, -r * 0.22), r * 0.045);

    // Terminator — zachte schaduwrand voor 3D-effect.
    canvas.drawCircle(
      Offset(r * 0.42, r * 0.02),
      r * 0.96,
      Paint()
        ..color = const Color(0xFF475569).withValues(alpha: 0.22)
        ..blendMode = BlendMode.multiply,
    );

    canvas.restore();

    // Hooglicht — langzaam verschuivend.
    final highlightShift = _sin(t * 0.75) * r * 0.04;
    canvas.drawCircle(
      Offset(-r * 0.28 + highlightShift, -r * 0.3),
      r * 0.18,
      Paint()..color = Colors.white.withValues(alpha: 0.38),
    );
    canvas.drawCircle(
      Offset(-r * 0.15 + highlightShift * 0.6, -r * 0.18),
      r * 0.07,
      Paint()..color = Colors.white.withValues(alpha: 0.22),
    );

    // Dunne rand.
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.045,
    );

    canvas.restore();
  }

  void _drawMoonPatch(
    Canvas canvas,
    Offset center,
    double w,
    double h,
    double alpha,
  ) {
    canvas.drawOval(
      Rect.fromCenter(center: center, width: w, height: h),
      Paint()..color = const Color(0xFF94A3B8).withValues(alpha: alpha),
    );
  }

  void _drawCrater(Canvas canvas, Offset center, double radius) {
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = const Color(0xFF94A3B8).withValues(alpha: 0.16),
    );
    canvas.drawCircle(
      center.translate(-radius * 0.22, -radius * 0.22),
      radius * 0.28,
      Paint()..color = Colors.white.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF64748B).withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.12,
    );
  }

  void _drawStars(Canvas canvas, Offset c, double s) {
    final stars = [
      (Offset(-0.24, -0.22), 0.016, 0.0),
      (Offset(0.2, -0.26), 0.013, 0.35),
      (Offset(0.26, -0.04), 0.011, 0.7),
      (Offset(-0.3, 0.06), 0.009, 1.05),
      (Offset(0.08, -0.34), 0.012, 1.4),
      (Offset(-0.08, 0.28), 0.008, 1.75),
    ];

    for (final (rel, size, phase) in stars) {
      final twinkle = 0.25 + 0.75 * _sin(t * 1.15 + phase);
      final drift = _sin(t * 0.4 + phase) * s * 0.004;
      _drawTwinkleStar(
        canvas,
        Offset(c.dx + rel.dx * s + drift, c.dy + rel.dy * s),
        s * size,
        twinkle,
      );
    }
  }

  void _drawTwinkleStar(Canvas canvas, Offset center, double size, double alpha) {
    final paint = Paint()
      ..color = const Color(0xFFEFF6FF).withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, center.dy - size * 2.2)
      ..lineTo(center.dx + size * 0.45, center.dy - size * 0.45)
      ..lineTo(center.dx + size * 2.2, center.dy)
      ..lineTo(center.dx + size * 0.45, center.dy + size * 0.45)
      ..lineTo(center.dx, center.dy + size * 2.2)
      ..lineTo(center.dx - size * 0.45, center.dy + size * 0.45)
      ..lineTo(center.dx - size * 2.2, center.dy)
      ..lineTo(center.dx - size * 0.45, center.dy - size * 0.45)
      ..close();
    canvas.drawPath(path, paint);

    canvas.drawCircle(
      center,
      size * 0.55,
      Paint()..color = Colors.white.withValues(alpha: alpha * 0.85),
    );
  }

  void _paintCloudy(Canvas canvas, Offset c, double s, {bool night = false}) {
    final drift = _sin(t * 0.35) * s * 0.015;
    _drawCartoonCloud(
      canvas,
      Offset(c.dx + drift, c.dy),
      s * 0.56,
      night: night,
    );
  }

  void _paintRain(Canvas canvas, Offset c, double s, {bool night = false}) {
    final drift = _sin(t * 0.35) * s * 0.012;
    _drawCartoonCloud(
      canvas,
      Offset(c.dx + drift, c.dy - s * 0.08),
      s * 0.52,
      dark: true,
      night: night,
    );
    _drawFallingRain(canvas, Offset(c.dx + drift, c.dy), s);
  }

  void _paintSunShowers(Canvas canvas, Offset c, double s, {bool heavy = false}) {
    final drift = _sin(t * 0.35) * s * 0.01;
    _drawAnimatedSun(
      canvas,
      Offset(c.dx - s * 0.16, c.dy - s * 0.18),
      s * 0.58,
    );
    _drawCartoonCloud(
      canvas,
      Offset(c.dx + s * 0.05 + drift, c.dy + s * 0.04),
      s * 0.46,
    );
    _drawFallingRain(
      canvas,
      Offset(c.dx + s * 0.08 + drift, c.dy + s * 0.06),
      s * (heavy ? 0.78 : 0.62),
      dropCount: heavy ? 5 : 3,
    );
  }

  void _paintLightRain(Canvas canvas, Offset c, double s, {bool night = false}) {
    final drift = _sin(t * 0.35) * s * 0.012;
    _drawCartoonCloud(
      canvas,
      Offset(c.dx + drift, c.dy - s * 0.06),
      s * 0.48,
      night: night,
    );
    _drawFallingRain(
      canvas,
      Offset(c.dx + drift, c.dy + s * 0.02),
      s * 0.55,
      dropCount: 3,
    );
  }

  void _paintSnow(Canvas canvas, Offset c, double s, {bool night = false}) {
    final drift = _sin(t * 0.3) * s * 0.012;
    _drawCartoonCloud(
      canvas,
      Offset(c.dx + drift, c.dy - s * 0.08),
      s * 0.5,
      night: night,
    );
    _drawFallingSnow(canvas, Offset(c.dx + drift, c.dy), s);
  }

  void _paintStorm(Canvas canvas, Offset c, double s, {bool night = false}) {
    final drift = _sin(t * 0.4) * s * 0.01;
    _drawCartoonCloud(
      canvas,
      Offset(c.dx + drift, c.dy - s * 0.1),
      s * 0.54,
      dark: true,
      night: night,
    );
    _drawFallingRain(canvas, Offset(c.dx + drift, c.dy - s * 0.02), s * 0.85);
    _drawLightning(canvas, Offset(c.dx + drift, c.dy), s);
  }

  void _drawFallingRain(Canvas canvas, Offset c, double s, {int dropCount = 6}) {
    for (var i = 0; i < dropCount; i++) {
      final phase = (t + i * 0.16) % 1.0;
      final x = c.dx - s * 0.16 + i * s * 0.065;
      final yStart = c.dy + s * 0.04;
      final y = yStart + phase * s * 0.22;
      final alpha = phase < 0.85 ? 1.0 : (1 - phase) / 0.15;
      _drawRainDrop(
        canvas,
        Offset(x, y),
        s * 0.045,
        alpha: alpha,
      );
    }
  }

  void _drawRainDrop(Canvas canvas, Offset tip, double size, {double alpha = 1}) {
    final path = Path()
      ..moveTo(tip.dx, tip.dy)
      ..quadraticBezierTo(
        tip.dx + size * 0.65,
        tip.dy + size * 0.55,
        tip.dx,
        tip.dy + size * 1.15,
      )
      ..quadraticBezierTo(
        tip.dx - size * 0.65,
        tip.dy + size * 0.55,
        tip.dx,
        tip.dy,
      );
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF3B82F6).withValues(alpha: alpha),
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF93C5FD).withValues(alpha: alpha * 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size * 0.08,
    );
  }

  void _drawFallingSnow(Canvas canvas, Offset c, double s) {
    for (var i = 0; i < 6; i++) {
      final phase = (t + i * 0.14) % 1.0;
      final sway = _sin(t * 0.8 + i) * s * 0.02;
      final x = c.dx - s * 0.15 + i * s * 0.06 + sway;
      final y = c.dy + s * 0.05 + phase * s * 0.2;
      final r = s * 0.018 + (i.isEven ? 0.004 * s : 0);
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()..color = Colors.white.withValues(alpha: 0.95),
      );
      canvas.drawCircle(
        Offset(x, y),
        r,
        Paint()
          ..color = const Color(0xFFBAE6FD).withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * 0.006,
      );
    }
  }

  void _drawLightning(Canvas canvas, Offset c, double s) {
    if (t % 1.0 > 0.55 && t % 1.0 < 0.72) return;

    final bolt = Path()
      ..moveTo(c.dx + s * 0.04, c.dy + s * 0.04)
      ..lineTo(c.dx - s * 0.02, c.dy + s * 0.13)
      ..lineTo(c.dx + s * 0.03, c.dy + s * 0.13)
      ..lineTo(c.dx - s * 0.05, c.dy + s * 0.26);
    canvas.drawPath(
      bolt,
      Paint()
        ..color = const Color(0xFFFFEB3B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.04
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Pluizig wolkje in cartoon-stijl.
  void _drawCartoonCloud(
    Canvas canvas,
    Offset c,
    double w, {
    bool dark = false,
    bool night = false,
  }) {
    final h = w * 0.38;
    final base = night
        ? const Color(0xFF475569)
        : dark
            ? const Color(0xFFCBD5E1)
            : const Color(0xFFF8FAFC);
    final shadow = night
        ? const Color(0xFF1E293B)
        : dark
            ? const Color(0xFF64748B)
            : const Color(0xFF94A3B8);
    final puff = Paint()..color = base;
    final shade = Paint()..color = shadow.withValues(alpha: 0.35);

    canvas.drawOval(
      Rect.fromCenter(center: c.translate(0, h * 0.08), width: w, height: h),
      shade,
    );
    canvas.drawCircle(Offset(c.dx - w * 0.2, c.dy - h * 0.05), w * 0.19, puff);
    canvas.drawCircle(Offset(c.dx + w * 0.18, c.dy - h * 0.08), w * 0.21, puff);
    canvas.drawCircle(Offset(c.dx, c.dy - h * 0.2), w * 0.22, puff);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy + h * 0.02),
        width: w * 0.9,
        height: h * 0.72,
      ),
      puff,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeWeatherArtPainter oldDelegate) {
    return oldDelegate.code != code ||
        oldDelegate.isDay != isDay ||
        oldDelegate.t != t;
  }
}

/// Compact stat-tegel voor de hero-kaart (3 naast elkaar).
class WeatherHeroStatTile extends StatelessWidget {
  const WeatherHeroStatTile({
    super.key,
    required this.kind,
    required this.value,
    required this.caption,
  });

  final WeatherStatKind kind;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = switch (kind) {
      WeatherStatKind.wind => (
          Icons.air_rounded,
          const Color(0xFF0284C7),
          const Color(0xFFE0F2FE),
        ),
      WeatherStatKind.humidity => (
          Icons.water_drop_outlined,
          const Color(0xFF2563EB),
          const Color(0xFFDBEAFE),
        ),
      WeatherStatKind.uv => (
          Icons.wb_sunny_rounded,
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7),
        ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: TuinierColors.textPrimary,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          caption,
          style: const TextStyle(
            fontSize: 10,
            color: TuinierColors.textSecondary,
            height: 1.1,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Wind / vochtigheid / UV in de hero-kaart.
class WeatherStatChip extends StatelessWidget {
  const WeatherStatChip({
    super.key,
    required this.kind,
    required this.label,
  });

  final WeatherStatKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (icon, color, bg) = switch (kind) {
      WeatherStatKind.wind => (
          Icons.air_rounded,
          const Color(0xFF0284C7),
          const Color(0xFFE0F2FE),
        ),
      WeatherStatKind.humidity => (
          Icons.water_drop_outlined,
          const Color(0xFF2563EB),
          const Color(0xFFDBEAFE),
        ),
      WeatherStatKind.uv => (
          Icons.wb_sunny_rounded,
          const Color(0xFFD97706),
          const Color(0xFFFEF3C7),
        ),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: TuinierColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum WeatherStatKind { wind, humidity, uv }

/// Risico-icoon: regenwolk, wind, thermometer.
class WeatherRiskIcon extends StatelessWidget {
  const WeatherRiskIcon({
    super.key,
    required this.kind,
    this.size = 44,
  });

  final GardenWeatherRiskKind kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (widget, bg) = switch (kind) {
      GardenWeatherRiskKind.rain => (_RainCloudIcon(size: size * 0.55), const Color(0xFFDBEAFE)),
      GardenWeatherRiskKind.wind => (
          Icon(Icons.air_rounded, size: size * 0.52, color: const Color(0xFF0284C7)),
          const Color(0xFFE0F2FE),
        ),
      GardenWeatherRiskKind.cold => (
          Icon(Icons.thermostat_rounded, size: size * 0.52, color: TuinierColors.error),
          const Color(0xFFFEE2E2),
        ),
      GardenWeatherRiskKind.none => (
          Icon(Icons.info_outline_rounded, size: size * 0.48, color: TuinierColors.textSecondary),
          TuinierColors.border,
        ),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      alignment: Alignment.center,
      child: widget,
    );
  }
}

class _RainCloudIcon extends StatelessWidget {
  const _RainCloudIcon({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 1.4,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: Icon(
              Icons.cloud,
              size: size * 0.85,
              color: const Color(0xFF3B82F6),
            ),
          ),
          Positioned(
            bottom: 0,
            left: size * 0.15,
            child: Icon(
              Icons.water_drop_outlined,
              size: size * 0.32,
              color: const Color(0xFF2563EB),
            ),
          ),
          Positioned(
            bottom: 0,
            right: size * 0.15,
            child: Icon(
              Icons.water_drop_outlined,
              size: size * 0.28,
              color: const Color(0xFF60A5FA),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tuin-impact icoon per categorie.
class WeatherImpactIcon extends StatelessWidget {
  const WeatherImpactIcon({
    super.key,
    required this.title,
    required this.tone,
    this.size = 40,
  });

  final String title;
  final WeatherImpactTone tone;
  final double size;

  @override
  Widget build(BuildContext context) {
    final key = title.toLowerCase();
    final (icon, color, bg) = switch (key) {
      'water geven' => (
          Icons.water_drop_outlined,
          const Color(0xFF2563EB),
          const Color(0xFFDBEAFE),
        ),
      'oogsten' => (
          Icons.shopping_basket_outlined,
          const Color(0xFF15803D),
          const Color(0xFFDCFCE7),
        ),
      'snoeien' => (
          Icons.content_cut_outlined,
          const Color(0xFFCA8A04),
          const Color(0xFFFEF9C3),
        ),
      'zaaien' => (
          Icons.yard_outlined,
          TuinierColors.primary,
          const Color(0xFFDCFCE7),
        ),
      _ => (
          Icons.eco_outlined,
          TuinierColors.primary,
          const Color(0xFFDCFCE7),
        ),
    };

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Icon(icon, size: size * 0.52, color: color),
    );
  }
}

/// Neerslagkans met druppel.
class PrecipBadge extends StatelessWidget {
  const PrecipBadge({super.key, required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final high = percent >= 50;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.water_drop_outlined,
          size: 12,
          color: high ? const Color(0xFF2563EB) : TuinierColors.info,
        ),
        const SizedBox(width: 2),
        Text(
          '$percent%',
          style: TextStyle(
            fontSize: 11,
            color: high ? const Color(0xFF2563EB) : TuinierColors.info,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

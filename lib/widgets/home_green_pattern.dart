import 'package:flutter/material.dart';

import '../theme/tuinier_colors.dart';

/// Organisch donkergroen patroon — mockup tuingezondheid / AI-kaart.
class HomeGreenPattern extends StatelessWidget {
  const HomeGreenPattern({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.dark = false,
  });

  final Widget child;
  final double borderRadius;
  /// `true` = AI-advies (nog donkerder); `false` = tuingezondheid.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? const [Color(0xFF143D18), Color(0xFF1B5E20)]
                    : const [Color(0xFF1B5E20), Color(0xFF2E7D32)],
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _OrganicGreenPatternPainter(dark: dark),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _OrganicGreenPatternPainter extends CustomPainter {
  _OrganicGreenPatternPainter({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final baseDark = dark ? const Color(0xFF0F2A12) : const Color(0xFF144A19);
    final baseMid = dark ? const Color(0xFF1A4D1F) : const Color(0xFF256B29);
    final baseLight = dark ? const Color(0xFF236028) : const Color(0xFF338A38);

    final blobs = [
      (Offset(size.width * 0.88, size.height * 0.08), size.width * 0.58, baseMid, 0.55),
      (Offset(size.width * 0.02, size.height * 0.72), size.width * 0.48, baseDark, 0.65),
      (Offset(size.width * 0.62, size.height * 0.92), size.width * 0.4, baseDark, 0.5),
      (Offset(size.width * 0.28, size.height * 0.18), size.width * 0.34, baseLight, 0.35),
      (Offset(size.width * 0.72, size.height * 0.52), size.width * 0.3, baseMid, 0.4),
    ];

    for (final (center, radius, color, opacity) in blobs) {
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
      canvas.drawCircle(center, radius, paint);
    }

    // Subtiele donkere golf — geen lichte overlay.
    final wave = Path()
      ..moveTo(0, size.height * 0.52)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.42,
        size.width * 0.55,
        size.height * 0.5,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.58,
        size.width,
        size.height * 0.46,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      wave,
      Paint()..color = baseDark.withValues(alpha: 0.22),
    );

    // Zeer subtiele highlight rechtsboven (niet wit — donkergroen).
    canvas.drawCircle(
      Offset(size.width * 0.95, size.height * 0.05),
      size.width * 0.35,
      Paint()
        ..color = baseLight.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

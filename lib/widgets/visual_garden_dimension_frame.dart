import 'package:flutter/material.dart';

import '../data/visual_garden_bed_colors.dart';

/// Omlijsting met zichtbare afmetingslijnen (breedte boven, hoogte links).
class VisualGardenDimensionFrame extends StatelessWidget {
  const VisualGardenDimensionFrame({
    super.key,
    required this.widthCm,
    required this.heightCm,
    required this.child,
  });

  final double widthCm;
  final double heightCm;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final wLabel = '${widthCm.round()} cm';
    final hLabel = '${heightCm.round()} cm';

    return Center(
      child: ConstrainedBox(
        // Ruim genoeg voor een grotere sleep-canvas; breedte volgt de parent.
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 36),
              child: SizedBox(
                height: 26,
                child: CustomPaint(
                  painter: const _DimLinePainter(),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      color: Colors.white,
                      child: Text(
                        wLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: VisualGardenBedColors.titleGreen,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 36,
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: SizedBox(
                      height: 26,
                      child: CustomPaint(
                        painter: const _DimLinePainter(),
                        child: Center(
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8),
                            color: Colors.white,
                            child: Text(
                              hLabel,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: VisualGardenBedColors.titleGreen,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DimLinePainter extends CustomPainter {
  const _DimLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = VisualGardenBedColors.dimensionLine
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square;
    final y = size.height / 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    canvas.drawLine(Offset(0, y - 6), Offset(0, y + 6), paint);
    canvas.drawLine(
      Offset(size.width, y - 6),
      Offset(size.width, y + 6),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

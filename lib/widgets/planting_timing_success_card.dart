import 'package:flutter/material.dart';

import '../data/planting_timing_advice.dart';

/// Groen bericht bij teeltinformatie als scan oogst nog haalbaar vindt.
class PlantingTimingSuccessCard extends StatelessWidget {
  const PlantingTimingSuccessCard({
    super.key,
    required this.assessment,
  });

  final PlantingTimingAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final bg = Color.alphaBlend(
      Colors.green.withValues(alpha: 0.14),
      cs.surfaceContainerLow,
    );
    final fg = Color.lerp(cs.onSurface, Colors.green.shade800, 0.5)!;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green.shade700, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Oogst nog haalbaar',
                    style: t.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...assessment.positiveLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        line,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: fg,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Zoekknop naar de groentenatlas — zacht groen, niet fel.
class VegetableSearchButton extends StatelessWidget {
  const VegetableSearchButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final softGreen = Color.lerp(cs.surface, cs.primary, 0.14)!;
    final borderGreen = Color.lerp(cs.outline, cs.primary, 0.35)!;
    final iconGreen = Color.lerp(cs.onSurfaceVariant, cs.primary, 0.45)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Material(
        color: softGreen,
        elevation: 0,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderGreen, width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(Icons.search, color: iconGreen, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Alle groenten zoeken',
                      style: t.textTheme.titleSmall?.copyWith(
                        color: cs.onSurface.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

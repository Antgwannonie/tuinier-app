import 'package:flutter/material.dart';

import '../models/garden_pest.dart';

/// Uitklapbare kaart met herkenning en actiestappen voor één plaag.
class PestDetailCard extends StatelessWidget {
  const PestDetailCard({
    super.key,
    required this.pest,
    required this.expanded,
    required this.onTap,
  });

  final GardenPest pest;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pest_control,
                      size: 22,
                      color: cs.error,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        pest.nameNl,
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(
                      expanded ? Icons.expand_less : Icons.expand_more,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  pest.recognition,
                  maxLines: expanded ? null : 2,
                  overflow: expanded ? null : TextOverflow.ellipsis,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                if (expanded) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Zo pak je het aan',
                    style: t.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...pest.actionSteps.asMap().entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${e.key + 1}.',
                            style: t.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(child: Text(e.value)),
                        ],
                      ),
                    );
                  }),
                  if (pest.prevention.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Voorkomen',
                      style: t.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...pest.prevention.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text('• $tip'),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

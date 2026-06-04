import 'package:flutter/material.dart';

import '../data/pest_guide_lookup.dart';
import '../models/garden_plant_profile.dart';
import '../models/garden_pest.dart';
import '../models/vegetable.dart';
import '../screens/pest_guide_screen.dart';
import 'pest_detail_card.dart';

/// Stappenplan bij een AI-waarschuwing: gekoppelde plagen + advies.
Future<void> showPestActionGuideSheet({
  required BuildContext context,
  required Vegetable vegetable,
  required String warningText,
  GardenPlantProfile? profile,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final pests = pestsForWarningsAndPlant(
        warnings: [warningText],
        vegetable: vegetable,
        profile: profile,
      );
      final advice = profile?.lastAnalysis?.advice;

      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return _PestActionGuideBody(
            scrollController: scrollController,
            vegetable: vegetable,
            warningText: warningText,
            pests: pests,
            aiAdvice: advice,
          );
        },
      );
    },
  );
}

class _PestActionGuideBody extends StatefulWidget {
  const _PestActionGuideBody({
    required this.scrollController,
    required this.vegetable,
    required this.warningText,
    required this.pests,
    this.aiAdvice,
  });

  final ScrollController scrollController;
  final Vegetable vegetable;
  final String warningText;
  final List<GardenPest> pests;
  final String? aiAdvice;

  @override
  State<_PestActionGuideBody> createState() => _PestActionGuideBodyState();
}

class _PestActionGuideBodyState extends State<_PestActionGuideBody> {
  String? _expandedId;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return SafeArea(
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Text(
            'Actie ondernemen',
            style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            widget.vegetable.nameNl,
            style: t.textTheme.titleSmall?.copyWith(color: cs.primary),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.errorContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded, color: cs.error, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(widget.warningText)),
              ],
            ),
          ),
          if (widget.aiAdvice != null && widget.aiAdvice!.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Advies van je laatste scan',
              style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(widget.aiAdvice!),
          ],
          if (widget.vegetable.commonIssues.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Bekend bij dit gewas',
              style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              widget.vegetable.commonIssues,
              style: t.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            widget.pests.isEmpty
                ? 'Geen exacte match in de plagen-gids'
                : 'Aanbevolen aanpak (${widget.pests.length})',
            style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (widget.pests.isEmpty)
            Text(
              'Open de volledige plagen-gids om symptomen te vergelijken, '
              'of scan opnieuw met een scherpere foto.',
              style: t.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            )
          else
            ...widget.pests.map(
              (p) => PestDetailCard(
                pest: p,
                expanded: _expandedId == p.id,
                onTap: () => setState(() {
                  _expandedId = _expandedId == p.id ? null : p.id;
                }),
              ),
            ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => PestGuideScreen(
                    initialQuery: widget.warningText.split(' ').first,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('Volledige plagen-gids'),
          ),
        ],
      ),
    );
  }
}

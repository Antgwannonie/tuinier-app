import 'package:flutter/material.dart';

import '../../data/plant_combination_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'combination_illustrations.dart';
import 'plant_combination_detail_screen.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

const _comboGreen = Color(PlantDetailDesign.primaryGreen);

class PlantCombinationGuideView extends StatelessWidget {
  const PlantCombinationGuideView({super.key, required this.guide});

  final PlantCombinationGuide guide;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < guide.sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          PlantDetailCard(
            child: _CombinationSectionCard(section: guide.sections[i]),
          ),
        ],
      ],
    );
  }
}

class _CombinationSectionCard extends StatelessWidget {
  const _CombinationSectionCard({required this.section});

  final PlantCombinationSection section;

  void _openDetail(BuildContext context) {
    if (!section.hasDetailPage) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantCombinationDetailScreen(section: section),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final tappable = section.hasDetailPage;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          section.title,
          style: t.textTheme.titleMedium?.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: _comboGreen,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          section.summary,
          style: t.textTheme.bodyMedium?.copyWith(
            height: 1.45,
            fontSize: 14,
            color: const Color(PlantDetailDesign.textPrimary),
          ),
        ),
        if (section.checklist != null && section.checklist!.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final item in section.checklist!) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded,
                    size: 18, color: _comboGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
        const SizedBox(height: 14),
        CombinationIllustration(
          kind: section.illustration,
          size: CombinationIllustrationSize.large,
        ),
        if (tappable) const GuideMeerInfoFooter(margin: EdgeInsets.only(top: 12)),
      ],
    );

    if (!tappable) return content;

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
      child: content,
    );
  }
}

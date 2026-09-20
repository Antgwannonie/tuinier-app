import 'package:flutter/material.dart';

import '../../data/plant_problems_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'plant_problems_detail_screen.dart';
import 'problems_illustrations.dart';

const _problemsGreen = Color(PlantDetailDesign.primaryGreen);

class PlantProblemsGuideView extends StatelessWidget {
  const PlantProblemsGuideView({super.key, required this.guide});

  final PlantProblemsGuide guide;

  @override
  Widget build(BuildContext context) {
    final sections = <PlantProblemsSection>[
      for (final row in guide.rows) ...row.sections,
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _ProblemSummaryCard(section: sections[i]),
        ],
      ],
    );
  }
}

class _ProblemSummaryCard extends StatelessWidget {
  const _ProblemSummaryCard({required this.section});

  final PlantProblemsSection section;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantProblemsDetailScreen(section: section),
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
            color: _problemsGreen,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          section.summary,
          style: t.textTheme.bodyMedium?.copyWith(
            height: 1.45,
            fontSize: 13,
            color: const Color(PlantDetailDesign.textPrimary),
          ),
        ),
        const SizedBox(height: 12),
        ProblemsIllustration(
          kind: section.illustration,
          size: ProblemsIllustrationSize.compact,
        ),
        if (tappable) const GuideMeerInfoFooter(margin: EdgeInsets.only(top: 12)),
      ],
    );

    if (!tappable) {
      return PlantDetailCard(child: content);
    }

    return PlantDetailCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context),
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      ),
    );
  }
}

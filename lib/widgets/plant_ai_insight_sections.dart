import 'package:flutter/material.dart';

import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import 'garden_warning_style.dart';

/// Uitgebreide AI-secties: gezondheid, plagen, water, coach, enz.
class PlantAiInsightSections extends StatelessWidget {
  const PlantAiInsightSections({
    super.key,
    required this.analysis,
    this.compact = false,
    this.ornamentalBloomOnly = false,
    this.edibleBloomDual = false,
  });

  final PlantAiAnalysis analysis;
  final bool compact;
  /// Sier-moestuinbloem: geen oogst-tegel, alleen bloei.
  final bool ornamentalBloomOnly;
  /// Eetbare moestuinbloem: bloei én optioneel plukken om te eten.
  final bool edibleBloomDual;

  @override
  Widget build(BuildContext context) {
    final insight = analysis.insight;
    if (insight == null) return const SizedBox.shrink();

    final children = <Widget>[
      _SummaryBlock(insight: insight, priority: insight.priority),
      _ScoreRow(insight: insight),
      if (insight.problems.isNotEmpty) _ProblemsBlock(problems: insight.problems),
      if (insight.growthScheduleNote != null &&
          insight.growthScheduleNote!.trim().isNotEmpty)
        _InfoTile(
          icon: Icons.timeline,
          title: 'Groei t.o.v. gemiddeld',
          body: insight.growthScheduleNote!,
          highlight: insight.growthScheduleStatus ==
              AiGrowthScheduleStatus.behind,
        ),
      if (!compact) ...[
        _IssueGrid(
          title: 'Plaagherkenning',
          icon: Icons.bug_report_outlined,
          items: insight.pests,
        ),
        _IssueGrid(
          title: 'Ziekteherkenning',
          icon: Icons.coronavirus_outlined,
          items: insight.diseases,
        ),
        if (insight.waterStatus != null)
          _InfoTile(
            icon: Icons.water_drop_outlined,
            title: 'Vocht — ${insight.waterStatus!.labelNl}',
            body: [
              if (insight.waterSymptoms != null) insight.waterSymptoms!,
              if (insight.waterAdvice != null) insight.waterAdvice!,
            ].where((s) => s.trim().isNotEmpty).join('\n'),
            highlight: insight.waterStatus != AiWaterStatus.ok,
          ),
        if (insight.confirmedNutrients.isNotEmpty)
          _NutrientBlock(nutrients: insight.confirmedNutrients),
        if (insight.growthPhaseDetail != null)
          _InfoTile(
            icon: Icons.eco_outlined,
            title: 'Groeifase',
            body: insight.growthPhaseDetail!,
          ),
        if (insight.floweringStatus != null)
          _InfoTile(
            icon: Icons.local_florist_outlined,
            title: 'Bloei',
            body: [
              insight.floweringStatus!.labelNl,
              if (insight.floweringNote != null) insight.floweringNote!,
            ].join('\n'),
          ),
        if ((!ornamentalBloomOnly || edibleBloomDual) &&
            (insight.harvestReady != null || insight.ripenessNote != null))
          _InfoTile(
            icon: edibleBloomDual
                ? Icons.restaurant_outlined
                : Icons.shopping_basket_outlined,
            title: edibleBloomDual
                ? (insight.harvestReady == true
                    ? 'Geschikt om te plukken'
                    : 'Eetbaar & bloei')
                : (insight.harvestReady == true
                    ? 'Oogstklaar'
                    : 'Oogst & rijpheid'),
            body: [
              if (insight.harvestReady == true)
                edibleBloomDual
                    ? 'Bloemen of blad lijken geschikt om te eten — of laat staan voor insecten.'
                    : 'Plant lijkt klaar om te oogsten.',
              if (insight.ripenessNote != null) insight.ripenessNote!,
              if (edibleBloomDual)
                'Je kunt ook «Seizoen afronden» kiezen om niet te eten en uit te laten bloeien.',
            ].where((s) => s.isNotEmpty).join('\n'),
          ),
        if ((ornamentalBloomOnly || edibleBloomDual) &&
            analysis.bloomSeasonNote != null &&
            analysis.bloomSeasonNote!.trim().isNotEmpty)
          _InfoTile(
            icon: Icons.local_florist_outlined,
            title: edibleBloomDual ? 'Bloei in de moestuin' : 'Bloei op haar best',
            body: analysis.bloomSeasonNote!,
          ),
        if (insight.pruningAdvice != null &&
            insight.pruningAdvice!.trim().isNotEmpty)
          _InfoTile(
            icon: Icons.content_cut_outlined,
            title: 'Snoeiadvies',
            body: insight.pruningAdvice!,
          ),
        if (insight.weedsDetected == true)
          _InfoTile(
            icon: Icons.grass_outlined,
            title: 'Onkruid',
            body: insight.weedsNote ?? 'Onkruid of ongewenste planten zichtbaar.',
            highlight: true,
          ),
        if (insight.sunlightLevel != null)
          _InfoTile(
            icon: Icons.wb_sunny_outlined,
            title: 'Zonlicht (${insight.sunlightLevel})',
            body: insight.sunlightAdvice ?? '',
          ),
      ],
      if (insight.recommendedActions.isNotEmpty)
        _ActionsBlock(actions: insight.recommendedActions),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          children[i],
        ],
      ],
    );
  }
}

class _SummaryBlock extends StatelessWidget {
  const _SummaryBlock({
    required this.insight,
    required this.priority,
  });

  final PlantAiInsightReport insight;
  final AiPriority priority;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final urgent = priority == AiPriority.high || priority == AiPriority.urgent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: urgent
            ? GardenWarningStyle.background(cs)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: urgent
            ? Border.all(color: GardenWarningStyle.icon(cs).withValues(alpha: 0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Samenvatting',
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _ChipLabel(
                label: 'Prioriteit: ${priority.labelNl}',
                urgent: urgent,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            insight.summary,
            style: t.textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({required this.insight});

  final PlantAiInsightReport insight;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: _ScoreCard(
            label: 'Gezondheid',
            score: insight.healthScore,
            icon: Icons.favorite_border,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ScoreCard(
            label: 'Groei',
            score: insight.growthScore,
            icon: Icons.trending_up,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ScoreCard(
            label: 'Risico',
            score: null,
            risk: insight.riskLevel,
            icon: Icons.shield_outlined,
          ),
        ),
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    this.score,
    this.risk,
    required this.icon,
  });

  final String label;
  final int? score;
  final AiRiskLevel? risk;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final value = score != null ? '$score' : risk?.labelNl ?? '—';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(height: 4),
          Text(
            value,
            style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: t.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProblemsBlock extends StatelessWidget {
  const _ProblemsBlock({required this.problems});

  final List<String> problems;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: GardenWarningStyle.background(cs),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Geconstateerde problemen',
            style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          ...problems.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• $p',
                style: t.textTheme.bodySmall?.copyWith(
                  color: GardenWarningStyle.foreground(cs),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IssueGrid extends StatelessWidget {
  const _IssueGrid({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<AiIssueFinding> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final detected = items.where((i) => i.detected).toList();
    if (detected.isEmpty && !items.any((i) => i.confidencePercent >= 40)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.map((item) => _IssueRow(item: item)),
      ],
    );
  }
}

class _IssueRow extends StatelessWidget {
  const _IssueRow({required this.item});

  final AiIssueFinding item;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final active = item.detected && item.confidencePercent >= 55;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            active ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 18,
            color: active
                ? GardenWarningStyle.icon(cs)
                : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.labelNl} — ${item.confidencePercent}%',
                  style: t.textTheme.bodySmall?.copyWith(
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? GardenWarningStyle.foreground(cs) : null,
                  ),
                ),
                if (active && item.symptoms != null)
                  Text(item.symptoms!, style: t.textTheme.bodySmall),
                if (active && item.action != null)
                  Text(
                    item.action!,
                    style: t.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientBlock extends StatelessWidget {
  const _NutrientBlock({required this.nutrients});

  final List<AiNutrientIssue> nutrients;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Voedingstekorten',
          style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        ...nutrients.map(
          (n) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '• ${n.labelNl} (${n.confidencePercent}%): '
              '${n.symptoms ?? n.explanation ?? ''}',
              style: t.textTheme.bodySmall,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.body,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: highlight
            ? GardenWarningStyle.infoBackground(cs)
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(body, style: t.textTheme.bodySmall?.copyWith(height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsBlock extends StatelessWidget {
  const _ActionsBlock({required this.actions});

  final List<AiRecommendedAction> actions;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aanbevolen acties',
          style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        ...actions.map(
          (a) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ChipLabel(
                  label: a.priority.labelNl,
                  urgent: a.priority == AiPriority.high ||
                      a.priority == AiPriority.urgent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.title,
                        style: t.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (a.description != null)
                        Text(a.description!, style: t.textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.label, this.urgent = false});

  final String label;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: urgent
            ? GardenWarningStyle.background(cs)
            : cs.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: urgent
              ? GardenWarningStyle.foreground(cs)
              : cs.onSecondaryContainer,
        ),
      ),
    );
  }
}

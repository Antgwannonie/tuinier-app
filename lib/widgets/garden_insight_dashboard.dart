import 'package:flutter/material.dart';

import '../data/daily_tip_prefs_store.dart';
import '../data/garden_daily_tips.dart';
import '../data/garden_insight_snapshot.dart';
import '../data/garden_weather_advice.dart';
import '../data/insect_scan_store.dart';
import '../models/plant_ai_insight_report.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';
import '../theme/tuinier_theme.dart';

class GardenInsightDashboard extends StatelessWidget {
  const GardenInsightDashboard({
    super.key,
    required this.snapshot,
    required this.dailyTipPrefs,
    this.insectStore,
    this.onResolveHarmfulPest,
    this.onDailyTipNotificationsChanged,
    this.onRefreshWeather,
    this.weatherLoading = false,
  });

  final GardenInsightSnapshot snapshot;
  final DailyTipPrefsStore dailyTipPrefs;
  final InsectScanStore? insectStore;
  final Future<void> Function(String pestId)? onResolveHarmfulPest;
  final ValueChanged<bool>? onDailyTipNotificationsChanged;
  final VoidCallback? onRefreshWeather;
  final bool weatherLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _InsightHero(snapshot: snapshot),
        const SizedBox(height: 12),
        _StatsGrid(snapshot: snapshot),
        const SizedBox(height: 12),
        _CoachCard(summary: snapshot.coachSummary),
        const SizedBox(height: 16),
        _SectionTitle('Belangrijk nu', icon: Icons.priority_high),
        const SizedBox(height: 8),
        _CompactWeather(
          summary: snapshot.weatherSummary,
          tips: snapshot.weatherTips,
          loading: weatherLoading,
          onRefresh: onRefreshWeather,
        ),
        const SizedBox(height: 10),
        _SubLabel('Taken voor vandaag'),
        const SizedBox(height: 6),
        _ActionsSection(
          actions: snapshot.todayActions,
          compact: true,
          limit: 4,
        ),
        const SizedBox(height: 12),
        _SubLabel('Problemen & waarschuwingen'),
        const SizedBox(height: 6),
        _ProblemsSection(
          problems: snapshot.problems,
          compact: true,
          limit: 4,
        ),
        if (snapshot.problems.length > 4) ...[
          const SizedBox(height: 8),
          _ExpandBlock(
            title: 'Alle waarschuwingen',
            subtitle: '${snapshot.problems.length} problemen',
            icon: Icons.warning_amber_outlined,
            children: [
              _ProblemsSection(problems: snapshot.problems),
            ],
          ),
        ],
        if (snapshot.todayActions.length > 4) ...[
          const SizedBox(height: 8),
          _ExpandBlock(
            title: 'Alle taken',
            subtitle: '${snapshot.todayActions.length} taken',
            icon: Icons.bolt_outlined,
            children: [
              _ActionsSection(actions: snapshot.todayActions),
            ],
          ),
        ],
        const SizedBox(height: 14),
        _ExpandBlock(
          title: 'Groei, water & oogst',
          subtitle: _growWaterHarvestSubtitle(snapshot),
          icon: Icons.trending_up,
          children: [
            _SubLabel('Groei-overzicht'),
            const SizedBox(height: 6),
            _GrowthSection(items: snapshot.growthItems),
            const SizedBox(height: 12),
            _SubLabel('Waterstatus'),
            const SizedBox(height: 6),
            _WaterSection(
              waterScore: snapshot.waterScore,
              items: snapshot.waterItems,
            ),
            const SizedBox(height: 12),
            _SubLabel('Oogstcentrum'),
            const SizedBox(height: 6),
            _HarvestSection(
              within7: snapshot.harvestWithin7,
              within30: snapshot.harvestWithin30,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ExpandBlock(
          title: 'Insecten & biodiversiteit',
          subtitle: '${snapshot.biodiversity.beneficialCount} nuttig · '
              'score ${snapshot.biodiversity.score}',
          icon: Icons.bug_report_outlined,
          children: [
            _BiodiversitySection(
              bio: snapshot.biodiversity,
              onResolveHarmfulPest: onResolveHarmfulPest,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ExpandBlock(
          title: 'Voeding & AI-scans',
          subtitle: '${snapshot.nutrients.length} tekorten · '
              '${snapshot.recentScans.length} scans',
          icon: Icons.science_outlined,
          children: [
            _SubLabel('Voedingstekorten'),
            const SizedBox(height: 6),
            _NutrientsSection(nutrients: snapshot.nutrients),
            const SizedBox(height: 12),
            _SubLabel('Laatste AI-scans'),
            const SizedBox(height: 6),
            _RecentScansSection(scans: snapshot.recentScans),
          ],
        ),
        const SizedBox(height: 8),
        _ExpandBlock(
          title: 'Statistieken & weetje',
          subtitle: '${snapshot.seasonStats.scanCount} scans dit seizoen',
          icon: Icons.bar_chart_outlined,
          children: [
            _SeasonStatsSection(stats: snapshot.seasonStats),
            const SizedBox(height: 12),
            _DailyTipCard(
              tip: gardenTipOfTheDay(),
              notificationsEnabled: dailyTipPrefs.notificationsEnabled,
              onNotificationsChanged: onDailyTipNotificationsChanged,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _ExpandBlock(
          title: 'Alle scores',
          subtitle: 'Planten, groei, water, biodiversiteit',
          icon: Icons.eco_outlined,
          children: [
            _HealthCard(snapshot: snapshot),
          ],
        ),
      ],
    );
  }

  String _growWaterHarvestSubtitle(GardenInsightSnapshot s) {
    final parts = <String>[];
    if (s.growthItems.isNotEmpty) parts.add('${s.growthItems.length} groei');
    if (s.waterItems.isNotEmpty) parts.add('${s.waterItems.length} water');
    final harvest = s.harvestWithin7.length + s.harvestWithin30.length;
    if (harvest > 0) parts.add('$harvest oogst');
    return parts.isEmpty ? 'Geen data' : parts.join(' · ');
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: t.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SubLabel extends StatelessWidget {
  const _SubLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    );
  }
}

class _InsightHero extends StatelessWidget {
  const _InsightHero({required this.snapshot});

  final GardenInsightSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final h = snapshot.health;
    final empty = h.plantCount == 0;
    final scoreColor = empty
        ? TuinierColors.textSecondary
        : TuinierColors.healthScoreColor(h.total);

    return Material(
      color: TuinierColors.card,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: TuinierDecorations.card(radius: 20),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  empty ? '—' : '${h.total}',
                  style: tuinScoreStyle(context, color: scoreColor),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    '/100',
                    style: t.textTheme.titleSmall?.copyWith(
                      color: TuinierColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tuingezondheid',
                      style: t.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      snapshot.healthStatus,
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: scoreColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (!empty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _MetricChip('Planten', h.plantHealth),
                  _MetricChip('Groei', snapshot.growthScore),
                  _MetricChip('Water', snapshot.waterScore),
                  _MetricChip('Insecten', h.insectBalance),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.snapshot});

  final GardenInsightSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.55,
      children: [
        _StatCard(
          icon: Icons.warning_amber_rounded,
          label: 'Problemen',
          value: '${snapshot.problems.length}',
          iconColor: TuinierColors.error,
        ),
        _StatCard(
          icon: Icons.bug_report_outlined,
          label: 'Insecten',
          value: '${snapshot.biodiversity.beneficialCount}',
          iconColor: TuinierColors.success,
        ),
        _StatCard(
          icon: Icons.water_drop_outlined,
          label: 'Waterstatus',
          value: snapshot.waterScore >= 70 ? 'Goed' : 'Let op',
          iconColor: TuinierColors.info,
        ),
        _StatCard(
          icon: Icons.calendar_today_outlined,
          label: 'Oogstverwachting',
          value: '${snapshot.harvestWithin7.length + snapshot.harvestWithin30.length}',
          iconColor: TuinierColors.warning,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Material(
      color: TuinierColors.card,
      elevation: 0,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: TuinierDecorations.card(radius: 20),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const Spacer(),
            Text(
              value,
              style: tuinDisplayStyle(context, fontSize: 22),
            ),
            Text(
              label,
              style: t.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip(this.label, this.value);

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: TuinierColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TuinierColors.border),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _QuickChips extends StatelessWidget {
  const _QuickChips({
    required this.actionCount,
    required this.problemCount,
    required this.harvestCount,
    required this.weatherAlerts,
  });

  final int actionCount;
  final int problemCount;
  final int harvestCount;
  final int weatherAlerts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _QuickChip(
            icon: Icons.bolt,
            label: '$actionCount taken',
            highlight: actionCount > 0,
          ),
          const SizedBox(width: 8),
          _QuickChip(
            icon: Icons.warning_amber,
            label: '$problemCount problemen',
            highlight: problemCount > 0,
            alert: problemCount > 0,
          ),
          const SizedBox(width: 8),
          _QuickChip(
            icon: Icons.shopping_basket_outlined,
            label: '$harvestCount oogst',
            highlight: harvestCount > 0,
          ),
          const SizedBox(width: 8),
          _QuickChip(
            icon: Icons.cloud_outlined,
            label: weatherAlerts > 0 ? '$weatherAlerts weer' : 'Weer ok',
            highlight: weatherAlerts > 0,
            alert: weatherAlerts > 0,
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.icon,
    required this.label,
    this.highlight = false,
    this.alert = false,
  });

  final IconData icon;
  final String label;
  final bool highlight;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = alert ? cs.error : cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: highlight
            ? color.withValues(alpha: 0.12)
            : cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlight
              ? color.withValues(alpha: 0.35)
              : cs.outlineVariant.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: highlight ? color : cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: highlight ? color : cs.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _ExpandBlock extends StatelessWidget {
  const _ExpandBlock({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.children,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TuinierColors.card,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: TuinierDecorations.card(radius: 20, shadow: false),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            leading: Icon(icon, size: 22, color: TuinierColors.primary),
            title: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            subtitle: Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TuinierColors.textSecondary,
                  ),
            ),
            children: children,
          ),
        ),
      ),
    );
  }
}

class _CompactWeather extends StatelessWidget {
  const _CompactWeather({
    required this.summary,
    required this.tips,
    required this.loading,
    this.onRefresh,
  });

  final String? summary;
  final List<GardenWeatherTip> tips;
  final bool loading;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (loading && summary == null) {
      return const SizedBox(
        height: 48,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (summary == null) {
      return _Card(
        child: Row(
          children: [
            const Expanded(child: Text('Weer niet beschikbaar')),
            if (onRefresh != null)
              TextButton(onPressed: onRefresh, child: const Text('Opnieuw')),
          ],
        ),
      );
    }

    final topTip = tips.isNotEmpty ? tips.first : null;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.cloud_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Weersinvloed',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (onRefresh != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh, size: 18),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            summary!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
          ),
          if (topTip != null) ...[
            const SizedBox(height: 6),
            Text(
              '${topTip.title}: ${topTip.action}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DailyTipCard extends StatelessWidget {
  const _DailyTipCard({
    required this.tip,
    required this.notificationsEnabled,
    this.onNotificationsChanged,
  });

  final GardenDailyTip tip;
  final bool notificationsEnabled;
  final ValueChanged<bool>? onNotificationsChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.tertiaryContainer.withValues(alpha: 0.35),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, size: 18, color: cs.tertiary),
                const SizedBox(width: 8),
                Text(
                  'Weetje van de dag',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tip.title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              tip.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dagelijkse melding'),
              subtitle: const Text(
                'Elke ochtend om 8:30 een nieuw tuinweetje',
              ),
              value: notificationsEnabled,
              onChanged: onNotificationsChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.primaryContainer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'AI tuincoach',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard({required this.snapshot});

  final GardenInsightSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final h = snapshot.health;
    final empty = h.plantCount == 0;

    if (empty) {
      return const _EmptyHint('Voeg planten toe om scores te zien.');
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _MetricRow(label: 'Totaal', value: h.total),
          _MetricRow(label: 'Plantgezondheid', value: h.plantHealth),
          _MetricRow(label: 'Insectenbalans', value: h.insectBalance),
          _MetricRow(label: 'Groei', value: snapshot.growthScore),
          _MetricRow(label: 'Waterstatus', value: snapshot.waterScore),
          _MetricRow(label: 'Biodiversiteit', value: h.biodiversity),
        ],
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
          Text(
            '$value',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _ProblemsSection extends StatelessWidget {
  const _ProblemsSection({
    required this.problems,
    this.compact = false,
    this.limit,
  });

  final List<InsightProblem> problems;
  final bool compact;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    if (problems.isEmpty) {
      return const _EmptyHint('Geen actieve problemen, je tuin ziet er gezond uit.');
    }
    final shown = limit != null ? problems.take(limit!).toList() : problems;
    final extra = limit != null ? problems.length - shown.length : 0;

    return Column(
      children: [
        ...shown.map(
          (p) => _ProblemTile(problem: p, compact: compact),
        ),
        if (extra > 0)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '+ $extra meer, tik op een sectie hieronder',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
      ],
    );
  }
}

class _ProblemTile extends StatelessWidget {
  const _ProblemTile({
    required this.problem,
    this.compact = false,
  });

  final InsightProblem problem;
  final bool compact;

  Color _color(BuildContext context) {
    return switch (problem.priority) {
      InsightPriority.high => Theme.of(context).colorScheme.error,
      InsightPriority.medium => Colors.orange.shade700,
      InsightPriority.low => Colors.amber.shade800,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    if (compact) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: _Card(
          borderColor: color.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${problem.plantName} · ${problem.title}',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      problem.solution,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            height: 1.3,
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: _Card(
        borderColor: color.withValues(alpha: 0.35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    problem.priority.labelNl,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${problem.plantName} · ${problem.title}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Oorzaak: ${problem.cause}',
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 4),
            Text(
              'Oplossing: ${problem.solution}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionsSection extends StatelessWidget {
  const _ActionsSection({
    required this.actions,
    this.compact = false,
    this.limit,
  });

  final List<InsightTodayAction> actions;
  final bool compact;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const _EmptyHint('Geen urgente taken voor vandaag.');
    }
    final shown = limit != null ? actions.take(limit!).toList() : actions;
    final extra = limit != null ? actions.length - shown.length : 0;

    return Column(
      children: [
        ...shown.map((a) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: _Card(
              padding: compact
                  ? const EdgeInsets.symmetric(horizontal: 10, vertical: 4)
                  : const EdgeInsets.all(12),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                dense: compact,
                visualDensity:
                    compact ? VisualDensity.compact : VisualDensity.standard,
                leading: Icon(
                  Icons.check_circle_outline,
                  size: compact ? 20 : 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
                title: Text(
                  '${a.action} · ${a.plantName}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: compact ? 14 : null,
                  ),
                ),
                subtitle: a.detail != null
                    ? Text(
                        a.detail!,
                        maxLines: compact ? 1 : null,
                        overflow: compact ? TextOverflow.ellipsis : null,
                      )
                    : null,
              ),
            ),
          );
        }),
        if (extra > 0)
          Text(
            '+ $extra meer taken',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
      ],
    );
  }
}

class _GrowthSection extends StatelessWidget {
  const _GrowthSection({required this.items});

  final List<InsightGrowthItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyHint(
        'Nog geen groeidata. Maak AI-scans om groei te vergelijken.',
      );
    }
    return Column(
      children: items.map((g) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _Card(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    g.plantName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  g.detail ?? g.status.labelNl,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WaterSection extends StatelessWidget {
  const _WaterSection({
    required this.waterScore,
    required this.items,
  });

  final int waterScore;
  final List<InsightWaterItem> items;

  String _overallLabel() {
    if (items.any((i) =>
        i.status == AiWaterStatus.tooWet || i.status == AiWaterStatus.wilting)) {
      return 'Mogelijk te nat';
    }
    if (items.any((i) => i.status == AiWaterStatus.tooDry)) {
      return 'Mogelijk droog';
    }
    return 'Goed';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
          child: Row(
            children: [
              Text(
                '$waterScore/100',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
              const SizedBox(width: 12),
              Text(
                _overallLabel(),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: _EmptyHint('Geen waterproblemen gedetecteerd op scans.'),
          )
        else
          ...items.map(
            (w) => Padding(
              padding: const EdgeInsets.only(top: 6),
              child: _Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${w.plantName} · ${w.status.labelNl}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (w.advice != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        w.advice!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HarvestSection extends StatelessWidget {
  const _HarvestSection({
    required this.within7,
    required this.within30,
  });

  final List<InsightHarvestItem> within7;
  final List<InsightHarvestItem> within30;

  @override
  Widget build(BuildContext context) {
    if (within7.isEmpty && within30.isEmpty) {
      return const _EmptyHint('Nog geen oogst in zicht op basis van scans.');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (within7.isNotEmpty) ...[
          Text(
            'Binnen 7 dagen',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          ...within7.map((h) => _HarvestTile(item: h)),
        ],
        if (within30.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Binnen 30 dagen',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          ...within30.map((h) => _HarvestTile(item: h)),
        ],
      ],
    );
  }
}

class _HarvestTile extends StatelessWidget {
  const _HarvestTile({required this.item});

  final InsightHarvestItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: _Card(
        child: Row(
          children: [
            Expanded(
              child: Text(
                item.plantName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              item.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BiodiversitySection extends StatelessWidget {
  const _BiodiversitySection({
    required this.bio,
    this.onResolveHarmfulPest,
  });

  final InsightBiodiversity bio;
  final Future<void> Function(String pestId)? onResolveHarmfulPest;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Biodiversiteitsscore: ${bio.score}/100',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nuttig: ${bio.beneficialCount} · Actief schadelijk: ${bio.harmfulCount} · '
            'Neutraal: ${bio.neutralCount}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (bio.openHarmful.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Actieve plagen (verlagen je score tot je ze oplost)',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: TuinierColors.warning,
                  ),
            ),
            const SizedBox(height: 6),
            for (final pest in bio.openHarmful.take(5))
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Material(
                  color: TuinierColors.warning.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pest.nameNl,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              if (pest.summary.trim().isNotEmpty) ...[
                                const SizedBox(height: 2),
                                Text(
                                  pest.summary,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (onResolveHarmfulPest != null)
                          TextButton(
                            onPressed: () => onResolveHarmfulPest!(pest.id),
                            child: const Text('Opgelost'),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          if (bio.recentNames.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              bio.recentNames.join(' · '),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text('Nog geen insectenscans.'),
            ),
        ],
      ),
    );
  }
}

class _NutrientsSection extends StatelessWidget {
  const _NutrientsSection({required this.nutrients});

  final List<InsightNutrientIssue> nutrients;

  @override
  Widget build(BuildContext context) {
    if (nutrients.isEmpty) {
      return const _EmptyHint('Geen voedingstekorten gedetecteerd op scans.');
    }
    return Column(
      children: nutrients.take(6).map((n) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${n.plantName} · ${n.label}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('Oorzaak: ${n.cause}',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  'Oplossing: ${n.solution}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeatherSection extends StatelessWidget {
  const _WeatherSection({
    required this.summary,
    required this.tips,
    required this.loading,
    this.onRefresh,
  });

  final String? summary;
  final List<GardenWeatherTip> tips;
  final bool loading;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (loading && summary == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (summary == null) {
      return _Card(
        child: Column(
          children: [
            const Text('Weer kon niet laden.'),
            if (onRefresh != null) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: onRefresh, child: const Text('Opnieuw')),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                summary!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
              if (onRefresh != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: onRefresh,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Ververs'),
                  ),
                ),
              ],
            ],
          ),
        ),
        ...tips.take(4).map((tip) {
          final color = switch (tip.level) {
            GardenWeatherLevel.alert => Theme.of(context).colorScheme.error,
            GardenWeatherLevel.watch => Colors.orange.shade700,
            GardenWeatherLevel.ok => Theme.of(context).colorScheme.primary,
          };
          return Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _Card(
              borderColor: color.withValues(alpha: 0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tip.body,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Taak: ${tip.action}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _RecentScansSection extends StatelessWidget {
  const _RecentScansSection({required this.scans});

  final List<InsightRecentScan> scans;

  @override
  Widget build(BuildContext context) {
    if (scans.isEmpty) {
      return const _EmptyHint('Nog geen AI-scans in deze moestuin.');
    }
    return Column(
      children: scans.map((s) {
        final date =
            '${s.scannedAt.day}-${s.scannedAt.month}-${s.scannedAt.year}';
        final problems = s.problems.isEmpty
            ? 'Geen problemen'
            : s.problems.take(2).join(' · ');
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.plantName,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      date,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Gezondheid: ${s.healthScore ?? '—'}/100',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  problems,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _SeasonStatsSection extends StatelessWidget {
  const _SeasonStatsSection({required this.stats});

  final InsightSeasonStats stats;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Wrap(
        spacing: 16,
        runSpacing: 10,
        children: [
          _StatChip('Scans', '${stats.scanCount}'),
          _StatChip('Planten', '${stats.plantCount}'),
          _StatChip('Soorten', '${stats.speciesCount}'),
          _StatChip('Met scan', '${stats.plantsWithScans}'),
          _StatChip('Problemen', '${stats.problemCount}'),
          _StatChip('Oogst klaar', '${stats.harvestReadyCount}'),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.borderColor,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: borderColor ?? cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../data/plant_scan_history.dart';
import '../data/scan_report_builder.dart';
import '../data/scan_report_modules.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../models/vegetable.dart';
import '../screens/scan_result_screen.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';
import 'scan_task_detail_sheet.dart';

const _cardRadius = 16.0;

Color _insightScoreColor(int score) {
  if (score >= 90) return const Color(0xFF15803D);
  if (score >= 70) return const Color(0xFF22C55E);
  if (score >= 50) return const Color(0xFFEAB308);
  if (score >= 30) return const Color(0xFFEA580C);
  return const Color(0xFFDC2626);
}

/// Volledige Inzichten-tab: overzicht, plantanalyse, groei, timeline, taken.
class PlantInsightInzichtenTab extends StatefulWidget {
  const PlantInsightInzichtenTab({
    super.key,
    required this.vegetable,
    required this.profile,
    this.onScan,
    this.onOpenScan,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final VoidCallback? onScan;
  final void Function(PlantAiAnalysis analysis, PlantAiAnalysis? previous)? onOpenScan;

  @override
  State<PlantInsightInzichtenTab> createState() =>
      _PlantInsightInzichtenTabState();
}

class _PlantInsightInzichtenTabState extends State<PlantInsightInzichtenTab> {
  bool _tasksExpanded = true;
  final _completedTaskTitles = <String>{};

  @override
  Widget build(BuildContext context) {
    final analysis = widget.profile.lastAnalysis;
    if (analysis == null || !analysis.hasInsight || analysis.insight == null) {
      return _NoScanState(onScan: widget.onScan);
    }

    final scans = plantScanEntries(widget.profile);
    final previous = scans.length > 1
        ? scans[scans.length - 2].analysis
        : null;
    final layout = buildScanReportLayout(
      analysis: analysis,
      vegetable: widget.vegetable,
      previousAnalysis: previous,
    );
    final photoPath = scans.isNotEmpty
        ? scans.last.photoPath ?? widget.profile.lastScanPhotoPath
        : widget.profile.lastScanPhotoPath;
    final openTasks = layout.tasks
        .where((t) => !_completedTaskTitles.contains(t.title))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _OverviewCard(
          layout: layout,
          analysis: analysis,
          photoPath: photoPath,
        ),
        const SizedBox(height: 20),
        const _SectionHeading(title: 'Plantanalyse'),
        const SizedBox(height: 8),
        if (layout.coachObservations.isEmpty)
          const _MutedNote(
            text: 'Geen aparte observaties in de laatste scan.',
          )
        else
          for (final obs in layout.coachObservations)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _AnalysisRow(observation: obs),
            ),
        const SizedBox(height: 20),
        _GrowthSection(analysis: analysis, insight: analysis.insight!),
        if (scans.length > 1) ...[
          const SizedBox(height: 20),
          const _SectionHeading(title: 'Groei timeline'),
          const SizedBox(height: 10),
          _GrowthTimeline(
            scans: scans,
            onTap: (entry, prev) => _openScan(entry.analysis, prev),
          ),
        ],
        const SizedBox(height: 20),
        _TasksAccordion(
          expanded: _tasksExpanded,
          tasks: openTasks,
          onToggle: () => setState(() => _tasksExpanded = !_tasksExpanded),
          onTaskTap: (task) {
            showScanTaskDetailSheet(
              context: context,
              task: task,
              onCompleted: () {
                setState(() => _completedTaskTitles.add(task.title));
              },
            );
          },
        ),
      ],
    );
  }

  void _openScan(PlantAiAnalysis analysis, PlantAiAnalysis? previous) {
    if (widget.onOpenScan != null) {
      widget.onOpenScan!(analysis, previous);
      return;
    }
    if (!scanResultSupportsFullPage(analysis)) return;
    openScanResultScreen(
      context,
      analysis: analysis,
      vegetable: widget.vegetable,
      previousAnalysis: previous,
      onNewScan: widget.onScan,
    );
  }
}

class _NoScanState extends StatelessWidget {
  const _NoScanState({this.onScan});

  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TuinierDecorations.card(radius: _cardRadius),
      child: Column(
        children: [
          const Icon(Icons.photo_camera_outlined,
              size: 40, color: TuinierColors.iconMuted),
          const SizedBox(height: 12),
          Text(
            'Nog geen scan',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Maak je eerste scan om gezondheid, oogstkans en AI-adviezen '
            'voor deze plant te zien.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TuinierColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (onScan != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Eerste scan maken'),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: TuinierColors.textPrimary,
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.layout,
    required this.analysis,
    this.photoPath,
  });

  final ScanReportLayout layout;
  final PlantAiAnalysis analysis;
  final String? photoPath;

  @override
  Widget build(BuildContext context) {
    final health = layout.scoreCards.isNotEmpty ? layout.scoreCards.first : null;
    final harvest =
        layout.scoreCards.length > 1 ? layout.scoreCards[1] : null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: TuinierDecorations.card(radius: _cardRadius, shadow: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ScanThumb(path: photoPath),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overzicht',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Laatste scan: ${formatDateShortNl(analysis.scannedAt)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TuinierColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        if (health != null)
                          Expanded(
                            child: _CompactScoreRing(
                              label: 'Gezondheid',
                              percent: health.percent,
                              color: health.ringColor ??
                                  TuinierColors.plantHealthColor(health.percent),
                            ),
                          ),
                        if (health != null && harvest != null)
                          const SizedBox(width: 10),
                        if (harvest != null)
                          Expanded(
                            child: _CompactScoreRing(
                              label: 'Oogstkans',
                              percent: harvest.percent,
                              color: harvest.ringColor ??
                                  observationScoreColor(harvest.percent),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: TuinierColors.scanHover,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome,
                    size: 18, color: TuinierColors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _summaryTwoLines(layout.summary),
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: TuinierColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _summaryTwoLines(String raw) {
    final text = raw.trim();
    if (text.length <= 140) return text;
    return '${text.substring(0, 137).trimRight()}…';
  }
}

class _ScanThumb extends StatelessWidget {
  const _ScanThumb({this.path});

  final String? path;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: path != null && File(path!).existsSync()
            ? Image.file(File(path!), fit: BoxFit.cover)
            : Container(
                color: TuinierColors.searchBar,
                child: const Icon(Icons.eco_outlined,
                    color: TuinierColors.iconMuted),
              ),
      ),
    );
  }
}

class _CompactScoreRing extends StatelessWidget {
  const _CompactScoreRing({
    required this.label,
    required this.percent,
    required this.color,
  });

  final String label;
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: TuinierColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: percent / 100,
                strokeWidth: 4,
                backgroundColor: color.withValues(alpha: 0.15),
                color: color,
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({required this.observation});

  final ScanCoachObservation observation;

  @override
  Widget build(BuildContext context) {
    final scoreColor = _insightScoreColor(observation.scorePercent);
    return Material(
      color: TuinierColors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: TuinierColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: TuinierColors.scanHover,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  observation.icon,
                  size: 18,
                  color: observation.iconColor ?? TuinierColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      observation.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    observationDescriptionText(
                      observation.description,
                      fontSize: 12,
                    ),
                  ],
                ),
              ),
              if (observation.showScoreRing) ...[
                _MiniScoreRing(
                  percent: observation.scorePercent,
                  color: scoreColor,
                ),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.chevron_right,
                  size: 20, color: TuinierColors.iconMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniScoreRing extends StatelessWidget {
  const _MiniScoreRing({required this.percent, required this.color});

  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 3.5,
            backgroundColor: color.withValues(alpha: 0.15),
            color: color,
          ),
          Text(
            '$percent%',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthSection extends StatelessWidget {
  const _GrowthSection({
    required this.analysis,
    required this.insight,
  });

  final PlantAiAnalysis analysis;
  final PlantAiInsightReport insight;

  static const _stages = [
    ('Zaailing', PlantAiPhase.seedling),
    ('Groei', PlantAiPhase.growing),
    ('Bloei', PlantAiPhase.flowering),
    ('Vruchtvorming', PlantAiPhase.fruiting),
    ('Oogst', PlantAiPhase.ripe),
  ];

  @override
  Widget build(BuildContext context) {
    final schedule = _growthScheduleLabel(insight.growthScore);
    final currentIndex = _stageIndex(analysis.phase);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: TuinierDecorations.card(radius: _cardRadius, bordered: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Groei & ontwikkeling',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TuinierColors.scanHover,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  schedule,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: TuinierColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < _stages.length; i++) ...[
                if (i > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: i <= currentIndex
                          ? TuinierColors.primary
                          : TuinierColors.border,
                    ),
                  ),
                _StageDot(
                  label: _stages[i].$1,
                  active: i == currentIndex,
                  completed: i < currentIndex,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  int _stageIndex(PlantAiPhase phase) {
    return switch (phase) {
      PlantAiPhase.seedling => 0,
      PlantAiPhase.growing => 1,
      PlantAiPhase.flowering => 2,
      PlantAiPhase.fruiting => 3,
      PlantAiPhase.almostRipe || PlantAiPhase.ripe => 4,
    };
  }

  String _growthScheduleLabel(int growthScore) {
    if (growthScore >= 80) return 'Voor op schema';
    if (growthScore >= 55) return 'Op schema';
    return 'Achter op schema';
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot({
    required this.label,
    required this.active,
    required this.completed,
  });

  final String label;
  final bool active;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? TuinierColors.primary
                : completed
                    ? TuinierColors.primary.withValues(alpha: 0.15)
                    : TuinierColors.searchBar,
            border: Border.all(
              color: active ? TuinierColors.primary : TuinierColors.border,
            ),
          ),
          child: Icon(
            active
                ? Icons.check_rounded
                : completed
                    ? Icons.check_rounded
                    : Icons.circle,
            size: active ? 16 : 8,
            color: active
                ? Colors.white
                : completed
                    ? TuinierColors.primary
                    : TuinierColors.border,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 56,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 9,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? TuinierColors.primary : TuinierColors.textSecondary,
              height: 1.15,
            ),
          ),
        ),
      ],
    );
  }
}

class _GrowthTimeline extends StatelessWidget {
  const _GrowthTimeline({
    required this.scans,
    required this.onTap,
  });

  final List<PlantScanEntry> scans;
  final void Function(PlantScanEntry entry, PlantAiAnalysis? previous) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scans.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final entry = scans[index];
          final isLatest = index == scans.length - 1;
          final prev = index > 0 ? scans[index - 1].analysis : null;
          return GestureDetector(
            onTap: () => onTap(entry, prev),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isLatest
                          ? TuinierColors.primary
                          : TuinierColors.border,
                      width: isLatest ? 2 : 1,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _ScanThumb(path: entry.photoPath),
                ),
                const SizedBox(height: 6),
                Text(
                  formatDateShortNl(entry.analysis.scannedAt),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isLatest ? FontWeight.w700 : FontWeight.w500,
                    color: isLatest
                        ? TuinierColors.primary
                        : TuinierColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TasksAccordion extends StatelessWidget {
  const _TasksAccordion({
    required this.expanded,
    required this.tasks,
    required this.onToggle,
    required this.onTaskTap,
  });

  final bool expanded;
  final List<ScanTaskItem> tasks;
  final VoidCallback onToggle;
  final ValueChanged<ScanTaskItem> onTaskTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TuinierDecorations.card(radius: _cardRadius, bordered: true),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
              child: Row(
                children: [
                  const Icon(Icons.checklist_rounded,
                      size: 20, color: TuinierColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Taken voor jouw plant',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Icon(
                    expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: TuinierColors.iconMuted,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: TuinierColors.border),
            if (tasks.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: _MutedNote(
                  text: 'Geen open taken uit de laatste scan.',
                ),
              )
            else
              for (var i = 0; i < tasks.length; i++)
                _TaskRow(
                  task: tasks[i],
                  onTap: () => onTaskTap(tasks[i]),
                  showDivider: i < tasks.length - 1,
                ),
          ],
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.task,
    required this.onTap,
    required this.showDivider,
  });

  final ScanTaskItem task;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final badge = _taskBadge(task);
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Row(
              children: [
                Icon(task.icon, size: 20, color: TuinierColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _PriorityBadge(label: badge.label, color: badge.color),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, indent: 44, color: TuinierColors.border),
      ],
    );
  }

  ({String label, Color color}) _taskBadge(ScanTaskItem task) {
    final timeline = task.timeline.toLowerCase();
    if (task.priority == AiPriority.urgent ||
        task.priority == AiPriority.high ||
        timeline.contains('vandaag')) {
      return (label: 'Vandaag', color: TuinierColors.error);
    }
    if (timeline.contains('3') ||
        timeline.contains('2') ||
        task.priority == AiPriority.medium) {
      return (label: 'Over 3 dagen', color: TuinierColors.warning);
    }
    return (label: 'Over 7 dagen', color: TuinierColors.success);
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _MutedNote extends StatelessWidget {
  const _MutedNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        color: TuinierColors.textSecondary,
        height: 1.35,
      ),
    );
  }
}

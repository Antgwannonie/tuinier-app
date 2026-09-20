import 'package:flutter/material.dart';

import '../data/scan_report_builder.dart';
import '../data/scan_report_modules.dart';
import '../data/weather_service.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../models/vegetable.dart';
import '../navigation/scan_result_navigation.dart';
import '../theme/tuinier_colors.dart';
import 'scan_plant_info_body.dart';
import 'scan_task_detail_sheet.dart';

const _cardRadius = 16.0;

/// Tabbed scanresultaat: samenvatting + observaties + Taken | Plantinfo.
class ScanResultBody extends StatefulWidget {
  const ScanResultBody({
    super.key,
    required this.analysis,
    this.vegetable,
    this.previousAnalysis,
    this.weather,
    this.onNewScan,
    this.onGoToMoestuin,
    this.onWizardContinue,
    this.wizardMode = false,
    this.initialTab = 0,
  });

  final PlantAiAnalysis analysis;
  final Vegetable? vegetable;
  final PlantAiAnalysis? previousAnalysis;
  final WeatherForecast? weather;
  final VoidCallback? onNewScan;
  final VoidCallback? onGoToMoestuin;
  final VoidCallback? onWizardContinue;
  final bool wizardMode;
  final int initialTab;

  @override
  State<ScanResultBody> createState() => _ScanResultBodyState();
}

class _ScanResultBodyState extends State<ScanResultBody>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _completedTaskTitles = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.analysis.hasInsight || widget.analysis.insight == null) {
      return const SizedBox.shrink();
    }

    final layout = buildScanReportLayout(
      analysis: widget.analysis,
      vegetable: widget.vegetable,
      previousAnalysis: widget.previousAnalysis,
      weather: widget.weather,
    );

    final openTasks = layout.tasks
        .where((t) => !_completedTaskTitles.contains(t.title))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: TuinierColors.scanPageBackground,
          child: TabBar(
            controller: _tabController,
            labelColor: TuinierColors.primary,
            unselectedLabelColor: TuinierColors.textSecondary,
            indicatorColor: TuinierColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.checklist_rounded, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      openTasks.isEmpty
                          ? 'Scan & taken'
                          : 'Scan & taken (${openTasks.length})',
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lightbulb_outline, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      layout.infoItems.isEmpty
                          ? 'Plantinfo'
                          : 'Plantinfo (${layout.infoItems.length})',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ScanAndTasksPage(
                layout: layout,
                analysis: widget.analysis,
                tasks: openTasks,
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
              ScanPlantInfoBody(items: layout.infoItems),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: widget.wizardMode
              ? _WizardBottomActions(
                  onWizardContinue: widget.onWizardContinue,
                  onBackToScan: () => Navigator.of(context).pop(),
                )
              : _BottomActions(
                  onNewScan: widget.onNewScan,
                  onGoToMoestuin: widget.onGoToMoestuin ??
                      () => goToMoestuinFromScanContext(
                            context,
                            popScanResult: true,
                          ),
                ),
        ),
      ],
    );
  }
}

class _ScanAndTasksPage extends StatelessWidget {
  const _ScanAndTasksPage({
    required this.layout,
    required this.analysis,
    required this.tasks,
    required this.onTaskTap,
  });

  final ScanReportLayout layout;
  final PlantAiAnalysis analysis;
  final List<ScanTaskItem> tasks;
  final ValueChanged<ScanTaskItem> onTaskTap;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _ScanSummaryCard(
          layout: layout,
          analysis: analysis,
        ),
        const SizedBox(height: 16),
        const _SectionTitle(
          icon: Icons.auto_awesome,
          title: 'AI Observaties',
        ),
        const SizedBox(height: 8),
        for (final observation in layout.coachObservations)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _ObservationCard(observation: observation),
          ),
        const SizedBox(height: 16),
        const _SectionTitle(
          icon: Icons.checklist_rounded,
          title: 'Taken',
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          const _EmptyTabMessage(
            icon: Icons.task_alt_outlined,
            title: 'Geen open taken',
            body: 'Alles bijgewerkt voor deze scan. Swipe naar Plantinfo voor tips.',
          )
        else
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _TaskListTile(task: tasks[i], onTap: () => onTaskTap(tasks[i])),
          ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: TuinierColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: TuinierColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ScanSummaryCard extends StatelessWidget {
  const _ScanSummaryCard({
    required this.layout,
    required this.analysis,
  });

  final ScanReportLayout layout;
  final PlantAiAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TuinierColors.white,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: TuinierColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _scanTimeLabel(analysis.scannedAt),
            style: const TextStyle(
              fontSize: 11,
              color: TuinierColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: TuinierColors.scanHover,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco_outlined, size: 16, color: TuinierColors.primary),
                const SizedBox(width: 6),
                Text(
                  'Fase: ${analysis.phaseLabel}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: TuinierColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            layout.summary,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: TuinierColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              for (var i = 0; i < layout.scoreCards.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _ScoreRingTile(tile: layout.scoreCards[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ScoreRingTile extends StatelessWidget {
  const _ScoreRingTile({required this.tile});

  final ScanStatusTile tile;

  @override
  Widget build(BuildContext context) {
    final ringColor = tile.ringColor ?? observationScoreColor(tile.percent);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: TuinierColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: TuinierColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tile.icon, size: 12, color: tile.iconColor ?? TuinierColors.primary),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  tile.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: TuinierColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: tile.percent / 100,
                  strokeWidth: 4,
                  backgroundColor: ringColor.withValues(alpha: 0.15),
                  color: ringColor,
                ),
                Text(
                  '${tile.percent}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: ringColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            tile.status,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: ringColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({required this.observation});

  final ScanCoachObservation observation;

  @override
  Widget build(BuildContext context) {
    final scoreColor = observationScoreColor(observation.scorePercent);
    final bgColor =
        observation.isWarning ? const Color(0xFFFFF7ED) : TuinierColors.white;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(
          color: observation.isWarning
              ? const Color(0xFFFED7AA)
              : TuinierColors.border,
        ),
        borderRadius: BorderRadius.circular(_cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TuinierColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                observationDescriptionText(observation.description),
              ],
            ),
          ),
          if (observation.showScoreRing) ...[
            const SizedBox(width: 8),
            _MiniScoreRing(
              percent: observation.scorePercent,
              color: scoreColor,
            ),
          ],
        ],
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
      width: 44,
      height: 44,
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
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTabMessage extends StatelessWidget {
  const _EmptyTabMessage({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: TuinierColors.iconMuted),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: TuinierColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: TuinierColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskListTile extends StatelessWidget {
  const _TaskListTile({required this.task, required this.onTap});

  final ScanTaskItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (task.priority) {
      AiPriority.urgent || AiPriority.high => (
          const Color(0xFFFEE2E2),
          const Color(0xFFDC2626),
          'Hoog',
        ),
      AiPriority.medium => (
          const Color(0xFFFEF3C7),
          const Color(0xFFD97706),
          'Gemiddeld',
        ),
      AiPriority.low => (
          const Color(0xFFDCFCE7),
          const Color(0xFF15803D),
          'Laag',
        ),
    };

    return Material(
      color: TuinierColors.white,
      borderRadius: BorderRadius.circular(_cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            border: Border.all(color: TuinierColors.border),
            borderRadius: BorderRadius.circular(_cardRadius),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TuinierColors.scanHover,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: TuinierColors.border),
                ),
                child: Icon(task.icon, size: 20, color: TuinierColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: TuinierColors.textPrimary,
                      ),
                    ),
                    if (task.whyText.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.whyText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: TuinierColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: fg,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.timeline,
                          style: const TextStyle(
                            fontSize: 10,
                            color: TuinierColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: TuinierColors.iconMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    this.onNewScan,
    required this.onGoToMoestuin,
  });

  final VoidCallback? onNewScan;
  final VoidCallback onGoToMoestuin;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onNewScan,
            icon: const Icon(Icons.photo_camera_outlined, size: 18),
            label: const Text('Nieuwe scan'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: FilledButton.icon(
            onPressed: onGoToMoestuin,
            icon: const Icon(Icons.yard_outlined, size: 18),
            label: const Text('Naar moestuin'),
            style: FilledButton.styleFrom(
              backgroundColor: TuinierColors.headerDark,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _WizardBottomActions extends StatelessWidget {
  const _WizardBottomActions({
    this.onWizardContinue,
    required this.onBackToScan,
  });

  final VoidCallback? onWizardContinue;
  final VoidCallback onBackToScan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: onWizardContinue,
          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
          label: const Text('Volgende stap'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onBackToScan,
          icon: const Icon(Icons.arrow_back_rounded, size: 18),
          label: const Text('Terug naar scan'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }
}

String _scanTimeLabel(DateTime scannedAt) {
  final now = DateTime.now();
  final diff = now.difference(scannedAt);
  if (diff.inMinutes < 2) return 'Zojuist gescand';
  if (diff.inHours < 1) return '${diff.inMinutes} min geleden';
  if (diff.inDays < 1) return '${diff.inHours} uur geleden';
  return '${scannedAt.day}-${scannedAt.month}-${scannedAt.year}';
}

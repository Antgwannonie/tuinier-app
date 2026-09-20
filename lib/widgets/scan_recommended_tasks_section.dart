import 'package:flutter/material.dart';

import '../data/scan_report_modules.dart';
import '../models/plant_ai_insight_report.dart';
import '../theme/tuinier_colors.dart';
import 'collapsible_info_section.dart';
import 'scan_task_detail_sheet.dart';

/// Uitklapbare lijst met AI-aanbevolen taken (zelfde patroon als home).
class ScanRecommendedTasksSection extends StatelessWidget {
  const ScanRecommendedTasksSection({
    super.key,
    required this.tasks,
    required this.onTaskCompleted,
    this.completedTitles = const {},
  });

  final List<ScanTaskItem> tasks;
  final ValueChanged<ScanTaskItem> onTaskCompleted;
  final Set<String> completedTitles;

  @override
  Widget build(BuildContext context) {
    final open =
        tasks.where((t) => !completedTitles.contains(t.title)).toList();

    return CollapsibleInfoSection(
      title: 'Aanbevolen taken',
      icon: Icons.checklist_rounded,
      solidWhite: true,
      subtitle: open.isEmpty
          ? 'Geen open taken'
          : '${open.length} ${open.length == 1 ? 'taak' : 'taken'}',
      initiallyExpanded: open.isNotEmpty,
      child: open.isEmpty
          ? Text(
              'Alle aanbevolen taken zijn afgerond.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TuinierColors.textSecondary,
                  ),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 280),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: open.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final task = open[i];
                  return _ScanTaskListTile(
                    task: task,
                    onTap: () {
                      showScanTaskDetailSheet(
                        context: context,
                        task: task,
                        onCompleted: () => onTaskCompleted(task),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}

class _ScanTaskListTile extends StatelessWidget {
  const _ScanTaskListTile({required this.task, required this.onTap});

  final ScanTaskItem task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, fg, label) = switch (task.priority) {
      AiPriority.urgent || AiPriority.high => (
          const Color(0xFFFEE2E2),
          const Color(0xFFB91C1C),
          'Hoog',
        ),
      AiPriority.medium => (
          const Color(0xFFFFEDD5),
          const Color(0xFFC2410C),
          'Gemiddeld',
        ),
      AiPriority.low => (
          const Color(0xFFDCFCE7),
          const Color(0xFF166534),
          'Laag',
        ),
    };

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: TuinierColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(task.icon, color: TuinierColors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 4),
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
                      const SizedBox(width: 6),
                      Text(
                        task.timeline,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: TuinierColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: TuinierColors.iconMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

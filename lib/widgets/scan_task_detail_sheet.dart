import 'package:flutter/material.dart';

import '../data/scan_report_modules.dart';
import '../data/scan_task_plan.dart';
import '../theme/tuinier_colors.dart';

Future<void> showScanTaskDetailSheet({
  required BuildContext context,
  required ScanTaskItem task,
  VoidCallback? onCompleted,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => _ScanTaskDetailSheet(
      task: task,
      onCompleted: onCompleted,
    ),
  );
}

class _ScanTaskDetailSheet extends StatefulWidget {
  const _ScanTaskDetailSheet({
    required this.task,
    this.onCompleted,
  });

  final ScanTaskItem task;
  final VoidCallback? onCompleted;

  @override
  State<_ScanTaskDetailSheet> createState() => _ScanTaskDetailSheetState();
}

class _ScanTaskDetailSheetState extends State<_ScanTaskDetailSheet> {
  bool _completing = false;

  Future<void> _markCompleted() async {
    if (_completing) return;
    setState(() => _completing = true);
    widget.onCompleted?.call();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${widget.task.title} afgerond')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final steps = resolveScanTaskSteps(widget.task);
    final accent = TuinierColors.primary;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: accent,
                    ),
                    child: Icon(widget.task.icon, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.task.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.task.timeline,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: TuinierColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Waarom deze taak?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.task.whyText,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: TuinierColors.textSecondary,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 24),
              Text(
                'Stappenplan',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ...steps.asMap().entries.map((entry) {
                final i = entry.key + 1;
                final step = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: TuinierColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: TuinierColors.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: accent,
                          child: Text(
                            '$i',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (step.detail?.trim().isNotEmpty == true) ...[
                                const SizedBox(height: 4),
                                Text(
                                  step.detail!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: TuinierColors.textSecondary,
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _completing ? null : _markCompleted,
                icon: _completing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_rounded),
                label: const Text('Taak afgerond'),
              ),
            ],
          ),
        );
      },
    );
  }
}

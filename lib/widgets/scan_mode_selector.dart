import 'package:flutter/material.dart';

enum ScanSubjectMode {
  plant,
  insect,
  weed,
}

extension ScanSubjectModeLabel on ScanSubjectMode {
  String get label {
    switch (this) {
      case ScanSubjectMode.plant:
        return 'Plant';
      case ScanSubjectMode.insect:
        return 'Insect';
      case ScanSubjectMode.weed:
        return 'Onkruid';
    }
  }

  IconData get icon {
    switch (this) {
      case ScanSubjectMode.plant:
        return Icons.local_florist_outlined;
      case ScanSubjectMode.insect:
        return Icons.bug_report_outlined;
      case ScanSubjectMode.weed:
        return Icons.grass_outlined;
    }
  }
}

class ScanModeSelector extends StatelessWidget {
  const ScanModeSelector({
    super.key,
    required this.mode,
    required this.onChanged,
  });

  final ScanSubjectMode mode;
  final ValueChanged<ScanSubjectMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SegmentedButton<ScanSubjectMode>(
      showSelectedIcon: false,
      segments: ScanSubjectMode.values
          .map(
            (m) => ButtonSegment(
              value: m,
              label: Text(m.label),
              icon: Icon(m.icon, size: 18),
            ),
          )
          .toList(),
      selected: {mode},
      onSelectionChanged: (set) => onChanged(set.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: WidgetStatePropertyAll(
          BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
    );
  }
}

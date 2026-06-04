import 'package:flutter/material.dart';

import 'garden_warning_style.dart';

/// Inklapbaar meldingsblok (licht geel).
class CollapsibleGardenWarning extends StatefulWidget {
  const CollapsibleGardenWarning({
    super.key,
    required this.title,
    required this.icon,
    required this.bodyLines,
    this.subtitle,
    this.footer,
    this.initiallyExpanded = true,
    this.tone = GardenNoticeTone.warning,
  });

  final String title;
  final IconData icon;
  final List<String> bodyLines;
  final String? subtitle;
  final String? footer;
  final bool initiallyExpanded;

  final GardenNoticeTone tone;

  @override
  State<CollapsibleGardenWarning> createState() =>
      _CollapsibleGardenWarningState();
}

enum GardenNoticeTone {
  danger,
  warning,
  info,
  neutral,
}

class _CollapsibleGardenWarningState extends State<CollapsibleGardenWarning> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final (bg, fg, iconColor) = switch (widget.tone) {
      GardenNoticeTone.danger => (
          GardenWarningStyle.dangerBackground(cs),
          GardenWarningStyle.dangerForeground(cs),
          GardenWarningStyle.dangerIcon(cs),
        ),
      GardenNoticeTone.warning => (
          GardenWarningStyle.background(cs),
          GardenWarningStyle.foreground(cs),
          GardenWarningStyle.icon(cs),
        ),
      GardenNoticeTone.info => (
          GardenWarningStyle.infoBackground(cs),
          GardenWarningStyle.infoForeground(cs),
          GardenWarningStyle.infoIcon(cs),
        ),
      GardenNoticeTone.neutral => (
          cs.surfaceContainerHighest.withValues(alpha: 0.5),
          cs.onSurface,
          cs.primary,
        ),
    };

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(widget.icon, color: iconColor, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: t.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                        if (!_expanded &&
                            widget.subtitle != null &&
                            widget.subtitle!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              widget.subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.textTheme.bodySmall?.copyWith(
                                color: fg.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: fg.withValues(alpha: 0.7),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...widget.bodyLines.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        line,
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: fg,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                  if (widget.footer != null && widget.footer!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.footer!,
                      style: t.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

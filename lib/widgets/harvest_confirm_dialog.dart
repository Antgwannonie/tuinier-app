import 'package:flutter/material.dart';

import '../data/crop_harvest_kind.dart';

/// Bevestiging voordat een plant wordt afgerond en naar history gaat.
Future<bool> showHarvestConfirmDialog(
  BuildContext context, {
  required CropHarvestUiCopy copy,
  required String plantNameNl,
  bool isUnderground = false,
  bool harvestConfirmedByProbe = false,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) => _HarvestConfirmDialog(
      copy: copy,
      plantNameNl: plantNameNl,
      isUnderground: isUnderground,
      harvestConfirmedByProbe: harvestConfirmedByProbe,
    ),
  ).then((v) => v == true);
}

class _HarvestConfirmDialog extends StatefulWidget {
  const _HarvestConfirmDialog({
    required this.copy,
    required this.plantNameNl,
    this.isUnderground = false,
    this.harvestConfirmedByProbe = false,
  });

  final CropHarvestUiCopy copy;
  final String plantNameNl;
  final bool isUnderground;
  final bool harvestConfirmedByProbe;

  @override
  State<_HarvestConfirmDialog> createState() => _HarvestConfirmDialogState();
}

class _HarvestConfirmDialogState extends State<_HarvestConfirmDialog> {
  bool _infoExpanded = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final copy = widget.copy;

    final bodyText = widget.isUnderground && !widget.harvestConfirmedByProbe
        ? 'Weet je zeker dat je ${widget.plantNameNl} uit je moestuin wilt halen? '
            'Je hebt nog geen proefoogst bevestigd via een scan. '
            'De plant wordt verwijderd uit je moestuin en opgeslagen in History.'
        : copy.dialogBody;

    return AlertDialog(
      title: Text(copy.dialogTitle),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              bodyText,
              style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            const SizedBox(height: 12),
            Material(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(12),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  InkWell(
                    onTap: () => setState(() => _infoExpanded = !_infoExpanded),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              copy.infoTitle,
                              style: t.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Icon(
                            _infoExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstCurve: Curves.easeOutCubic,
                    secondCurve: Curves.easeOutCubic,
                    sizeCurve: Curves.easeOutCubic,
                    duration: const Duration(milliseconds: 200),
                    crossFadeState: _infoExpanded
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Column(
                      children: [
                        Divider(
                          height: 1,
                          color: cs.outlineVariant.withValues(alpha: 0.45),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: Text(
                            copy.infoBody,
                            style: t.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    secondChild: const SizedBox(width: double.infinity),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(copy.buttonLabel),
        ),
      ],
    );
  }
}

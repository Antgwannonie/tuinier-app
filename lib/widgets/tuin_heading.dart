import 'package:flutter/material.dart';

import '../theme/tuinier_theme.dart';

/// Sectiekop in tuin-sierletter (Fraunces).
class TuinHeading extends StatelessWidget {
  const TuinHeading(
    this.text, {
    super.key,
    this.style,
    this.fontSize,
    this.icon,
    this.iconSize = 20,
    this.maxLines,
    this.textAlign,
  });

  final String text;
  final TextStyle? style;
  final double? fontSize;
  final IconData? icon;
  final double iconSize;
  final int? maxLines;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textStyle = style ??
        tuinDisplayStyle(
          context,
          fontSize: fontSize,
          color: cs.onSurface,
        );

    if (icon == null) {
      return Text(
        text,
        maxLines: maxLines,
        textAlign: textAlign,
        style: textStyle,
      );
    }

    return Row(
      children: [
        Icon(icon, size: iconSize, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: maxLines,
            style: textStyle,
          ),
        ),
      ],
    );
  }
}

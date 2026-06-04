import 'package:flutter/material.dart';

import '../theme/tuinier_theme.dart';

/// «Mijn moestuin» in tuin-thema lettertype.
class TuinMoestuinTitle extends StatelessWidget {
  const TuinMoestuinTitle({
    super.key,
    this.style,
    this.color,
    this.compact = false,
  });

  final TextStyle? style;
  final Color? color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final base = style ??
        (compact
            ? t.textTheme.titleSmall
            : t.appBarTheme.titleTextStyle ?? t.textTheme.titleLarge);
    final fontSize = compact ? 14.0 : (base?.fontSize ?? 30);
    final effectiveStyle = (compact
            ? tuinDisplayStyle(
                context,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
              )
            : tuinAccentDisplayStyle(
                context,
                fontSize: fontSize,
                color: color ?? base?.color,
              )) ??
        TextStyle(fontSize: fontSize, color: color);

    return Text(
      'Mijn moestuin',
      textAlign: TextAlign.center,
      style: effectiveStyle,
    );
  }
}

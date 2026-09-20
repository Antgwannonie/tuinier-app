import 'package:flutter/material.dart';

import '../theme/tuinier_colors.dart';

/// Zoekveld met wis-knop en optionele plagen-gids-knop.
class ClearableSearchField extends StatelessWidget {
  const ClearableSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.fillColor,
    this.borderRadius = 14,
    this.onPestGuide,
    this.showPestGuideButton = false,
    this.focusNode,
    this.onTap,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final Color? fillColor;
  final double borderRadius;
  final VoidCallback? onPestGuide;
  final bool showPestGuideButton;
  final FocusNode? focusNode;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasText = controller.text.isNotEmpty;
    final showPest = showPestGuideButton && onPestGuide != null;

    Widget? suffix;
    if (showPest || hasText) {
      suffix = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPest)
            IconButton(
              tooltip: 'Plagen opzoeken',
              icon: Icon(Icons.pest_control_outlined, color: cs.primary),
              onPressed: onPestGuide,
            ),
          if (hasText)
            IconButton(
              tooltip: 'Wissen',
              icon: const Icon(Icons.close),
              onPressed: () {
                controller.clear();
                onChanged('');
              },
            ),
        ],
      );
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onTap: onTap,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: suffix,
        filled: fillColor != null,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(
            color: TuinierColors.border,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        isDense: true,
      ),
    );
  }
}

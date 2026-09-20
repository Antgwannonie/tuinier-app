import 'package:flutter/material.dart';

import '../theme/plant_setup_palette.dart';
import '../theme/tuinier_colors.dart';

const kWizardMaxSteps = 7;
const kWizardTotalSteps = kWizardMaxSteps;

class WizardProgressHeader extends StatelessWidget {
  const WizardProgressHeader({
    super.key,
    required this.step,
    required this.onClose,
    this.totalSteps = kWizardTotalSteps,
  });

  final int step;
  final int totalSteps;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final progress = step / totalSteps;
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: 40),
            Expanded(
              child: Text(
                'Stap $step van $totalSteps',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              tooltip: 'Sluiten',
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: TuinierColors.border,
            color: TuinierColors.primary,
          ),
        ),
      ],
    );
  }
}

class WizardStepTitle extends StatelessWidget {
  const WizardStepTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.centerTitle = false,
  });

  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final bool centerTitle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    if (centerTitle) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: titleStyle ??
                t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: titleStyle ??
              t.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: t.textTheme.bodyMedium?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class WizardNavBar extends StatelessWidget {
  const WizardNavBar({
    super.key,
    required this.showBack,
    required this.onBack,
    required this.onNext,
    required this.nextLabel,
    this.nextEnabled = true,
    this.showNext = true,
  });

  final bool showBack;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  final String nextLabel;
  final bool nextEnabled;
  final bool showNext;

  @override
  Widget build(BuildContext context) {
    if (!showBack && !showNext) {
      return const SizedBox.shrink();
    }

    final p = PlantSetupPalette.of(context);
    return Row(
      children: [
        if (showBack)
          Expanded(
            child: OutlinedButton(
              onPressed: onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: TuinierColors.textPrimary,
                side: const BorderSide(color: TuinierColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Vorige'),
            ),
          ),
        if (showBack && showNext) const SizedBox(width: 12),
        if (showNext)
          Expanded(
            flex: showBack ? 1 : 1,
            child: FilledButton(
              onPressed: nextEnabled ? onNext : null,
              style: FilledButton.styleFrom(
                backgroundColor: p.confirmButton,
                foregroundColor: p.confirmButtonForeground,
                disabledBackgroundColor: p.confirmButton.withValues(alpha: 0.4),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                nextLabel,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: p.confirmButtonForeground,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

class WizardSelectCard extends StatelessWidget {
  const WizardSelectCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final p = PlantSetupPalette.of(context);
    final borderColor = selected ? TuinierColors.primary : TuinierColors.border;
    final bg = selected ? TuinierColors.scanHover : TuinierColors.card;

    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: borderColor,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            p.dateIconForeground,
                            Color.lerp(p.dateIconForeground, Colors.black, 0.15)!,
                          ],
                        )
                      : null,
                  color: selected ? null : TuinierColors.searchBar,
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: p.dateIconForeground.withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: selected ? Colors.white : p.chipIdleForeground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: TuinierColors.primary)
              else
                Icon(Icons.chevron_right_rounded, color: t.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class WizardGridOption extends StatelessWidget {
  const WizardGridOption({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final p = PlantSetupPalette.of(context);
    return Material(
      color: selected ? p.chipSelectedBackground : TuinierColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? TuinierColors.primary : TuinierColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: selected
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            p.chipSelectedForeground,
                            Color.lerp(p.chipSelectedForeground, Colors.black, 0.14)!,
                          ],
                        )
                      : null,
                  color: selected ? null : TuinierColors.searchBar,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: selected
                      ? Colors.white
                      : TuinierColors.iconPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: t.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? p.chipSelectedForeground
                      : TuinierColors.textPrimary,
                  height: 1.2,
                ),
              ),
              if (selected) ...[
                const SizedBox(height: 6),
                Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: p.chipSelectedForeground,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WizardListOption extends StatelessWidget {
  const WizardListOption({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final p = PlantSetupPalette.of(context);
    return Material(
      color: selected ? TuinierColors.scanHover : TuinierColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? TuinierColors.primary : TuinierColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: selected
                      ? TuinierColors.primary.withValues(alpha: 0.12)
                      : TuinierColors.searchBar,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: selected ? TuinierColors.primary : p.chipIdleForeground,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: TuinierColors.primary)
              else
                Icon(Icons.chevron_right_rounded, color: t.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class WizardSuccessRing extends StatelessWidget {
  const WizardSuccessRing({
    super.key,
    required this.percent,
    required this.caption,
    required this.detail,
    this.ringSize = 140,
    this.captionColor,
    this.captionStyle,
    this.detailStyle,
    this.stacked = false,
  });

  final int percent;
  final String caption;
  final String detail;
  final double ringSize;
  final Color? captionColor;
  final TextStyle? captionStyle;
  final TextStyle? detailStyle;
  final bool stacked;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final stroke = ringSize * 0.085;
    final ring = SizedBox(
      width: ringSize,
      height: ringSize,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: ringSize,
            height: ringSize,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: stroke,
              backgroundColor: TuinierColors.border,
              color: TuinierColors.primary,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$percent%',
                style: t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: TuinierColors.primary,
                  fontSize: ringSize * 0.22,
                  height: 1.05,
                ),
              ),
              Text(
                'Kans',
                style: t.textTheme.labelMedium?.copyWith(
                  color: TuinierColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    final captionBlock = Column(
      crossAxisAlignment:
          stacked ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          caption,
          textAlign: stacked ? TextAlign.center : TextAlign.start,
          style: captionStyle ??
              t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: captionColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          detail,
          textAlign: stacked ? TextAlign.center : TextAlign.start,
          style: detailStyle ??
              t.textTheme.bodySmall?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
        ),
      ],
    );

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ring,
          const SizedBox(height: 10),
          captionBlock,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ring,
        const SizedBox(width: 18),
        Expanded(child: captionBlock),
      ],
    );
  }
}

class WizardInfoRow extends StatelessWidget {
  const WizardInfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.tone = WizardInfoTone.neutral,
    this.titleStyle,
  });

  final IconData icon;
  final String title;
  final String body;
  final WizardInfoTone tone;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final color = switch (tone) {
      WizardInfoTone.neutral => TuinierColors.primary,
      WizardInfoTone.warning => TuinierColors.warning,
      WizardInfoTone.tip => TuinierColors.info,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle ??
                      t.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: t.textTheme.bodySmall?.copyWith(
                    height: 1.35,
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum WizardInfoTone { neutral, warning, tip }

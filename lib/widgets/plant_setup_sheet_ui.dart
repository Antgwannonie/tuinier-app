import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../models/garden_plant_profile.dart';
import '../theme/plant_setup_palette.dart';

/// Gedeelde opmaak voor sheets bij toevoegen / als geplant markeren.
class PlantSetupSheetFrame extends StatelessWidget {
  const PlantSetupSheetFrame({
    super.key,
    required this.child,
    this.maxHeightFactor = 0.88,
  });

  final Widget child;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor,
        ),
        child: child,
      ),
    );
  }
}

class PlantSetupSheetHeader extends StatelessWidget {
  const PlantSetupSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    this.centered = false,
  });

  final String title;
  final String? subtitle;
  final String? badge;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = PlantSetupPalette.of(context);
    final align = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    return Column(
      crossAxisAlignment: align,
      children: [
        if (badge != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: p.badgeBackground,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge!,
              style: t.textTheme.labelSmall?.copyWith(
                color: p.badgeForeground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        _headerLine(
          centered: centered,
          child: Text(
            title,
            textAlign: textAlign,
            style: t.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          _headerLine(
            centered: centered,
            child: Text(
              subtitle!,
              textAlign: textAlign,
              style: t.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Widget _headerLine({required bool centered, required Widget child}) {
  if (!centered) return child;
  return SizedBox(width: double.infinity, child: child);
}

class PlantSetupSurfaceCard extends StatelessWidget {
  const PlantSetupSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final p = PlantSetupPalette.of(context);
    return Material(
      color: p.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.cardBorder),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class PlantSetupSectionLabel extends StatelessWidget {
  const PlantSetupSectionLabel(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final p = PlantSetupPalette.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8),
      child: Text(
        text,
        style: style ??
            Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: p.sectionLabel,
                ),
      ),
    );
  }
}

/// Schakelaar: staat al in de grond (toevoegen-sheet).
class PlantSetupPlantedSwitch extends StatelessWidget {
  const PlantSetupPlantedSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = PlantSetupPalette.of(context);

    return PlantSetupSurfaceCard(
      child: Row(
        children: [
          Icon(
            value ? Icons.yard : Icons.schedule_outlined,
            color: value ? p.activeIcon : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Staat al in de grond',
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value
                      ? 'Je plant of zaait nu, datum en plek tellen mee.'
                      : 'Je markeert deze groente als gepland voor het komende '
                          'zaai- of plantseizoen. Verschijnt in Taken zodra je '
                          'kunt zaaien of planten.',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// Datum kiezen + “datum onbekend” in één kaart.
class PlantSetupDateCard extends StatelessWidget {
  const PlantSetupDateCard({
    super.key,
    required this.dateLabel,
    required this.plantedAt,
    required this.dateUnknown,
    required this.onPickDate,
    this.onDateUnknownChanged,
    this.showDateUnknownToggle = true,
  });

  final String dateLabel;
  final DateTime plantedAt;
  final bool dateUnknown;
  final ValueChanged<bool>? onDateUnknownChanged;
  final VoidCallback onPickDate;
  final bool showDateUnknownToggle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = PlantSetupPalette.of(context);

    return PlantSetupSurfaceCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: dateUnknown ? null : onPickDate,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: dateUnknown
                            ? p.chipIdleBackground
                            : p.dateIconBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: dateUnknown
                            ? p.chipIdleForeground
                            : p.dateIconForeground,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateLabel,
                            style: t.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dateUnknown
                                ? 'Datum niet bekend'
                                : formatDateShortNl(plantedAt),
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (dateUnknown) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Intern: ${formatDateShortNl(plantedAt)}',
                              style: t.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!dateUnknown)
                      Icon(
                        Icons.chevron_right,
                        color: cs.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (showDateUnknownToggle && onDateUnknownChanged != null) ...[
            Divider(height: 1, color: p.cardBorder),
            SwitchListTile(
              contentPadding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              activeThumbColor: p.confirmButton,
              activeTrackColor: p.dateIconBackground,
              title: Text(
                'Datum niet meer bekend',
                style: t.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                dateUnknown
                    ? 'Geen seizoenswaarschuwing op deze datum.'
                    : 'Handig als je al langer geleden gezaaid hebt.',
                style: t.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              value: dateUnknown,
              onChanged: onDateUnknownChanged,
            ),
          ],
        ],
      ),
    );
  }
}

class PlantSetupOptionChips<T> extends StatelessWidget {
  const PlantSetupOptionChips({
    super.key,
    required this.options,
    required this.labelFor,
    required this.selected,
    required this.onSelected,
  });

  final List<T> options;
  final String Function(T) labelFor;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return _SetupChip(
          label: labelFor(opt),
          selected: isSelected,
          onTap: () => onSelected(opt),
        );
      }).toList(),
    );
  }
}

class _SetupChip extends StatelessWidget {
  const _SetupChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final p = PlantSetupPalette.of(context);

    return Material(
      color: selected ? p.chipSelectedBackground : p.chipIdleBackground,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: t.textTheme.labelMedium?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? p.chipSelectedForeground
                  : p.chipIdleForeground,
            ),
          ),
        ),
      ),
    );
  }
}

/// Bevestigknop met sheet-kleuren (niet het standaard theme-primary).
class PlantSetupConfirmButton extends StatelessWidget {
  const PlantSetupConfirmButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final p = PlantSetupPalette.of(context);

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: p.confirmButton,
        foregroundColor: p.confirmButtonForeground,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: Text(
        label,
        style: t.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

Future<DateTime?> pickPlantSetupDate(
  BuildContext context, {
  required DateTime initial,
  bool plannedForSeason = false,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (plannedForSeason) {
    return showDatePicker(
      context: context,
      initialDate: initial.isBefore(today) ? today : initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
      helpText: 'Gepland voor',
    );
  }
  return showDatePicker(
    context: context,
    initialDate: initial.isAfter(today) ? today : initial,
    firstDate: today.subtract(const Duration(days: 365 * 3)),
    lastDate: today,
    helpText: 'Gezaaid / geplant op',
  );
}

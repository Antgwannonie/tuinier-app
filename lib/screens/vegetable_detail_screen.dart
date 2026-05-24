import 'package:flutter/material.dart';

import '../data/garden_growth_engine.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/planting_calendar.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../widgets/plant_ai_data_sections.dart';
import '../widgets/vegetable_info_accordion.dart';
import '../widgets/vegetable_thumbnail.dart';

class VegetableDetailScreen extends StatelessWidget {
  const VegetableDetailScreen({
    super.key,
    required this.vegetable,
    this.focusMonth,
    this.profileStore,
    this.scanPrefs,
    this.onGoToPlantScan,
  });

  final Vegetable vegetable;

  /// Maand uit kalender/startpagina; anders huidige maand.
  final int? focusMonth;
  final GardenProfileStore? profileStore;
  final GardenScanPrefsStore? scanPrefs;
  final VoidCallback? onGoToPlantScan;

  List<VegetableMonthActivity> get _monthTasks {
    final month = focusMonth ?? DateTime.now().month;
    return kPlantingCalendar
        .where((a) => a.vegetableId == vegetable.id && a.months.contains(month))
        .toList()
      ..sort((a, b) => a.type.sortOrder.compareTo(b.type.sortOrder));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final month = focusMonth ?? DateTime.now().month;
    final monthTasks = _monthTasks;
    final monthName = kMonthNamesNl[month];
    final profile = profileStore?.profileFor(vegetable.id);
    final insight =
        profile != null
            ? growthInsightFor(
                vegetable,
                profile,
                null,
                scanPrefs?.daysUntilFirstPhoto ??
                    GardenScanPrefsStore.defaultDaysUntilFirstPhoto,
              )
            : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(vegetable.nameNl),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        children: [
          Center(
            child: VegetableThumbnail.large(vegetable: vegetable),
          ),
          const SizedBox(height: 20),
          Text(
            vegetable.nameNl,
            style: t.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (vegetable.nameLatin != null) ...[
            const SizedBox(height: 4),
            Text(
              vegetable.nameLatin!,
              style: t.textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(
                label: Text(vegetable.family),
                visualDensity: VisualDensity.compact,
              ),
              if (vegetable.growthCategory != null)
                Chip(
                  label: Text(vegetable.growthCategory!),
                  backgroundColor: t.colorScheme.primaryContainer,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          if (profile != null && profileStore != null) ...[
            const SizedBox(height: 16),
            Text(
              'Jouw plant — AI & planning',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            PlantAiDataSections(
              profile: profile,
              daysUntilFirstPhoto: scanPrefs?.daysUntilFirstPhoto ??
                  GardenScanPrefsStore.defaultDaysUntilFirstPhoto,
              weeklyScanIntervalDays: scanPrefs?.weeklyScanIntervalDays ??
                  GardenScanPrefsStore.defaultWeeklyScanIntervalDays,
              onScan: onGoToPlantScan != null
                  ? () {
                      Navigator.pop(context);
                      onGoToPlantScan!();
                    }
                  : null,
            ),
          ],
          if (monthTasks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Material(
              color: t.colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kalender — $monthName (algemeen)',
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: t.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...monthTasks.map((a) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• ${a.type.label}',
                              style: t.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (a.hint != null)
                              Text(
                                a.hint!,
                                style: t.textTheme.bodyMedium,
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(vegetable.summary, style: t.textTheme.bodyLarge),
          const SizedBox(height: 20),
          Text(
            'Teeltinformatie',
            style: t.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tik op een groep of onderdeel om uit te klappen.',
            style: t.textTheme.bodyMedium?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          VegetableInfoAccordion(vegetable: vegetable),
        ],
      ),
    );
  }
}

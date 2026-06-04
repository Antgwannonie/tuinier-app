import 'package:flutter/material.dart';

import '../data/calendar_display_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_image_info.dart';
import '../data/vegetable_repository.dart';

/// Instellingen voor welke gewassen in de plantkalender staan.
Future<void> showCalendarFilterSheet({
  required BuildContext context,
  required CalendarDisplayPrefsStore prefs,
  required VegetableRepository repository,
  required MyGardenStore gardenStore,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (_, scroll) => _CalendarFilterSheet(
        scrollController: scroll,
        prefs: prefs,
        repository: repository,
        gardenStore: gardenStore,
      ),
    ),
  );
}

class _CalendarFilterSheet extends StatefulWidget {
  const _CalendarFilterSheet({
    required this.scrollController,
    required this.prefs,
    required this.repository,
    required this.gardenStore,
  });

  final ScrollController scrollController;
  final CalendarDisplayPrefsStore prefs;
  final VegetableRepository repository;
  final MyGardenStore gardenStore;

  @override
  State<_CalendarFilterSheet> createState() => _CalendarFilterSheetState();
}

class _CalendarFilterSheetState extends State<_CalendarFilterSheet> {
  late Set<String> _draftCustomIds;

  @override
  void initState() {
    super.initState();
    _draftCustomIds = Set<String>.from(widget.prefs.customIds);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final vegetables = widget.repository.all;

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        Text(
          'Kalender weergave',
          style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Kies welke gewassen je in de kalender wilt zien. Zo blijft het overzichtelijk.',
          style: t.textTheme.bodyMedium?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Text('Weergave', style: t.textTheme.titleSmall),
        RadioListTile<CalendarViewMode>(
          title: const Text('Mijn moestuin'),
          subtitle: Text(
            widget.gardenStore.isEmpty
                ? 'Geen planten gekozen — dan tonen we alles'
                : '${widget.gardenStore.count} plant(en) uit je moestuin',
          ),
          value: CalendarViewMode.myGarden,
          groupValue: widget.prefs.mode,
          onChanged: (v) {
            if (v == null) return;
            widget.prefs.setMode(v);
            setState(() {});
          },
        ),
        RadioListTile<CalendarViewMode>(
          title: const Text('Alle groenten'),
          subtitle: const Text('Volledige database in de kalender'),
          value: CalendarViewMode.all,
          groupValue: widget.prefs.mode,
          onChanged: (v) {
            if (v == null) return;
            widget.prefs.setMode(v);
            setState(() {});
          },
        ),
        RadioListTile<CalendarViewMode>(
          title: const Text('Zelf kiezen'),
          subtitle: const Text('Vink alleen de gewassen aan die je wilt zien'),
          value: CalendarViewMode.custom,
          groupValue: widget.prefs.mode,
          onChanged: (v) {
            if (v == null) return;
            widget.prefs.setMode(v);
            if (_draftCustomIds.isEmpty && widget.gardenStore.isNotEmpty) {
              _draftCustomIds = widget.gardenStore.ids.toSet();
            }
            setState(() {});
          },
        ),
        const SizedBox(height: 12),
        Text('Categorieën', style: t.textTheme.titleSmall),
        const SizedBox(height: 4),
        ...CalendarPlantCategory.values.map((cat) {
          final enabled = widget.prefs.enabledCategories.contains(cat);
          return SwitchListTile(
            title: Text(cat.label),
            value: enabled,
            onChanged: (on) => widget.prefs.setCategoryEnabled(cat, on),
          );
        }),
        if (widget.prefs.mode == CalendarViewMode.custom) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text('Gewassen', style: t.textTheme.titleSmall),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _draftCustomIds =
                        vegetables.map((v) => v.id).toSet();
                  });
                },
                child: const Text('Alles'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _draftCustomIds.clear());
                },
                child: const Text('Geen'),
              ),
            ],
          ),
          ...vegetables.map((v) {
            final selected = _draftCustomIds.contains(v.id);
            final emoji = vegetableImageFor(v.id).emoji;
            return CheckboxListTile(
              value: selected,
              onChanged: (on) {
                setState(() {
                  if (on == true) {
                    _draftCustomIds.add(v.id);
                  } else {
                    _draftCustomIds.remove(v.id);
                  }
                });
              },
              title: Text('$emoji ${v.nameNl}'),
              subtitle: Text(calendarCategoryFor(v).label),
              controlAffinity: ListTileControlAffinity.leading,
              dense: true,
            );
          }),
          FilledButton(
            onPressed: () async {
              await widget.prefs.setCustomIds(_draftCustomIds);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Keuze opslaan'),
          ),
        ],
      ],
    );
  }
}

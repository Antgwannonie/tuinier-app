import 'package:flutter/material.dart';

import '../data/my_garden_store.dart';
import '../models/tuin_space.dart';
import '../theme/plant_setup_palette.dart';
import '../theme/tuinier_colors.dart';
import 'plant_setup_sheet_ui.dart';
import 'tuin_space_place_illustration.dart';

Future<void> showCreateMoestuinSheet(
  BuildContext context, {
  required MyGardenStore gardenStore,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final bottomInset = MediaQuery.viewInsetsOf(sheetContext).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: FractionallySizedBox(
          heightFactor: bottomInset > 0 ? 0.82 : 0.72,
          child: RepaintBoundary(
            child: _CreateMoestuinSheet(gardenStore: gardenStore),
          ),
        ),
      );
    },
  );
}

class _CreateMoestuinSheet extends StatefulWidget {
  const _CreateMoestuinSheet({required this.gardenStore});

  final MyGardenStore gardenStore;

  @override
  State<_CreateMoestuinSheet> createState() => _CreateMoestuinSheetState();
}

class _CreateMoestuinSheetState extends State<_CreateMoestuinSheet> {
  final _nameController = TextEditingController();
  TuinSpacePlace _place = TuinSpacePlace.outdoor;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);
    final name = _nameController.text;
    await widget.gardenStore.createSpace(
      name: name,
      place: _place,
    );
    if (!mounted) return;
    final createdName = widget.gardenStore.activeSpace?.name ?? 'Moestuin';
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$createdName is aangemaakt en nu actief')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = PlantSetupPalette.of(context);

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: TuinierColors.cardTintGreen,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            alignment: Alignment.center,
                            child: const TuinSpaceSproutIllustration(size: 38),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Nieuwe moestuin',
                            textAlign: TextAlign.center,
                            style: t.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Voeg een extra moestuin toe',
                            textAlign: TextAlign.center,
                            style: t.textTheme.bodyMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      tooltip: 'Sluiten',
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      style: IconButton.styleFrom(
                        backgroundColor:
                            TuinierColors.border.withValues(alpha: 0.35),
                      ),
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              const PlantSetupSectionLabel('Naam van je moestuin'),
              PlantSetupSurfaceCard(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: p.dateIconBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: TuinSpacePotIllustration(size: 36),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Bijv. Achtertuin, Balkon, Kas...',
                          isDense: true,
                        ),
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const PlantSetupSectionLabel('Standplaats'),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.35,
                children: TuinSpacePlace.values
                    .map(
                      (place) => _PlaceOptionTile(
                        label: place.label,
                        place: place,
                        selected: _place == place,
                        onTap: _saving
                            ? null
                            : () => setState(() => _place = place),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: p.confirmButton,
                  foregroundColor: p.confirmButtonForeground,
                  disabledBackgroundColor:
                      p.confirmButton.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: p.confirmButtonForeground,
                        ),
                      )
                    : Text(
                        'Moestuin toevoegen',
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: p.confirmButtonForeground,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceOptionTile extends StatelessWidget {
  const _PlaceOptionTile({
    required this.label,
    required this.place,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final TuinSpacePlace place;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final borderColor =
        selected ? TuinierColors.primary : TuinierColors.border;
    final textColor =
        selected ? TuinierColors.primary : TuinierColors.textPrimary;

    return Material(
      color: TuinierColors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: borderColor,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              TuinSpacePlaceIllustration(place: place, size: 40),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    height: 1.15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

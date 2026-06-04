import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'tuin_heading.dart';

import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_note.dart';
import '../models/vegetable.dart';
import 'vegetable_thumbnail.dart';

/// Resultaat na opslaan van een notitie.
class SaveGardenNoteResult {
  const SaveGardenNoteResult({
    required this.note,
    required this.addToCalendar,
  });

  final GardenNote note;
  final bool addToCalendar;
}

/// Notitie schrijven + datum, type en groente-keuze.
Future<SaveGardenNoteResult?> showGardenNoteEditor({
  required BuildContext context,
  required VegetableRepository repository,
  required MyGardenStore gardenStore,
  GardenNote? existing,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<SaveGardenNoteResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (ctx) => _GardenNoteEditorSheet(
      repository: repository,
      gardenStore: gardenStore,
      existing: existing,
      initialDate: initialDate,
    ),
  );
}

class _GardenNoteEditorSheet extends StatefulWidget {
  const _GardenNoteEditorSheet({
    required this.repository,
    required this.gardenStore,
    this.existing,
    this.initialDate,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenNote? existing;
  final DateTime? initialDate;

  @override
  State<_GardenNoteEditorSheet> createState() => _GardenNoteEditorSheetState();
}

enum _NoteLinkMode { gardenTask, vegetables }

class _GardenNoteEditorSheetState extends State<_GardenNoteEditorSheet> {
  static const _vegetablePickerBoxHeight = 220.0;

  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _searchCtrl;
  late bool _onCalendar;
  late DateTime _selectedDate;
  late _NoteLinkMode _linkMode;
  late Set<String> _selectedIds;
  bool _onlyMyGarden = true;
  bool _vegetableBoxExpanded = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.existing?.body ?? '');
    _searchCtrl = TextEditingController();
    _onCalendar = widget.existing?.onCalendar ?? true;
    _selectedDate = widget.existing?.dateOnly ??
        widget.initialDate ??
        DateTime(now.year, now.month, now.day);
    _selectedIds = {...?widget.existing?.vegetableIds};
    _linkMode = widget.existing?.isGeneralGardenTask == false
        ? _NoteLinkMode.vegetables
        : _NoteLinkMode.gardenTask;
    _vegetableBoxExpanded = _linkMode == _NoteLinkMode.vegetables;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<Vegetable> get _pickList {
    final all = widget.repository.all;
    final filtered = _onlyMyGarden
        ? all.where((v) => widget.gardenStore.contains(v.id)).toList()
        : List<Vegetable>.from(all);
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return filtered;
    return filtered.where((v) => v.matchesQuery(q)).toList();
  }

  String get _vegetableBoxSummary {
    if (_selectedIds.isEmpty) return 'Geen groenten gekozen';
    if (_selectedIds.length == 1) {
      return widget.repository.byId(_selectedIds.first)?.nameNl ??
          _selectedIds.first;
    }
    return '${_selectedIds.length} groenten gekozen';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      helpText: 'Kies een dag',
      cancelText: 'Annuleren',
      confirmText: 'Kies',
    );
    if (picked != null && mounted) {
      setState(
        () => _selectedDate = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();
    if (title.isEmpty && body.isEmpty) {
      Navigator.pop(context);
      return;
    }

    if (_linkMode == _NoteLinkMode.vegetables && _selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vink minstens één groente aan, of kies “Tuintaak”.'),
        ),
      );
      return;
    }

    final List<String> ids;
    if (_linkMode == _NoteLinkMode.vegetables) {
      ids = _selectedIds.toList()..sort();
    } else {
      ids = const [];
    }

    final note = GardenNote(
      id: widget.existing?.id ??
          'user_${_selectedDate.millisecondsSinceEpoch}_${DateTime.now().microsecond}',
      date: _selectedDate,
      title: title.isEmpty
          ? (_linkMode == _NoteLinkMode.gardenTask
              ? 'Tuintaak'
              : 'Groentenotitie')
          : title,
      body: body,
      source: GardenNoteSource.user,
      vegetableIds: ids,
      onCalendar: _onCalendar,
      notify: false,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    Navigator.pop(
      context,
      SaveGardenNoteResult(
        note: note,
        addToCalendar: _onCalendar,
      ),
    );
  }

  Widget _vegetablePickRow(BuildContext context, Vegetable v, ColorScheme cs) {
    final checked = _selectedIds.contains(v.id);
    return Material(
      color: checked
          ? cs.primaryContainer.withValues(alpha: 0.35)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          setState(() {
            if (checked) {
              _selectedIds.remove(v.id);
            } else {
              _selectedIds.add(v.id);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: checked,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (on) {
                    setState(() {
                      if (on == true) {
                        _selectedIds.add(v.id);
                      } else {
                        _selectedIds.remove(v.id);
                      }
                    });
                  },
                ),
              ),
              VegetableThumbnail(
                vegetable: v,
                size: 44,
                borderRadius: 8,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      v.nameNl,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    if (v.nameLatin != null)
                      Text(
                        v.nameLatin!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: cs.onSurfaceVariant,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vegetableListContent(
    BuildContext context,
    List<Vegetable> pickList,
    ColorScheme cs,
  ) {
    if (_onlyMyGarden && widget.gardenStore.ids.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Je moestuin is nog leeg. Kies “Alle groenten” of voeg planten toe.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
          ),
        ),
      );
    }
    if (pickList.isEmpty) {
      return Center(
        child: Text(
          'Geen groenten gevonden.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
      );
    }

    return Scrollbar(
      thumbVisibility: pickList.length > 3,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 8),
        itemCount: pickList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 2),
        itemBuilder: (context, i) =>
            _vegetablePickRow(context, pickList[i], cs),
      ),
    );
  }

  Widget _collapsibleVegetableBox(
    BuildContext context,
    List<Vegetable> pickList,
    ColorScheme cs,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.65)),
        borderRadius: BorderRadius.circular(14),
        color: cs.surfaceContainerLowest.withValues(alpha: 0.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.vertical(
                top: const Radius.circular(14),
                bottom: Radius.circular(_vegetableBoxExpanded ? 0 : 14),
              ),
              onTap: () => setState(
                () => _vegetableBoxExpanded = !_vegetableBoxExpanded,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt_rounded,
                      size: 22,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _vegetableBoxExpanded
                                ? 'Scroll in het kader'
                                : 'Tik om lijst te openen',
                            style:
                                Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                          Text(
                            _vegetableBoxSummary,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      _vegetableBoxExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeOutCubic,
            secondCurve: Curves.easeOutCubic,
            sizeCurve: Curves.easeOutCubic,
            crossFadeState: _vegetableBoxExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
            firstChild: Column(
              children: [
                Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.4)),
                SizedBox(
                  height: _vegetablePickerBoxHeight,
                  child: _vegetableListContent(context, pickList, cs),
                ),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TuinHeading(title, icon: icon, fontSize: 16),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context);
    final pickList = _pickList;
    final isEdit = widget.existing != null;
    final maxSheetHeight = math.max(
      360.0,
      MediaQuery.sizeOf(context).height * 0.92 - bottom,
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, 16 + bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxSheetHeight),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_note_rounded : Icons.note_add_rounded,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEdit ? 'Notitie bewerken' : 'Nieuwe notitie',
                          style: t.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Tuintaak of gekoppeld aan groenten',
                          style: t.textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _sectionCard(
                context: context,
                title: 'Type',
                icon: Icons.category_outlined,
                children: [
                  SegmentedButton<_NoteLinkMode>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: _NoteLinkMode.gardenTask,
                        label: Text('Tuintaak'),
                        icon: Icon(Icons.yard_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: _NoteLinkMode.vegetables,
                        label: Text('Groenten'),
                        icon: Icon(Icons.eco_outlined, size: 18),
                      ),
                    ],
                    selected: {_linkMode},
                    onSelectionChanged: (s) {
                      setState(() {
                        _linkMode = s.first;
                        if (_linkMode == _NoteLinkMode.vegetables) {
                          _vegetableBoxExpanded = true;
                        }
                      });
                    },
                  ),
                  if (_linkMode == _NoteLinkMode.gardenTask) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Algemene klus in de tuin — niet gekoppeld aan één plant.',
                      style: t.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                  if (_linkMode == _NoteLinkMode.vegetables) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        FilterChip(
                          label: const Text('Mijn moestuin'),
                          selected: _onlyMyGarden,
                          showCheckmark: false,
                          onSelected: (_) =>
                              setState(() => _onlyMyGarden = true),
                        ),
                        FilterChip(
                          label: const Text('Alle groenten'),
                          selected: !_onlyMyGarden,
                          showCheckmark: false,
                          onSelected: (_) =>
                              setState(() => _onlyMyGarden = false),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Zoek groente…',
                        prefixIcon: const Icon(Icons.search, size: 22),
                        filled: true,
                        fillColor: cs.surface,
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    _collapsibleVegetableBox(context, pickList, cs),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              _sectionCard(
                context: context,
                title: 'Inhoud',
                icon: Icons.description_outlined,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 20,
                            color: cs.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Datum',
                                  style: t.textTheme.labelMedium?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  _formatDayNl(_selectedDate),
                                  style: t.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _titleCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: 'Titel',
                      hintText: _linkMode == _NoteLinkMode.gardenTask
                          ? 'Bijv. Compost omzetten'
                          : 'Bijv. Wortelen uitdunnen',
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyCtrl,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: 'Notitie',
                      hintText: 'Wat ga je doen in de tuin?',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    title: const Text('In kalender tonen'),
                    subtitle: Text(
                      'Zichtbaar op de kalender (swipe in Notities).',
                      style: t.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    value: _onCalendar,
                    onChanged: (v) => setState(() => _onCalendar = v),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: Icon(isEdit ? Icons.check_rounded : Icons.save_outlined),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                label: Text(isEdit ? 'Wijzigingen opslaan' : 'Notitie opslaan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDayNl(DateTime d) {
  const months = [
    '',
    'januari',
    'februari',
    'maart',
    'april',
    'mei',
    'juni',
    'juli',
    'augustus',
    'september',
    'oktober',
    'november',
    'december',
  ];
  return '${d.day} ${months[d.month]} ${d.year}';
}

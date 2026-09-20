import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/garden_history_store.dart';
import '../data/moestuin_plan_engine.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/vegetable_thumbnail.dart';

/// Wizard: moestuin plannen met buren, wisselteelt en optionele afmetingen.
Future<bool?> showMoestuinPlanWizard({
  required BuildContext context,
  required VegetableRepository repository,
  required MyGardenStore gardenStore,
  required GardenHistoryStore historyStore,
}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => MoestuinPlanWizardScreen(
        repository: repository,
        gardenStore: gardenStore,
        historyStore: historyStore,
      ),
    ),
  );
}

enum _PlanWhen { now, thisSeason, nextSeason }

class MoestuinPlanWizardScreen extends StatefulWidget {
  const MoestuinPlanWizardScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.historyStore,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenHistoryStore historyStore;

  @override
  State<MoestuinPlanWizardScreen> createState() =>
      _MoestuinPlanWizardScreenState();
}

class _MoestuinPlanWizardScreenState extends State<MoestuinPlanWizardScreen> {
  final _pageController = PageController();
  final _searchCtrl = TextEditingController();
  final _widthCtrl = TextEditingController(text: '300');
  final _heightCtrl = TextEditingController(text: '200');

  int _step = 0;
  _PlanWhen _when = _PlanWhen.thisSeason;
  final Set<String> _selectedIds = {};
  bool _advanced = false;
  MoestuinPlanAdvice? _advice;

  @override
  void initState() {
    super.initState();
    _selectedIds.addAll(widget.gardenStore.ids.take(8));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchCtrl.dispose();
    _widthCtrl.dispose();
    _heightCtrl.dispose();
    super.dispose();
  }

  List<Vegetable> get _selectedVegetables => [
        for (final id in _selectedIds)
          if (widget.repository.byId(id) case final v?) v,
      ];

  int get _planYear {
    final now = DateTime.now();
    if (_when == _PlanWhen.nextSeason && now.month >= 9) {
      return now.year + 1;
    }
    return now.year;
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _buildAdvice() {
    final w = double.tryParse(_widthCtrl.text.replaceAll(',', '.'));
    final h = double.tryParse(_heightCtrl.text.replaceAll(',', '.'));
    setState(() {
      _advice = buildMoestuinPlanAdvice(
        selected: _selectedVegetables,
        bedWidthCm: _advanced ? w : null,
        bedHeightCm: _advanced ? h : null,
      );
    });
  }

  Future<void> _save() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kies minstens één gewas')),
      );
      return;
    }
    _buildAdvice();
    final w = double.tryParse(_widthCtrl.text.replaceAll(',', '.')) ?? 300;
    final h = double.tryParse(_heightCtrl.text.replaceAll(',', '.')) ?? 200;
    await widget.historyStore.savePlan(
      GardenYearPlan(
        year: _planYear,
        vegetableIds: _selectedIds.toList(),
        bedWidthCm: _advanced ? w : 300,
        bedHeightCm: _advanced ? h : 200,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Moestuinplan $_planYear opgeslagen '
          '(${_selectedIds.length} gewassen)',
        ),
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: TuinierColors.background,
      appBar: AppBar(
        title: const Text('Moestuin plannen'),
        backgroundColor: TuinierColors.background,
        foregroundColor: TuinierColors.textPrimary,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: List.generate(4, (i) {
                final active = i <= _step;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: active
                          ? TuinierColors.primary
                          : TuinierColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _stepWhen(textTheme),
                _stepPlants(textTheme),
                _stepAdvice(textTheme),
                _stepAdvanced(textTheme),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: () => _goTo(_step - 1),
                      child: const Text('Vorige'),
                    ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: TuinierColors.primary,
                    ),
                    onPressed: () {
                      if (_step == 0) {
                        _goTo(1);
                      } else if (_step == 1) {
                        if (_selectedIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Kies minstens één gewas'),
                            ),
                          );
                          return;
                        }
                        _buildAdvice();
                        _goTo(2);
                      } else if (_step == 2) {
                        _goTo(3);
                      } else {
                        _save();
                      }
                    },
                    child: Text(
                      _step == 3 ? 'Plan opslaan' : 'Volgende',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepWhen(TextTheme t) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Wanneer wil je plannen?',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Kies of je nu wilt starten, dit seizoen optimaliseert, '
          'of alvast volgend seizoen voorbereidt.',
          style: t.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        ...[
          (_PlanWhen.now, 'Nu starten', 'Direct aan de slag met dit moment'),
          (
            _PlanWhen.thisSeason,
            'Dit seizoen',
            'Maximale oogst in het lopende seizoen'
          ),
          (
            _PlanWhen.nextSeason,
            'Volgend seizoen',
            'Voorbereiden op wisselteelt en opvolgers'
          ),
        ].map((e) {
          final selected = _when == e.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              selected: selected,
              selectedTileColor: TuinierColors.primary.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(
                  color: selected ? TuinierColors.primary : TuinierColors.border,
                ),
              ),
              title: Text(e.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(e.$3),
              trailing: selected
                  ? const Icon(Icons.check_circle, color: TuinierColors.primary)
                  : null,
              onTap: () => setState(() => _when = e.$1),
            ),
          );
        }),
      ],
    );
  }

  Widget _stepPlants(TextTheme t) {
    final q = _searchCtrl.text.trim().toLowerCase();
    final gardenFirst = [
      for (final id in widget.gardenStore.ids)
        if (widget.repository.byId(id) case final v?) v,
    ];
    final others = widget.repository.all
        .where((v) => !widget.gardenStore.ids.contains(v.id))
        .toList();
    final pool = [...gardenFirst, ...others];
    final filtered = q.isEmpty
        ? pool
        : pool
            .where((v) => v.nameNl.toLowerCase().contains(q))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welke gewassen teel je?',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Start met planten uit je moestuin of zoek nieuwe gewassen. '
                'Daarna berekenen we buren, bloemen en wisselteelt.',
                style: t.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Zoek een gewas…',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_selectedIds.length} geselecteerd',
                style: t.labelMedium?.copyWith(
                  color: TuinierColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: filtered.length.clamp(0, 80),
            itemBuilder: (context, i) {
              final v = filtered[i];
              final selected = _selectedIds.contains(v.id);
              final inGarden = widget.gardenStore.ids.contains(v.id);
              return CheckboxListTile(
                value: selected,
                onChanged: (on) {
                  setState(() {
                    if (on == true) {
                      _selectedIds.add(v.id);
                    } else {
                      _selectedIds.remove(v.id);
                    }
                  });
                },
                secondary: VegetableThumbnail(vegetable: v, size: 40),
                title: Text(v.nameNl),
                subtitle: Text(inGarden ? 'In je moestuin' : v.family),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _stepAdvice(TextTheme t) {
    final advice = _advice ??
        buildMoestuinPlanAdvice(selected: _selectedVegetables);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Slim teeltplan',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Op basis van jouw gewassen: goede buren, nuttige bloemen, '
          'en wat je na de oogst kunt volgen voor maximale oogst.',
          style: t.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        _AdviceCard(
          title: 'Goede buren',
          color: const Color(0xFFE8F5E9),
          items: advice.goodCompanions,
          empty: 'Geen specifieke buren gevonden',
        ),
        _AdviceCard(
          title: 'Liever niet ernaast',
          color: const Color(0xFFFFEBEE),
          items: advice.badNeighbors,
          empty: 'Geen duidelijke conflicten',
        ),
        _AdviceCard(
          title: 'Nuttige bloemen erbij',
          color: const Color(0xFFF3E5F5),
          items: advice.flowerCompanions,
          empty: '—',
        ),
        _AdviceCard(
          title: 'Wisselteelt / opvolgers na oogst',
          color: const Color(0xFFE3F2FD),
          items: advice.successors,
          empty: 'Kies snelle teelten als voorganger',
        ),
        if (advice.predecessors.isNotEmpty)
          _AdviceCard(
            title: 'Goede voorgangers',
            color: const Color(0xFFFFF8E1),
            items: advice.predecessors,
            empty: '',
          ),
        if (advice.warnings.isNotEmpty)
          _AdviceCard(
            title: 'Let op',
            color: const Color(0xFFFFF3E0),
            items: advice.warnings,
            empty: '',
          ),
      ],
    );
  }

  Widget _stepAdvanced(TextTheme t) {
    final advice = _advice;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Advanced: tuin-afmetingen',
          style: t.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Geef de afmetingen van je bak of bed. We berekenen hoeveel '
          'planten er passen en hoe je ze slim naast elkaar zet.',
          style: t.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Afmetingen gebruiken'),
          subtitle: const Text('Voor bakken of een stuk tuin'),
          value: _advanced,
          activeThumbColor: TuinierColors.primary,
          onChanged: (v) {
            setState(() => _advanced = v);
            if (v) _buildAdvice();
          },
        ),
        if (_advanced) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _widthCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Breedte (cm)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _buildAdvice(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _heightCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Lengte (cm)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _buildAdvice(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (advice != null) ...[
            ...advice.layoutHints.map(
              (h) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.straighten, size: 18,
                        color: TuinierColors.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(h)),
                  ],
                ),
              ),
            ),
            ...advice.warnings.map(
              (w) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        size: 18, color: Color(0xFFE65100)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(w)),
                  ],
                ),
              ),
            ),
          ],
        ] else
          Text(
            'Je kunt dit overslaan — je teeltadvies (buren & wisselteelt) '
            'blijft bewaard.',
            style: t.bodyMedium,
          ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'Plan voor $_planYear · ${_selectedIds.length} gewassen. '
            'Na opslaan vind je dit terug bij je moestuinplannen.',
            style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _AdviceCard extends StatelessWidget {
  const _AdviceCard({
    required this.title,
    required this.color,
    required this.items,
    required this.empty,
  });

  final String title;
  final Color color;
  final List<String> items;
  final String empty;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            Text(empty)
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: items
                  .map(
                    (e) => Chip(
                      label: Text(e, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

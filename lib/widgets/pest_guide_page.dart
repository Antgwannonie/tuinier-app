import 'package:flutter/material.dart';

import '../data/pest_guide_lookup.dart';
import 'clearable_search_field.dart';
import 'pest_detail_card.dart';

/// Inhoud plagen-gids (ingebed in Zoeken-tab of apart scherm).
class PestGuidePage extends StatefulWidget {
  const PestGuidePage({
    super.key,
    this.initialQuery,
  });

  final String? initialQuery;

  @override
  State<PestGuidePage> createState() => _PestGuidePageState();
}

class _PestGuidePageState extends State<PestGuidePage> {
  late final TextEditingController _search;
  String? _expandedId;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final pests = searchGardenPests(_search.text);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: ClearableSearchField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            hintText: 'Zoek plaag of symptoom…',
            fillColor: Color.lerp(cs.surface, cs.primary, 0.08),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '${pests.length} plaag(en) · tik voor herkenning en oplossing',
            style: t.textTheme.labelMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: pests.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Geen plaag gevonden.\n'
                      'Probeer “bladluis”, “schimmel” of “koolrups”.',
                      textAlign: TextAlign.center,
                      style: t.textTheme.bodyLarge?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: pests.length,
                  itemBuilder: (context, i) {
                    final p = pests[i];
                    return PestDetailCard(
                      pest: p,
                      expanded: _expandedId == p.id,
                      onTap: () => setState(() {
                        _expandedId = _expandedId == p.id ? null : p.id;
                      }),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

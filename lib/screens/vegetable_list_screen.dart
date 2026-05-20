import 'package:flutter/material.dart';

import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import 'vegetable_detail_screen.dart';

class VegetableListScreen extends StatefulWidget {
  const VegetableListScreen({super.key, required this.repository});

  final VegetableRepository repository;

  @override
  State<VegetableListScreen> createState() => _VegetableListScreenState();
}

class _VegetableListScreenState extends State<VegetableListScreen> {
  final TextEditingController _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Vegetable> get _visible => widget.repository.search(_search.text);

  @override
  Widget build(BuildContext context) {
    final veggies = _visible;
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groentenatlas'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Zoek op naam, familie of trefwoord…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${veggies.length} soorten',
              style: t.textTheme.labelLarge?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: veggies.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final v = veggies[i];
                return ListTile(
                  title: Text(v.nameNl),
                  subtitle: Text(
                    v.family,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VegetableDetailScreen(vegetable: v),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

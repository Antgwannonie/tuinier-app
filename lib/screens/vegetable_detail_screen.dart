import 'package:flutter/material.dart';

import '../models/vegetable.dart';

class VegetableDetailScreen extends StatelessWidget {
  const VegetableDetailScreen({super.key, required this.vegetable});

  final Vegetable vegetable;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(vegetable.nameNl),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
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
          Chip(
            label: Text(vegetable.family),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 16),
          Text(vegetable.summary, style: t.textTheme.bodyLarge),
          const SizedBox(height: 24),
          _Section(title: 'Zaaien binnen / kas', body: vegetable.sowingIndoors),
          _Section(title: 'Zaaien buiten', body: vegetable.sowingOutdoors),
          _Section(title: 'Planten / verplanten', body: vegetable.transplant),
          _Section(title: 'Oogstperiode', body: vegetable.harvest),
          _Section(
            title: 'Afstand (plant × rij)',
            body:
                '${vegetable.spacingCm} cm × ${vegetable.rowSpacingCm} cm tussen de rijen',
          ),
          _Section(title: 'Licht', body: vegetable.sunRequirement),
          _Section(title: 'Water', body: vegetable.water),
          _Section(title: 'Bodem & bemesting', body: vegetable.soilAndFood),
          _Section(title: 'Verzorging', body: vegetable.care),
          _Section(title: 'Oogsttips', body: vegetable.harvestTips),
          _Section(title: 'Ziektes & plagen', body: vegetable.commonIssues),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: t.textTheme.titleMedium?.copyWith(
              color: t.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(body, style: t.textTheme.bodyLarge),
        ],
      ),
    );
  }
}

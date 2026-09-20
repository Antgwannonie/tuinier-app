import 'package:flutter/material.dart';

import '../../data/plant_combination_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'combination_illustrations.dart';

const _comboGreen = Color(PlantDetailDesign.primaryGreen);

class PlantCombinationDetailScreen extends StatelessWidget {
  const PlantCombinationDetailScreen({super.key, required this.section});

  final PlantCombinationSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(PlantDetailDesign.textPrimary),
        elevation: 0,
        title: Text(
          section.title,
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _comboGreen,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          CombinationIllustration(
            kind: section.illustration,
            size: CombinationIllustrationSize.large,
          ),
          const SizedBox(height: 16),
          Text(
            section.summary,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              fontSize: 14,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
          if (section.checklist != null && section.checklist!.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final item in section.checklist!) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: _comboGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: t.textTheme.bodyMedium?.copyWith(
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
          const SizedBox(height: 20),
          for (final block in section.details) ...[
            Text(
              block.heading,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: _comboGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              block.body,
              style: t.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                fontSize: 14,
                color: const Color(PlantDetailDesign.textPrimary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

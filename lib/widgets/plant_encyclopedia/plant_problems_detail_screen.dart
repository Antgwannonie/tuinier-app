import 'package:flutter/material.dart';

import '../../data/plant_problems_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'problems_illustrations.dart';

const _problemsGreen = Color(PlantDetailDesign.primaryGreen);

class PlantProblemsDetailScreen extends StatelessWidget {
  const PlantProblemsDetailScreen({super.key, required this.section});

  final PlantProblemsSection section;

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
            color: _problemsGreen,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          ProblemsIllustration(
            kind: section.illustration,
            size: ProblemsIllustrationSize.compact,
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
          const SizedBox(height: 20),
          for (final block in section.details) ...[
            Text(
              block.heading,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: _problemsGreen,
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

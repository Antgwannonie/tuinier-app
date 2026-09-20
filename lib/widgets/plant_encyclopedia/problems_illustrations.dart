import 'package:flutter/material.dart';

import '../../data/plant_problems_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';

const _problemsAssets = {
  PlantProblemsIllustration.symptoms:
      'assets/images/problems/problems_symptoms.png',
  PlantProblemsIllustration.insects:
      'assets/images/problems/problems_insects.png',
  PlantProblemsIllustration.fungus:
      'assets/images/problems/problems_fungus.png',
  PlantProblemsIllustration.nutrients:
      'assets/images/problems/problems_nutrients.png',
  PlantProblemsIllustration.water:
      'assets/images/problems/problems_water.png',
  PlantProblemsIllustration.weather:
      'assets/images/problems/problems_weather.png',
  PlantProblemsIllustration.pollination:
      'assets/images/problems/problems_pollination.png',
  PlantProblemsIllustration.growth:
      'assets/images/problems/problems_growth.png',
  PlantProblemsIllustration.pot: 'assets/images/problems/problems_pot.png',
  PlantProblemsIllustration.greenhouse:
      'assets/images/problems/problems_greenhouse.png',
  PlantProblemsIllustration.animals:
      'assets/images/problems/problems_animals.png',
};

enum ProblemsIllustrationSize {
  compact,
  icon,
}

class ProblemsIllustration extends StatelessWidget {
  const ProblemsIllustration({
    super.key,
    required this.kind,
    this.size = ProblemsIllustrationSize.compact,
  });

  final PlantProblemsIllustration kind;
  final ProblemsIllustrationSize size;

  double get _height {
    return switch (size) {
      ProblemsIllustrationSize.icon => 72,
      ProblemsIllustrationSize.compact => 100,
    };
  }

  @override
  Widget build(BuildContext context) {
    final asset = _problemsAssets[kind];
    if (asset == null) return SizedBox(height: _height);

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: const Color(PlantDetailDesign.card),
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}

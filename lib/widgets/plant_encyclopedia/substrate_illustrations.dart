import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

/// Asset-paden voor substraat-illustraties.
abstract final class SubstrateAssets {
  static const best = 'assets/images/mushroom_substrate/substrate_best.png';
  static const stro = 'assets/images/mushroom_substrate/substrate_stro.png';
  static const zaagsel = 'assets/images/mushroom_substrate/substrate_zaagsel.png';
  static const chips = 'assets/images/mushroom_substrate/substrate_chips.png';
  static const woodPoplar =
      'assets/images/mushroom_substrate/substrate_wood_poplar.png';
  static const woodWillow =
      'assets/images/mushroom_substrate/substrate_wood_willow.png';
  static const woodBeech =
      'assets/images/mushroom_substrate/substrate_wood_beech.png';
  static const moistChips =
      'assets/images/mushroom_substrate/substrate_moist_chips.png';
  static const stepMix =
      'assets/images/mushroom_substrate/substrate_step_mix.png';
  static const stepMoisten =
      'assets/images/mushroom_substrate/substrate_step_moisten.png';
  static const stepPasteurize =
      'assets/images/mushroom_substrate/substrate_step_pasteurize.png';
  static const stepCool =
      'assets/images/mushroom_substrate/substrate_step_cool.png';
  static const pasteurize =
      'assets/images/mushroom_substrate/substrate_pasteurize.png';
  static const sterilize =
      'assets/images/mushroom_substrate/substrate_sterilize.png';
  static const temperature =
      'assets/images/mushroom_substrate/substrate_temperature.png';
}

class SubstrateIllustration extends StatelessWidget {
  const SubstrateIllustration({
    super.key,
    required this.assetPath,
    this.aspectRatio = 4 / 3,
    this.compact = false,
  });

  final String assetPath;
  final double aspectRatio;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => _Placeholder(compact: compact),
    );

    if (compact) {
      return AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ColoredBox(
            color: const Color(0xFFF8FAF7),
            child: image,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: const Color(PlantDetailDesign.card),
          child: image,
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.eco_outlined,
        size: compact ? 24 : 36,
        color: const Color(PlantDetailDesign.primaryGreen).withValues(alpha: 0.5),
      ),
    );
  }
}

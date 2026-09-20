import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class StorageAssets {
  static const hero = 'assets/images/mushroom_storage/storage_hero.png';
  static const methodFridge =
      'assets/images/mushroom_storage/storage_method_fridge.png';
  static const methodDry =
      'assets/images/mushroom_storage/storage_method_dry.png';
  static const methodFreeze =
      'assets/images/mushroom_storage/storage_method_freeze.png';
  static const methodJar =
      'assets/images/mushroom_storage/storage_method_jar.png';
  static const stepHarvest =
      'assets/images/mushroom_storage/storage_step_harvest.png';
  static const stepClean =
      'assets/images/mushroom_storage/storage_step_clean.png';
  static const stepPack =
      'assets/images/mushroom_storage/storage_step_pack.png';
  static const stepFridge =
      'assets/images/mushroom_storage/storage_step_fridge.png';
  static const qualityFresh =
      'assets/images/mushroom_storage/storage_quality_fresh.png';
  static const qualityWarning =
      'assets/images/mushroom_storage/storage_quality_warning.png';
  static const qualityBad =
      'assets/images/mushroom_storage/storage_quality_bad.png';
}

class StorageIllustration extends StatelessWidget {
  const StorageIllustration({
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
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => _Placeholder(compact: compact),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 10 : 12),
      child: ColoredBox(
        color: compact ? const Color(0xFFF8FAF7) : const Color(PlantDetailDesign.card),
        child: AspectRatio(
          aspectRatio: aspectRatio,
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
        Icons.inventory_2_outlined,
        size: compact ? 22 : 32,
        color: const Color(PlantDetailDesign.primaryGreen).withValues(alpha: 0.5),
      ),
    );
  }
}

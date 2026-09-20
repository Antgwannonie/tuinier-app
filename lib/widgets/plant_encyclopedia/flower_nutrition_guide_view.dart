import 'package:flutter/material.dart';

import '../../data/flower_guide_profiles.dart';
import '../../data/flower_section_details.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_nutrition_guide.dart';
import '../../models/vegetable.dart';
import 'overview_illustrations.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'plant_nutrition_guide_view.dart';

class FlowerNutritionGuideView extends StatelessWidget {
  const FlowerNutritionGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantNutritionGuide guide;

  @override
  Widget build(BuildContext context) {
    final p = flowerGuideProfileFor(vegetable.id);
    final soil = _shortSoil(p.soilType.isNotEmpty
        ? p.soilType
        : (vegetable.soilAndFood.isNotEmpty ? vegetable.soilAndFood : '—'));
    final ph = p.phRange.isNotEmpty ? p.phRange : '—';
    final compost = _shortCompost(p.compostAdvice);
    final fertilizer = _shortFertiliser(p.fertiliserAdvice);

    Widget wrapTile({
      required String title,
      required String value,
      required Widget child,
    }) {
      return wrapGuideDetailCard(
        context: context,
        title: title,
        summary: value,
        details: flowerSectionDetailsFor(
          tab: 'nutrition',
          title: title,
          vegetable: vegetable,
          profile: p,
        ),
        showMeerInfo: false,
        child: child,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlantDetailCard(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PlantDetailSectionTitle(
                title: 'Voeding & Bodem',
                imageAsset: OverviewAssets.voeding,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.78,
                children: [
                  wrapTile(
                    title: 'Beste bodem',
                    value: soil,
                    child: _NutritionSquareTile(
                      imageAsset:
                          'assets/images/nutrition/nutrition_soil_humus.png',
                      icon: Icons.grass_outlined,
                      label: 'Beste bodem',
                      value: soil,
                      showMeerInfoFooter: true,
                    ),
                  ),
                  wrapTile(
                    title: 'pH-waarde',
                    value: ph,
                    child: _NutritionSquareTile(
                      imageAsset:
                          'assets/images/nutrition/nutrition_soil_loam.png',
                      icon: Icons.science_outlined,
                      label: 'pH-waarde',
                      value: ph,
                      showMeerInfoFooter: true,
                    ),
                  ),
                  wrapTile(
                    title: 'Compost',
                    value: compost,
                    child: _NutritionSquareTile(
                      imageAsset:
                          'assets/images/nutrition/nutrition_compost_bin.png',
                      icon: Icons.yard_outlined,
                      label: 'Compost',
                      value: compost,
                      showMeerInfoFooter: true,
                    ),
                  ),
                  wrapTile(
                    title: 'Meststof',
                    value: fertilizer,
                    child: _NutritionSquareTile(
                      imageAsset:
                          'assets/images/nutrition/nutrition_growth_feed.png',
                      icon: Icons.spa_outlined,
                      label: 'Meststof',
                      value: fertilizer,
                      showMeerInfoFooter: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PlantNutritionGuideView(
          guide: PlantNutritionGuide(
            rows: [
              for (final row in guide.rows)
                if (row.kind != PlantNutritionRowKind.soilBest &&
                    row.kind != PlantNutritionRowKind.fertilizerBest &&
                    !(row.kind == PlantNutritionRowKind.columns2 &&
                        row.sections.any(
                          (s) =>
                              s.title.toLowerCase().contains('ph') ||
                              s.title.toLowerCase().contains('compost'),
                        )))
                  row,
            ],
          ),
        ),
      ],
    );
  }
}

class _NutritionSquareTile extends StatelessWidget {
  const _NutritionSquareTile({
    required this.imageAsset,
    required this.icon,
    required this.label,
    required this.value,
    this.showMeerInfoFooter = false,
  });

  final String imageAsset;
  final IconData icon;
  final String label;
  final String value;
  final bool showMeerInfoFooter;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFF59D)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  imageAsset,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Icon(
                    icon,
                    size: 30,
                    color: const Color(PlantDetailDesign.primaryGreen),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: t.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(PlantDetailDesign.textSecondary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(PlantDetailDesign.textPrimary),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          if (showMeerInfoFooter)
            const GuideMeerInfoFooter(
              compact: true,
              margin: EdgeInsets.only(top: 4),
            ),
        ],
      ),
    );
  }
}

String _shortSoil(String raw) {
  final t = raw.trim();
  if (t.isEmpty || t == '—') return '—';
  final cut = t.split(RegExp(r'[.;]')).first.trim();
  if (cut.length <= 36) return cut;
  return '${cut.substring(0, 34).trimRight()}…';
}

String _shortCompost(String advice) {
  final t = advice.toLowerCase();
  if (t.isEmpty) return 'Matig';
  if (t.contains('geen') || t.contains('weinig') || t.contains('arm')) {
    return 'Weinig';
  }
  if (t.contains('rijk') || t.contains('veel')) return 'Rijk';
  return 'Matig';
}

String _shortFertiliser(String advice) {
  final t = advice.toLowerCase();
  if (t.isEmpty) return 'Licht organisch';
  if (t.contains('geen') || t.contains('niet bemest') || t.contains('arm')) {
    return 'Nauwelijks / arm';
  }
  if (t.contains('laag n') || t.contains('weinig stikstof')) {
    return 'Organisch · laag N';
  }
  if (t.contains('kalium') || t.contains('bloei')) {
    return 'Organisch · bloei';
  }
  return 'Licht organisch';
}

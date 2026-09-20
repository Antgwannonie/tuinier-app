import 'package:flutter/material.dart';

import '../../data/flower_guide_profiles.dart';
import '../../data/flower_section_details.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_water_guide.dart';
import '../../models/vegetable.dart';
import 'overview_illustrations.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'plant_water_guide_view.dart';

class FlowerWaterGuideView extends StatelessWidget {
  const FlowerWaterGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantWaterGuide guide;

  @override
  Widget build(BuildContext context) {
    final p = flowerGuideProfileFor(vegetable.id);
    final need = (p.waterNeed.isNotEmpty ? p.waterNeed : layout.water)
        .toLowerCase();
    final dryPreferring = p.droughtResistant ||
        need.contains('weinig') ||
        need.contains('droog');
    final thirsty = need.contains('veel') || need.contains('nat');

    final waterNeed = p.waterNeed.isNotEmpty ? p.waterNeed : layout.water;
    // Korte, krachtige tegels — uitgebreide uitleg zit in de detailpagina.
    final howOften = dryPreferring
        ? '1×/week bij droogte'
        : (thirsty
            ? 'Regelmatig · niet laten uitdrogen'
            : '2–3×/week bij droogte');
    final howMuch =
        dryPreferring ? 'Diep, spaarzaam' : (thirsty ? 'Ruim bij de voet' : 'Gelijkmatig vochtig');
    final bestMoment = '’s ochtends';

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
          tab: 'water',
          title: title,
          vegetable: vegetable,
          profile: p,
        ),
        // Footer zit in de gekleurde tile.
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
                title: 'Water',
                imageAsset: OverviewAssets.water,
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.82,
                children: [
                  wrapTile(
                    title: 'Waterbehoefte',
                    value: waterNeed,
                    child: _WaterSquareTile(
                      imageAsset: 'assets/images/water/water_watering_can.png',
                      icon: Icons.water_drop_outlined,
                      label: 'Waterbehoefte',
                      value: waterNeed,
                      showMeerInfoFooter: true,
                    ),
                  ),
                  wrapTile(
                    title: 'Hoe vaak',
                    value: howOften,
                    child: _WaterSquareTile(
                      imageAsset: 'assets/images/water/water_growth_stages.png',
                      icon: Icons.schedule_outlined,
                      label: 'Hoe vaak',
                      value: howOften,
                      showMeerInfoFooter: true,
                    ),
                  ),
                  wrapTile(
                    title: 'Hoeveel',
                    value: howMuch,
                    child: _WaterSquareTile(
                      imageAsset:
                          'assets/images/water/water_germination_spray.png',
                      icon: Icons.format_color_fill_outlined,
                      label: 'Hoeveel',
                      value: howMuch,
                      showMeerInfoFooter: true,
                    ),
                  ),
                  wrapTile(
                    title: 'Beste moment',
                    value: bestMoment,
                    child: _WaterSquareTile(
                      imageAsset: 'assets/images/water/water_greenhouse.png',
                      icon: Icons.wb_sunny_outlined,
                      label: 'Beste moment',
                      value: bestMoment,
                      showMeerInfoFooter: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PlantWaterGuideView(
          guide: PlantWaterGuide(
            rows: [
              for (final row in guide.rows)
                if (row.kind != PlantWaterRowKind.waterNeed) row,
            ],
          ),
        ),
        const SizedBox(height: 12),
        wrapGuideDetailCard(
          context: context,
          title: 'Veelgemaakte fouten',
          summary: dryPreferring
              ? 'Droogtetolerante bloem: pas op met te veel water.'
              : 'Houd vocht gelijkmatig; voorkom schimmel.',
          details: flowerSectionDetailsFor(
            tab: 'water',
            title: 'Veelgemaakte fouten',
            vegetable: vegetable,
            profile: p,
          ),
          child: _FlowerWaterMistakesCard(
            items: dryPreferring
                ? const [
                  (
                    'Te vaak water geven',
                    'Wortels rotten bij natte grond. Wacht tot de grond droog aanvoelt.',
                  ),
                  (
                    'Geen drainage',
                    'Zonder gaten in de pot blijft water staan en gaan wortels rotten.',
                  ),
                  (
                    'Water geven op de verkeerde tijd',
                    '’s Avonds water geven bevordert schimmel. Kies liever de ochtend.',
                  ),
                  (
                    'Te veel water in potten',
                    'Potgrond droogt sneller uit, maar overgieten is nóg schadelijker.',
                  ),
                ]
              : const [
                  (
                    'Te weinig water geven',
                    'Laat de grond niet volledig uitdrogen tijdens droge periodes.',
                  ),
                  (
                    'Onregelmatig water geven',
                    'Gelijkmatig vochtig houden werkt beter dan wisselvallig gieten.',
                  ),
                  (
                    'Water geven op de verkeerde tijd',
                    '’s Avonds water geven bevordert schimmel. Kies liever de ochtend.',
                  ),
                ],
          ),
        ),
      ],
    );
  }
}

class _WaterSquareTile extends StatelessWidget {
  const _WaterSquareTile({
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
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBBDEFB)),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.labelMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(PlantDetailDesign.textPrimary),
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

class _FlowerWaterMistakesCard extends StatelessWidget {
  const _FlowerWaterMistakesCard({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Veelgemaakte fouten',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB71C1C),
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.close_rounded,
                      size: 16, color: Color(0xFFE53935)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$1,
                          style: t.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          item.$2,
                          style: t.bodySmall?.copyWith(height: 1.35),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/flower_guide_profiles.dart';
import '../../data/flower_section_details.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_location_guide.dart';
import '../../models/vegetable.dart';
import 'overview_illustrations.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'plant_location_guide_view.dart';

class FlowerLocationGuideView extends StatelessWidget {
  const FlowerLocationGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantLocationGuide guide;

  @override
  Widget build(BuildContext context) {
    final p = flowerGuideProfileFor(vegetable.id);
    final ideal = p.sunNeed.isNotEmpty ? p.sunNeed : layout.standplaats;
    final lightNeed = p.sunHoursIdeal.isNotEmpty
        ? '${p.sunHoursIdeal} (min. ${p.sunHoursMin})'
        : (p.sunNeed.isNotEmpty ? p.sunNeed : layout.standplaats);

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
          tab: 'location',
          title: title,
          vegetable: vegetable,
          profile: p,
        ),
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
                title: 'Standplaats',
                imageAsset: OverviewAssets.standplaats,
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.05,
                children: [
                  wrapTile(
                    title: 'Ideale standplaats',
                    value: ideal,
                    child: _SquareStatTile(
                      imageAsset:
                          'assets/images/location/location_sun_full.png',
                      label: 'Ideale standplaats',
                      value: ideal,
                    ),
                  ),
                  wrapTile(
                    title: 'Lichtbehoefte',
                    value: lightNeed,
                    child: _SquareStatTile(
                      imageAsset:
                          'assets/images/location/location_sun_hours.png',
                      label: 'Lichtbehoefte',
                      value: lightNeed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PlantLocationGuideView(guide: guide),
      ],
    );
  }
}

class _SquareStatTile extends StatelessWidget {
  const _SquareStatTile({
    required this.imageAsset,
    required this.label,
    required this.value,
  });

  final String imageAsset;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imageAsset,
            width: 72,
            height: 72,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.wb_sunny_outlined,
              size: 34,
              color: Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 6),
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
    );
  }
}

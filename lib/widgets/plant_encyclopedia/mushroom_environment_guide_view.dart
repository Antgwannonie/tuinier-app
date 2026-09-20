import 'package:flutter/material.dart';

import '../../data/mushroom_environment_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'environment_illustrations.dart';
import 'mushroom_guide_card.dart';

class MushroomEnvironmentGuideView extends StatelessWidget {
  const MushroomEnvironmentGuideView({super.key, required this.guide});

  final MushroomEnvironmentGuide guide;

  static const _twoColBreakpoint = 520.0;
  static const _fourColBreakpoint = 640.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 32;
    final twoCol = width >= _twoColBreakpoint;
    final fourCol = width >= _fourColBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'De ideale omgeving',
          child: (summary) => _HeroCard(summary: summary),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Kies je kweekomgeving',
          child: (summary) =>
              _LocationGrid(locations: guide.locations, summary: summary, twoCol: twoCol),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Ideale omgevingsfactoren',
          child: (summary) => _FactorsCard(
            guide: guide,
            summary: summary,
            fourCol: fourCol,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        _TipCard(text: guide.stabilityTip),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Omgeving per groeifase',
          child: (summary) =>
              _PhasesCard(phases: guide.phases, summary: summary, twoCol: twoCol),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Veelgemaakte fouten',
          child: (summary) => _MistakesCard(
            mistakes: guide.mistakes,
            summary: summary,
            fourCol: fourCol,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        _TipCard(text: guide.monitoringTip),
      ],
    );
  }
}

class _GreenSectionTitle extends StatelessWidget {
  const _GreenSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: Color(PlantDetailDesign.primaryGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tip: $text',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stack = MediaQuery.sizeOf(context).width < 400;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('De ideale omgeving'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const hero = EnvironmentIllustration(
      assetPath: EnvironmentAssets.hero,
      aspectRatio: 16 / 9,
    );

    return stack
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [textBlock, const SizedBox(height: 12), hero],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                textBlock,
                const SizedBox(height: 12),
                hero,
              ],
            );
  }
}

class _LocationGrid extends StatelessWidget {
  const _LocationGrid({
    required this.locations,
    required this.summary,
    required this.twoCol,
  });

  final List<EnvironmentLocationOption> locations;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Kies je kweekomgeving'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 10),
        if (twoCol)
          Column(
            children: [
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _LocationCard(location: locations[0])),
                    const SizedBox(width: 10),
                    Expanded(child: _LocationCard(location: locations[1])),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _LocationCard(location: locations[2])),
                    const SizedBox(width: 10),
                    Expanded(child: _LocationCard(location: locations[3])),
                  ],
                ),
              ),
            ],
          )
        else
          Column(
            children: [
              for (var i = 0; i < locations.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _LocationCard(location: locations[i]),
              ],
            ],
          ),
      ],
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location});

  final EnvironmentLocationOption location;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EnvironmentIllustration(
          assetPath: location.assetPath,
          aspectRatio: 16 / 10,
          compact: true,
        ),
        const SizedBox(height: 8),
        Text(
          location.title,
          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}

class _FactorsCard extends StatelessWidget {
  const _FactorsCard({
    required this.guide,
    required this.summary,
    required this.fourCol,
    required this.twoCol,
  });

  final MushroomEnvironmentGuide guide;
  final String summary;
  final bool fourCol;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final factors = [
      _FactorData(
        icon: Icons.thermostat_rounded,
        iconColor: const Color(0xFFDC2626),
        value: guide.temperature,
        label: 'Temperatuur',
        note: guide.temperatureNote,
      ),
      _FactorData(
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFF3B82F6),
        value: guide.humidity,
        label: 'Luchtvochtigheid',
        note: guide.humidityNote,
      ),
      _FactorData(
        icon: Icons.air_rounded,
        iconColor: const Color(0xFF6B7280),
        value: guide.ventilationValue,
        label: 'Ventilatie',
        note: guide.ventilationNote,
      ),
      _FactorData(
        icon: Icons.wb_sunny_outlined,
        iconColor: const Color(0xFFF59E0B),
        value: guide.lightValue,
        label: 'Licht',
        note: guide.lightNote,
      ),
      _FactorData(
        icon: Icons.bedtime_outlined,
        iconColor: const Color(0xFF6366F1),
        value: guide.restValue,
        label: 'Rust',
        note: guide.restNote,
      ),
    ];

    Widget row(List<_FactorData> items) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _FactorTile(data: items[i])),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Ideale omgevingsfactoren'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (fourCol)
            row(factors)
          else if (twoCol) ...[
            row(factors.sublist(0, 3)),
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _FactorTile(data: factors[3])),
                  const SizedBox(width: 8),
                  Expanded(child: _FactorTile(data: factors[4])),
                ],
              ),
            ),
          ] else ...[
            row(factors.sublist(0, 2)),
            const SizedBox(height: 8),
            row(factors.sublist(2, 4)),
            const SizedBox(height: 8),
            _FactorTile(data: factors[4]),
          ],
        ],
      );
  }
}

class _FactorData {
  const _FactorData({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.note,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String note;
}

class _FactorTile extends StatelessWidget {
  const _FactorTile({required this.data});

  final _FactorData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        children: [
          Icon(data.icon, size: 26, color: data.iconColor),
          const SizedBox(height: 6),
          Text(
            data.value,
            textAlign: TextAlign.center,
            style: t.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhasesCard extends StatelessWidget {
  const _PhasesCard({
    required this.phases,
    required this.summary,
    required this.twoCol,
  });

  final List<EnvironmentPhase> phases;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget phaseTile(EnvironmentPhase phase) {
      return Column(
        children: [
          EnvironmentIllustration(
            assetPath: phase.assetPath,
            aspectRatio: 1,
            compact: true,
          ),
          const SizedBox(height: 6),
          Text(
            phase.label,
            style: t.labelSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          for (final stat in phase.stats)
            Text(
              stat,
              textAlign: TextAlign.center,
              style: t.labelSmall?.copyWith(
                fontSize: 9,
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Omgeving per groeifase'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol)
            Row(
              children: [
                for (var i = 0; i < phases.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(PlantDetailDesign.primaryGreen),
                      ),
                    ),
                  Expanded(child: phaseTile(phases[i])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var i = 0; i < phases.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  phaseTile(phases[i]),
                ],
              ],
            ),
        ],
      );
  }
}

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({
    required this.mistakes,
    required this.summary,
    required this.fourCol,
    required this.twoCol,
  });

  final List<EnvironmentMistake> mistakes;
  final String summary;
  final bool fourCol;
  final bool twoCol;

  static const _icons = [
    Icons.air_rounded,
    Icons.thermostat_rounded,
    Icons.wb_sunny_outlined,
    Icons.water_drop_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget mistakeTile(EnvironmentMistake mistake, IconData icon) {
      return Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 32, color: const Color(0xFF9CA3AF)),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            mistake.title,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB71C1C),
            ),
          ),
        ],
      );
    }

    Widget row(int start, int end) {
      return Row(
        children: [
          for (var i = start; i < end; i++) ...[
            if (i > start) const SizedBox(width: 8),
            Expanded(child: mistakeTile(mistakes[i], _icons[i])),
          ],
        ],
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PlantDetailDesign.cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(color: const Color(0xFFFFCDD2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
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
          const SizedBox(height: 8),
          Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
          const SizedBox(height: 12),
          if (fourCol)
            row(0, 4)
          else if (twoCol) ...[
            row(0, 2),
            const SizedBox(height: 12),
            row(2, 4),
          ] else ...[
            row(0, 2),
            const SizedBox(height: 12),
            row(2, 4),
          ],
        ],
      ),
    );
  }
}

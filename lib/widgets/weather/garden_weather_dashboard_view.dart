import 'package:flutter/material.dart';

import '../../data/garden_weather_dashboard.dart';
import '../../data/weather_service.dart';
import '../../theme/tuinier_colors.dart';
import '../../theme/tuinier_decorations.dart';
import '../vegetable_thumbnail.dart';
import 'weather_visual_icons.dart';

class GardenWeatherDashboardView extends StatelessWidget {
  const GardenWeatherDashboardView({
    super.key,
    required this.forecast,
    required this.dashboard,
    required this.coachLoading,
    required this.placeName,
    required this.onPickCity,
  });

  final WeatherForecast forecast;
  final GardenWeatherDashboard? dashboard;
  final bool coachLoading;
  final String placeName;
  final VoidCallback onPickCity;

  static const _cardRadius = 24.0;
  static const _dayRadius = 20.0;

  @override
  Widget build(BuildContext context) {
    final dash = dashboard;
    final alertCrops = dash == null
        ? <GardenCropWeatherAdvice>[]
        : attentionCropAdvices(dash.cropAdvices);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeroCard(forecast: forecast, placeName: placeName, onPickCity: onPickCity),
        const SizedBox(height: 12),
        _sectionTitle(context, 'Komende 7 dagen'),
        const SizedBox(height: 8),
        _DayRow(days: forecast.daily, currentIsDay: forecast.isDay),
        const SizedBox(height: 16),
        _CoachCard(dashboard: dash, loading: coachLoading),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Tuin impact'),
        const SizedBox(height: 8),
        if (dash != null) _ImpactGrid(impacts: dash.impacts),
        const SizedBox(height: 16),
        if (dash != null && dash.risks.isNotEmpty)
          _RisksCard(risks: dash.risks),
        if (dash != null && alertCrops.isNotEmpty) ...[
          const SizedBox(height: 16),
          _CropsCard(advices: alertCrops),
        ],
      ],
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: TuinierColors.textPrimary,
          ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.forecast,
    required this.placeName,
    required this.onPickCity,
  });

  final WeatherForecast forecast;
  final String placeName;
  final VoidCallback onPickCity;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final today = forecast.daily.isNotEmpty ? forecast.daily.first : null;
    final tomorrow = forecast.daily.length > 1 ? forecast.daily[1] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: TuinierDecorations.card(radius: 24, bordered: false),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              WeatherCodeIcon(
                code: forecast.currentCode,
                size: 52,
                isDay: forecast.isDay,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: onPickCity,
                            borderRadius: BorderRadius.circular(8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.place_outlined, size: 15, color: TuinierColors.textSecondary),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    placeName,
                                    style: t.textTheme.labelMedium?.copyWith(
                                      color: TuinierColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${forecast.currentTempC.round()}°C',
                            style: t.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: TuinierColors.textPrimary,
                              height: 1.05,
                            ),
                          ),
                          Text(
                            weatherCodeLabelNl(
                              forecast.currentCode,
                              isDay: forecast.isDay,
                            ),
                            style: t.textTheme.bodySmall?.copyWith(
                              color: TuinierColors.textSecondary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (today != null) ...[
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _dayRange(t, 'Vandaag', today.maxTempC, today.minTempC),
                          if (tomorrow != null) ...[
                            const SizedBox(height: 4),
                            _dayRange(t, 'Morgen', tomorrow.maxTempC, tomorrow.minTempC),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            decoration: BoxDecoration(
              color: TuinierColors.background,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Expanded(
                  child: WeatherHeroStatTile(
                    kind: WeatherStatKind.wind,
                    value: '${forecast.currentWindKmh.round()} km/u',
                    caption: 'Wind',
                  ),
                ),
                Container(width: 1, height: 36, color: TuinierColors.border),
                Expanded(
                  child: WeatherHeroStatTile(
                    kind: WeatherStatKind.humidity,
                    value: '${forecast.currentHumidityPercent}%',
                    caption: 'Vochtigheid',
                  ),
                ),
                Container(width: 1, height: 36, color: TuinierColors.border),
                Expanded(
                  child: WeatherHeroStatTile(
                    kind: WeatherStatKind.uv,
                    value: '${forecast.currentUvIndex.round()} · ${uvLabelNl(forecast.currentUvIndex)}',
                    caption: 'UV-index',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayRange(ThemeData t, String label, double max, double min) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: t.textTheme.labelSmall?.copyWith(
            color: TuinierColors.textSecondary,
            fontSize: 10,
          ),
        ),
        Text(
          '${max.round()}° / ${min.round()}°',
          style: t.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({required this.dashboard, required this.loading});

  final GardenWeatherDashboard? dashboard;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    if (loading) {
      return Container(
        height: 160,
        padding: const EdgeInsets.all(20),
        decoration: TuinierDecorations.aiCoachGradient(radius: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'AI tuincoach maakt samenvatting klaar',
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ],
        ),
      );
    }
    final dash = dashboard;
    if (dash == null) return const SizedBox.shrink();

    final score = dash.scoreToday.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: TuinierDecorations.aiCoachGradient(radius: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                'AI Tuincoach',
                style: t.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (dash.usedAi)
                Text(
                  'AI',
                  style: t.textTheme.labelSmall?.copyWith(color: Colors.white70),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Score vandaag: $score/10',
            style: t.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dash.coachSummary,
            style: t.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.45,
            ),
          ),
          if (dash.recommendedActions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              'Aanbevolen taken',
              style: t.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            ...dash.recommendedActions.map(
              (a) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a,
                        style: t.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.days,
    required this.currentIsDay,
  });

  final List<DailyWeather> days;
  final bool currentIsDay;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['ma', 'di', 'wo', 'do', 'vr', 'za', 'zo'];
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final d = days[i];
          final isDay = i == 0 ? currentIsDay : true;
          final iconCode = dailyWeatherIconCode(d, isDay: isDay);
          return Container(
            width: 64,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            decoration: TuinierDecorations.card(radius: 16, bordered: false),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  weekdays[d.date.weekday - 1].toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                ),
                WeatherCodeIcon(
                  code: iconCode,
                  size: 30,
                  isDay: isDay,
                ),
                Text(
                  '${d.maxTempC.round()}° / ${d.minTempC.round()}°',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                ),
                PrecipBadge(percent: d.precipChancePercent),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ImpactGrid extends StatelessWidget {
  const _ImpactGrid({required this.impacts});

  final List<GardenWeatherImpactItem> impacts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth - 8) / 2;
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in impacts)
              SizedBox(
                width: cardWidth,
                child: _ImpactTile(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _ImpactTile extends StatelessWidget {
  const _ImpactTile({required this.item});

  final GardenWeatherImpactItem item;

  @override
  Widget build(BuildContext context) {
    final color = impactToneColor(item.tone);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: TuinierDecorations.card(radius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          WeatherImpactIcon(title: item.title, tone: item.tone, size: 36),
          const SizedBox(height: 8),
          Text(
            item.title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            item.statusLabel,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: color,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: TuinierColors.textSecondary,
                  height: 1.35,
                  fontSize: 12,
                ),
          ),
        ],
      ),
    );
  }
}

class _RisksCard extends StatefulWidget {
  const _RisksCard({required this.risks, this.compact = false});

  final List<GardenWeatherRiskItem> risks;
  final bool compact;

  @override
  State<_RisksCard> createState() => _RisksCardState();
}

class _RisksCardState extends State<_RisksCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final pad = widget.compact ? 12.0 : 20.0;
    return Container(
      decoration: TuinierDecorations.card(radius: widget.compact ? 20 : 24),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: EdgeInsets.fromLTRB(pad, pad, pad, _expanded ? (widget.compact ? 8 : 12) : pad),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: TuinierColors.warning,
                      size: widget.compact ? 18 : 22,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Risico\'s deze week',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: widget.compact ? 13 : null,
                            ),
                      ),
                    ),
                    if (!_expanded && widget.risks.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: TuinierColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.risks.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: TuinierColors.warning,
                          ),
                        ),
                      ),
                    Icon(
                      _expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: TuinierColors.iconMuted,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            firstCurve: Curves.easeOut,
            secondCurve: Curves.easeIn,
            sizeCurve: Curves.easeInOut,
            crossFadeState:
                _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 200),
            firstChild: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < widget.risks.length; i++) ...[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: pad,
                      endIndent: pad,
                      color: TuinierColors.border,
                    ),
                  _RiskRow(risk: widget.risks[i], compact: widget.compact),
                ],
                SizedBox(height: widget.compact ? 2 : 4),
              ],
            ),
            secondChild: const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

class _RiskRow extends StatelessWidget {
  const _RiskRow({required this.risk, this.compact = false});

  final GardenWeatherRiskItem risk;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 36.0 : 44.0;
    final hPad = compact ? 12.0 : 20.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: compact ? 10 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WeatherRiskIcon(kind: risk.kind, size: iconSize),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Text(
              risk.label,
              style: (compact
                      ? Theme.of(context).textTheme.bodySmall
                      : Theme.of(context).textTheme.bodyMedium)
                  ?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _CropsCard extends StatelessWidget {
  const _CropsCard({required this.advices, this.compact = false});

  final List<GardenCropWeatherAdvice> advices;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final pad = compact ? 12.0 : 20.0;
    return Container(
      decoration: TuinierDecorations.card(radius: compact ? 20 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(pad, pad, pad, compact ? 8 : 12),
            child: Row(
              children: [
                Icon(
                  Icons.eco_rounded,
                  color: TuinierColors.primary,
                  size: compact ? 18 : 22,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Jouw gewassen',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: compact ? 13 : null,
                        ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < advices.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: pad,
                endIndent: pad,
                color: TuinierColors.border,
              ),
            _CropRow(advice: advices[i], compact: compact),
          ],
          SizedBox(height: compact ? 2 : 4),
        ],
      ),
    );
  }
}

class _CropRow extends StatelessWidget {
  const _CropRow({required this.advice, this.compact = false});

  final GardenCropWeatherAdvice advice;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final hPad = compact ? 12.0 : 20.0;
    final thumbSize = compact ? 36.0 : 48.0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: compact ? 10 : 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          VegetableThumbnail(
            vegetable: advice.vegetable,
            size: thumbSize,
            borderRadius: thumbSize / 2,
          ),
          SizedBox(width: compact ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  advice.vegetable.nameNl,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 13 : null,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  advice.advice,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TuinierColors.textSecondary,
                        height: 1.3,
                        fontSize: compact ? 11 : null,
                      ),
                  maxLines: compact ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: compact ? 4 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 7 : 10,
              vertical: compact ? 3 : 5,
            ),
            decoration: BoxDecoration(
              color: TuinierColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Let op',
              style: TextStyle(
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w700,
                color: TuinierColors.warning,
              ),
            ),
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: TuinierColors.iconMuted, size: 22),
          ],
        ],
      ),
    );
  }
}

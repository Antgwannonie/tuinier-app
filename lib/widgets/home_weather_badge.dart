import 'package:flutter/material.dart';

import '../data/weather_service.dart';
import '../theme/tuinier_colors.dart';
import 'weather/weather_visual_icons.dart';

/// Compact weerkaart op home — icoon + temp.
class HomeWeatherBadge extends StatelessWidget {
  const HomeWeatherBadge({
    super.key,
    required this.loading,
    this.forecast,
    this.onTap,
  });

  final bool loading;
  final WeatherForecast? forecast;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final child = loading ? _buildLoading() : _buildContent(context);

    if (onTap == null) return child;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }

  Widget _buildLoading() {
    return const SizedBox(
      width: 28,
      height: 28,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
  }

  Widget _buildContent(BuildContext context) {
    final temp = forecast?.currentTempC?.round();
    final code = forecast?.currentCode;
    final isDay = forecast?.isDay ?? _estimateIsDay();
    final desc = forecast != null
        ? weatherCodeLabelNl(forecast!.currentCode, isDay: isDay)
        : 'Weer onbekend';

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        HomeWeatherBadgeIcon(code: code ?? 48, size: 84, isDay: isDay),
        Transform.translate(
          offset: const Offset(-10, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                temp != null ? '$temp°C' : '—',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      color: TuinierColors.textPrimary,
                      height: 1,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: TuinierColors.textSecondary,
                      fontSize: 12,
                      height: 1.15,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static bool _estimateIsDay() {
    final hour = DateTime.now().hour;
    return hour >= 7 && hour < 21;
  }
}

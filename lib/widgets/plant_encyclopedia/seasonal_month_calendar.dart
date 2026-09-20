import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/planting_calendar.dart';
/// Seizoenskalender in tuinplanner-stijl met seizoensiconen en jaarrond-illustratie.
class SeasonalMonthCalendar extends StatelessWidget {
  const SeasonalMonthCalendar({
    super.key,
    required this.months,
    this.label,
    this.compact = false,
    this.accentColor = const Color(PlantDetailDesign.primaryGreen),
    this.showTitle = true,
  });

  final Set<int> months;
  final String? label;
  final bool compact;
  final Color accentColor;
  final bool showTitle;

  static const _monthLetters = [
    'J',
    'F',
    'M',
    'A',
    'M',
    'J',
    'J',
    'A',
    'S',
    'O',
    'N',
    'D',
  ];

  static const _stripAsset = 'assets/images/calendar/seasonal_year_strip.png';

  static const _monthGap = 4.0;

  static String _displayPeriodLabel(String label) {
    if (label == '—') return label;
    String cap(String word) {
      final trimmed = word.trim();
      if (trimmed.isEmpty) return trimmed;
      return '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
    }

    return label
        .split(', ')
        .map(
          (part) => part.split(' – ').map(cap).join(' – '),
        )
        .join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final circleSize = compact ? 22.0 : 28.0;
    final seasonHeight = compact ? 28.0 : 34.0;
    final bottomPad = compact ? 8.0 : 10.0;
    final periodLabel = _displayPeriodLabel(formatPlantMonthRange(months));

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8DE)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(
            child: _SeasonalCalendarBackground(),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(10, compact ? 10 : 12, 10, bottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showTitle && label != null && label!.isNotEmpty) ...[
                  Text(
                    label!,
                    style: t.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: compact ? 14 : 15,
                      color: const Color(PlantDetailDesign.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  height: seasonHeight,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return CustomPaint(
                        size: Size(constraints.maxWidth, seasonHeight),
                        painter: _SeasonArcPainter(),
                        child: Row(
                          children: const [
                            Expanded(
                              child: _SeasonIcon(
                                icon: Icons.ac_unit_rounded,
                                color: Color(0xFF7DD3FC),
                              ),
                            ),
                            Expanded(
                              child: _SeasonIcon(
                                icon: Icons.eco_rounded,
                                color: Color(0xFF86EFAC),
                              ),
                            ),
                            Expanded(
                              child: _SeasonIcon(
                                icon: Icons.wb_sunny_rounded,
                                color: Color(0xFFFCD34D),
                              ),
                            ),
                            Expanded(
                              child: _SeasonIcon(
                                icon: Icons.park_rounded,
                                color: Color(0xFFFB923C),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final totalGap = _monthGap * 11;
                    final slotWidth =
                        (constraints.maxWidth - totalGap).clamp(0, double.infinity) /
                            12;

                    return Column(
                      children: [
                        Row(
                          children: List.generate(12, (i) {
                            final month = i + 1;
                            final active = months.contains(month);

                            return Padding(
                              padding: EdgeInsets.only(
                                right: i < 11 ? _monthGap : 0,
                              ),
                              child: SizedBox(
                                width: slotWidth,
                                child: Column(
                                  children: [
                                    active
                                        ? Container(
                                            width: circleSize,
                                            height: circleSize,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: accentColor,
                                              border: Border.all(
                                                color: accentColor.withValues(
                                                  alpha: 0.85,
                                                ),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: accentColor.withValues(
                                                    alpha: 0.4,
                                                  ),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Text(
                                              _monthLetters[i],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: compact ? 10 : 12,
                                                fontWeight: FontWeight.w800,
                                                height: 1,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: circleSize,
                                            height: circleSize,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(
                                                alpha: 0.95,
                                              ),
                                              border: Border.all(
                                                color: const Color(0xFFD0D9CC),
                                                width: 1.2,
                                              ),
                                            ),
                                            child: Text(
                                              _monthLetters[i],
                                              style: const TextStyle(
                                                color: Color(0xFF6B7280),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                height: 1,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                        if (periodLabel != '—') ...[
                          const SizedBox(height: 10),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: accentColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                periodLabel,
                                textAlign: TextAlign.center,
                                style: t.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: compact ? 13 : 14,
                                  color: accentColor,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SeasonalCalendarBackground extends StatelessWidget {
  const _SeasonalCalendarBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1.12, 0, 0, 0, 8,
            0, 1.12, 0, 0, 8,
            0, 0, 1.08, 0, 6,
            0, 0, 0, 1, 0,
          ]),
          child: Image.asset(
            SeasonalMonthCalendar._stripAsset,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => const ColoredBox(
              color: Color(0xFFE8F0E4),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFFD6EEFB).withValues(alpha: 0.55),
                const Color(0xFFD8F0DE).withValues(alpha: 0.5),
                const Color(0xFFFFF0C2).withValues(alpha: 0.48),
                const Color(0xFFFFE4CC).withValues(alpha: 0.52),
              ],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.22),
                Colors.white.withValues(alpha: 0.08),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SeasonIcon extends StatelessWidget {
  const _SeasonIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Icon(icon, size: 20, color: color),
    );
  }
}

class _SeasonArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFB8C4B0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.08, h * 0.85);
    path.quadraticBezierTo(w * 0.5, h * 0.05, w * 0.92, h * 0.85);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

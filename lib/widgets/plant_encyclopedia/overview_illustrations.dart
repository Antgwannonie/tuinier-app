import 'package:flutter/material.dart';

/// Watercolor iconen voor het overzicht-tabblad (hergebruikt tab-iconen waar passend).
abstract final class OverviewAssets {
  static const standplaats = 'assets/images/plant_info_tabs/tab_standplaats.png';
  static const water = 'assets/images/plant_info_tabs/tab_water.png';
  static const moeilijkheid = 'assets/images/overview/overview_moeilijkheid.png';
  static const levensduur = 'assets/images/plant_info_tabs/tab_groei.png';
  static const samenvatting = 'assets/images/plant_info_tabs/tab_weetjes.png';
  static const momenten = 'assets/images/overview/overview_calendar.png';
  static const zaaien = 'assets/images/plant_info_tabs/tab_zaaien.png';
  static const uitplanten = 'assets/images/plant_info_tabs/tab_uitplanten.png';
  static const bloei = 'assets/images/plant_info_tabs/tab_bloei.png';
  static const oogsten = 'assets/images/plant_info_tabs/tab_oogsten.png';
  static const info = 'assets/images/overview/overview_info.png';
  static const groei = 'assets/images/plant_info_tabs/tab_groei.png';
  static const weetjes = 'assets/images/plant_info_tabs/tab_weetjes.png';
  static const voeding = 'assets/images/plant_info_tabs/tab_voeding.png';
  static const locatie = 'assets/images/plant_info_tabs/tab_standplaats.png';
  static const ruimte = 'assets/images/plant_info_tabs/tab_combinatie.png';
  static const oogstTijd = 'assets/images/plant_info_tabs/tab_oogsten.png';
  static const opbrengst = 'assets/images/plant_info_tabs/tab_oogsten.png';
}

class OverviewIcon extends StatelessWidget {
  const OverviewIcon({
    super.key,
    required this.asset,
    this.size = 28,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => Icon(
        Icons.eco_rounded,
        size: size * 0.85,
        color: const Color(0xFF43A047),
      ),
    );
  }
}

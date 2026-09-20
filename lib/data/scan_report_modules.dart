import 'package:flutter/material.dart';

import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../theme/tuinier_colors.dart';

/// Minimale zekerheid voordat een analysekaart wordt getoond.
const int kScanSectionConfidenceThreshold = 80;

/// Maximaal aantal kaarten per scan (inclusief vaste onderdelen).
const int kScanReportMaxCards = 10;

/// Maximaal aantal optionele kaarten (naast samenvatting, coach, weetje).
const int kScanReportMaxOptionalCards = 7;

/// Vaste volgorde van rapportsecties (1–21).
enum ScanReportSectionId {
  summary(1),
  health(2),
  growth(3),
  growthPhase(4),
  scanComparison(5),
  flowering(6),
  fruits(7),
  leaves(8),
  pests(9),
  diseases(10),
  environment(11),
  strengths(12),
  attention(13),
  pruning(14),
  tasks(15),
  harvestForecast(16),
  season(17),
  weekFocus(18),
  outlook(19),
  coach(20),
  didYouKnow(21);

  const ScanReportSectionId(this.order);
  final int order;

  /// Altijd zichtbaar in het rapport (AI moet inhoud leveren).
  bool get isCoreSection =>
      this == ScanReportSectionId.summary ||
      this == ScanReportSectionId.health ||
      this == ScanReportSectionId.growth ||
      this == ScanReportSectionId.growthPhase ||
      this == ScanReportSectionId.scanComparison ||
      this == ScanReportSectionId.environment ||
      this == ScanReportSectionId.strengths ||
      this == ScanReportSectionId.attention ||
      this == ScanReportSectionId.tasks ||
      this == ScanReportSectionId.harvestForecast ||
      this == ScanReportSectionId.season ||
      this == ScanReportSectionId.weekFocus ||
      this == ScanReportSectionId.coach ||
      this == ScanReportSectionId.didYouKnow ||
      this == ScanReportSectionId.pests;

  /// Alleen tonen als zichtbaar/relevant op de foto (confidence ≥ drempel).
  bool get isOptionalSection => !isCoreSection;
}

/// Status-tegel in de horizontale rij «Belangrijkste status».
class ScanStatusTile {
  const ScanStatusTile({
    required this.label,
    required this.value,
    required this.status,
    required this.icon,
    required this.percent,
    this.iconColor,
    this.ringColor,
  });

  final String label;
  final String value;
  final String status;
  final int percent;
  final IconData icon;
  final Color? iconColor;
  final Color? ringColor;
}

/// Eén stap in een scan-taak.
class ScanTaskStep {
  const ScanTaskStep({required this.title, this.detail});

  final String title;
  final String? detail;
}

/// Taak in de lijst «Aanbevolen taken».
class ScanTaskItem {
  ScanTaskItem({
    required this.title,
    required this.priority,
    this.summary,
    this.description,
    this.steps = const [],
    this.timeline = 'Deze week',
    this.icon = Icons.task_alt_outlined,
  });

  final String title;
  /// Waarom deze taak nu nodig is (AI).
  final String? summary;
  final String? description;
  final List<ScanTaskStep> steps;
  final AiPriority priority;
  final String timeline;
  final IconData icon;

  String get whyText {
    final s = summary?.trim();
    if (s != null && s.isNotEmpty) return s;
    final d = description?.trim();
    if (d != null && d.isNotEmpty) return d;
    return 'Deze taak helpt je plant gezond te houden en verder te laten groeien.';
  }
}

/// Let-op / plantinfo-item in het scanresultaat.
class ScanInfoItem {
  ScanInfoItem({
    required this.title,
    required this.summary,
    this.steps = const [],
    this.icon = Icons.info_outline,
    this.taskId,
  });

  final String title;
  final String summary;
  final List<ScanTaskStep> steps;
  final IconData icon;
  final String? taskId;

  String get bodyText => summary.trim();
}

/// Observatiekaart «AI Observaties».
class ScanCoachObservation {
  const ScanCoachObservation({
    required this.title,
    required this.description,
    required this.scorePercent,
    required this.icon,
    this.iconColor,
    this.isWarning = false,
    this.showScoreRing = true,
  });

  final String title;
  final String description;
  final int scorePercent;
  final IconData icon;
  final Color? iconColor;
  /// Oranje/rode achtergrond voor aandachtspunten.
  final bool isWarning;
  /// Scorecirkel tonen (uit bij vaste oogst-samenvatting).
  final bool showScoreRing;

  /// Backward compat.
  String get subtitle => description;
}

String observationScoreLabel(int score) {
  if (score >= 90) return 'Uitstekend';
  if (score >= 75) return 'Goed';
  if (score >= 60) return 'Aandachtspunt';
  if (score >= 40) return 'Probleem aanwezig';
  return 'Ernstig probleem';
}

Color observationScoreColor(int score) {
  if (score >= 75) return const Color(0xFF15803D);
  if (score >= 60) return const Color(0xFFCA8A04);
  if (score >= 40) return const Color(0xFFEA580C);
  return const Color(0xFFDC2626);
}

final _countdownDaysPattern = RegExp(r'±\d+ dagen');

/// Oogst-/bloei-dagen (±N dagen) vet in observatietekst.
Widget observationDescriptionText(
  String description, {
  double fontSize = 12,
  double height = 1.35,
}) {
  final baseStyle = TextStyle(
    fontSize: fontSize,
    height: height,
    color: TuinierColors.textSecondary,
  );
  final boldStyle = baseStyle.copyWith(
    fontWeight: FontWeight.w800,
    color: TuinierColors.textPrimary,
  );

  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in _countdownDaysPattern.allMatches(description)) {
    if (match.start > cursor) {
      spans.add(TextSpan(text: description.substring(cursor, match.start)));
    }
    spans.add(TextSpan(text: match.group(0), style: boldStyle));
    cursor = match.end;
  }
  if (cursor < description.length) {
    spans.add(TextSpan(text: description.substring(cursor)));
  }

  if (spans.isEmpty) {
    return Text(description, style: baseStyle);
  }

  return Text.rich(
    TextSpan(style: baseStyle, children: spans),
  );
}

/// Kaart «Verandering met vorige scan».
class ScanChangeCard {
  const ScanChangeCard({
    required this.category,
    required this.status,
    required this.detail,
    required this.previousLabel,
    required this.icon,
    this.improved = true,
  });

  final String category;
  final String status;
  final String detail;
  final String previousLabel;
  final IconData icon;
  final bool improved;
}

/// Volledige layout voor het AI-scanrapport (mockup-structuur).
class ScanReportLayout {
  const ScanReportLayout({
    required this.summary,
    required this.priority,
    required this.statusHeadline,
    required this.scoreCards,
    required this.progressTitle,
    required this.progressBody,
    required this.progressBullets,
    required this.tasks,
    required this.infoItems,
    required this.coachObservations,
    required this.changeCards,
    required this.coachTip,
    required this.fullAnalysisSections,
  });

  final String summary;
  final AiPriority priority;
  final String statusHeadline;
  final List<ScanStatusTile> scoreCards;
  final String progressTitle;
  final String progressBody;
  final List<String> progressBullets;
  final List<ScanTaskItem> tasks;
  final List<ScanInfoItem> infoItems;
  final List<ScanCoachObservation> coachObservations;
  final List<ScanChangeCard> changeCards;
  final String coachTip;
  final List<DynamicScanSection> fullAnalysisSections;
}

/// Zekerheid per analysemodule (0–100), van de AI.
class ScanModuleConfidence {
  const ScanModuleConfidence({
    this.health,
    this.growth,
    this.growthPhase,
    this.scanComparison,
    this.flowering,
    this.fruits,
    this.leaves,
    this.pests,
    this.diseases,
    this.environment,
    this.strengths,
    this.attention,
    this.pruning,
    this.tasks,
    this.harvestForecast,
    this.season,
    this.weekFocus,
    this.outlook,
  });

  final int? health;
  final int? growth;
  final int? growthPhase;
  final int? scanComparison;
  final int? flowering;
  final int? fruits;
  final int? leaves;
  final int? pests;
  final int? diseases;
  final int? environment;
  final int? strengths;
  final int? attention;
  final int? pruning;
  final int? tasks;
  final int? harvestForecast;
  final int? season;
  final int? weekFocus;
  final int? outlook;

  int? forSection(ScanReportSectionId id) {
    switch (id) {
      case ScanReportSectionId.summary:
        return 100;
      case ScanReportSectionId.health:
        return health;
      case ScanReportSectionId.growth:
        return growth;
      case ScanReportSectionId.growthPhase:
        return growthPhase;
      case ScanReportSectionId.scanComparison:
        return scanComparison;
      case ScanReportSectionId.flowering:
        return flowering;
      case ScanReportSectionId.fruits:
        return fruits;
      case ScanReportSectionId.leaves:
        return leaves;
      case ScanReportSectionId.pests:
        return pests;
      case ScanReportSectionId.diseases:
        return diseases;
      case ScanReportSectionId.environment:
        return environment;
      case ScanReportSectionId.strengths:
        return strengths;
      case ScanReportSectionId.attention:
        return attention;
      case ScanReportSectionId.pruning:
        return pruning;
      case ScanReportSectionId.tasks:
        return tasks;
      case ScanReportSectionId.harvestForecast:
        return harvestForecast;
      case ScanReportSectionId.season:
        return season;
      case ScanReportSectionId.weekFocus:
        return weekFocus;
      case ScanReportSectionId.outlook:
        return outlook;
      case ScanReportSectionId.coach:
      case ScanReportSectionId.didYouKnow:
        return 100;
    }
  }

  factory ScanModuleConfidence.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ScanModuleConfidence();
    int? i(String key) => (json[key] as num?)?.toInt()?.clamp(0, 100);
    return ScanModuleConfidence(
      health: i('health'),
      growth: i('growth'),
      growthPhase: i('growthPhase'),
      scanComparison: i('scanComparison'),
      flowering: i('flowering'),
      fruits: i('fruits'),
      leaves: i('leaves'),
      pests: i('pests'),
      diseases: i('diseases'),
      environment: i('environment'),
      strengths: i('strengths'),
      attention: i('attention'),
      pruning: i('pruning'),
      tasks: i('tasks'),
      harvestForecast: i('harvestForecast'),
      season: i('season'),
      weekFocus: i('weekFocus'),
      outlook: i('outlook'),
    );
  }

  Map<String, dynamic> toJson() => {
        if (health != null) 'health': health,
        if (growth != null) 'growth': growth,
        if (growthPhase != null) 'growthPhase': growthPhase,
        if (scanComparison != null) 'scanComparison': scanComparison,
        if (flowering != null) 'flowering': flowering,
        if (fruits != null) 'fruits': fruits,
        if (leaves != null) 'leaves': leaves,
        if (pests != null) 'pests': pests,
        if (diseases != null) 'diseases': diseases,
        if (environment != null) 'environment': environment,
        if (strengths != null) 'strengths': strengths,
        if (attention != null) 'attention': attention,
        if (pruning != null) 'pruning': pruning,
        if (tasks != null) 'tasks': tasks,
        if (harvestForecast != null) 'harvestForecast': harvestForecast,
        if (season != null) 'season': season,
        if (weekFocus != null) 'weekFocus': weekFocus,
        if (outlook != null) 'outlook': outlook,
      };
}

/// Eén kaart in het dynamische scanrapport.
class DynamicScanSection {
  const DynamicScanSection({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
    this.confidence,
    this.highlight = false,
    this.bullets = const [],
    this.priority,
    this.subtitle,
  });

  final ScanReportSectionId id;
  final String title;
  final String body;
  final IconData icon;
  final int? confidence;
  final bool highlight;
  final List<String> bullets;
  final AiPriority? priority;
  final String? subtitle;
}

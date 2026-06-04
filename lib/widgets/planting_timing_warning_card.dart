import 'package:flutter/material.dart';

import '../data/planting_timing_advice.dart';
import 'collapsible_garden_warning.dart';

/// Seizoens-/plantdatum-melding op het detailscherm (licht geel, inklapbaar).
class PlantingTimingWarningCard extends StatelessWidget {
  const PlantingTimingWarningCard({
    super.key,
    required this.assessment,
  });

  final PlantingTimingAssessment assessment;

  @override
  Widget build(BuildContext context) {
    final isUnknown = assessment.status == PlantingTimingStatus.unknownDate;
    final isWarn = assessment.hasWarnings;
    final lines = [
      ...assessment.warningLines,
      if (!isWarn) ...assessment.infoLines,
    ];
    final title = isWarn
        ? 'Seizoenswaarschuwing'
        : isUnknown
            ? 'Zaaidatum onbekend'
            : 'Plant- en oogstseizoen';

    return CollapsibleGardenWarning(
      title: title,
      icon: isWarn
          ? Icons.warning_amber_rounded
          : isUnknown
              ? Icons.help_outline
              : Icons.event_available_outlined,
      subtitle: lines.isNotEmpty ? lines.first : null,
      bodyLines: lines,
      footer: assessment.alternativeLabel != null
          ? 'Alternatief\n${assessment.alternativeLabel}'
          : null,
      initiallyExpanded: isWarn || isUnknown,
      tone: isWarn ? GardenNoticeTone.warning : GardenNoticeTone.neutral,
    );
  }
}

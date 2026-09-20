import 'package:flutter/material.dart';

import '../../data/mushroom_info_layout.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'plant_info_category_tab_bar.dart';

/// Rendert paddenstoel-info secties als kaarten (volle/halve breedte).
class MushroomInfoGuideView extends StatelessWidget {
  const MushroomInfoGuideView({super.key, required this.guide});

  final MushroomInfoGuide guide;

  static const _halfWidthBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    final sections =
        guide.sections.where((s) => s.body.trim().isNotEmpty).toList();
    if (sections.isEmpty) {
      return const Text(
        'Geen inhoud voor dit onderwerp.',
        style: TextStyle(color: Color(0xFF6B7280)),
      );
    }

    final maxWidth = MediaQuery.sizeOf(context).width - 32;
    final allowHalf = maxWidth >= _halfWidthBreakpoint;

    final rows = <List<MushroomInfoSection>>[];
    var i = 0;
    while (i < sections.length) {
      final current = sections[i];
      if (allowHalf &&
          !current.prefersFullWidth &&
          i + 1 < sections.length &&
          !sections[i + 1].prefersFullWidth) {
        rows.add([current, sections[i + 1]]);
        i += 2;
      } else {
        rows.add([current]);
        i += 1;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 12),
          _MushroomInfoRow(sections: rows[r]),
        ],
      ],
    );
  }
}

class _MushroomInfoRow extends StatelessWidget {
  const _MushroomInfoRow({required this.sections});

  final List<MushroomInfoSection> sections;

  @override
  Widget build(BuildContext context) {
    if (sections.length == 1) {
      return MushroomInfoSectionCard(section: sections.first);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: MushroomInfoSectionCard(section: sections[i])),
          ],
        ],
      ),
    );
  }
}

class MushroomInfoSectionCard extends StatelessWidget {
  const MushroomInfoSectionCard({super.key, required this.section});

  final MushroomInfoSection section;

  @override
  Widget build(BuildContext context) {
    return PlantInfoBlockCard(
      block: PlantInfoBlock(
        title: section.title,
        body: section.body,
        isWarning: section.isWarning,
      ),
    );
  }
}

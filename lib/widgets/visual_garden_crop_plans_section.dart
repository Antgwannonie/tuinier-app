import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/vegetable_repository.dart';
import '../data/visual_garden_bed_colors.dart';
import '../models/visual_garden_plan.dart';
import '../theme/tuinier_colors.dart';

/// Teeltplannen in mockup-stijl: horizontale kaarten + suggest-banner.
class VisualGardenCropPlansSection extends StatelessWidget {
  const VisualGardenCropPlansSection({
    super.key,
    required this.bed,
    required this.repository,
    required this.onOpenPlan,
    required this.onAddPlan,
    required this.onSuggestNext,
    required this.onDeletePlan,
  });

  final VisualGardenBed bed;
  final VegetableRepository repository;
  final ValueChanged<VisualCropPlan> onOpenPlan;
  final VoidCallback onAddPlan;
  final VoidCallback onSuggestNext;
  final ValueChanged<VisualCropPlan> onDeletePlan;

  @override
  Widget build(BuildContext context) {
    final plans = bed.cropPlansSorted;
    final activeId = bed.activeCropPlan?.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Mijn teeltplannen',
          style: GoogleFonts.fraunces(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            color: VisualGardenBedColors.titleGreen,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 118,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (var i = 0; i < plans.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                _CropPlanCard(
                  index: i + 1,
                  plan: plans[i],
                  active: plans[i].id == activeId,
                  onTap: () => onOpenPlan(plans[i]),
                  onLongPress: plans.length > 1
                      ? () => onDeletePlan(plans[i])
                      : null,
                ),
              ],
              const SizedBox(width: 10),
              _NewCropPlanCard(onTap: onAddPlan),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _SuggestNextBanner(onTap: onSuggestNext),
      ],
    );
  }
}

class _CropPlanCard extends StatelessWidget {
  const _CropPlanCard({
    required this.index,
    required this.plan,
    required this.active,
    required this.onTap,
    this.onLongPress,
  });

  final int index;
  final VisualCropPlan plan;
  final bool active;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 148,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active
                  ? VisualGardenBedColors.titleGreen
                  : TuinierColors.border,
              width: active ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active
                          ? VisualGardenBedColors.titleGreen
                          : const Color(0xFF3F6B42),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      plan.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                plan.seasonLabel ??
                    VisualCropPlan.seasonForMonth(plan.startDate.month),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: TuinierColors.textSecondary,
                ),
              ),
              Text(
                plan.placements.isEmpty
                    ? 'Nog geen planten'
                    : '${plan.placements.length} plant'
                        '${plan.placements.length == 1 ? '' : 'en'}',
                style: const TextStyle(
                  fontSize: 11,
                  color: TuinierColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: active
                      ? VisualGardenBedColors.softGreen
                      : const Color(0xFFF0F1EE),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  active ? 'Actief' : 'Gepland',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: active
                        ? VisualGardenBedColors.titleGreen
                        : TuinierColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewCropPlanCard extends StatelessWidget {
  const _NewCropPlanCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFAFBF8),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          painter: _DashedRRectPainter(
            color: TuinierColors.border,
            radius: 16,
          ),
          child: SizedBox(
            width: 148,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: VisualGardenBedColors.softGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_rounded,
                      color: VisualGardenBedColors.titleGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nieuw teeltplan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: VisualGardenBedColors.titleGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Voeg een volgende teelt toe',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: TuinierColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestNextBanner extends StatelessWidget {
  const _SuggestNextBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F0),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: VisualGardenBedColors.softGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  color: VisualGardenBedColors.titleGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welke teelt past hierna?',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: VisualGardenBedColors.titleGreen,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Slimme opvolgteelt: zie wat je kunt zaaien of planten na dit teeltplan.',
                      style: TextStyle(
                        fontSize: 11,
                        color: TuinierColors.textSecondary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: VisualGardenBedColors.titleGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      const dash = 5.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

/// Dialog om een nieuw teeltplan te maken (alleen naam).
///
/// Geen start-/einddatum hier: planten worden per soort klaar — bij
/// plant toevoegen filter je op oogstdatum van eerdere planten.
Future<VisualCropPlan?> showCreateCropPlanDialog({
  required BuildContext context,
  VisualCropPlan? afterPlan,
  int planNumber = 1,
}) async {
  final nameCtrl = TextEditingController(text: 'Teeltplan $planNumber');
  // Stille defaults voor opslag/taken; periode volgt later uit de planten.
  final start = afterPlan?.endDateOnly.add(const Duration(days: 1)) ??
      DateTime(DateTime.now().year, DateTime.now().month, 1);
  var end = DateTime(start.year, start.month + 3, 0);
  if (end.isBefore(start)) {
    end = start.add(const Duration(days: 90));
  }

  final result = await showDialog<VisualCropPlan>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: const Text('Nieuw teeltplan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF6EE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: VisualGardenBedColors.titleGreen
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: const Text(
                  'Wat is een teeltplan?\n\n'
                  'De bak blijft hetzelfde; een teeltplan is een volgende '
                  'ronde planten op dezelfde plek.\n\n'
                  'Niet elke plant is tegelijk klaar — daarom kies je hier '
                  'geen vaste datum. Bij “Plant toevoegen” filter je op '
                  'wanneer een eerdere plant geoogst is, zodat je precies '
                  'die plek opnieuw kunt benutten.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: TuinierColors.textPrimary,
                  ),
                ),
              ),
              if (afterPlan != null) ...[
                const SizedBox(height: 12),
                Text(
                  afterPlan.placements.isEmpty
                      ? 'Volgt op “${afterPlan.name}”.'
                      : 'Volgt op “${afterPlan.name}” '
                          '(${afterPlan.placements.length} plant'
                          '${afterPlan.placements.length == 1 ? '' : 'en'}). '
                          'Bij toevoegen kies je na welke oogst er plek is.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: TuinierColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Naam',
                  hintText: 'Zomerteelt',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(
                ctx,
                VisualCropPlan(
                  id: 'crop_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  startDate: start,
                  endDate: end,
                  seasonLabel: VisualCropPlan.seasonForMonth(start.month),
                  placements: const [],
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2F6B32),
            ),
            child: const Text('Maak teeltplan'),
          ),
        ],
      );
    },
  );
  nameCtrl.dispose();
  return result;
}
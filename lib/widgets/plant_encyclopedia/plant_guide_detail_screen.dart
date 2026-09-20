import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_guide_detail.dart';

const _guideDetailGreen = Color(PlantDetailDesign.primaryGreen);

/// Groene, klikbare “Meer info”-footer (volle breedte).
/// Gebruik overal dezelfde knop zodat Zaaien/Uitplanten/etc. gelijk ogen.
class GuideMeerInfoFooter extends StatelessWidget {
  const GuideMeerInfoFooter({
    super.key,
    this.compact = false,
    this.margin = const EdgeInsets.only(top: 8),
  });

  /// Compacte variant voor kleine tegels (water/voeding-grid).
  final bool compact;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final labelStyle = (compact ? t.labelSmall : t.labelMedium)?.copyWith(
      fontWeight: FontWeight.w700,
      color: _guideDetailGreen,
    );

    return Container(
      width: double.infinity,
      margin: margin,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 6 : 9,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(compact ? 8 : 10),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Meer info',
              textAlign: compact ? TextAlign.center : TextAlign.start,
              style: labelStyle,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: compact ? 11 : 14,
            color: _guideDetailGreen,
          ),
        ],
      ),
    );
  }
}

/// Generieke detailpagina: titel + samenvatting + blokken (waarom/hoe/tips).
class PlantGuideDetailScreen extends StatelessWidget {
  const PlantGuideDetailScreen({
    super.key,
    required this.title,
    this.summary,
    required this.blocks,
    this.leading,
  });

  final String title;
  final String? summary;
  final List<PlantGuideDetailBlock> blocks;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final summaryText = summary?.trim() ?? '';
    final firstBody = blocks.isNotEmpty ? blocks.first.body.trim() : '';
    // Geen dubbele intro: kaarttekst niet herhalen als die al in het eerste blok staat.
    final showSummary = summaryText.isNotEmpty &&
        summaryText.toLowerCase() != firstBody.toLowerCase();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(PlantDetailDesign.textPrimary),
        elevation: 0,
        title: Text(
          title,
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _guideDetailGreen,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(height: 16),
          ],
          if (showSummary) ...[
            Text(
              summaryText,
              style: t.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
            const SizedBox(height: 20),
          ],
          for (final block in blocks) ...[
            Text(
              block.heading,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: _guideDetailGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              block.body,
              style: t.textTheme.bodyMedium?.copyWith(
                height: 1.55,
                fontSize: 14,
                color: const Color(PlantDetailDesign.textPrimary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

/// Tikbare kaart als er detailblokken zijn.
///
/// [meerInfoInCard] zet de knop in een card-achtige footer onder de inhoud
/// (binnen dezelfde tikbare kaart).
Widget wrapGuideDetailCard({
  required BuildContext context,
  required String title,
  String? summary,
  required List<PlantGuideDetailBlock> details,
  required Widget child,
  Widget? leading,
  /// Toont de groene “Meer info”-footer onder de inhoud (standaard aan).
  bool showMeerInfo = true,
}) {
  if (title.isEmpty || details.isEmpty) {
    return child;
  }

  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PlantGuideDetailScreen(
              title: title,
              summary: summary,
              blocks: details,
              leading: leading,
            ),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          if (showMeerInfo) const GuideMeerInfoFooter(),
        ],
      ),
    ),
  );
}

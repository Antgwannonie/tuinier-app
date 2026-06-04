import 'package:flutter/material.dart';

import '../data/vegetable_image_info.dart';
import '../models/plant_image_frame_prefs.dart';

/// Plantfoto in kaartkader met opgeslagen zoom / positie / fit.
class PlantCardFramedImage extends StatelessWidget {
  const PlantCardFramedImage({
    super.key,
    required this.assetPath,
    required this.frame,
    this.expand = false,
    this.height,
  });

  final String assetPath;
  final PlantImageFramePrefs frame;
  final bool expand;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final bg = Color(frame.backgroundArgb);
    // Vult Zoeken-kaart; contain gaf blauwe balken bij te brede PNG.
    final fit = frame.isNearDefaults() && frame.boxFit == PlantImageBoxFit.contain
        ? BoxFit.cover
        : plantImageBoxFitToFlutter(frame.boxFit);

    final image = Image.asset(
      assetPath,
      fit: fit,
      alignment: Alignment(
        frame.alignX.clamp(-1.0, 1.0),
        frame.alignY.clamp(-1.0, 1.0),
      ),
      width: expand ? double.infinity : null,
      height: expand ? double.infinity : height,
      filterQuality: FilterQuality.medium,
    );

    Widget content = ColoredBox(
      color: bg,
      child: ClipRect(
        child: Transform.scale(
          scale: frame.scale.clamp(0.25, 4.0),
          alignment: Alignment(
            frame.alignX.clamp(-1.0, 1.0),
            frame.alignY.clamp(-1.0, 1.0),
          ),
          child: image,
        ),
      ),
    );

    if (expand) {
      return SizedBox.expand(child: content);
    }
    return SizedBox(
      width: double.infinity,
      height: height,
      child: content,
    );
  }
}

/// Preview met zelfde verhouding als Zoeken-fotovlak.
class PlantCardFramePreview extends StatelessWidget {
  const PlantCardFramePreview({
    super.key,
    required this.assetPath,
    required this.frame,
    this.footerHeight = 52,
  });

  final String assetPath;
  final PlantImageFramePrefs frame;
  final double footerHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final cardH = w / kAtlasSearchCardGridAspectRatio;
        final imageH = cardH - footerHeight;

        return SizedBox(
          height: cardH,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageH.clamp(80, cardH),
                child: PlantCardFramedImage(
                  assetPath: assetPath,
                  frame: frame,
                  expand: true,
                ),
              ),
              SizedBox(
                height: footerHeight,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Nu planten',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

import '../data/plant_scan_photo_store.dart';
import '../data/vegetable_image_info.dart';
import '../models/vegetable.dart';
import 'plant_card_framed_image.dart';
import 'plant_image_frame_scope.dart';
import 'scan_photo_viewer.dart';

/// Grote coverfoto voor plantkaarten in het raster.
class VegetableHeroImage extends StatelessWidget {
  const VegetableHeroImage({
    super.key,
    required this.vegetable,
    this.height = 120,
    this.expand = false,
    this.scanPhotoPath,
    this.borderRadius = const BorderRadius.vertical(top: Radius.circular(14)),
    /// Zoek-atlas en detailpagina: lokaal icoon / illustratie i.p.v. emoji.
    this.useAtlasIllustration = false,
  });

  final Vegetable vegetable;
  final double? height;
  final bool expand;
  final String? scanPhotoPath;
  final BorderRadius borderRadius;
  final bool useAtlasIllustration;

  static const _greenBg = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final frameStore = PlantImageFrameScope.maybeOf(context);
    if (frameStore != null) {
      return ListenableBuilder(
        listenable: frameStore,
        builder: (context, _) => _buildHero(context),
      );
    }
    return _buildHero(context);
  }

  Widget _buildHero(BuildContext context) {
    final info = vegetableImageFor(vegetable.id);
    final cs = Theme.of(context).colorScheme;
    final bg = _backgroundFor(info, cs);
    final image = _buildImage(context, info, bg);

    final child = expand
        ? SizedBox.expand(child: image)
        : SizedBox(
            height: height,
            width: double.infinity,
            child: image,
          );

    final freeAtlas =
        expand && useAtlasIllustration && info.transparentAsset;
    if (freeAtlas) {
      return child;
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: child,
    );
  }

  Color _backgroundFor(VegetableImageInfo info, ColorScheme cs) {
    if (useAtlasIllustration && info.transparentAsset) {
      return Colors.transparent;
    }
    if (useAtlasIllustration && info.assetPath != null) {
      return cs.surfaceContainerLow;
    }
    return info.greenBackground ? _greenBg : Colors.white;
  }

  Widget _buildImage(BuildContext context, VegetableImageInfo info, Color bg) {
    if (PlantScanPhotoStore.exists(scanPhotoPath)) {
      final fileImage = Image.file(
        File(scanPhotoPath!),
        fit: BoxFit.cover,
        width: expand ? double.infinity : null,
        height: expand ? double.infinity : height,
        errorBuilder: (_, __, ___) => _stockOrEmoji(context, info, bg),
      );
      return Builder(
        builder: (context) => GestureDetector(
          onTap: () => showScanPhotoViewer(context, scanPhotoPath!),
          child: fileImage,
        ),
      );
    }
    return _stockOrEmoji(context, info, bg);
  }

  Widget _stockOrEmoji(
    BuildContext context,
    VegetableImageInfo info,
    Color bg,
  ) {
    if (useAtlasIllustration) {
      if (!kAtlasIconsForAllPlants && info.assetPath == null) {
        return _emojiBox(info, bg, expand);
      }
      if (info.assetPath != null) {
        final frameStore = PlantImageFrameScope.maybeOf(context);
        if (frameStore != null && info.atlasCardCover) {
          return _illustrationBox(
            context,
            PlantCardFramedImage(
              assetPath: info.assetPath!,
              frame: frameStore.prefsFor(vegetable.id),
              expand: expand,
              height: height,
            ),
            bg,
            info: info,
            skipCardCoverWrapper: true,
          );
        }

        final cardCover = info.atlasCardCover;
        final alignment = Alignment(0, info.atlasCardAlignY);
        final fit = cardCover
            ? (info.atlasCardPrecropped ? BoxFit.contain : BoxFit.cover)
            : BoxFit.contain;

        return _illustrationBox(
          context,
          Image.asset(
            info.assetPath!,
            fit: fit,
            alignment: cardCover && !info.atlasCardPrecropped
                ? alignment
                : Alignment.center,
            width: cardCover ? double.infinity : null,
            height: cardCover ? double.infinity : null,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => _emojiBox(info, bg, expand),
          ),
          bg,
          info: info,
        );
      }
      return _emojiBox(info, bg, expand);
    }

    if (info.imageUrl != null) {
      return Image.network(
        info.imageUrl!,
        fit: BoxFit.cover,
        width: expand ? double.infinity : null,
        height: expand ? double.infinity : height,
        errorBuilder: (_, __, ___) => _emojiBox(info, bg, expand),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _emojiBox(info, bg, expand);
        },
      );
    }
    return _emojiBox(info, bg, expand);
  }

  Widget _illustrationBox(
    BuildContext context,
    Widget image,
    Color bg, {
    required VegetableImageInfo info,
    bool skipCardCoverWrapper = false,
  }) {
    final transparent = info.transparentAsset;
    final scale = info.atlasIllustrationScale;
    final cardCover = info.atlasCardCover;

    Widget content = image;
    if (transparent) {
      content = _atlasTransparentLayout(
        context: context,
        plant: image,
        scale: scale,
        groundShadow: info.atlasGroundShadow,
        recessDisc: info.atlasRecessDisc,
      );
    } else if (scale > 1.0 && !cardCover) {
      content = Transform.scale(scale: scale, child: image);
    }

    if (cardCover && !skipCardCoverWrapper) {
      final skyBg = info.atlasCardPrecropped
          ? const Color(0xFF8EC8E8)
          : bg;
      final framed = ColoredBox(color: skyBg, child: content);
      return expand
          ? SizedBox.expand(child: framed)
          : SizedBox(
              width: double.infinity,
              height: height,
              child: framed,
            );
    }

    if (skipCardCoverWrapper) {
      return expand
          ? SizedBox.expand(child: content)
          : SizedBox(
              width: double.infinity,
              height: height,
              child: content,
            );
    }

    final padded = Padding(
      padding: EdgeInsets.fromLTRB(
        transparent ? 0 : 8,
        transparent ? 0 : 8,
        transparent ? 0 : 8,
        transparent ? 28 : 8,
      ),
      child: Center(child: content),
    );

    if (transparent) {
      return padded;
    }

    return ColoredBox(
      color: bg,
      child: padded,
    );
  }

  /// Alleen tekening + optionele grondschaduw (zoals atlas-referentie).
  Widget _atlasTransparentLayout({
    required BuildContext context,
    required Widget plant,
    required double scale,
    required bool groundShadow,
    required bool recessDisc,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final cs = Theme.of(context).colorScheme;
        final discSize = w * 0.88;
        final discColor = Color.alphaBlend(
          Colors.black.withValues(alpha: 0.38),
          cs.surfaceContainerLow,
        );

        return Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            if (recessDisc)
              Align(
                alignment: const Alignment(0, 0.48),
                child: Container(
                  width: discSize,
                  height: discSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: discColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            if (groundShadow && !recessDisc)
              Align(
                alignment: const Alignment(0, 0.78),
                child: Container(
                  width: w * 0.52,
                  height: h * 0.09,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: RadialGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, h * 0.02, 0, h * 0.08),
                child: Transform.scale(
                  scale: scale.clamp(1.05, 1.55),
                  child: SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      alignment: const Alignment(0, 0.2),
                      child: plant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _emojiBox(VegetableImageInfo info, Color bg, bool fill) {
    return ColoredBox(
      color: bg,
      child: Center(
        child: Text(info.emoji, style: TextStyle(fontSize: fill ? 56 : 48)),
      ),
    );
  }
}

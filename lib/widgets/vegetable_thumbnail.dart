import 'package:flutter/material.dart';

import '../data/vegetable_image_info.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';

/// Foto of emoji op groene of witte achtergrond.
class VegetableThumbnail extends StatelessWidget {
  const VegetableThumbnail({
    super.key,
    required this.vegetable,
    this.size = 56,
    this.borderRadius = 12,
  });

  const VegetableThumbnail.large({
    super.key,
    required this.vegetable,
    this.size = 200,
    this.borderRadius = 16,
  });

  final Vegetable vegetable;
  final double size;
  final double borderRadius;

  static const _greenBg = TuinierColors.cardTintGreen;

  @override
  Widget build(BuildContext context) {
    final info = vegetableImageFor(vegetable.id);

    if (info.transparentAsset && info.assetPath != null) {
      return SizedBox(
        width: size,
        height: size,
        child: _thumbnailImage(context, info, BoxFit.contain),
      );
    }

    final bg = info.greenBackground ? _greenBg : TuinierColors.card;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: TuinierColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: _thumbnailImage(context, info, BoxFit.cover),
    );
  }

  Widget _thumbnailImage(
    BuildContext context,
    VegetableImageInfo info,
    BoxFit fit,
  ) {
    if (info.assetPath != null) {
      final scale = info.thumbnailScale;
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final cachePx = (size * dpr * scale).round().clamp(128, 1024);
      final image = Image.asset(
        info.assetPath!,
        width: size,
        height: size,
        fit: fit,
        cacheWidth: cachePx,
        cacheHeight: cachePx,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (_, __, ___) => _emojiFallback(info, null),
      );
      if (scale <= 1.0) return image;
      return Transform.scale(scale: scale, child: image);
    }
    if (info.imageUrl != null) {
      return Image.network(
        info.imageUrl!,
        width: size,
        height: size,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _emojiFallback(info, progress);
        },
        errorBuilder: (_, __, ___) => _emojiFallback(info, null),
      );
    }
    return _emojiFallback(info, null);
  }

  Widget _emojiFallback(VegetableImageInfo info, ImageChunkEvent? progress) {
    return Center(
      child: progress != null
          ? SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TuinierColors.midGreen,
              ),
            )
          : Text(
              info.emoji,
              style: TextStyle(fontSize: size * 0.45),
            ),
    );
  }
}

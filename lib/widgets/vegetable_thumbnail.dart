import 'package:flutter/material.dart';

import '../data/vegetable_image_info.dart';
import '../models/vegetable.dart';

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

  static const _greenBg = Color(0xFFE8F5E9);

  @override
  Widget build(BuildContext context) {
    final info = vegetableImageFor(vegetable.id);
    final bg = info.greenBackground ? _greenBg : Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: info.imageUrl != null
          ? Image.network(
              info.imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return _emojiFallback(info, progress);
              },
              errorBuilder: (_, __, ___) => _emojiFallback(info, null),
            )
          : _emojiFallback(info, null),
    );
  }

  Widget _emojiFallback(VegetableImageInfo info, ImageChunkEvent? progress) {
    return Center(
      child: progress != null
          ? SizedBox(
              width: size * 0.35,
              height: size * 0.35,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.green.shade700,
              ),
            )
          : Text(
              info.emoji,
              style: TextStyle(fontSize: size * 0.45),
            ),
    );
  }
}

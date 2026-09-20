import 'dart:collection';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

/// Verwijdert wit/grijs/schaakbord uit plant-PNG's.
class GardenHealthImageProcessor {
  GardenHealthImageProcessor._();

  static final _cache = <String, Uint8List>{};

  static Future<Uint8List?> processedAssetBytes(String assetPath) async {
    if (_cache.containsKey(assetPath)) return _cache[assetPath];

    try {
      final raw = await rootBundle.load(assetPath);
      final decoded = img.decodeImage(raw.buffer.asUint8List());
      if (decoded == null) return null;

      final png = Uint8List.fromList(img.encodePng(_stripBackground(decoded)));
      _cache[assetPath] = png;
      return png;
    } catch (_) {
      return null;
    }
  }

  static img.Image _stripBackground(img.Image decoded) {
    final image = decoded.convert(numChannels: 4);
    final w = image.width;
    final h = image.height;
    final remove = List<bool>.filled(w * h, false);

    int idx(int x, int y) => y * w + x;

    bool isBackgroundPixel(int r, int g, int b) {
      final maxC = math.max(r, math.max(g, b));
      final minC = math.min(r, math.min(g, b));
      final spread = maxC - minC;
      final lum = 0.299 * r + 0.587 * g + 0.114 * b;
      if (spread < 48 && lum > 145) return true;
      if (lum > 235 && spread < 30) return true;
      if (r > 170 && g > 170 && b > 170 && spread < 35) return true;
      return false;
    }

    bool isPlantPixel(int r, int g, int b) {
      final maxC = math.max(r, math.max(g, b));
      final minC = math.min(r, math.min(g, b));
      final spread = maxC - minC;
      if (g > 55 && g >= r - 8 && g >= b - 8 && spread > 12) return true;
      if (r > 140 && g > 130 && b < 160 && spread > 25) return true;
      if (g > 25 && g >= r && g >= b && maxC < 130) return true;
      if (r > 80 && g < 95 && b < 85 && spread > 18) return true;
      return false;
    }

    void floodFrom(int sx, int sy) {
      final queue = Queue<(int, int)>();
      queue.add((sx, sy));

      while (queue.isNotEmpty) {
        final (x, y) = queue.removeFirst();
        if (x < 0 || y < 0 || x >= w || y >= h) continue;

        final i = idx(x, y);
        if (remove[i]) continue;

        final p = image.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();

        if (isPlantPixel(r, g, b)) continue;
        if (!isBackgroundPixel(r, g, b)) continue;

        remove[i] = true;
        queue.add((x + 1, y));
        queue.add((x - 1, y));
        queue.add((x, y + 1));
        queue.add((x, y - 1));
      }
    }

    for (var x = 0; x < w; x++) {
      floodFrom(x, 0);
      floodFrom(x, h - 1);
    }
    for (var y = 0; y < h; y++) {
      floodFrom(0, y);
      floodFrom(w - 1, y);
    }

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = idx(x, y);
        if (remove[i]) continue;
        final p = image.getPixel(x, y);
        if (!isPlantPixel(p.r.toInt(), p.g.toInt(), p.b.toInt()) &&
            isBackgroundPixel(p.r.toInt(), p.g.toInt(), p.b.toInt())) {
          remove[i] = true;
        }
      }
    }

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = image.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        if (remove[idx(x, y)] ||
            (isBackgroundPixel(r, g, b) && !isPlantPixel(r, g, b))) {
          image.setPixelRgba(x, y, r, g, b, 0);
        }
      }
    }

    return image;
  }
}

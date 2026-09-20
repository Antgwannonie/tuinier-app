import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

bool _isBackgroundPixel(int r, int g, int b, int a, {int threshold = 215}) {
  if (a < 12) return true;
  final minRgb = r < g ? (r < b ? r : b) : (g < b ? g : b);
  final maxRgb = r > g ? (r > b ? r : b) : (g > b ? g : b);
  if (r >= threshold && g >= threshold && b >= threshold) return true;
  if (maxRgb - minRgb < 22 && minRgb >= threshold - 40) return true;
  return false;
}

bool _isDarkBackdropPixel(int r, int g, int b, int a, {int maxChannel = 56}) {
  if (a < 12) return true;
  return r <= maxChannel && g <= maxChannel && b <= maxChannel;
}

/// Chroma-key achtergrond (#FF00FF) — plantwit blijft behouden.
bool _isMagentaBackdropPixel(int r, int g, int b, int a) {
  if (a < 12) return true;
  return r > 130 && b > 130 && g < 140 && (r - g) > 60 && (b - g) > 60;
}

bool imageUsesMagentaBackdrop(img.Image image) {
  final w = image.width;
  final h = image.height;
  var magenta = 0;
  var samples = 0;

  void sample(int x, int y) {
    final p = image.getPixel(x, y);
    samples++;
    if (_isMagentaBackdropPixel(
      p.r.toInt(),
      p.g.toInt(),
      p.b.toInt(),
      p.a.toInt(),
    )) {
      magenta++;
    }
  }

  final step = math.max(4, w ~/ 32);
  for (var x = 0; x < w; x += step) {
    sample(x, 0);
    sample(x, h - 1);
  }
  for (var y = 0; y < h; y += step) {
    sample(0, y);
    sample(w - 1, y);
  }
  return samples > 0 && magenta / samples > 0.42;
}

/// Verwijdert alle magenta pixels (ook tussen bladeren — flood-fill mist die).
void knockOutMagentaBackdrop(img.Image image) {
  final w = image.width;
  final h = image.height;
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final p = image.getPixel(x, y);
      if (_isMagentaBackdropPixel(
        p.r.toInt(),
        p.g.toInt(),
        p.b.toInt(),
        p.a.toInt(),
      )) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
}

void floodFillMagentaBackdrop(img.Image image) {
  final w = image.width;
  final h = image.height;
  final visited = Uint8List(w * h);
  final queue = <int>[];

  void trySeed(int x, int y) {
    final i = y * w + x;
    if (visited[i] != 0) return;
    final p = image.getPixel(x, y);
    if (!_isMagentaBackdropPixel(
      p.r.toInt(),
      p.g.toInt(),
      p.b.toInt(),
      p.a.toInt(),
    )) {
      return;
    }
    queue.add(i);
    visited[i] = 1;
  }

  for (var x = 0; x < w; x++) {
    trySeed(x, 0);
    trySeed(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    trySeed(0, y);
    trySeed(w - 1, y);
  }

  while (queue.isNotEmpty) {
    final i = queue.removeLast();
    final x = i % w;
    final y = i ~/ w;
    image.setPixelRgba(x, y, 0, 0, 0, 0);

    void neighbor(int nx, int ny) {
      if (nx < 0 || ny < 0 || nx >= w || ny >= h) return;
      final ni = ny * w + nx;
      if (visited[ni] != 0) return;
      final p = image.getPixel(nx, ny);
      if (!_isMagentaBackdropPixel(
        p.r.toInt(),
        p.g.toInt(),
        p.b.toInt(),
        p.a.toInt(),
      )) {
        return;
      }
      visited[ni] = 1;
      queue.add(ni);
    }

    neighbor(x + 1, y);
    neighbor(x - 1, y);
    neighbor(x, y + 1);
    neighbor(x, y - 1);
  }
}

double _luminance(int r, int g, int b) => 0.299 * r + 0.587 * g + 0.114 * b;

bool _isSoilOrShadowPixel(int r, int g, int b, int a) {
  if (a < 12) return false;
  final lum = _luminance(r, g, b);
  if (lum > 115) return false;
  final maxC = math.max(r, math.max(g, b));
  final minC = math.min(r, math.min(g, b));
  if (maxC - minC > 42 && lum > 50) return false;
  return lum <= 112;
}

void floodFillDarkBackdrop(img.Image image, {int maxChannel = 56}) {
  final w = image.width;
  final h = image.height;
  final visited = Uint8List(w * h);
  final queue = <int>[];

  void trySeed(int x, int y) {
    final i = y * w + x;
    if (visited[i] != 0) return;
    final p = image.getPixel(x, y);
    if (!_isDarkBackdropPixel(
      p.r.toInt(),
      p.g.toInt(),
      p.b.toInt(),
      p.a.toInt(),
      maxChannel: maxChannel,
    )) {
      return;
    }
    queue.add(i);
    visited[i] = 1;
  }

  for (var x = 0; x < w; x++) {
    trySeed(x, 0);
    trySeed(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    trySeed(0, y);
    trySeed(w - 1, y);
  }

  while (queue.isNotEmpty) {
    final i = queue.removeLast();
    final x = i % w;
    final y = i ~/ w;
    image.setPixelRgba(x, y, 0, 0, 0, 0);

    void neighbor(int nx, int ny) {
      if (nx < 0 || ny < 0 || nx >= w || ny >= h) return;
      final ni = ny * w + nx;
      if (visited[ni] != 0) return;
      final p = image.getPixel(nx, ny);
      if (!_isDarkBackdropPixel(
        p.r.toInt(),
        p.g.toInt(),
        p.b.toInt(),
        p.a.toInt(),
        maxChannel: maxChannel,
      )) {
        return;
      }
      visited[ni] = 1;
      queue.add(ni);
    }

    neighbor(x + 1, y);
    neighbor(x - 1, y);
    neighbor(x, y + 1);
    neighbor(x, y - 1);
  }
}

void floodFillBackground(
  img.Image image, {
  int threshold = 215,
  bool preserveFlowerWhites = false,
}) {
  final w = image.width;
  final h = image.height;
  final visited = Uint8List(w * h);
  final queue = <int>[];

  bool canFlood(int x, int y) {
    final p = image.getPixel(x, y);
    final r = p.r.toInt();
    final g = p.g.toInt();
    final b = p.b.toInt();
    final a = p.a.toInt();
    if (!_isBackgroundPixel(r, g, b, a, threshold: threshold)) {
      return false;
    }
    if (preserveFlowerWhites &&
        _shouldPreserveLightPlantPixel(image, x, y, minPlantNeighbors: 2)) {
      return false;
    }
    return true;
  }

  void trySeed(int x, int y) {
    final i = y * w + x;
    if (visited[i] != 0) return;
    if (!canFlood(x, y)) return;
    queue.add(i);
    visited[i] = 1;
  }

  for (var x = 0; x < w; x++) {
    trySeed(x, 0);
    trySeed(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    trySeed(0, y);
    trySeed(w - 1, y);
  }

  while (queue.isNotEmpty) {
    final i = queue.removeLast();
    final x = i % w;
    final y = i ~/ w;
    image.setPixelRgba(x, y, 0, 0, 0, 0);

    void neighbor(int nx, int ny) {
      if (nx < 0 || ny < 0 || nx >= w || ny >= h) return;
      final ni = ny * w + nx;
      if (visited[ni] != 0) return;
      if (!canFlood(nx, ny)) return;
      visited[ni] = 1;
      queue.add(ni);
    }

    neighbor(x + 1, y);
    neighbor(x - 1, y);
    neighbor(x, y + 1);
    neighbor(x, y - 1);
  }
}

void removeBottomSoilDisc(img.Image image) {
  final w = image.width;
  final h = image.height;
  final visited = Uint8List(w * h);
  final queue = <int>[];
  final minY = (h * 0.42).round();

  void trySeed(int x, int y) {
    if (y < minY) return;
    final i = y * w + x;
    if (visited[i] != 0) return;
    final p = image.getPixel(x, y);
    if (!_isSoilOrShadowPixel(
      p.r.toInt(),
      p.g.toInt(),
      p.b.toInt(),
      p.a.toInt(),
    )) {
      return;
    }
    queue.add(i);
    visited[i] = 1;
  }

  for (var x = (w * 0.08).round(); x < (w * 0.92).round(); x++) {
    for (var y = h - 1; y >= minY; y -= math.max(1, h ~/ 64)) {
      trySeed(x, y);
    }
  }

  while (queue.isNotEmpty) {
    final i = queue.removeLast();
    final x = i % w;
    final y = i ~/ w;
    image.setPixelRgba(x, y, 0, 0, 0, 0);

    void neighbor(int nx, int ny) {
      if (nx < 0 || ny < 0 || nx >= w || ny >= h || ny < minY) return;
      final ni = ny * w + nx;
      if (visited[ni] != 0) return;
      final p = image.getPixel(nx, ny);
      if (!_isSoilOrShadowPixel(
        p.r.toInt(),
        p.g.toInt(),
        p.b.toInt(),
        p.a.toInt(),
      )) {
        return;
      }
      visited[ni] = 1;
      queue.add(ni);
    }

    neighbor(x + 1, y);
    neighbor(x - 1, y);
    neighbor(x, y + 1);
    if (y > minY) neighbor(x, y - 1);
  }
}

void healDarkSpecklesOnBrightAreas(img.Image image, {int passes = 8}) {
  final w = image.width;
  final h = image.height;
  const radius = 2;

  bool isBright(int r, int g, int b, int a) =>
      a >= 12 && _luminance(r, g, b) >= 140;

  bool isDarkSpeckle(int r, int g, int b, int a) =>
      a >= 12 && _luminance(r, g, b) <= 72;

  for (var pass = 0; pass < passes; pass++) {
    final fixes = <(int x, int y, int r, int g, int b)>[];
    final minBright = pass < 3 ? 5 : 3;

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = image.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        final a = p.a.toInt();
        if (!isDarkSpeckle(r, g, b, a)) continue;

        var brightNeighbors = 0;
        var sumR = 0;
        var sumG = 0;
        var sumB = 0;

        for (var dy = -radius; dy <= radius; dy++) {
          for (var dx = -radius; dx <= radius; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
            final np = image.getPixel(nx, ny);
            final nr = np.r.toInt();
            final ng = np.g.toInt();
            final nb = np.b.toInt();
            final na = np.a.toInt();
            if (!isBright(nr, ng, nb, na)) continue;
            brightNeighbors++;
            sumR += nr;
            sumG += ng;
            sumB += nb;
          }
        }

        if (brightNeighbors >= minBright) {
          fixes.add((
            x,
            y,
            (sumR / brightNeighbors).round(),
            (sumG / brightNeighbors).round(),
            (sumB / brightNeighbors).round(),
          ));
        }
      }
    }

    if (fixes.isEmpty) break;
    for (final fix in fixes) {
      image.setPixelRgba(fix.$1, fix.$2, fix.$3, fix.$4, fix.$5, 255);
    }
  }
}

void knockoutNearWhite(img.Image image, {int threshold = 220}) {
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();
      final a = p.a.toInt();
      if (a < 8) continue;
      if (_isBackgroundPixel(r, g, b, a, threshold: threshold)) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
}

img.Image _prepareRgbaImage(Uint8List input) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw StateError('Kon PNG niet lezen.');
  }
  return decoded.numChannels == 4
      ? decoded.clone()
      : decoded.convert(numChannels: 4, alpha: 255);
}

img.Image trimTransparent(img.Image source, {int alphaCutoff = 12}) {
  int? minX;
  int? minY;
  int? maxX;
  int? maxY;

  for (var y = 0; y < source.height; y++) {
    for (var x = 0; x < source.width; x++) {
      if (source.getPixel(x, y).a.toInt() > alphaCutoff) {
        minX = minX == null ? x : (x < minX ? x : minX);
        maxX = maxX == null ? x : (x > maxX ? x : maxX);
        minY = minY == null ? y : (y < minY ? y : minY);
        maxY = maxY == null ? y : (y > maxY ? y : maxY);
      }
    }
  }

  if (minX == null || minY == null || maxX == null || maxY == null) {
    return source;
  }

  const pad = 4;
  final x0 = (minX - pad).clamp(0, source.width - 1);
  final y0 = (minY - pad).clamp(0, source.height - 1);
  final x1 = (maxX + pad).clamp(0, source.width - 1);
  final y1 = (maxY + pad).clamp(0, source.height - 1);

  return img.copyCrop(
    source,
    x: x0,
    y: y0,
    width: x1 - x0 + 1,
    height: y1 - y0 + 1,
  );
}

img.Image padToSquare(img.Image source, {int size = 512, double fillRatio = 0.96}) {
  final maxDim = source.width > source.height ? source.width : source.height;
  final target = size * fillRatio;
  final scale = target / maxDim;
  final w = (source.width * scale).round().clamp(1, size);
  final h = (source.height * scale).round().clamp(1, size);
  final resized = img.copyResize(
    source,
    width: w,
    height: h,
    interpolation: img.Interpolation.cubic,
  );
  final canvas = img.Image(width: size, height: size, numChannels: 4);
  final ox = (size - w) ~/ 2;
  final oy = ((size - h) * 0.42).round().clamp(0, size - h);
  img.compositeImage(canvas, resized, dstX: ox, dstY: oy);
  return canvas;
}

/// Zoek-tab grid: breedte / hoogte (hele kaart).
const double kAtlasSearchCardGridAspectRatio = 0.62;

/// Foto-vlak op atlas-kaart (zonder seizoen-footer).
const double kAtlasSearchCardImageAspectRatio = 0.78;

@Deprecated('Use kAtlasSearchCardGridAspectRatio')
const double kAtlasSearchCardAspectRatio = kAtlasSearchCardGridAspectRatio;

/// Exportbreedte Zoeken-kaart (hoogte = breedte / ratio).
const int kAtlasSearchCardWidth = 512;

/// Detailpagina hero-balk (~390×180 logisch).
const double kAtlasDetailBannerAspectRatio = 2.17;

img.Image coverCropToSearchCard(
  img.Image source, {
  int width = 512,
  double aspectRatio = kAtlasSearchCardAspectRatio,
  double focusY = 0.42,
}) {
  final height = (width / aspectRatio).round();
  final scale = math.max(width / source.width, height / source.height);
  final w = (source.width * scale).round();
  final h = (source.height * scale).round();
  final resized = img.copyResize(source, width: w, height: h);
  final maxX = w > width ? w - width : 0;
  final maxY = h > height ? h - height : 0;
  final x = ((w - width) / 2).round().clamp(0, maxX);
  final y = ((h - height) * focusY).round().clamp(0, maxY);
  return img.copyCrop(
    resized,
    x: x,
    y: y,
    width: width,
    height: height,
  );
}

img.Image padToSearchCardAspect(
  img.Image source, {
  int width = 512,
  double aspectRatio = kAtlasSearchCardAspectRatio,
  double focusY = 0.42,
}) {
  return coverCropToSearchCard(
    source,
    width: width,
    aspectRatio: aspectRatio,
    focusY: focusY,
  );
}

img.ColorRgb8 _skyFillColor(img.Image source) {
  var r = 0, g = 0, b = 0, n = 0;
  final rows = math.max(1, (source.height * 0.15).round());
  for (var y = 0; y < rows; y++) {
    for (var x = 0; x < source.width; x += 3) {
      final p = source.getPixel(x, y);
      r += p.r.toInt();
      g += p.g.toInt();
      b += p.b.toInt();
      n++;
    }
  }
  if (n == 0) return img.ColorRgb8(135, 206, 235);
  return img.ColorRgb8(
    (r ~/ n).clamp(0, 255),
    (g ~/ n).clamp(0, 255),
    (b ~/ n).clamp(0, 255),
  );
}

img.ColorRgb8 _edgeFillColor(img.Image source) {
  var r = 0, g = 0, b = 0, n = 0;

  void sample(int x, int y) {
    final p = source.getPixel(
      x.clamp(0, source.width - 1),
      y.clamp(0, source.height - 1),
    );
    r += p.r.toInt();
    g += p.g.toInt();
    b += p.b.toInt();
    n++;
  }

  for (var x = 0; x < source.width; x += 4) {
    sample(x, 0);
    sample(x, source.height - 1);
  }
  for (var y = 0; y < source.height; y += 4) {
    sample(0, y);
    sample(source.width - 1, y);
  }

  if (n == 0) return img.ColorRgb8(40, 72, 38);
  return img.ColorRgb8(
    (r ~/ n).clamp(0, 255),
    (g ~/ n).clamp(0, 255),
    (b ~/ n).clamp(0, 255),
  );
}

/// Vierkante kaart: hele plant zichtbaar op doorlopende achtergrond (geen witte rand).
img.Image composeOpaqueSquareCard(
  img.Image source, {
  int size = 1024,
  double plantFill = 0.88,
}) {
  final canvas = img.Image(width: size, height: size, numChannels: 3);
  img.fill(canvas, color: _edgeFillColor(source));

  final fill = plantFill.clamp(0.5, 1.0);
  final scale =
      math.min(size / source.width, size / source.height) * fill;
  final fw = (source.width * scale).round().clamp(1, size);
  final fh = (source.height * scale).round().clamp(1, size);
  final plant = img.copyResize(source, width: fw, height: fh);
  img.compositeImage(
    canvas,
    plant,
    dstX: (size - fw) ~/ 2,
    dstY: (size - fh) ~/ 2,
  );
  return canvas;
}

/// Verwijdert witte/lichte randen (AI-export met letterbox).
img.Image trimLightBorders(img.Image source, {int threshold = 235}) {
  final w = source.width;
  final h = source.height;

  bool rowIsBorder(int y) {
    for (var x = 0; x < w; x++) {
      final p = source.getPixel(x, y);
      if (p.a < 12) continue;
      if (p.r < threshold || p.g < threshold || p.b < threshold) {
        return false;
      }
    }
    return true;
  }

  bool colIsBorder(int x) {
    for (var y = 0; y < h; y++) {
      final p = source.getPixel(x, y);
      if (p.a < 12) continue;
      if (p.r < threshold || p.g < threshold || p.b < threshold) {
        return false;
      }
    }
    return true;
  }

  var top = 0;
  while (top < h && rowIsBorder(top)) {
    top++;
  }
  var bottom = h - 1;
  while (bottom > top && rowIsBorder(bottom)) {
    bottom--;
  }
  var left = 0;
  while (left < w && colIsBorder(left)) {
    left++;
  }
  var right = w - 1;
  while (right > left && colIsBorder(right)) {
    right--;
  }

  final cw = right - left + 1;
  final ch = bottom - top + 1;
  if (cw < 2 || ch < 2) return source;
  return img.copyCrop(source, x: left, y: top, width: cw, height: ch);
}

bool _isNearWhiteFringePixel(
  int r,
  int g,
  int b, {
  int minRgb = 188,
  int maxChroma = 40,
}) {
  final minC = math.min(r, math.min(g, b));
  final maxC = math.max(r, math.max(g, b));
  if (minC < minRgb) return false;
  return maxC - minC <= maxChroma;
}

bool _isPlantColoredPixel(int r, int g, int b) {
  if (_isNearWhiteFringePixel(r, g, b, minRgb: 200, maxChroma: 36)) {
    return false;
  }
  final maxC = math.max(r, math.max(g, b));
  final minC = math.min(r, math.min(g, b));
  if (maxC - minC < 14) return false;
  if (g > r + 12 && g > 70) return true;
  // Bloemhart (aardappel, aardbei).
  if (r > 130 && g > 115 && b < 145 && r - b > 18) return true;
  if (r > 95 && g > 95 && b < 130 && r - b > 25) return true;
  // Fruit (aalbes, aardbei).
  if (r > 70 && g < 95 && b < 85) return true;
  return false;
}

/// Witte bloemblaadjes / lichte halo: behouden als er genoeg plantkleur in de buurt zit.
bool _shouldPreserveLightPlantPixel(
  img.Image image,
  int x,
  int y, {
  int minPlantNeighbors = 2,
}) {
  final p = image.getPixel(x, y);
  if (p.a < 12) return false;
  final r = p.r.toInt();
  final g = p.g.toInt();
  final b = p.b.toInt();
  if (!_isNearWhiteFringePixel(r, g, b, minRgb: 188, maxChroma: 42)) {
    return false;
  }
  return _plantColoredNeighbors(image, x, y, 2) >= minPlantNeighbors;
}

int _plantColoredNeighbors(img.Image image, int x, int y, int radius) {
  final w = image.width;
  final h = image.height;
  var count = 0;
  for (var dy = -radius; dy <= radius; dy++) {
    for (var dx = -radius; dx <= radius; dx++) {
      if (dx == 0 && dy == 0) continue;
      final nx = x + dx;
      final ny = y + dy;
      if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
      final p = image.getPixel(nx, ny);
      if (p.a < 12) continue;
      if (_isPlantColoredPixel(p.r.toInt(), p.g.toInt(), p.b.toInt())) {
        count++;
      }
    }
  }
  return count;
}

/// Witte halo weg, witte bloemblaadjes blijven (zitten tussen groen/geel/rood).
void removeWhiteHaloKeepFlowers(
  img.Image image, {
  int minRgb = 200,
  int maxChroma = 34,
  int minPlantNeighbors = 2,
  int expandPasses = 4,
}) {
  final w = image.width;
  final h = image.height;
  final keep = Uint8List(w * h);

  bool isNearWhite(int x, int y) {
    final p = image.getPixel(x, y);
    if (p.a < 12) return false;
    return _isNearWhiteFringePixel(
      p.r.toInt(),
      p.g.toInt(),
      p.b.toInt(),
      minRgb: minRgb,
      maxChroma: maxChroma,
    );
  }

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (!isNearWhite(x, y)) continue;
      if (_plantColoredNeighbors(image, x, y, 2) >= minPlantNeighbors) {
        keep[y * w + x] = 1;
      }
    }
  }

  for (var pass = 0; pass < expandPasses; pass++) {
    var changed = false;
    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final i = y * w + x;
        if (keep[i] != 0 || !isNearWhite(x, y)) continue;
        var keptNeighbors = 0;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
            if (keep[ny * w + nx] != 0) keptNeighbors++;
          }
        }
        if (keptNeighbors >= 2) {
          keep[i] = 1;
          changed = true;
        }
      }
    }
    if (!changed) break;
  }

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      if (!isNearWhite(x, y)) continue;
      if (keep[y * w + x] != 0) continue;
      image.setPixelRgba(x, y, 0, 0, 0, 0);
    }
  }
}

/// Zoeken-lijst illustratie (transparant PNG), ~4× voor scherpe weergave (88dp @3x).
const int kZoekenListIconSize = 512;

void processZoekenListIconFile(
  File input,
  File output, {
  int size = kZoekenListIconSize,
  double fillRatio = 0.94,
}) {
  final decoded = img.decodeImage(input.readAsBytesSync());
  if (decoded == null) {
    throw StateError('Kon PNG niet lezen.');
  }
  var rgba = decoded.numChannels == 4
      ? decoded.clone()
      : decoded.convert(numChannels: 4, alpha: 255);
  // Magenta-bron (#FF00FF): alles magenta weg → transparant (past op zwarte pagina).
  // Zwarte bron (#000): alleen rand-zwart weg → transparant (zelfde effect op detail).
  if (imageUsesMagentaBackdrop(rgba)) {
    knockOutMagentaBackdrop(rgba);
  } else {
    rgba = trimLightBorders(rgba, threshold: 248);
    floodFillDarkBackdrop(rgba, maxChannel: 18);
  }
  final trimmed = trimTransparent(rgba);
  final icon = padToSquare(trimmed, size: size, fillRatio: fillRatio);
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(Uint8List.fromList(img.encodePng(icon)));
}

/// Zoeken-lijst icoon: 76dp → 152px (@2x), vierkant met achtergrond.
const int kZoekenThumbnailSize = 152;

img.Image composeZoekenThumbnail(
  img.Image source, {
  int size = kZoekenThumbnailSize,
  double plantFill = 0.90,
}) {
  final prepared = trimLightBorders(source);
  final canvas = img.Image(width: size, height: size, numChannels: 3);
  img.fill(canvas, color: img.ColorRgb8(232, 245, 233));

  final scale =
      math.min(size / prepared.width, size / prepared.height) * plantFill;
  final fw = (prepared.width * scale).round();
  final fh = (prepared.height * scale).round();
  final plant = img.copyResize(prepared, width: fw, height: fh);
  img.compositeImage(
    canvas,
    plant,
    dstX: (size - fw) ~/ 2,
    dstY: (size - fh) ~/ 2,
  );
  return canvas;
}

void processZoekenThumbnailFile(
  File input,
  File output, {
  int size = kZoekenThumbnailSize,
  double plantFill = 0.90,
}) {
  final decoded = img.decodeImage(input.readAsBytesSync());
  if (decoded == null) {
    throw StateError('Kon PNG niet lezen.');
  }
  final thumb = composeZoekenThumbnail(decoded, size: size, plantFill: plantFill);
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(Uint8List.fromList(img.encodePng(thumb)));
}

/// Snijdt landschap-bron bij tot portret (zelfde ratio als export).
img.Image cropSourceToAspect(img.Image source, double targetAspect) {
  final w = source.width;
  final h = source.height;
  final srcAspect = w / h;
  if ((srcAspect - targetAspect).abs() < 0.04) return source;
  if (srcAspect > targetAspect) {
    final newW = (h * targetAspect).round().clamp(1, w);
    final x = (w - newW) ~/ 2;
    return img.copyCrop(source, x: x, y: 0, width: newW, height: h);
  }
  final newH = (w / targetAspect).round().clamp(1, h);
  final y = (h - newH) ~/ 2;
  return img.copyCrop(source, x: 0, y: y, width: w, height: newH);
}

/// Zoeken-kaart: hele plant zichtbaar (contain), één laag, lucht als achtergrond.
img.Image composeSearchCardPlantImage(
  img.Image source, {
  int width = kAtlasSearchCardWidth,
  double aspectRatio = kAtlasSearchCardImageAspectRatio,
  double plantFill = 0.90,
  /// -1 = boven, 0 = midden, 1 = onder (hele plant blijft in canvas).
  double plantAlignY = 0,
}) {
  final height = (width / aspectRatio).round();
  final trimmed = trimLightBorders(source);
  final cropped = cropSourceToAspect(trimmed, aspectRatio);
  final canvas = img.Image(width: width, height: height, numChannels: 3);
  img.fill(canvas, color: _skyFillColor(cropped));

  /// Plant iets kleiner dan het kader (geen bladeren afgesneden).
  final scale =
      math.min(width / cropped.width, height / cropped.height) * plantFill;
  final fw = (cropped.width * scale).round();
  final fh = (cropped.height * scale).round();
  final plant = img.copyResize(cropped, width: fw, height: fh);
  final maxY = height - fh;
  final align = plantAlignY.clamp(-1.0, 1.0);
  final dstY = (maxY * (align + 1) / 2).round().clamp(0, maxY);
  img.compositeImage(
    canvas,
    plant,
    dstX: (width - fw) ~/ 2,
    dstY: dstY,
  );
  return canvas;
}

Uint8List processSearchCardPlantBytes(
  Uint8List input, {
  double plantFill = 0.90,
  double aspectRatio = kAtlasSearchCardImageAspectRatio,
  double plantAlignY = 0,
}) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw StateError('Kon PNG niet lezen.');
  }
  final card = composeSearchCardPlantImage(
    decoded,
    plantFill: plantFill,
    aspectRatio: aspectRatio,
    plantAlignY: plantAlignY,
  );
  return Uint8List.fromList(img.encodePng(card));
}

void processSearchCardPlantFile(
  File input,
  File output, {
  double plantFill = 0.90,
  double aspectRatio = kAtlasSearchCardImageAspectRatio,
  double plantAlignY = 0,
}) {
  final out = processSearchCardPlantBytes(
    input.readAsBytesSync(),
    plantFill: plantFill,
    aspectRatio: aspectRatio,
    plantAlignY: plantAlignY,
  );
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(out);
}

Uint8List processSearchCardIconBytes(Uint8List input) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw StateError('Kon PNG niet lezen.');
  }
  final card = padToSearchCardAspect(decoded);
  return Uint8List.fromList(img.encodePng(card));
}

void processSearchCardIconFile(File input, File output) {
  final out = processSearchCardIconBytes(input.readAsBytesSync());
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(out);
}

img.Image coverCropToDetailBanner(
  img.Image source, {
  int width = 780,
  double aspectRatio = kAtlasDetailBannerAspectRatio,
  double focusY = 0.5,
}) {
  return coverCropToSearchCard(
    source,
    width: width,
    aspectRatio: aspectRatio,
    focusY: focusY,
  );
}

Uint8List processDetailBannerIconBytes(
  Uint8List input, {
  double focusY = 0.5,
}) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw StateError('Kon PNG niet lezen.');
  }
  final banner = coverCropToDetailBanner(decoded, focusY: focusY);
  return Uint8List.fromList(img.encodePng(banner));
}

void processDetailBannerIconFile(
  File input,
  File output, {
  double focusY = 0.5,
}) {
  final out = processDetailBannerIconBytes(input.readAsBytesSync(), focusY: focusY);
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(out);
}

/// Volledige plant behouden (geen cover-crop); alleen verkleinen voor app-grootte.
img.Image resizeFullPlantPreserve(
  img.Image source, {
  int maxSide = 1024,
}) {
  if (source.width <= maxSide && source.height <= maxSide) {
    return source;
  }
  if (source.width >= source.height) {
    return img.copyResize(source, width: maxSide);
  }
  return img.copyResize(source, height: maxSide);
}

Uint8List processFullPlantIconBytes(Uint8List input, {int maxSide = 1024}) {
  final decoded = img.decodeImage(input);
  if (decoded == null) {
    throw StateError('Kon PNG niet lezen.');
  }
  final out = resizeFullPlantPreserve(decoded, maxSide: maxSide);
  return Uint8List.fromList(img.encodePng(out));
}

void processFullPlantIconFile(
  File input,
  File output, {
  int maxSide = 1024,
}) {
  final out = processFullPlantIconBytes(input.readAsBytesSync(), maxSide: maxSide);
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(out);
}

Uint8List processAtlasPlantIconBytes(Uint8List input, {bool gentle = false}) {
  final image = _prepareRgbaImage(input);
  if (gentle) {
    // Alleen echte zwarte achtergrond (rand) — blad/schaduw blijft intact.
    floodFillDarkBackdrop(image, maxChannel: 22);
  } else {
    floodFillDarkBackdrop(image);
    floodFillBackground(image, threshold: 218);
    knockoutNearWhite(image, threshold: 218);
    removeBottomSoilDisc(image);
    healDarkSpecklesOnBrightAreas(image);
  }
  final trimmed = trimTransparent(image);
  final squared = padToSquare(trimmed, fillRatio: 0.97);
  return Uint8List.fromList(img.encodePng(squared));
}

void processAtlasPlantIconFile(
  File input,
  File output, {
  bool gentle = false,
}) {
  final out = processAtlasPlantIconBytes(
    input.readAsBytesSync(),
    gentle: gentle,
  );
  output.parent.createSync(recursive: true);
  output.writeAsBytesSync(out);
}

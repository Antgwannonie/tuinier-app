import 'dart:collection';
import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

/// Kopieert plant-PNG's en verwijdert witte/grijze/checkerboard-achtergrond.
void main() {
  final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
  if (home == null) {
    stderr.writeln('USERPROFILE not set');
    exit(1);
  }

  final src = Directory('$home/.cursor/projects/empty-window/assets');
  final dst = Directory('assets/images/garden_health');
  dst.createSync(recursive: true);

  const names = [
    'garden_health_dying.png',
    'garden_health_weak.png',
    'garden_health_seedling.png',
    'garden_health_growing.png',
    'garden_health_flourishing.png',
  ];

  var processed = 0;
  for (final name in names) {
    final source = File('${src.path}/$name');
    final target = File('${dst.path}/$name');

    if (!source.existsSync() && !target.existsSync()) {
      stderr.writeln('Missing: $name');
      continue;
    }

    if (source.existsSync()) {
      source.copySync(target.path);
    }

    _removeBackground(target);
    processed++;
    stdout.writeln('Prepared $name');
  }

  if (processed == 0) {
    stderr.writeln('No PNG files processed.');
    exit(1);
  }
}

void _removeBackground(File file) {
  final decoded = img.decodeImage(file.readAsBytesSync());
  if (decoded == null) {
    throw StateError('Could not decode ${file.path}');
  }

  final image = decoded.convert(numChannels: 4);
  final w = image.width;
  final h = image.height;
  final remove = List<bool>.filled(w * h, false);

  bool isBackgroundPixel(int r, int g, int b) {
    final maxC = math.max(r, math.max(g, b));
    final minC = math.min(r, math.min(g, b));
    final spread = maxC - minC;
    final lum = 0.299 * r + 0.587 * g + 0.114 * b;

    // Schaakbord / wit / lichtgrijs — geen plantkleur.
    if (spread < 48 && lum > 145) return true;
    if (lum > 235 && spread < 30) return true;

    // Lichtgrijze vakjes van transparantie-preview in PNG.
    if (r > 170 && g > 170 && b > 170 && spread < 35) return true;

    return false;
  }

  bool isPlantPixel(int r, int g, int b) {
    final maxC = math.max(r, math.max(g, b));
    final minC = math.min(r, math.min(g, b));
    final spread = maxC - minC;

    // Groen blad / stengel.
    if (g > 55 && g >= r - 8 && g >= b - 8 && spread > 12) return true;
    // Geel bloemhart.
    if (r > 140 && g > 130 && b < 160 && spread > 25) return true;
    // Donkergroene lijn.
    if (g > 25 && g >= r && g >= b && maxC < 130) return true;
    // Bruin (verwelkte plant).
    if (r > 80 && g < 95 && b < 85 && spread > 18) return true;

    return false;
  }

  int idx(int x, int y) => y * w + x;

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

  // Flood fill vanaf alle randen.
  for (var x = 0; x < w; x++) {
    floodFrom(x, 0);
    floodFrom(x, h - 1);
  }
  for (var y = 0; y < h; y++) {
    floodFrom(0, y);
    floodFrom(w - 1, y);
  }

  // Extra: resterende lichte vlakken die geen plant zijn.
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final i = idx(x, y);
      if (remove[i]) continue;

      final p = image.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();

      if (!isPlantPixel(r, g, b) && isBackgroundPixel(r, g, b)) {
        remove[i] = true;
      }
    }
  }

  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      final i = idx(x, y);
      final p = image.getPixel(x, y);
      final r = p.r.toInt();
      final g = p.g.toInt();
      final b = p.b.toInt();

      if (remove[i]) {
        image.setPixelRgba(x, y, r, g, b, 0);
        continue;
      }

      // Anti-alias rand zachter maken.
      if (isBackgroundPixel(r, g, b) && !isPlantPixel(r, g, b)) {
        image.setPixelRgba(x, y, r, g, b, 0);
      }
    }
  }

  file.writeAsBytesSync(img.encodePng(image));
}

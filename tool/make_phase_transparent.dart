import 'dart:io';

import 'package:image/image.dart' as img;

void main() {
  final dir = Directory('assets/images/growth');
  final names = [
    'growth_phase_germination.png',
    'growth_phase_seedling.png',
    'growth_phase_young.png',
    'growth_phase_growth.png',
    'growth_phase_bloom.png',
    'growth_phase_fruiting.png',
    'growth_phase_harvest.png',
  ];

  for (final name in names) {
    final file = File('${dir.path}/$name');
    if (!file.existsSync()) {
      stderr.writeln('Skip missing: $name');
      continue;
    }
    final bytes = file.readAsBytesSync();
    final image = img.decodePng(bytes);
    if (image == null) {
      stderr.writeln('Decode failed: $name');
      continue;
    }

    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        if (_isBackground(r, g, b)) {
          image.setPixelRgba(x, y, r, g, b, 0);
        }
      }
    }

    file.writeAsBytesSync(img.encodePng(image));
    stdout.writeln('Transparent: $name');
  }
}

bool _isBackground(int r, int g, int b) {
  // White / near-white
  if (r > 235 && g > 235 && b > 235) return true;
  // Light blue watercolor wash
  if (b > r + 8 && b > g + 4 && r > 175 && g > 190 && b > 210) return true;
  // Grey checkerboard fake transparency from generators
  if ((r - g).abs() < 6 && (g - b).abs() < 6 && r > 180 && r < 220) {
    return true;
  }
  return false;
}

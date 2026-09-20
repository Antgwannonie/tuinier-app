import 'dart:io';

import 'package:image/image.dart' as img;

/// Maakt lichtgrijze/witte randen rond zaai-illustraties puur wit (#FFFFFF).
void main() {
  final dir = Directory('assets/images/sowing');
  if (!dir.existsSync()) {
    stderr.writeln('Map niet gevonden: ${dir.path}');
    exit(1);
  }

  for (final file in dir.listSync().whereType<File>()) {
    if (!file.path.toLowerCase().endsWith('.png')) continue;

    final bytes = file.readAsBytesSync();
    final image = img.decodePng(bytes);
    if (image == null) {
      stderr.writeln('Skip (geen PNG): ${file.path}');
      continue;
    }

    var changed = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final r = p.r.toInt();
        final g = p.g.toInt();
        final b = p.b.toInt();
        final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
        final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);

        // Randen en vlakke lichte achtergrond → puur wit.
        final isLightBg = minC >= 228 && maxC - minC <= 18;
        if (isLightBg) {
          image.setPixelRgba(x, y, 255, 255, 255, 255);
          changed++;
        }
      }
    }

    file.writeAsBytesSync(img.encodePng(image));
    stdout.writeln('OK: ${file.uri.pathSegments.last} ($changed px → wit)');
  }
}

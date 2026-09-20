import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

bool isBackgroundPixel(int r, int g, int b, int a) {
  if (a < 8) return true;

  final maxDiff = math.max(
    (r - g).abs(),
    math.max((g - b).abs(), (r - b).abs()),
  );
  final avg = (r + g + b) / 3;

  // Checkerboard / white / light gray matte.
  if (maxDiff <= 20 && avg >= 155) return true;

  // Black matte export (common after prior processing).
  if (maxDiff <= 15 && avg <= 40) return true;

  return false;
}

void floodClearBackground(img.Image image) {
  final width = image.width;
  final height = image.height;
  final visited = List.generate(height, (_) => List.filled(width, false));
  final queue = <(int, int)>[];

  void seed(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return;
    final pixel = image.getPixel(x, y);
    if (!isBackgroundPixel(
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
      pixel.a.toInt(),
    )) {
      return;
    }
    queue.add((x, y));
  }

  for (var x = 0; x < width; x++) {
    seed(x, 0);
    seed(x, height - 1);
  }
  for (var y = 0; y < height; y++) {
    seed(0, y);
    seed(width - 1, y);
  }

  while (queue.isNotEmpty) {
    final (x, y) = queue.removeLast();
    if (visited[y][x]) continue;
    final pixel = image.getPixel(x, y);
    if (!isBackgroundPixel(
      pixel.r.toInt(),
      pixel.g.toInt(),
      pixel.b.toInt(),
      pixel.a.toInt(),
    )) {
      continue;
    }
    visited[y][x] = true;
    image.setPixelRgba(x, y, 0, 0, 0, 0);
    seed(x + 1, y);
    seed(x - 1, y);
    seed(x, y + 1);
    seed(x, y - 1);
  }
}

void removeOpaqueBlackMatte(img.Image image) {
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      final r = pixel.r.toInt();
      final g = pixel.g.toInt();
      final b = pixel.b.toInt();
      final a = pixel.a.toInt();
      if (a < 8) continue;
      final maxDiff = math.max(
        (r - g).abs(),
        math.max((g - b).abs(), (r - b).abs()),
      );
      final avg = (r + g + b) / 3;
      if (maxDiff <= 18 && avg <= 45) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }
}

void stripCheckerboard(File file) {
  final bytes = file.readAsBytesSync();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) {
    stderr.writeln('skip ${file.path}: decode failed');
    return;
  }

  final image = decoded.numChannels == 4
      ? decoded
      : decoded.convert(numChannels: 4);
  floodClearBackground(image);
  removeOpaqueBlackMatte(image);
  file.writeAsBytesSync(Uint8List.fromList(img.encodePng(image)));
  stdout.writeln('updated ${file.uri.pathSegments.last}');
}

void main(List<String> args) {
  final dir = Directory('assets/images/growth');
  if (!dir.existsSync()) {
    stderr.writeln('growth dir not found');
    exit(1);
  }

  final onlyPhase = args.contains('--phase-only');
  for (final entity in dir.listSync().whereType<File>()) {
    final name = entity.path.toLowerCase();
    if (!name.endsWith('.png')) continue;
    if (onlyPhase && !name.contains('growth_phase_')) continue;
    stripCheckerboard(entity);
  }
}

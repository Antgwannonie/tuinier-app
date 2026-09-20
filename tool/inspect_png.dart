import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/images/growth/growth_phase_germination.png');
  final image = img.decodeImage(file.readAsBytesSync())!;
  print('channels=${image.numChannels} ${image.width}x${image.height}');

  final corners = [
    (0, 0),
    (image.width - 1, 0),
    (0, image.height - 1),
    (image.width - 1, image.height - 1),
  ];
  for (final (x, y) in [
    ...corners,
    (image.width ~/ 2, 0),
    (image.width ~/ 2, image.height ~/ 2),
    (100, 100),
    (image.width - 100, 100),
  ]) {
    final p = image.getPixel(x, y);
    print('corner ($x,$y): r=${p.r} g=${p.g} b=${p.b} a=${p.a}');
  }

  var transparent = 0;
  var opaqueBlack = 0;
  var opaque = 0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      final p = image.getPixel(x, y);
      final a = p.a.toInt();
      if (a < 10) {
        transparent++;
      } else {
        opaque++;
        if (p.r < 40 && p.g < 40 && p.b < 40) opaqueBlack++;
      }
    }
  }
  print('transparent=$transparent opaque=$opaque opaqueBlack=$opaqueBlack');
}

// Aardappel-foto voor Zoeken-fotovlak (512×656, ratio 0.78, hele plant).
//
//   dart run tool/install_aardappel.dart

import 'dart:io';

import 'plant_icon_processing.dart';

void main() {
  const sources = [
    r'C:\Users\frede\.cursor\projects\empty-window\assets\aardappel_kaart_volledig.png',
    r'C:\Users\frede\.cursor\projects\empty-window\assets\aardappel_kaart_bron.png',
    r'C:\Users\frede\.cursor\projects\empty-window\assets\aardappel_moestuin_v3.png',
    r'C:\Users\frede\.cursor\projects\empty-window\assets\aardappel_moestuin_v2.png',
    r'C:\Users\frede\.cursor\projects\empty-window\assets\aardappel_moestuin.png',
    r'C:\Users\frede\.cursor\projects\empty-window\assets\aardappel_card.png',
    r'C:\Users\frede\.cursor\projects\empty-window\assets\aardappel.png',
  ];
  final dest = File(
    '${Directory.current.path}${Platform.pathSeparator}'
    'assets${Platform.pathSeparator}images${Platform.pathSeparator}'
    'vegetables${Platform.pathSeparator}aardappel.png',
  );

  File? src;
  for (final path in sources) {
    final f = File(path);
    if (f.existsSync()) {
      src = f;
      break;
    }
  }
  if (src == null) {
    stderr.writeln('Geen bron gevonden. Verwacht o.a.:');
    for (final s in sources) {
      stderr.writeln('  $s');
    }
    exit(1);
  }

  processSearchCardPlantFile(src, dest);
  final h = (kAtlasSearchCardWidth / kAtlasSearchCardImageAspectRatio).round();
  stdout.writeln(
    'OK: ${dest.path} (${dest.lengthSync()} bytes, ${kAtlasSearchCardWidth}×$h, fotovlak)',
  );
}

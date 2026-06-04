// Illustratie voor Zoeken-lijst (transparant, stijl seed-catalog).
//
//   dart run tool/install_lijst_icon.dart aardappel

import 'dart:io';

import 'plant_icon_processing.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Gebruik: dart run tool/install_lijst_icon.dart <id>');
    exit(1);
  }

  final id = args.first.trim().toLowerCase();
  final root = Directory.current.path;
  final dest = File(
    '$root${Platform.pathSeparator}assets${Platform.pathSeparator}images'
    '${Platform.pathSeparator}vegetables${Platform.pathSeparator}${id}_lijst.png',
  );

  final names = <String>[
    '${id}_lijst_icon_bron.png',
    '${id}_lijst_bron.png',
    '${id}_zoeken_icon_bron.png',
    '$id.png',
  ];

  File? src;
  for (final name in names) {
    for (final dir in [
      r'C:\Users\frede\.cursor\projects\empty-window\assets\',
      '$root${Platform.pathSeparator}assets${Platform.pathSeparator}images'
          '${Platform.pathSeparator}vegetables${Platform.pathSeparator}',
    ]) {
      final f = File(dir + name);
      if (f.existsSync()) {
        src = f;
        break;
      }
    }
    if (src != null) break;
  }

  if (src == null) {
    stderr.writeln('Geen bron voor "$id".');
    exit(1);
  }

  processZoekenListIconFile(src, dest);
  stdout.writeln(
    'OK: ${dest.path} (${kZoekenListIconSize}×$kZoekenListIconSize px, transparant)',
  );
}

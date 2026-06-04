// Zoeken-lijst icoon (152×152, groene achtergrond) voor 76dp thumbnail.
//
//   dart run tool/install_zoeken_thumbnail.dart aardappel

import 'dart:io';

import 'plant_icon_processing.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Gebruik: dart run tool/install_zoeken_thumbnail.dart <id>');
    exit(1);
  }

  final id = args.first.trim().toLowerCase();
  final root = Directory.current.path;
  final dest = File(
    '$root${Platform.pathSeparator}assets${Platform.pathSeparator}images'
    '${Platform.pathSeparator}vegetables${Platform.pathSeparator}${id}_zoeken.png',
  );

  final names = <String>[
    '${id}_zoeken_icon_bron.png',
    '${id}_zoeken_icon.png',
    '${id}_kaart_bron.png',
    '${id}_kaart_volledig.png',
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
    stderr.writeln('Geen bron voor "$id". Verwacht o.a.:');
    stderr.writeln(
      '  ...\\empty-window\\assets\\${id}_zoeken_icon_bron.png',
    );
    exit(1);
  }

  final fill = switch (id) {
    'aardappel' => 1.0,
    _ => 0.90,
  };
  processZoekenThumbnailFile(src, dest, plantFill: fill);
  stdout.writeln(
    'OK: ${dest.path} (${kZoekenThumbnailSize}×$kZoekenThumbnailSize) ← ${src.path}',
  );
}

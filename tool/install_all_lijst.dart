// Verwerk alle Zoeken-lijsticonen waar een bron bestaat (512×512 transparant).
//
//   dart run tool/install_all_lijst.dart
//   dart run tool/install_all_lijst.dart --force   // meldt ook planten zonder bron

import 'dart:io';

import '../lib/data/vegetable_image_info.dart';
import 'plant_icon_processing.dart';

void main(List<String> args) {
  final force = args.contains('--force');
  final root = Directory.current.path;
  final vegDir = '$root${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}';
  const bronDir =
      r'C:\Users\frede\.cursor\projects\empty-window\assets\';

  var ok = 0;
  var skipped = 0;
  var noBron = 0;

  for (final e in kVegetableImages.entries) {
    final path = e.value.assetPath;
    if (path == null || !path.contains('_lijst.png')) continue;

    final id = e.key;
    final dest = File('$vegDir${id}_lijst.png');

    final names = <String>[
      '${id}_lijst_icon_bron.png',
      '${id}_lijst_bron.png',
      '${id}_zoeken_icon_bron.png',
      '$id.png',
    ];

    File? src;
    for (final name in names) {
      for (final dir in [bronDir, vegDir]) {
        final f = File(dir + name);
        if (f.existsSync()) {
          src = f;
          break;
        }
      }
      if (src != null) break;
    }

    if (src == null) {
      if (dest.existsSync() && !force) {
        skipped++;
      } else {
        stderr.writeln('Geen bron: $id');
        noBron++;
      }
      continue;
    }

    processZoekenListIconFile(src, dest);
    stdout.writeln('OK: $id');
    ok++;
  }

  stdout.writeln('');
  stdout.writeln('Klaar: $ok verwerkt, $skipped al aanwezig (geen bron nodig), $noBron zonder bron.');
}

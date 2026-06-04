// Kardoen, kamille, jostabes, paksoi, radijs, schorseneer, snijbonen, witlof, pastinaak.
//
//   dart run tool/plant_lijst_regen_batch_9.dart

import 'dart:io';

import 'plant_icon_processing.dart';

const kBatch9LijstIds = [
  'kardoen',
  'kamille',
  'jostabes',
  'paksoi',
  'radijs',
  'schorseneer',
  'snijbonen',
  'witlof',
  'pastinaak',
];

const _bronDir =
    r'C:\Users\frede\.cursor\projects\empty-window\assets\';

void main() {
  final root = Directory.current.path;
  final vegDir = '$root${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}';

  var ok = 0;
  var missing = 0;

  for (final id in kBatch9LijstIds) {
    final dest = File('${vegDir}${id}_lijst.png');
    File? src;
    for (final dir in [_bronDir, vegDir]) {
      final f = File('${dir}${id}_lijst_icon_bron.png');
      if (f.existsSync()) {
        src = f;
        break;
      }
    }
    if (src == null) {
      stderr.writeln('SKIP (geen bron): $id');
      missing++;
      continue;
    }
    processZoekenListIconFile(src, dest);
    stdout.writeln('OK: $id');
    ok++;
  }

  stdout.writeln('');
  stdout.writeln('Klaar: $ok geinstalleerd, $missing zonder bron.');
}

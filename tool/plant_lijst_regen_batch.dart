// Plantenlijst van gebruiker — nieuwe bron + lijst-icoon (magenta achtergrond).
//
//   dart run tool/plant_lijst_regen_batch.dart

import 'dart:io';

import 'plant_icon_processing.dart';

/// Gebruikerslijst (id in app).
const kUserLijstRegenIds = [
  'augurk',
  'aalbes',
  'appel',
  'bloemkool',
  'boerenkool',
  'broccoli',
  'chinese_kool',
  'courgette',
  'knoflook_hardnekkig',
  'paksoi_jong',
  'kardoen',
  'kastanjechampignon',
  'knoflook',
  'knolvenkel',
  'komkommer',
  'lions_mane',
  'meiraap',
  'prei',
  'raap',
  'shimeji',
  'limnanthes',
  'spitskool',
  'mais',
  'venkel',
  'lindebloesem',
  'witte_biet',
  'champignon_wit',
  'zaadslurf',
  'aardappel',
  'aardbei',
  'aardpeer',
  'cucamelon',
  'witte_asperge',
];

const _bronDir =
    r'C:\Users\frede\.cursor\projects\empty-window\assets\';

void main() {
  final root = Directory.current.path;
  final vegDir = '$root${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}';

  var ok = 0;
  var missing = 0;

  for (final id in kUserLijstRegenIds) {
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
  stdout.writeln('Klaar: $ok geinstalleerd, $missing zonder bron-PNG.');
}

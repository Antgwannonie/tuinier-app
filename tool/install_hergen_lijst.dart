// Verwerk hergeneratie-bronnen naar *_lijst.png (vervangt oude iconen).
//
//   dart run tool/install_hergen_lijst.dart

import 'dart:io';

import 'plant_icon_processing.dart';

const _ids = [
  'aalbes',
  'afrikaantje',
  'andijvie',
  'anijs_kruid',
  'appel',
  'aubergine',
  'augurk',
  'avocado',
  'basilicum',
  'bijenmengsel',
  'blauwe_bes',
  'bleekselderij',
  'basilicum_bloei',
  'look_bloei',
  'koriander_bloei',
  'munt_bloei',
  'salie_bloei',
  'tijm_bloei',
  'ui_bloei',
  'bloemkool',
  'boekweit',
  'boerenkool',
  'broccoli',
  'chinese_kool',
  'courgette',
  'dragon',
  'komkommerkruid',
  'komkommer',
  'lindenbloesem',
  'aardappel',
  'aardbei',
  'aardpeer',
  'artisjok',
  'blauwe_regen_bes',
  'bruine_boon',
  'cayenne_peper',
  'cucamelon',
  'doperwt',
];

void main() {
  final root = Directory.current.path;
  final vegDir = '$root${Platform.pathSeparator}assets'
      '${Platform.pathSeparator}images${Platform.pathSeparator}vegetables'
      '${Platform.pathSeparator}';
  const bronDir =
      r'C:\Users\frede\.cursor\projects\empty-window\assets\';

  var ok = 0;
  var fail = 0;

  for (final id in _ids) {
    final dest = File('${vegDir}${id}_lijst.png');
    final names = [
      '${id}_lijst_icon_bron.png',
      '${id}_lijst_bron.png',
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
      stderr.writeln('SKIP (geen bron): $id');
      fail++;
      continue;
    }

    processZoekenListIconFile(src, dest);
    stdout.writeln('OK: $id -> ${dest.path}');
    ok++;
  }

  stdout.writeln('');
  stdout.writeln('Klaar: $ok vervangen, $fail zonder bron.');
}

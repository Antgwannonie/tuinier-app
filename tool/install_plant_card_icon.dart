// Zoeken-kaart PNG voor een gewas (512×656, hele plant zichtbaar).
//
//   dart run tool/install_plant_card_icon.dart aalbes
//   dart run tool/install_plant_card_icon.dart aardbei
//   dart run tool/install_plant_card_icon.dart aardappel

import 'dart:io';

import 'plant_icon_processing.dart';

/// Lager = meer lucht/marge rond de plant (zoals aardappel in het kader).
double _plantFillFor(String id) => switch (id) {
      'aalbes' => 0.82,
      'aardbei' => 0.88,
      _ => 0.90,
    };

/// Verticale positie in export (-1 boven … 1 onder).
double _plantAlignYFor(String id) => switch (id) {
      'aardbei' => -0.22,
      _ => 0,
    };

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Gebruik: dart run tool/install_plant_card_icon.dart <gewas-id>');
    stderr.writeln('Voorbeeld: dart run tool/install_plant_card_icon.dart aalbes');
    exit(1);
  }

  final id = args.first.trim().toLowerCase();
  final projectRoot = Directory.current.path;
  final fileName = id == 'aardbei' ? 'aardbei_v2.png' : '$id.png';
  final dest = File(
    '$projectRoot${Platform.pathSeparator}assets${Platform.pathSeparator}'
    'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}$fileName',
  );
  if (id == 'aardbei') {
    final legacy = File(
      '$projectRoot${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}aardbei.png',
    );
    if (legacy.existsSync()) {
      legacy.deleteSync();
    }
  }

  final sources = <String>[
  for (final name in [
    '${id}_kaart_bron.png',
    '${id}_lang_bron.png',
    '${id}_512x656_bron.png',
    '${id}_zoeken_kaart.png',
    '${id}_kaart_bron.png',
    '${id}_kaart_volledig.png',
    '${id}_moestuin_v2.png',
    '${id}_moestuin.png',
    '$id.png',
  ])
    r'C:\Users\frede\.cursor\projects\empty-window\assets\' + name,
    '$projectRoot${Platform.pathSeparator}assets${Platform.pathSeparator}images${Platform.pathSeparator}vegetables${Platform.pathSeparator}$name',
  ];

  File? src;
  for (final path in sources) {
    final f = File(path);
    if (f.existsSync()) {
      src = f;
      break;
    }
  }

  if (src == null) {
    stderr.writeln('Geen bron gevonden voor "$id". Verwacht o.a.:');
    stderr.writeln(
      '  C:\\Users\\frede\\.cursor\\projects\\empty-window\\assets\\${id}_kaart_bron.png',
    );
    exit(1);
  }

  const aspect = kAtlasSearchCardImageAspectRatio;
  processSearchCardPlantFile(
    src,
    dest,
    plantFill: _plantFillFor(id),
    aspectRatio: aspect,
    plantAlignY: _plantAlignYFor(id),
  );
  final h = (kAtlasSearchCardWidth / aspect).round();
  stdout.writeln(
    'OK: ${dest.path} (${dest.lengthSync()} bytes, ${kAtlasSearchCardWidth}×$h, ratio $aspect)',
  );
  stdout.writeln('Bron: ${src.path}');
}

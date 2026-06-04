// Toont catalogus en ontbrekende atlas-PNG's.
//
//   dart run tool/export_plant_catalog.dart
//   dart run tool/export_plant_catalog.dart --write-missing

import 'dart:io';

import 'plant_catalog_loader.dart';

Future<void> main(List<String> args) async {
  final writeMissing = args.contains('--write-missing');
  final catalog = loadPlantCatalog();
  final destDir = Directory(
    '${Directory.current.path}${Platform.pathSeparator}'
    'assets${Platform.pathSeparator}images${Platform.pathSeparator}vegetables',
  );

  final missing = <PlantCatalogEntry>[];
  for (final plant in catalog) {
    final file = File('${destDir.path}${Platform.pathSeparator}${plant.id}.png');
    if (!file.existsSync()) missing.add(plant);
  }

  stdout.writeln('Catalogus: ${catalog.length} planten');
  stdout.writeln('Iconen aanwezig: ${catalog.length - missing.length}');
  stdout.writeln('Ontbrekend: ${missing.length}');

  if (writeMissing) {
    final out = File(
      '${destDir.path}${Platform.pathSeparator}missing_icons.txt',
    );
    final buf = StringBuffer();
    for (final p in missing) {
      buf.writeln('${p.id}|${p.nameNl}');
    }
    out.writeAsStringSync(buf.toString());
    stdout.writeln('Geschreven: ${out.path}');
  } else {
    for (final p in missing.take(40)) {
      stdout.writeln('  ${p.id} — ${p.nameNl}');
    }
    if (missing.length > 40) {
      stdout.writeln('  … en ${missing.length - 40} meer');
    }
    stdout.writeln('\nTip: dart run tool/export_plant_catalog.dart --write-missing');
  }
}

// Verwerkt alle atlas-PNG's opnieuw (grondschijf + zwarte vlekken weg).
//
//   dart run tool/reprocess_atlas_icons.dart

import 'dart:io';

import 'plant_catalog_loader.dart';
import 'plant_icon_processing.dart';

void main() {
  final root = findProjectRoot();
  final vegDir = Directory(
    '$root${Platform.pathSeparator}assets${Platform.pathSeparator}'
    'images${Platform.pathSeparator}vegetables',
  );
  if (!vegDir.existsSync()) {
    stderr.writeln('Map niet gevonden: ${vegDir.path}');
    exit(1);
  }

  var ok = 0;
  for (final entity in vegDir.listSync()) {
    if (entity is! File) continue;
    if (!entity.path.toLowerCase().endsWith('.png')) continue;
    final name = entity.uri.pathSegments.last;
    if (name.startsWith('.')) continue;
    try {
      final processed = processAtlasPlantIconBytes(entity.readAsBytesSync());
      entity.writeAsBytesSync(processed, flush: true);
      stdout.writeln('OK: $name');
      ok++;
    } catch (e) {
      stderr.writeln('Fout $name: $e');
    }
  }

  stdout.writeln('Klaar: $ok iconen opnieuw verwerkt. Hot restart in Flutter.');
}

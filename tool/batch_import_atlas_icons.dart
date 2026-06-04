// Importeert alle PNG's uit een map naar assets/images/vegetables/<id>.png
//
//   dart run tool/batch_import_atlas_icons.dart
//   dart run tool/batch_import_atlas_icons.dart C:\pad\naar\iconen

import 'dart:io';

import 'plant_icon_processing.dart';
import 'plant_catalog_loader.dart';

/// Oude stijl-proeven / geen plant-id.
bool _isStyleVariantFilename(String id) {
  return id.startsWith('tomaat_') ||
      id.contains('_stijl_') ||
      id.contains('_geraamte_') ||
      id.endsWith('_transparant') ||
      id.contains('_atlas_set_');
}

void main(List<String> args) {
  final projectRoot = findProjectRoot();
  final destDir = Directory(
    '$projectRoot${Platform.pathSeparator}'
    'assets${Platform.pathSeparator}images${Platform.pathSeparator}vegetables',
  );
  destDir.createSync(recursive: true);

  final sources = <Directory>[
    if (args.isNotEmpty) Directory(args.first),
    Directory(
      '$projectRoot${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'images${Platform.pathSeparator}incoming',
    ),
    Directory(r'C:\Users\frede\.cursor\projects\empty-window\assets\atlas_icons'),
    Directory(r'C:\Users\frede\.cursor\projects\empty-window\assets'),
  ];

  final knownIds = loadPlantCatalog().map((e) => e.id).toSet();
  stdout.writeln('Catalogus: ${knownIds.length} planten');

  var ok = 0;
  var skip = 0;
  final done = <String>{};

  for (final dir in sources) {
    if (!dir.existsSync()) continue;
    for (final entity in dir.listSync()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      if (!name.toLowerCase().endsWith('.png')) continue;
      final id = name.replaceAll(RegExp(r'\.png$', caseSensitive: false), '');
      if (!RegExp(r'^[a-z0-9_]+$').hasMatch(id)) continue;
      if (_isStyleVariantFilename(id)) continue;
      if (done.contains(id)) continue;
      if (!knownIds.contains(id)) {
        stderr.writeln('Onbekend id (overgeslagen): $id');
        skip++;
        continue;
      }
      final dest = File('${destDir.path}${Platform.pathSeparator}$id.png');
      processAtlasPlantIconFile(entity, dest);
      stdout.writeln('OK: $id');
      done.add(id);
      ok++;
    }
  }

  stdout.writeln('Klaar: $ok iconen geïmporteerd, $skip onbekend.');
}

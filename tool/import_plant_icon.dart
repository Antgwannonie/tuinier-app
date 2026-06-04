// Importeer één atlas-icoon: wit weg, transparant, bijgesneden.
//
//   dart run tool/import_plant_icon.dart <plant_id> [bron.png]
//   dart run tool/import_plant_icon.dart tomaat
//   dart run tool/import_plant_icon.dart radijs C:\pad\radijs.png

import 'dart:io';

import 'plant_icon_processing.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln('Gebruik: dart run tool/import_plant_icon.dart <plant_id> [bron.png]');
    exit(1);
  }

  final id = args.first.trim();
  if (!RegExp(r'^[a-z0-9_]+$').hasMatch(id)) {
    stderr.writeln('Ongeldige plant_id: $id');
    exit(1);
  }

  final projectRoot = Directory.current;
  final dest = File(
    '${projectRoot.path}${Platform.pathSeparator}'
    'assets${Platform.pathSeparator}images${Platform.pathSeparator}'
    'vegetables${Platform.pathSeparator}$id.png',
  );
  dest.parent.createSync(recursive: true);

  final customSource = args.length > 1 ? args[1].trim() : null;
  final candidates = <String>[
    if (customSource != null && customSource.isNotEmpty) customSource,
    '${projectRoot.path}${Platform.pathSeparator}assets${Platform.pathSeparator}'
        'images${Platform.pathSeparator}incoming${Platform.pathSeparator}$id.png',
    r'C:\Users\frede\.cursor\projects\empty-window\assets\$id.png'
        .replaceFirst(r'$id', id),
    r'C:\Users\frede\.cursor\projects\empty-window\assets\atlas_icons\$id.png'
        .replaceFirst(r'$id', id),
    if (dest.existsSync()) dest.path,
  ];

  for (final path in candidates) {
    final f = File(path);
    if (!f.existsSync()) continue;
    processAtlasPlantIconFile(f, dest);
    stdout.writeln('OK: $id → ${dest.path} (${dest.lengthSync()} bytes)');
    return;
  }

  stderr.writeln('Geen bron voor $id. Plaats PNG in assets/images/incoming/$id.png');
  exit(1);
}

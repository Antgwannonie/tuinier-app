// Eenmalig: zet het aardappel-icoon in assets/.
// Gebruik: dart run tool/import_aardappel_icon.dart
// Of met eigen bestand: dart run tool/import_aardappel_icon.dart "C:\pad\aardappel.png"

import 'dart:io';

import 'package:http/http.dart' as http;

const _fallbackUrl =
    'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Patates.jpg/512px-Patates.jpg';

void main(List<String> args) async {
  final projectRoot = Directory.current;
  final dest = File(
    '${projectRoot.path}${Platform.pathSeparator}'
    'assets${Platform.pathSeparator}images${Platform.pathSeparator}'
    'vegetables${Platform.pathSeparator}aardappel.png',
  );
  dest.parent.createSync(recursive: true);

  final candidates = <String>[
    if (args.isNotEmpty) args.first,
    r'C:\Users\frede\.cursor\projects\empty-window\assets\aardappel.png',
    '${projectRoot.path}${Platform.pathSeparator}assets${Platform.pathSeparator}'
        'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}'
        'aardappel-source.png',
  ];

  for (final path in candidates) {
    final f = File(path);
    if (f.existsSync()) {
      f.copySync(dest.path);
      stdout.writeln('OK (lokaal): ${dest.path} (${dest.lengthSync()} bytes)');
      return;
    }
  }

  stdout.writeln('Geen lokaal bestand — download fallback…');
  final response = await http.get(Uri.parse(_fallbackUrl));
  if (response.statusCode != 200) {
    stderr.writeln('Download mislukt (${response.statusCode}). '
        'Plaats handmatig: assets/images/vegetables/aardappel.png');
    exit(1);
  }
  await dest.writeAsBytes(response.bodyBytes);
  stdout.writeln('OK (download): ${dest.path} (${dest.lengthSync()} bytes)');
}

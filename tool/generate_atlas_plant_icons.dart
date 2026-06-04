// Genereert atlas-iconen via Gemini (zelfde stijl als tomaat).
//
//   dart pub get
//   dart run tool/generate_atlas_plant_icons.dart --limit 5
//   dart run tool/generate_atlas_plant_icons.dart --id radijs
//   dart run tool/generate_atlas_plant_icons.dart --missing
//
// Vereist: lib/config/local_gemini_key.dart of GEMINI_API_KEY in omgeving.

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../lib/config/local_gemini_key.dart';
import 'plant_catalog_loader.dart';
import 'plant_icon_processing.dart';

const _models = [
  'gemini-2.5-flash-image',
  'gemini-2.0-flash-preview-image-generation',
  'imagen-3.0-generate-002',
];

Future<void> main(List<String> args) async {
  final onlyId = _argValue(args, '--id');
  final missingOnly = args.contains('--missing');
  final limit = int.tryParse(_argValue(args, '--limit') ?? '') ?? 9999;
  final delayMs = int.tryParse(_argValue(args, '--delay-ms') ?? '') ?? 2500;

  final apiKey = Platform.environment['GEMINI_API_KEY']?.trim() ??
      localGeminiApiKey.trim();
  if (apiKey.isEmpty) {
    stderr.writeln('Geen API-sleutel. Zet local_gemini_key.dart of GEMINI_API_KEY.');
    exit(1);
  }

  final catalog = loadPlantCatalog();
  final destDir = Directory(
    '${Directory.current.path}${Platform.pathSeparator}'
    'assets${Platform.pathSeparator}images${Platform.pathSeparator}vegetables',
  );
  destDir.createSync(recursive: true);

  var todo = catalog;
  if (onlyId != null) {
    todo = catalog.where((e) => e.id == onlyId).toList();
    if (todo.isEmpty) {
      stderr.writeln('Onbekende plant_id: $onlyId');
      exit(1);
    }
  } else if (missingOnly) {
    todo = catalog
        .where((e) => !File('${destDir.path}${Platform.pathSeparator}${e.id}.png').existsSync())
        .toList();
  }

  if (todo.length > limit) {
    todo = todo.take(limit).toList();
  }

  final styleRefB64 = _loadStyleReferenceBase64(destDir);
  if (styleRefB64 != null) {
    stdout.writeln('Stijlreferentie: tomaat.png');
  } else {
    stdout.writeln('Let op: tomaat.png ontbreekt — geen visuele referentie.');
  }

  stdout.writeln('${todo.length} van ${catalog.length} iconen te genereren…');
  var ok = 0;
  var fail = 0;
  final failLog = File(
    '${Directory.current.path}${Platform.pathSeparator}'
    'assets${Platform.pathSeparator}images${Platform.pathSeparator}'
    'vegetables${Platform.pathSeparator}generate_failures.log',
  );

  for (final plant in todo) {
    stdout.write('${plant.id} (${plant.nameNl})… ');
    try {
      final bytes = await _generatePng(
        apiKey,
        atlasIconPrompt(plant.nameNl),
        styleRefB64: styleRefB64,
      );
      if (bytes == null || bytes.isEmpty) {
        stdout.writeln('geen beeld');
        fail++;
        continue;
      }
      final processed = processAtlasPlantIconBytes(bytes);
      final dest = File('${destDir.path}${Platform.pathSeparator}${plant.id}.png');
      dest.writeAsBytesSync(processed);
      stdout.writeln('OK (${dest.lengthSync()} bytes)');
      ok++;
    } catch (e) {
      stdout.writeln('fout: $e');
      failLog.writeAsStringSync('${plant.id}: $e\n', mode: FileMode.append);
      fail++;
    }
    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
  }

  stdout.writeln('Klaar: $ok gelukt, $fail mislukt. Hot restart in de app.');
}

String? _argValue(List<String> args, String flag) {
  final i = args.indexOf(flag);
  if (i < 0 || i + 1 >= args.length) return null;
  return args[i + 1];
}

String? _loadStyleReferenceBase64(Directory destDir) {
  final ref = File('${destDir.path}${Platform.pathSeparator}tomaat.png');
  if (!ref.existsSync()) return null;
  return base64Encode(ref.readAsBytesSync());
}

Future<Uint8List?> _generatePng(
  String apiKey,
  String prompt, {
  String? styleRefB64,
}) async {
  Object? lastError;
  for (final model in _models) {
    try {
      if (model.startsWith('imagen')) {
        final b = await _generateImagen(apiKey, model, prompt);
        if (b != null) return b;
      } else {
        final b = await _generateGeminiImage(
          apiKey,
          model,
          prompt,
          styleRefB64: styleRefB64,
        );
        if (b != null) return b;
      }
    } catch (e) {
      lastError = e;
    }
  }
  throw Exception('Geen model werkte: $lastError');
}

Future<Uint8List?> _generateGeminiImage(
  String apiKey,
  String model,
  String prompt, {
  String? styleRefB64,
}) async {
  final parts = <Map<String, dynamic>>[];
  if (styleRefB64 != null && styleRefB64.isNotEmpty) {
    parts.add({
      'inlineData': {'mimeType': 'image/png', 'data': styleRefB64},
    });
    parts.add({
      'text':
          'The PNG above is the tomato atlas icon (style reference). Create a '
          'NEW vegetable icon in the EXACT same semi-realistic 3D style, layout, '
          'soil disc, transparency, and color saturation — only change the plant '
          'species to match this brief:\n$prompt',
    });
  } else {
    parts.add({'text': prompt});
  }

  final uri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
  );
  final response = await http
      .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          'contents': [
            {'parts': parts},
          ],
          'generationConfig': {
            'responseModalities': ['IMAGE'],
          },
        }),
      )
      .timeout(const Duration(seconds: 90));

  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode}: ${response.body}');
  }

  return _extractImageBytes(jsonDecode(response.body) as Map<String, dynamic>);
}

Future<Uint8List?> _generateImagen(
  String apiKey,
  String model,
  String prompt,
) async {
  final uri = Uri.parse(
    'https://generativelanguage.googleapis.com/v1beta/models/$model:predict',
  );
  final response = await http
      .post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': apiKey,
        },
        body: jsonEncode({
          'instances': [
            {'prompt': prompt},
          ],
          'parameters': {
            'sampleCount': 1,
            'aspectRatio': '1:1',
          },
        }),
      )
      .timeout(const Duration(seconds: 90));

  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode}: ${response.body}');
  }

  final decoded = jsonDecode(response.body) as Map<String, dynamic>;
  final predictions = decoded['predictions'] as List<dynamic>?;
  if (predictions == null || predictions.isEmpty) return null;
  final b64 = predictions.first['bytesBase64Encoded'] as String?;
  if (b64 == null) return null;
  return base64Decode(b64);
}

Uint8List? _extractImageBytes(Map<String, dynamic> decoded) {
  final candidates = decoded['candidates'] as List<dynamic>?;
  if (candidates == null || candidates.isEmpty) return null;
  final content = candidates.first['content'] as Map<String, dynamic>?;
  final parts = content?['parts'] as List<dynamic>?;
  if (parts == null) return null;
  for (final part in parts) {
    if (part is! Map<String, dynamic>) continue;
    final inline = part['inlineData'] as Map<String, dynamic>?;
    if (inline == null) continue;
    final data = inline['data'] as String?;
    if (data != null && data.isNotEmpty) {
      return base64Decode(data);
    }
  }
  return null;
}

// Zoekt lijsticonen met typische verwerkingsfout (gaten / stipjes zoals avocado).
//
//   dart run tool/detect_beschadigde_lijst.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../lib/data/vegetable_image_info.dart';

/// Donker fruit / paddenstoelen: oude pipeline at gaten in het midden.
const _hoogRisicoIds = {
  'avocado',
  'aubergine',
  'aardpeer',
  'artisjok',
  'blauwe_bes',
  'blauwe_regen_bes',
  'druif',
  'rode_druif',
  'witte_druif',
  'pruim',
  'pruimenboom',
  'olijf',
  'walnoot',
  'hazelnoot',
  'maiskolf',
  'champignon_wit',
  'champignon_bruin',
  'shiitake',
  'oesterzwam',
  'lions_mane',
  'enoki',
  'shimeji',
  'portobello',
  'prei',
  'knoflook',
  'knoflook_hardnekkig',
  'ui',
  'look',
  'bleekselderij',
  'boerenkool',
  'broccoli',
  'bloemkool',
  'bloemkool_paars',
  'spruitkool',
  'spruitkool_rood',
  'chinese_kool',
  'andijvie',
  'paksoi',
  'paksoi_jong',
  'komkommer',
  'courgette',
  'courgette_geel',
  'augurk',
  'tomaat',
  'aubergine',
  'peper',
  'rode_paprika',
  'paprika_geel',
  'paprika_rood',
  'bruine_boon',
  'cayenne_peper',
  'chilipeper',
};

/// Batch die vaak opnieuw verwerkt werd (hergen + LAAD_LIJST).
const _hergenBatchIds = {
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
};

class _ScanResult {
  _ScanResult({
    required this.id,
    required this.path,
    required this.fileBytes,
    required this.holePixels,
    required this.centerTransparentRatio,
    required this.score,
  });

  final String id;
  final String path;
  final int fileBytes;
  final int holePixels;
  final double centerTransparentRatio;
  final double score;
}

void main() {
  final root = Directory.current.path;
  final vegDir = '$root${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}';

  final results = <_ScanResult>[];
  var missing = 0;

  for (final e in kVegetableImages.entries) {
    final asset = e.value.assetPath;
    if (asset == null || !asset.contains('_lijst.png')) continue;

    final id = e.key;
    final file = File('$vegDir${id}_lijst.png');
    if (!file.existsSync()) {
      missing++;
      continue;
    }

    final bytes = file.readAsBytesSync();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) continue;

    final w = decoded.width;
    final h = decoded.height;
    var holes = 0;
    var centerTransparent = 0;
    var centerTotal = 0;

    final x0 = (w * 0.15).round();
    final x1 = (w * 0.85).round();
    final y0 = (h * 0.15).round();
    final y1 = (h * 0.85).round();

    for (var y = 0; y < h; y++) {
      for (var x = 0; x < w; x++) {
        final p = decoded.getPixel(x, y);
        final a = p.a.toInt();
        final inCenter = x >= x0 && x < x1 && y >= y0 && y < y1;
        if (inCenter) {
          centerTotal++;
          if (a < 40) centerTransparent++;
        }

        if (a >= 40) continue;
        // Gat in plant: transparant met meerdere ondoorzichtige buren.
        var opaqueNeighbors = 0;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= w || ny >= h) continue;
            if (decoded.getPixel(nx, ny).a.toInt() >= 120) opaqueNeighbors++;
          }
        }
        if (opaqueNeighbors >= 4) holes++;
      }
    }

    final centerRatio =
        centerTotal == 0 ? 0.0 : centerTransparent / centerTotal;
    // Score: veel gaten + veel transparantie in het midden + klein bestand.
    final tinyFile = bytes.length < 25000 ? 1.0 : 0.0;
    final score = holes * 2.0 + centerRatio * 800 + tinyFile * 120;

    if (score >= 80 || holes >= 40 || (bytes.length < 15000 && centerRatio > 0.25)) {
      results.add(
        _ScanResult(
          id: id,
          path: file.path,
          fileBytes: bytes.length,
          holePixels: holes,
          centerTransparentRatio: centerRatio,
          score: score,
        ),
      );
    }
  }

  results.sort((a, b) => b.score.compareTo(a.score));

  stdout.writeln('=== Waarschijnlijk beschadigd (zoals avocado) ===');
  stdout.writeln('(gaten in plant / veel transparantie midden / klein PNG-bestand)\n');
  for (final r in results) {
    final tags = <String>[];
    if (_hoogRisicoIds.contains(r.id)) tags.add('donker fruit/groente');
    if (_hergenBatchIds.contains(r.id)) tags.add('hergen-batch');
    final tagStr = tags.isEmpty ? '' : ' [${tags.join(', ')}]';
    stdout.writeln(
      '${r.id.padRight(28)} '
      'gaten=${r.holePixels.toString().padLeft(5)} '
      'midden=${(r.centerTransparentRatio * 100).toStringAsFixed(1)}% '
      '${(r.fileBytes / 1024).toStringAsFixed(1)} KB$tagStr',
    );
  }
  stdout.writeln('\nTotaal verdacht: ${results.length}');
  stdout.writeln('Ontbrekend _lijst.png: $missing');

  stdout.writeln('\n=== Hoog risico (logica, nog niet gescand) ===');
  final hoog = _hoogRisicoIds.toList()..sort();
  for (final id in hoog) {
    if (kVegetableImages[id]?.assetPath?.contains('_lijst.png') != true) continue;
    final already = results.any((r) => r.id == id);
    if (!already) stdout.writeln('$id (check visueel in app)');
  }

  stdout.writeln('\n=== Hergen-batch (opnieuw verwerkt) ===');
  stdout.writeln(_hergenBatchIds.join(', '));
  stdout.writeln(
    '\nFix: GEN_VERVANG_LIJST_FIX.cmd in tuinier_app (nieuwe verwerking).',
  );
}

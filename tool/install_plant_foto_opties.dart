// Verwerkt 3 detail-banner bronnen per gewas + actieve lijstkaart.
//
//   dart run tool/install_plant_foto_opties.dart
//   dart run tool/install_plant_foto_opties.dart tomaat paprika

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'plant_icon_processing.dart';

const _detailBannerAspect = 1.38;

const _cursorAssets =
    r'C:\Users\frede\.cursor\projects\c-Users-frede-tuinier-app\assets';

class _PlantFotoJob {
  const _PlantFotoJob({
    required this.id,
    required this.activeOptie,
    required this.bronPrefix,
    this.bannerFocusY = 0.48,
    this.listFocusY = 0.48,
  });

  final String id;
  final String activeOptie;
  final String bronPrefix;
  final double bannerFocusY;
  final double listFocusY;
}

const _allJobs = [
  _PlantFotoJob(
    id: 'komkommer',
    activeOptie: 'b',
    bronPrefix: 'komkommer_natuur',
  ),
  _PlantFotoJob(
    id: 'tomaat',
    activeOptie: 'a',
    bronPrefix: 'tomaat_natuur',
  ),
  _PlantFotoJob(
    id: 'rode_paprika',
    activeOptie: 'b',
    bronPrefix: 'paprika_natuur',
    bannerFocusY: 0.46,
    listFocusY: 0.46,
  ),
];

void main(List<String> args) {
  final wanted = args.map((a) => a.trim().toLowerCase()).where((a) => a.isNotEmpty);
  final jobs = wanted.isEmpty
      ? _allJobs
      : _allJobs.where((j) => wanted.contains(j.id)).toList();

  if (jobs.isEmpty) {
    stderr.writeln('Geen gewassen. Kies uit: komkommer, tomaat, paprika.');
    exit(1);
  }

  final root = Directory.current.path;
  final vegDir = '$root${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}';

  for (final job in jobs) {
    stdout.writeln('--- ${job.id} ---');
    for (final label in ['a', 'b', 'c']) {
      _processDetailOptie(
        vegDir: vegDir,
        id: job.id,
        label: label,
        bronName: '${job.bronPrefix}_${label}_bron.png',
        focusY: job.bannerFocusY,
      );
    }
    _applyActiveAssets(
      vegDir: vegDir,
      job: job,
    );
  }
}

void _processDetailOptie({
  required String vegDir,
  required String id,
  required String label,
  required String bronName,
  required double focusY,
}) {
  final src = _resolveBron(vegDir, bronName);
  if (src == null) {
    stderr.writeln('Bron ontbreekt: $bronName');
    return;
  }

  if (src.path != '$vegDir$bronName') {
    src.copySync('$vegDir$bronName');
  }

  final decoded = img.decodeImage(src.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Kon $bronName niet lezen.');
    return;
  }

  final trimmed = trimLightBorders(decoded, threshold: 210);
  final banner = coverCropToDetailBanner(
    trimmed,
    width: 1024,
    aspectRatio: _detailBannerAspect,
    focusY: focusY,
  );

  final dest = File('${vegDir}${id}_detail_$label.png');
  dest.writeAsBytesSync(Uint8List.fromList(img.encodePng(banner)));
  stdout.writeln(
    'OK optie $label: ${dest.path} (${dest.lengthSync()} bytes)',
  );
}

void _applyActiveAssets({
  required String vegDir,
  required _PlantFotoJob job,
}) {
  final bronName = '${job.bronPrefix}_${job.activeOptie}_bron.png';
  final src = _resolveBron(vegDir, bronName);
  if (src == null) {
    stderr.writeln('Actieve bron ontbreekt: $bronName');
    return;
  }

  final decoded = img.decodeImage(src.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Kon actieve bron niet lezen: $bronName');
    return;
  }

  final trimmed = trimLightBorders(decoded, threshold: 210);
  final listCard = coverCropToSearchCard(
    trimmed,
    width: 1024,
    aspectRatio: 1.0,
    focusY: job.listFocusY,
  );

  final listDest = File('${vegDir}${job.id}_lijst.png');
  listDest.writeAsBytesSync(Uint8List.fromList(img.encodePng(listCard)));
  stdout.writeln(
    'OK lijstkaart (${job.id}, optie ${job.activeOptie}): ${listDest.path} '
    '(${listDest.lengthSync()} bytes)',
  );

  final detailSrc = File('${vegDir}${job.id}_detail_${job.activeOptie}.png');
  if (detailSrc.existsSync()) {
    detailSrc.copySync('${vegDir}${job.id}_detail.png');
    stdout.writeln(
      'OK detail-kopie: ${job.id}_detail.png ← ${job.activeOptie}',
    );
  }
}

File? _resolveBron(String vegDir, String bronName) {
  for (final path in [
    File('$vegDir$bronName'),
    File('$_cursorAssets${Platform.pathSeparator}$bronName'),
  ]) {
    if (path.existsSync()) return path;
  }
  return null;
}

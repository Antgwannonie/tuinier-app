// Verwerkt 3 detail-banner bronnen voor komkommer (kiezen in vegetable_image_info).
//
//   dart run tool/install_komkommer_detail_opties.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'plant_icon_processing.dart';

const _detailBannerAspect = 1.38;

/// Actieve keuze voor detail + alle kaartframes in de app.
const _activeOptie = 'b';

const _opties = [
  ('a', 'komkommer_natuur_a_bron.png'),
  ('b', 'komkommer_natuur_b_bron.png'),
  ('c', 'komkommer_natuur_c_bron.png'),
];

void main() {
  final root = Directory.current.path;
  final vegDir = '$root${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}';
  final cursorAssets =
      r'C:\Users\frede\.cursor\projects\c-Users-frede-tuinier-app\assets';

  for (final (label, bronName) in _opties) {
    final candidates = [
      File('$vegDir$bronName'),
      File('$cursorAssets${Platform.pathSeparator}$bronName'),
    ];

    File? src;
    for (final f in candidates) {
      if (f.existsSync()) {
        src = f;
        break;
      }
    }

    if (src == null) {
      stderr.writeln('Bron ontbreekt: $bronName');
      continue;
    }

    if (src.path != '${vegDir}$bronName') {
      src.copySync('${vegDir}$bronName');
    }

    final decoded = img.decodeImage(src.readAsBytesSync());
    if (decoded == null) {
      stderr.writeln('Kon $bronName niet lezen.');
      continue;
    }

    final trimmed = trimLightBorders(decoded, threshold: 210);
    final banner = coverCropToDetailBanner(
      trimmed,
      width: 1024,
      aspectRatio: _detailBannerAspect,
      focusY: 0.48,
    );

    final dest = File('${vegDir}komkommer_detail_$label.png');
    dest.writeAsBytesSync(Uint8List.fromList(img.encodePng(banner)));
    stdout.writeln(
      'OK optie $label: ${dest.path} (${dest.lengthSync()} bytes)',
    );
  }

  _applyActiveAssets(vegDir, cursorAssets);
}

void _applyActiveAssets(String vegDir, String cursorAssets) {
  final bronName = 'komkommer_natuur_${_activeOptie}_bron.png';
  final candidates = [
    File('$vegDir$bronName'),
    File('$cursorAssets${Platform.pathSeparator}$bronName'),
  ];

  File? src;
  for (final f in candidates) {
    if (f.existsSync()) {
      src = f;
      break;
    }
  }

  if (src == null) {
    stderr.writeln('Actieve bron ontbreekt: $bronName');
    return;
  }

  final decoded = img.decodeImage(src.readAsBytesSync());
  if (decoded == null) {
    stderr.writeln('Kon actieve bron niet lezen.');
    return;
  }

  final trimmed = trimLightBorders(decoded, threshold: 210);
  final listCard = coverCropToSearchCard(
    trimmed,
    width: 1024,
    aspectRatio: 1.0,
    focusY: 0.48,
  );

  final listDest = File('${vegDir}komkommer_lijst.png');
  listDest.writeAsBytesSync(Uint8List.fromList(img.encodePng(listCard)));
  stdout.writeln(
    'OK lijstkaart (optie $_activeOptie): ${listDest.path} '
    '(${listDest.lengthSync()} bytes, 1024×1024)',
  );

  final detailSrc = File('${vegDir}komkommer_detail_$_activeOptie.png');
  if (detailSrc.existsSync()) {
    detailSrc.copySync('${vegDir}komkommer_detail.png');
    stdout.writeln('OK detail-kopie: komkommer_detail.png ← $_activeOptie');
  }
}

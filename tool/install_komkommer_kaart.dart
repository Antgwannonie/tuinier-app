// Volledige komkommer-foto met achtergrond, strak gecentreerd op de plant.
//
//   dart run tool/install_komkommer_kaart.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import 'plant_icon_processing.dart';

/// Sync met [PlantDetailDesign.detailBannerAspectRatio] in de app.
const _detailBannerAspect = 1.38;

void main() {
  const id = 'komkommer';
  final root = Directory.current.path;
  final vegDir = '$root${Platform.pathSeparator}assets${Platform.pathSeparator}'
      'images${Platform.pathSeparator}vegetables${Platform.pathSeparator}';

  final listSources = [
    File('${vegDir}${id}_natuur_b_bron.png'),
    File('${vegDir}${id}_lijst_icon_bron.png'),
    File('${vegDir}${id}_kaart_bron.png'),
    File('${vegDir}${id}_detail_bron.png'),
  ];

  final detailSources = [
    File('${vegDir}${id}_detail_b.png'),
    File('${vegDir}${id}_natuur_b_bron.png'),
    File('${vegDir}${id}_detail_bron.png'),
    File('${vegDir}${id}_lijst_icon_bron.png'),
    File('${vegDir}${id}_kaart_bron.png'),
  ];

  File? listSrc;
  for (final f in listSources) {
    if (f.existsSync()) {
      listSrc = f;
      break;
    }
  }

  File? detailSrc;
  for (final f in detailSources) {
    if (f.existsSync()) {
      detailSrc = f;
      break;
    }
  }

  if (listSrc == null && detailSrc == null) {
    stderr.writeln('Geen bron gevonden voor $id.');
    exit(1);
  }

  final listDecoded = listSrc != null
      ? img.decodeImage(listSrc.readAsBytesSync())
      : null;
  final detailDecoded = detailSrc != null
      ? img.decodeImage(detailSrc.readAsBytesSync())
      : null;

  if (listDecoded == null && detailDecoded == null) {
    stderr.writeln('Kon bron niet lezen.');
    exit(1);
  }

  final listBase = listDecoded ?? detailDecoded!;
  final detailBase = detailDecoded ?? listDecoded!;

  final listTrimmed = trimLightBorders(listBase, threshold: 210);
  final detailTrimmed = trimLightBorders(detailBase, threshold: 210);

  // Volledige cover-crop: vult elk kader zonder groene/zwarte randen.
  final cropped = coverCropToSearchCard(
    listTrimmed,
    width: 1024,
    aspectRatio: 1.0,
    focusY: 0.50,
  );

  final banner = coverCropToDetailBanner(
    detailTrimmed,
    width: 1024,
    aspectRatio: _detailBannerAspect,
    focusY: 0.46,
  );

  final dest = File('${vegDir}${id}_lijst.png');
  dest.parent.createSync(recursive: true);
  dest.writeAsBytesSync(Uint8List.fromList(img.encodePng(cropped)));

  final detailDest = File('${vegDir}${id}_detail.png');
  detailDest.writeAsBytesSync(Uint8List.fromList(img.encodePng(banner)));

  stdout.writeln(
    'OK: ${dest.path} (${dest.lengthSync()} bytes, 1024×1024 cover-crop)',
  );
  stdout.writeln(
    'OK: ${detailDest.path} (${detailDest.lengthSync()} bytes, detail banner)',
  );
}

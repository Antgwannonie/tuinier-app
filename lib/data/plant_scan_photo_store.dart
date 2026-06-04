import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// Bewaart scanfoto's lokaal per gewas (voor pictogram en vergelijking).
class PlantScanPhotoStore {
  PlantScanPhotoStore._();

  static const _subdir = 'scan_photos';

  static Future<Directory> _vegDir(String vegetableId) async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory('${root.path}/$_subdir/$vegetableId');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Slaat JPEG op; retourneert absoluut pad.
  static Future<String> saveScanPhoto(
    String vegetableId,
    Uint8List bytes,
  ) async {
    final dir = await _vegDir(vegetableId);
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static bool exists(String? path) {
    if (path == null || path.isEmpty) return false;
    return File(path).existsSync();
  }

  static Future<void> deleteFile(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  /// Verwijdert alle foto's van één gewas (bij verwijderen uit moestuin).
  static Future<void> deleteAllFor(String vegetableId) async {
    try {
      final root = await getApplicationDocumentsDirectory();
      final dir = Directory('${root.path}/$_subdir/$vegetableId');
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {}
  }

  /// Oude paden opruimen na trim van geschiedenis.
  static Future<void> deletePaths(Iterable<String> paths) async {
    for (final p in paths) {
      await deleteFile(p);
    }
  }
}

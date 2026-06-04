import 'dart:io';

class PlantCatalogEntry {
  const PlantCatalogEntry({required this.id, required this.nameNl});
  final String id;
  final String nameNl;
}

/// Zoekt projectmap (pubspec.yaml) vanaf cwd of script-locatie.
String findProjectRoot() {
  final candidates = <String>[
    Directory.current.path,
    Platform.script.resolve('..').toFilePath(),
    Platform.script.resolve('../..').toFilePath(),
  ];
  for (final start in candidates) {
    var dir = Directory(start);
    while (true) {
      final pubspec = File('${dir.path}${Platform.pathSeparator}pubspec.yaml');
      if (pubspec.existsSync()) return dir.path;
      final parent = dir.parent;
      if (parent.path == dir.path) break;
      dir = parent;
    }
  }
  return Directory.current.path;
}

String _dataPath(String root, String relative) {
  return '$root${Platform.pathSeparator}'
      '${relative.replaceAll('/', Platform.pathSeparator)}';
}

/// Leest plant-ids en NL-namen uit de data-bestanden (geen Flutter nodig).
List<PlantCatalogEntry> loadPlantCatalog() {
  final root = findProjectRoot();
  final byId = <String, String>{};

  void addPipeFile(String relativePath) {
    final file = File(_dataPath(root, 'lib/data/$relativePath'));
    if (!file.existsSync()) return;
    final text = file.readAsStringSync();
    final re = RegExp(r'^([a-z0-9_]+)\|([^|\n]+)\|', multiLine: true);
    for (final m in re.allMatches(text)) {
      byId[m.group(1)!] = m.group(2)!.trim();
    }
  }

  void addDartIds(String relativePath) {
    final file = File(_dataPath(root, 'lib/data/$relativePath'));
    if (!file.existsSync()) return;
    final text = file.readAsStringSync();
    final blocks = text.split(
      RegExp(r'\b(?:Vegetable|nlPlant(?:Bulk)?)\s*\('),
    );
    for (final block in blocks.skip(1)) {
      final id = RegExp(r"id:\s*'([^']+)'").firstMatch(block)?.group(1);
      final name = RegExp(r"nameNl:\s*'([^']+)'").firstMatch(block)?.group(1);
      if (id != null && name != null) {
        byId.putIfAbsent(id, () => name);
      }
    }
  }

  addPipeFile('nl_common_plants_bulk.dart');
  addPipeFile('moestuin_companion_plants.dart');
  addDartIds('my_garden_plants.dart');
  addDartIds('extra_reference_vegetables.dart');
  addDartIds('new_atlas_vegetables.dart');
  addDartIds('expanded_fruit_and_plants.dart');

  final sorted = byId.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  return [
    for (final e in sorted) PlantCatalogEntry(id: e.key, nameNl: e.value),
  ];
}

String atlasIconPrompt(String nameNl) =>
    'Mobile garden app vegetable icon, EXACT same style as the tomato icon in this '
    'set: $nameNl, semi-realistic 3D digital illustration, vibrant saturated '
    'colors, soft highlights, healthy whole plant with typical leaves and edible '
    'parts visible, NO soil disc NO ground shadow NO circular base NO platform '
    'under the plant, plant only floating cleanly, FULLY TRANSPARENT PNG everywhere '
    'outside the plant, NO white box NO gray frame NO black background, '
    '512x512, consistent atlas icon series';

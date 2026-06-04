import '../lib/data/vegetable_image_info.dart';
import '../lib/data/vegetables_data.dart';

void main() {
  final done = <String>{};
  for (final e in kVegetableImages.entries) {
    if (e.value.assetPath?.contains('_lijst.png') == true) done.add(e.key);
  }
  final rows = <(String name, String id)>[];
  for (final v in kVegetablesSeed) {
    if (done.contains(v.id)) continue;
    rows.add((v.nameNl, v.id));
  }
  rows.sort((a, b) => a.$1.compareTo(b.$1));
  for (var i = 0; i < 12 && i < rows.length; i++) {
    print('${rows[i].$1} | ${rows[i].$2}');
  }
  print('total missing: ${rows.length}');
}

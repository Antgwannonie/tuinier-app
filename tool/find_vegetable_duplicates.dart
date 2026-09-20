import '../lib/data/vegetables_data.dart';
import '../lib/models/vegetable.dart';

void main() {
  final plants = kVegetablesSeed;
  print('=== ID contains another ID (possible duplicate) ===');
  for (final a in plants) {
    for (final b in plants) {
      if (a.id == b.id) continue;
      if (a.id.contains(b.id) || b.id.contains(a.id)) {
        final diff = a.id.length - b.id.length;
        if (diff < 0 ? -diff < 12 : diff < 12) {
          print('${a.id} (${a.nameNl}) <-> ${b.id} (${b.nameNl})');
        }
      }
    }
  }

  print('\n=== Similar Dutch names (normalized) ===');
  String norm(String s) => s
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '')
      .replaceAll('jes', '')
      .replaceAll('tjes', '')
      .replaceAll('jes', '');

  final byNorm = <String, List<Vegetable>>{};
  for (final v in plants) {
    final n = norm(v.nameNl);
    byNorm.putIfAbsent(n, () => []).add(v);
  }
  for (final e in byNorm.entries.where((e) => e.value.length > 1)) {
    print(
      '${e.key}: ${e.value.map((v) => '${v.id} (${v.nameNl})').join(', ')}',
    );
  }

  print('\n=== Same family + very similar name ===');
  for (var i = 0; i < plants.length; i++) {
    for (var j = i + 1; j < plants.length; j++) {
      final a = plants[i];
      final b = plants[j];
      if (a.family != b.family) continue;
      final an = a.nameNl.toLowerCase();
      final bn = b.nameNl.toLowerCase();
      if (an == bn) {
        print('SAME NAME: ${a.id} / ${b.id}');
        continue;
      }
      if (an.startsWith(bn) || bn.startsWith(an)) {
        final diff = an.length - bn.length;
        if (diff < 0 ? -diff <= 8 : diff <= 8) {
          print('${a.id} (${a.nameNl}) ~ ${b.id} (${b.nameNl}) [${a.family}]');
        }
      }
    }
  }
}

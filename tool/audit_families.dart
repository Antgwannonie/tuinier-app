import 'package:tuinier_app/data/vegetables_data.dart';

void main() {
  final families = <String>{};
  for (final v in kVegetablesSeed) {
    families.add(v.family.trim());
  }
  final sorted = families.toList()..sort();
  for (final f in sorted) {
    print(f);
  }
}

import 'package:tuinier_app/data/vegetable_display_names.dart';
import 'package:tuinier_app/data/vegetables_data.dart';

void main() {
  var noLatin = 0;
  var noEnglish = 0;
  var noCategory = 0;
  for (final v in kVegetablesSeed) {
    if (latinNameForVegetable(v) == null) noLatin++;
    if (englishNameForVegetable(v) == null) noEnglish++;
    if (plantCategoryForVegetable(v).isEmpty) noCategory++;
  }
  print('total=${kVegetablesSeed.length}');
  print('noLatin=$noLatin noEnglish=$noEnglish noCategory=$noCategory');
}

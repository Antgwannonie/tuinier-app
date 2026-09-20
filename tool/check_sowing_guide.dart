import 'package:tuinier_app/data/extra_reference_vegetables.dart';
import 'package:tuinier_app/data/plant_sowing_guide.dart';

void main() {
  final komkommer =
      kExtraReferenceVegetables.firstWhere((v) => v.id == 'komkommer');
  final guide = sowingGuideForVegetable(komkommer);
  assert(guide != null, 'guide should exist');
  assert(guide!.sections.length == 9, 'komkommer has 9 sections');
  print('OK: ${guide!.sections.length} zaai-secties voor komkommer');
}

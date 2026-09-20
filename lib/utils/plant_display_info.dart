import '../models/vegetable.dart';
import '../data/vegetables_data.dart';

export '../data/vegetable_display_names.dart'
    show englishNameForVegetable, latinNameForVegetable, plantCategoryForVegetable;

/// Planttype uit het family-veld, bv. "Vruchtgroente".
@Deprecated('Use plantCategoryForVegetable')
String? plantCategoryLabel(String family) {
  final trimmed = family.trim();
  if (trimmed.isEmpty) return null;
  final paren = trimmed.indexOf('(');
  if (paren > 0) return trimmed.substring(0, paren).trim();
  final lower = trimmed.toLowerCase();
  if (lower.contains('familie') || lower.startsWith('nachtschade')) {
    return null;
  }
  return trimmed;
}

/// Botanische familie uit haakjes, bv. "komkommerfamilie".
String? botanicalFamilyLabel(String family) {
  final start = family.indexOf('(');
  final end = family.indexOf(')');
  if (start >= 0 && end > start) {
    return family.substring(start + 1, end).trim();
  }
  final trimmed = family.trim();
  if (trimmed.toLowerCase().contains('familie')) return trimmed;
  return null;
}

String? _botanicalFamilyKey(String family) {
  final label = botanicalFamilyLabel(family);
  if (label == null || label.isEmpty) return null;
  return label.toLowerCase();
}

/// Andere planten in de app met dezelfde botanische familie.
List<String> botanicalFamilyMemberNames(Vegetable vegetable) {
  final key = _botanicalFamilyKey(vegetable.family);
  if (key == null) return const [];

  final names = <String>[];
  for (final other in kVegetablesSeed) {
    if (other.id == vegetable.id) continue;
    if (_botanicalFamilyKey(other.family) == key) {
      names.add(other.nameNl);
    }
  }
  names.sort();
  return names;
}

/// Bekende lange actieteksten → natuurlijke korte variant voor kaarten.
const _cardPhraseShortcuts = <String, String>{
  'Maak je eerste scan': 'Eerste scan',
  'Wekelijkse foto': 'Nieuwe scan',
  'Eetbaar of seizoen afronden': 'Nu oogsten',
  'Klaar om te oogsten': 'Nu oogstbaar',
};

/// Korte teksten op de hoofdpagina (plantkaarten). Volledige uitleg staat in de info-tab.
String shortTextForHomeCard(String? text, {int maxLen = 48}) {
  if (text == null) return '';
  var t = text.trim();
  if (t.isEmpty) return '';

  final shortcut = _cardPhraseShortcuts[t];
  if (shortcut != null) return shortcut;

  final semi = t.indexOf(';');
  if (semi > 0) {
    t = t.substring(0, semi).trim();
  }

  final dot = t.indexOf('. ');
  if (dot > 0 && dot < 60) {
    t = t.substring(0, dot + 1).trim();
  }

  const stripPatterns = [
    r'[;,.]?\s*goed voor bijen.*$',
    r'[;,.]?\s*nuttig voor bijen.*$',
    r'[;,.]?\s*trekt bijen.*$',
    r'[;,.]?\s*.*nuttige insecten.*$',
    r'[;,.]?\s*.*bestuiving.*$',
    r'[;,.]?\s*voedsel voor bijen.*$',
    r'[;,.]?\s*bijenmagnet.*$',
    r'[;,.]?\s*bijenplant.*$',
    r'[;,.]?\s*.*lieveheersbeestjes.*$',
    r'[;,.]?\s*.*zweefvliegen.*$',
    r'[;,.]?\s*.*hommels.*$',
  ];
  for (final p in stripPatterns) {
    t = t.replaceAll(RegExp(p, caseSensitive: false), '').trim();
  }

  t = t.replaceAll(RegExp(r'\s+'), ' ');
  if (t.endsWith(';') || t.endsWith(',')) {
    t = t.substring(0, t.length - 1).trim();
  }

  if (t.length <= maxLen) return t;
  final cut = t.substring(0, maxLen);
  final sp = cut.lastIndexOf(' ');
  if (sp > maxLen ~/ 2) {
    return '${cut.substring(0, sp).trim()}…';
  }
  return '$cut…';
}

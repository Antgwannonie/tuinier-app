import 'dart:io';

void main() {
  final src = Directory(
    r'C:\Users\frede\.cursor\projects\empty-window\assets',
  );
  final dst = Directory(
    r'C:\Users\frede\tuinier_app\assets\images\scan_hub',
  );
  dst.createSync(recursive: true);
  const files = [
    'scan_icon_vegetable.png',
    'scan_icon_herb.png',
    'scan_icon_insect.png',
    'scan_icon_disease.png',
    'scan_hero_bg.png',
  ];
  for (final name in files) {
    final from = File('${src.path}\\$name');
    if (!from.existsSync()) {
      stderr.writeln('skip (missing): $name');
      continue;
    }
    final to = File('${dst.path}\\$name');
    from.copySync(to.path);
    stdout.writeln('copied $name (${to.lengthSync()} bytes)');
  }
}

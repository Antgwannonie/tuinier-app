import 'dart:io';

void main() {
  final src = Directory(
    r'C:\Users\frede\.cursor\projects\empty-window\assets',
  );
  final dst = Directory(
    r'C:\Users\frede\tuinier_app\assets\images\moestuin_place',
  );
  dst.createSync(recursive: true);
  for (final entity in src.listSync()) {
    if (entity is! File) continue;
    final name = entity.uri.pathSegments.last;
    if (!name.startsWith('place_') || !name.endsWith('.png')) continue;
    final target = File('${dst.path}\\$name');
    entity.copySync(target.path);
    stdout.writeln('copied ${target.path}');
  }
}

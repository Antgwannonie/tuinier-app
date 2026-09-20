import 'dart:io';

void main() {
  final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
  if (home == null) {
    stderr.writeln('USERPROFILE not set');
    exit(1);
  }

  final src = Directory('$home/.cursor/projects/empty-window/assets');
  final dst = Directory('assets/images/garden_health');
  dst.createSync(recursive: true);

  var copied = 0;
  for (final name in [
    'garden_health_dying.png',
    'garden_health_weak.png',
    'garden_health_seedling.png',
    'garden_health_growing.png',
    'garden_health_flourishing.png',
  ]) {
    final file = File('${src.path}/$name');
    if (!file.existsSync()) {
      stderr.writeln('Missing: ${file.path}');
      continue;
    }
    file.copySync('${dst.path}/$name');
    copied++;
    stdout.writeln('Copied $name');
  }

  if (copied == 0) {
    stderr.writeln('No PNG files copied.');
    exit(1);
  }
}

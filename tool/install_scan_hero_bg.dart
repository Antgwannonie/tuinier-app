import 'dart:io';

void main() {
  final sources = [
    r'C:\Users\frede\.cursor\projects\empty-window\assets\scan_hero_bg.png',
  ];
  final dstDir = Directory(
    r'C:\Users\frede\tuinier_app\assets\images\scan_hub',
  );
  dstDir.createSync(recursive: true);

  var copied = false;
  for (final srcPath in sources) {
    final src = File(srcPath);
    if (!src.existsSync()) {
      stderr.writeln('bron ontbreekt: $srcPath');
      continue;
    }
    final dst = File('${dstDir.path}\\scan_hero_bg.png');
    src.copySync(dst.path);
    stdout.writeln('OK ${dst.path} (${dst.lengthSync()} bytes)');
    copied = true;
    break;
  }

  if (!copied) {
    stderr.writeln('Geen scan_hero_bg.png gekopieerd.');
    exitCode = 1;
  }
}

// Kleine zonnebloem-icoon voor «Mijn moestuin» (transparante PNG).
// dart run tool/generate_moestuin_sunflower_icon.dart

import 'dart:io';
import 'dart:math' as math;

import 'package:image/image.dart' as img;

void main() {
  const size = 128;
  const cx = size / 2;
  const cy = size * 0.42;
  final image = img.Image(width: size, height: size, numChannels: 4);
  img.fill(image, color: img.ColorRgba8(0, 0, 0, 0));

  const ink = img.ColorRgba8(30, 30, 30, 255);
  const inkSoft = img.ColorRgba8(30, 30, 30, 180);
  const fillSoft = img.ColorRgba8(30, 30, 30, 35);

  void drawPetal(double angle, double len, double width, {bool inner = false}) {
    final tipX = cx + math.cos(angle) * len;
    final tipY = cy + math.sin(angle) * len;
    final perp = angle + math.pi / 2;
    final w = width / 2;
    final baseL = Offset(cx + math.cos(perp) * w, cy + math.sin(perp) * w);
    final baseR = Offset(cx - math.cos(perp) * w, cy - math.sin(perp) * w);
    final tip = Offset(tipX, tipY);
    final midL = Offset(
      (baseL.dx + tip.dx) / 2 + math.cos(perp) * w * 0.4,
      (baseL.dy + tip.dy) / 2 + math.sin(perp) * w * 0.4,
    );
    final midR = Offset(
      (baseR.dx + tip.dx) / 2 - math.cos(perp) * w * 0.4,
      (baseR.dy + tip.dy) / 2 - math.sin(perp) * w * 0.4,
    );
    _fillTriangle(image, baseL, midL, tip, fillSoft);
    _fillTriangle(image, baseR, midR, tip, fillSoft);
    _strokeCurve(image, baseL, midL, tip, inner ? inkSoft : ink, 2);
    _strokeCurve(image, baseR, midR, tip, inner ? inkSoft : ink, 2);
  }

  // Buitenblaadjes
  const outerCount = 14;
  for (var i = 0; i < outerCount; i++) {
    final a = (i / outerCount) * 2 * math.pi - math.pi / 2;
    drawPetal(a, 46, 14);
  }

  // Binnenblaadjes
  const innerCount = 10;
  for (var i = 0; i < innerCount; i++) {
    final a = (i / innerCount) * 2 * math.pi;
    drawPetal(a, 28, 9, inner: true);
  }

  // Kern
  img.fillCircle(image, x: cx.round(), y: cy.round(), radius: 11, color: ink);
  for (var i = 0; i < 8; i++) {
    final a = (i / 8) * 2 * math.pi;
    img.fillCircle(
      image,
      x: (cx + math.cos(a) * 5.5).round(),
      y: (cy + math.sin(a) * 5.5).round(),
      radius: 2,
      color: img.ColorRgba8(255, 255, 255, 90),
    );
  }

  // Stengel + blaadjes
  _strokeLine(image, cx, cy + 12, cx - 1, size - 18, ink, 3);
  _strokeCurve(
    image,
    Offset(cx, cy + 28),
    Offset(cx - 14, cy + 24),
    Offset(cx - 10, cy + 36),
    inkSoft,
    2,
  );
  _strokeCurve(
    image,
    Offset(cx, cy + 42),
    Offset(cx + 12, cy + 38),
    Offset(cx + 8, cy + 50),
    inkSoft,
    2,
  );

  final out = File('assets/images/moestuin_zonnebloem_icon.png');
  out.parent.createSync(recursive: true);
  out.writeAsBytesSync(img.encodePng(image));
  // ignore: avoid_print
  print('Wrote ${out.path} (${out.lengthSync()} bytes)');
}

class Offset {
  const Offset(this.dx, this.dy);
  final double dx;
  final double dy;
}

void _fillTriangle(
  img.Image image,
  Offset a,
  Offset b,
  Offset c,
  img.ColorRgba8 color,
) {
  img.fillPolygon(
    image,
    x: [a.dx.round(), b.dx.round(), c.dx.round()],
    y: [a.dy.round(), b.dy.round(), c.dy.round()],
    color: color,
  );
}

void _strokeLine(
  img.Image image,
  double x0,
  double y0,
  double x1,
  double y1,
  img.ColorRgba8 color,
  int thickness,
) {
  img.drawLine(
    image,
    x1: x0.round(),
    y1: y0.round(),
    x2: x1.round(),
    y2: y1.round(),
    color: color,
    thickness: thickness,
    antialias: true,
  );
}

void _strokeCurve(
  img.Image image,
  Offset a,
  Offset b,
  Offset c,
  img.ColorRgba8 color,
  int thickness,
) {
  var px = a.dx;
  var py = a.dy;
  for (var t = 0.05; t <= 1.0; t += 0.05) {
    final x = _quad(a.dx, b.dx, c.dx, t);
    final y = _quad(a.dy, b.dy, c.dy, t);
    img.drawLine(
      image,
      x1: px.round(),
      y1: py.round(),
      x2: x.round(),
      y2: y.round(),
      color: color,
      thickness: thickness,
      antialias: true,
    );
    px = x;
    py = y;
  }
}

double _quad(double a, double b, double c, double t) {
  final u = 1 - t;
  return u * u * a + 2 * u * t * b + t * t * c;
}

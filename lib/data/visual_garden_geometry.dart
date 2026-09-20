import 'dart:math' as math;
import 'dart:ui';

import '../models/visual_garden_plan.dart';

/// Schaal: echte cm ↔ schermpixels voor één bak (bounding box).
class BedScale {
  const BedScale({
    required this.widthCm,
    required this.heightCm,
    required this.displayWidthPx,
    required this.displayHeightPx,
    this.originPx = Offset.zero,
  });

  final double widthCm;
  final double heightCm;
  final double displayWidthPx;
  final double displayHeightPx;
  final Offset originPx;

  double get pxPerCmX => displayWidthPx / widthCm;
  double get pxPerCmY => displayHeightPx / heightCm;
  double get pxPerCm => math.min(pxPerCmX, pxPerCmY);

  Offset cmToPx(double xCm, double yCm) =>
      Offset(originPx.dx + xCm * pxPerCmX, originPx.dy + yCm * pxPerCmY);

  Offset pxToCm(Offset px) => Offset(
        (px.dx - originPx.dx) / pxPerCmX,
        (px.dy - originPx.dy) / pxPerCmY,
      );

  Size zoneSizePx(double spacingCm) {
    final s = spacingCm * pxPerCm;
    return Size(s, s);
  }
}

/// Vereenvoudigt een vrije tekening tot rechte lijnen tussen hoeken.
List<Offset> straightenStrokeToPolygon(List<Offset> points) {
  if (points.length < 3) return List.of(points);

  // 1) Ramer-Douglas-Peucker-achtige vereenvoudiging
  final simplified = _rdp(points, epsilon: 10);
  if (simplified.length < 3) {
    return _boundingRectCorners(points);
  }

  // 2) Sluit polygoon: als eind dicht bij start, merge
  var corners = List<Offset>.from(simplified);
  if ((corners.first - corners.last).distance < 28) {
    corners.removeLast();
  }

  // 3) Verwijder te korte segmenten
  corners = _removeShortEdges(corners, minLen: 18);
  if (corners.length < 3) {
    return _boundingRectCorners(points);
  }

  // 4) Recht trekken: hoeken op snijpunten van gemiddelde richtingen
  corners = _snapNearOrthogonal(corners);

  return corners;
}

List<Offset> _boundingRectCorners(List<Offset> points) {
  var minX = points.first.dx, maxX = points.first.dx;
  var minY = points.first.dy, maxY = points.first.dy;
  for (final p in points) {
    minX = math.min(minX, p.dx);
    maxX = math.max(maxX, p.dx);
    minY = math.min(minY, p.dy);
    maxY = math.max(maxY, p.dy);
  }
  return [
    Offset(minX, minY),
    Offset(maxX, minY),
    Offset(maxX, maxY),
    Offset(minX, maxY),
  ];
}

List<Offset> _rdp(List<Offset> points, {required double epsilon}) {
  if (points.length < 3) return List.of(points);
  var maxDist = 0.0;
  var index = 0;
  final start = points.first;
  final end = points.last;
  for (var i = 1; i < points.length - 1; i++) {
    final d = _perpDistance(points[i], start, end);
    if (d > maxDist) {
      index = i;
      maxDist = d;
    }
  }
  if (maxDist > epsilon) {
    final left = _rdp(points.sublist(0, index + 1), epsilon: epsilon);
    final right = _rdp(points.sublist(index), epsilon: epsilon);
    return [...left.sublist(0, left.length - 1), ...right];
  }
  return [start, end];
}

double _perpDistance(Offset p, Offset a, Offset b) {
  final dx = b.dx - a.dx;
  final dy = b.dy - a.dy;
  if (dx == 0 && dy == 0) return (p - a).distance;
  final t = ((p.dx - a.dx) * dx + (p.dy - a.dy) * dy) / (dx * dx + dy * dy);
  final proj = Offset(a.dx + t * dx, a.dy + t * dy);
  return (p - proj).distance;
}

List<Offset> _removeShortEdges(List<Offset> corners, {required double minLen}) {
  if (corners.length < 3) return corners;
  final out = <Offset>[corners.first];
  for (var i = 1; i < corners.length; i++) {
    if ((corners[i] - out.last).distance >= minLen) {
      out.add(corners[i]);
    }
  }
  if (out.length >= 3 && (out.first - out.last).distance < minLen) {
    out.removeLast();
  }
  return out.length >= 3 ? out : corners;
}

/// Snap bijna-horizontale/verticale segmenten voor nettere rechte lijnen.
List<Offset> _snapNearOrthogonal(List<Offset> corners) {
  if (corners.length < 3) return corners;
  final out = List<Offset>.from(corners);
  for (var i = 0; i < out.length; i++) {
    final a = out[i];
    final b = out[(i + 1) % out.length];
    final dx = b.dx - a.dx;
    final dy = b.dy - a.dy;
    final angle = math.atan2(dy, dx).abs();
    // dicht bij 0 of π → horizontaal; dicht bij π/2 → verticaal
    final nearH = angle < 0.25 || (math.pi - angle) < 0.25;
    final nearV = (angle - math.pi / 2).abs() < 0.25;
    if (nearH) {
      final y = (a.dy + b.dy) / 2;
      out[i] = Offset(a.dx, y);
      out[(i + 1) % out.length] = Offset(b.dx, y);
    } else if (nearV) {
      final x = (a.dx + b.dx) / 2;
      out[i] = Offset(x, a.dy);
      out[(i + 1) % out.length] = Offset(x, b.dy);
    }
  }
  return out;
}

/// Bouwt een rechthoek (4 hoeken) uit lengte × breedte in cm.
List<Offset> buildRectangleCm({
  required double lengthCm,
  required double widthCm,
}) {
  final L = lengthCm.clamp(5.0, 5000.0);
  final W = widthCm.clamp(5.0, 5000.0);
  return [
    Offset.zero,
    Offset(L, 0),
    Offset(L, W),
    Offset(0, W),
  ];
}

/// Ellips / cirkel als gesloten polygoon (cm), approx. met [segments] hoeken.
List<Offset> buildEllipseCm({
  required double widthCm,
  required double heightCm,
  int segments = 24,
}) {
  final w = widthCm.clamp(5.0, 5000.0);
  final h = heightCm.clamp(5.0, 5000.0);
  final n = segments.clamp(8, 48);
  final rx = w / 2;
  final ry = h / 2;
  final verts = <Offset>[
    for (var i = 0; i < n; i++)
      Offset(
        rx + rx * math.cos(i * 2 * math.pi / n - math.pi / 2),
        ry + ry * math.sin(i * 2 * math.pi / n - math.pi / 2),
      ),
  ];
  return _normalizePolygonOrigin(verts);
}

/// Bouwt een regelmatige N-hoek met gelijke zijden.
List<Offset> buildRegularPolygonCm({
  required int corners,
  required double sideCm,
}) {
  final n = corners.clamp(3, 12);
  final side = sideCm.clamp(5.0, 5000.0);
  // Straal vanuit zijdelengte: a = 2 R sin(π/n)
  final r = side / (2 * math.sin(math.pi / n));
  final verts = <Offset>[
    for (var i = 0; i < n; i++)
      Offset(
        r * math.cos(i * 2 * math.pi / n - math.pi / 2),
        r * math.sin(i * 2 * math.pi / n - math.pi / 2),
      ),
  ];
  return _normalizePolygonOrigin(verts);
}

/// Bouwt een convexe N-hoek uit zijdelengtes (gelijke buitenhoeken).
///
/// Voor 4 hoeken met patroon L,W,L,W krijg je een nette rechthoek.
List<Offset> buildPolygonFromSideLengthsCm(List<double> sideLengthsCm) {
  assert(sideLengthsCm.length >= 3);
  final n = sideLengthsCm.length;
  final sides = <double>[
    for (final s in sideLengthsCm) s.clamp(5.0, 5000.0),
  ];

  // Rechthoek shortcut
  if (n == 4 &&
      (sides[0] - sides[2]).abs() < 0.5 &&
      (sides[1] - sides[3]).abs() < 0.5) {
    return buildRectangleCm(lengthCm: sides[0], widthCm: sides[1]);
  }

  // Alle zijden gelijk → regelmatig
  final allEqual = sides.every((s) => (s - sides.first).abs() < 0.5);
  if (allEqual) {
    return buildRegularPolygonCm(corners: n, sideCm: sides.first);
  }

  // Equiangulaire wandeling; sluit af op startpunt
  final turn = 2 * math.pi / n;
  var x = 0.0;
  var y = 0.0;
  var angle = 0.0;
  final verts = <Offset>[Offset.zero];
  for (var i = 0; i < n - 1; i++) {
    x += sides[i] * math.cos(angle);
    y += sides[i] * math.sin(angle);
    verts.add(Offset(x, y));
    angle += turn;
  }
  return _normalizePolygonOrigin(verts);
}

List<Offset> _normalizePolygonOrigin(List<Offset> verts) {
  var minX = verts.first.dx, minY = verts.first.dy;
  for (final v in verts) {
    minX = math.min(minX, v.dx);
    minY = math.min(minY, v.dy);
  }
  return [for (final v in verts) Offset(v.dx - minX, v.dy - minY)];
}

/// Legacy: bouwt cm-polygoon vanuit getekende hoeken + maten.
List<Offset> buildPolygonCmFromEdges({
  required List<Offset> cornersPx,
  required List<double?> edgeLengthsCm,
}) {
  assert(cornersPx.length >= 3);
  assert(edgeLengthsCm.length == cornersPx.length);

  final drawnLens = <double>[
    for (var i = 0; i < cornersPx.length; i++)
      math.max(
        (cornersPx[(i + 1) % cornersPx.length] - cornersPx[i]).distance,
        1,
      ),
  ];

  var scaleSum = 0.0;
  var scaleN = 0;
  for (var i = 0; i < edgeLengthsCm.length; i++) {
    final L = edgeLengthsCm[i];
    if (L != null && L > 0) {
      scaleSum += L / drawnLens[i];
      scaleN++;
    }
  }
  final avgScale = scaleN > 0 ? scaleSum / scaleN : 1.0;
  final lengths = <double>[
    for (var i = 0; i < edgeLengthsCm.length; i++)
      edgeLengthsCm[i] ?? (drawnLens[i] * avgScale),
  ];
  return buildPolygonFromSideLengthsCm(lengths);
}

bool pointInPolygon(Offset p, List<Offset> poly) {
  if (poly.length < 3) return false;
  var inside = false;
  for (var i = 0, j = poly.length - 1; i < poly.length; j = i++) {
    final xi = poly[i].dx, yi = poly[i].dy;
    final xj = poly[j].dx, yj = poly[j].dy;
    final intersect = ((yi > p.dy) != (yj > p.dy)) &&
        (p.dx <
            (xj - xi) * (p.dy - yi) / ((yj - yi) == 0 ? 1e-9 : (yj - yi)) + xi);
    if (intersect) inside = !inside;
  }
  return inside;
}

Rect _zoneAt(double xCm, double yCm, double spacingCm) {
  final half = spacingCm / 2;
  return Rect.fromLTRB(
    xCm - half,
    yCm - half,
    xCm + half,
    yCm + half,
  );
}

/// Of de volledige plantzone binnen de bak-polygoon valt.
bool plantFullyInsideBed({
  required VisualGardenBed bed,
  required double xCm,
  required double yCm,
  required double spacingCm,
}) {
  final zone = _zoneAt(xCm, yCm, spacingCm);
  final corners = [
    Offset(zone.left, zone.top),
    Offset(zone.right, zone.top),
    Offset(zone.left, zone.bottom),
    Offset(zone.right, zone.bottom),
    Offset(xCm, yCm),
  ];
  for (final c in corners) {
    if (!pointInPolygon(c, bed.verticesCm)) return false;
  }
  return true;
}

bool plantZonesOverlap({
  required double ax,
  required double ay,
  required double aSpacing,
  required double bx,
  required double by,
  required double bSpacing,
}) {
  final a = _zoneAt(ax, ay, aSpacing);
  final b = _zoneAt(bx, by, bSpacing);
  return a.overlaps(b);
}

int estimateMaxPlantsGrid({
  required VisualGardenBed bed,
  required double spacingCm,
}) {
  if (spacingCm <= 0) return 0;
  final cols = (bed.widthCm / spacingCm).floor();
  final rows = (bed.heightCm / spacingCm).floor();
  // Oppervlaktecorrectie
  final rectN = (cols * rows).clamp(0, 9999);
  final ratio = bed.areaM2 / math.max((bed.widthCm * bed.heightCm) / 10000, 0.01);
  return (rectN * ratio.clamp(0.3, 1.0)).floor();
}

class PlacementValidity {
  const PlacementValidity({
    required this.insideBed,
    required this.noOverlap,
    this.conflictingIds = const [],
  });

  final bool insideBed;
  final bool noOverlap;
  final List<String> conflictingIds;

  bool get isValid => insideBed && noOverlap;
}

PlacementValidity checkPlacement({
  required VisualGardenBed bed,
  required double xCm,
  required double yCm,
  required double spacingCm,
  required String? ignorePlacementId,
  required double Function(String plantId, double fallback) spacingFor,
}) {
  final inside = plantFullyInsideBed(
    bed: bed,
    xCm: xCm,
    yCm: yCm,
    spacingCm: spacingCm,
  );

  final conflicts = <String>[];
  for (final other in bed.placements) {
    if (ignorePlacementId != null && other.id == ignorePlacementId) continue;
    final otherSpacing = spacingFor(other.plantId, other.spacingCm);
    if (plantZonesOverlap(
      ax: xCm,
      ay: yCm,
      aSpacing: spacingCm,
      bx: other.xCm,
      by: other.yCm,
      bSpacing: otherSpacing,
    )) {
      conflicts.add(other.id);
    }
  }

  return PlacementValidity(
    insideBed: inside,
    noOverlap: conflicts.isEmpty,
    conflictingIds: conflicts,
  );
}

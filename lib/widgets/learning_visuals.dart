import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/academy_models.dart';

class LessonVisualCard extends StatelessWidget {
  const LessonVisualCard({super.key, required this.visual});

  final LessonVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: navy,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cyan.withOpacity(.16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _LearningPainter(visual),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _LearningPainter extends CustomPainter {
  _LearningPainter(this.visual);

  final LessonVisual visual;

  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()
      ..color = Colors.white.withOpacity(.035)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    switch (visual) {
      case LessonVisual.droneParts:
        _drawDrone(canvas, size);
      case LessonVisual.cameraTriangle:
        _drawCameraTriangle(canvas, size);
      case LessonVisual.overlap:
        _drawOverlap(canvas, size);
      case LessonVisual.gsd:
        _drawGsd(canvas, size);
      case LessonVisual.flightPlan:
        _drawFlightPlan(canvas, size);
      case LessonVisual.matching:
        _drawMatching(canvas, size);
      case LessonVisual.pointCloud:
        _drawPointCloud(canvas, size);
      case LessonVisual.quality:
        _drawQuality(canvas, size);
      case LessonVisual.mapLayout:
        _drawMapLayout(canvas, size);
      case LessonVisual.report:
        _drawReport(canvas, size);
    }
  }

  void _drawDrone(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final body = Paint()..color = cyan;
    final line = Paint()
      ..color = Colors.white70
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final glow = Paint()
      ..color = cyan.withOpacity(.14)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(c, 56, glow);
    canvas.drawLine(c + const Offset(-25, -18), c + const Offset(-72, -48), line);
    canvas.drawLine(c + const Offset(25, -18), c + const Offset(72, -48), line);
    canvas.drawLine(c + const Offset(-25, 18), c + const Offset(-72, 48), line);
    canvas.drawLine(c + const Offset(25, 18), c + const Offset(72, 48), line);
    for (final p in [
      c + const Offset(-78, -52),
      c + const Offset(78, -52),
      c + const Offset(-78, 52),
      c + const Offset(78, 52),
    ]) {
      canvas.drawCircle(p, 18, Paint()..color = Colors.white12);
      canvas.drawOval(Rect.fromCenter(center: p, width: 48, height: 10), Paint()..color = orange.withOpacity(.8));
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromCenter(center: c, width: 64, height: 48), const Radius.circular(14)),
      body,
    );
    canvas.drawCircle(c + const Offset(0, 20), 11, Paint()..color = navy);
    _label(canvas, const Offset(20, 22), 'GNSS', cyan);
    _label(canvas, Offset(size.width - 100, 24), 'Moteurs', orange);
    _label(canvas, Offset(size.width - 105, size.height - 36), 'Caméra', violet);
  }

  void _drawCameraTriangle(Canvas canvas, Size size) {
    final points = [
      Offset(size.width / 2, 35),
      Offset(55, size.height - 38),
      Offset(size.width - 55, size.height - 38),
    ];
    final path = Path()..moveTo(points[0].dx, points[0].dy);
    path.lineTo(points[1].dx, points[1].dy);
    path.lineTo(points[2].dx, points[2].dy);
    path.close();
    canvas.drawPath(path, Paint()..color = cyan.withOpacity(.08));
    canvas.drawPath(
      path,
      Paint()
        ..color = cyan
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    _node(canvas, points[0], Icons.shutter_speed, 'VITESSE', cyan);
    _node(canvas, points[1], Icons.camera, 'OUVERTURE', orange);
    _node(canvas, points[2], Icons.grain, 'ISO', violet);
    _label(canvas, Offset(size.width / 2 - 62, size.height / 2 + 8), 'EXPOSITION', Colors.white);
  }

  void _drawOverlap(Canvas canvas, Size size) {
    final top = 42.0;
    final h = size.height - 82;
    final w = size.width * .34;
    final left1 = size.width * .16;
    final left2 = size.width * .36;
    final left3 = size.width * .56;
    final colors = [cyan, orange, violet];
    for (var i = 0; i < 3; i++) {
      final left = [left1, left2, left3][i];
      final rect = Rect.fromLTWH(left, top, w, h);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(14)),
        Paint()..color = colors[i].withOpacity(.18),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(14)),
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    _label(canvas, const Offset(18, 14), 'ZONE COMMUNE = POINTS HOMOLOGUES', cyan);
    _label(canvas, Offset(size.width / 2 - 38, size.height - 29), '80 %', Colors.white);
  }

  void _drawGsd(Canvas canvas, Size size) {
    final horizon = size.height * .72;
    final ground = Paint()..color = const Color(0xFF183A43);
    canvas.drawRect(Rect.fromLTWH(0, horizon, size.width, size.height - horizon), ground);
    final drone = Offset(size.width / 2, 42);
    canvas.drawCircle(drone, 13, Paint()..color = cyan);
    canvas.drawLine(drone, Offset(size.width * .26, horizon), Paint()..color = cyan.withOpacity(.55)..strokeWidth = 2);
    canvas.drawLine(drone, Offset(size.width * .74, horizon), Paint()..color = cyan.withOpacity(.55)..strokeWidth = 2);
    final pixelPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke;
    for (var x = size.width * .26; x < size.width * .74; x += 14) {
      canvas.drawRect(Rect.fromLTWH(x, horizon, 14, 14), pixelPaint);
    }
    _label(canvas, Offset(size.width / 2 - 38, 72), 'ALTITUDE', orange);
    _label(canvas, Offset(size.width / 2 - 62, horizon + 28), 'TAILLE DU PIXEL AU SOL', cyan);
  }

  void _drawFlightPlan(Canvas canvas, Size size) {
    final area = RRect.fromRectAndRadius(
      Rect.fromLTWH(42, 28, size.width - 84, size.height - 56),
      const Radius.circular(18),
    );
    canvas.drawRRect(area, Paint()..color = cyan.withOpacity(.07));
    canvas.drawRRect(
      area,
      Paint()
        ..color = cyan.withOpacity(.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    final pathPaint = Paint()
      ..color = orange
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    var leftToRight = true;
    for (double y = 53; y < size.height - 45; y += 28) {
      final start = leftToRight ? 64.0 : size.width - 64;
      final end = leftToRight ? size.width - 64 : 64.0;
      canvas.drawLine(Offset(start, y), Offset(end, y), pathPaint);
      canvas.drawCircle(Offset(end, y), 4, Paint()..color = Colors.white);
      leftToRight = !leftToRight;
    }
    _label(canvas, const Offset(57, 7), 'MARGE + LIGNES RÉGULIÈRES', cyan);
  }

  void _drawMatching(Canvas canvas, Size size) {
    final left = Rect.fromLTWH(25, 38, size.width * .38, size.height - 76);
    final right = Rect.fromLTWH(size.width * .57, 38, size.width * .38, size.height - 76);
    for (final rect in [left, right]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(15)),
        Paint()..color = Colors.white.withOpacity(.07),
      );
      canvas.drawCircle(rect.center + const Offset(-25, -15), 10, Paint()..color = orange);
      canvas.drawRect(Rect.fromCenter(center: rect.center + const Offset(24, 18), width: 28, height: 28), Paint()..color = violet);
      canvas.drawCircle(rect.center + const Offset(6, -37), 6, Paint()..color = cyan);
    }
    final line = Paint()..strokeWidth = 1.5;
    final pairs = [
      [left.center + const Offset(-25, -15), right.center + const Offset(-25, -15), orange],
      [left.center + const Offset(24, 18), right.center + const Offset(24, 18), violet],
      [left.center + const Offset(6, -37), right.center + const Offset(6, -37), cyan],
    ];
    for (final pair in pairs) {
      line.color = pair[2] as Color;
      canvas.drawLine(pair[0] as Offset, pair[1] as Offset, line);
    }
    _label(canvas, Offset(size.width / 2 - 54, 12), 'APPARIEMENT', Colors.white);
  }

  void _drawPointCloud(Canvas canvas, Size size) {
    final random = math.Random(7);
    for (var i = 0; i < 380; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = size.height * .72 - math.sin(x / 38) * 25;
      final y = baseY - random.nextDouble() * (45 + 45 * math.sin(x / 80).abs());
      final color = i % 5 == 0 ? orange : (i % 3 == 0 ? violet : cyan);
      canvas.drawCircle(Offset(x, y), 1.4 + random.nextDouble() * 1.3, Paint()..color = color.withOpacity(.75));
    }
    _label(canvas, const Offset(18, 14), 'NUAGE 3D SIMULÉ', cyan);
    _label(canvas, Offset(size.width - 112, size.height - 30), 'X • Y • Z', Colors.white70);
  }

  void _drawQuality(Canvas canvas, Size size) {
    final cards = [
      Rect.fromLTWH(24, 45, size.width * .27, 110),
      Rect.fromLTWH(size.width * .365, 45, size.width * .27, 110),
      Rect.fromLTWH(size.width * .68, 45, size.width * .27, 110),
    ];
    final labels = ['NETTE', 'FLOUE', 'SUREXPOSÉE'];
    final colors = [success, danger, orange];
    for (var i = 0; i < cards.length; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(cards[i], const Radius.circular(13)),
        Paint()..color = colors[i].withOpacity(.12),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(cards[i], const Radius.circular(13)),
        Paint()
          ..color = colors[i].withOpacity(.7)
          ..style = PaintingStyle.stroke,
      );
      canvas.drawLine(cards[i].topLeft + const Offset(12, 75), cards[i].bottomRight - const Offset(12, 16), Paint()..color = colors[i]..strokeWidth = i == 1 ? 8 : 2);
      _label(canvas, cards[i].bottomLeft + const Offset(10, 15), labels[i], colors[i]);
    }
    _label(canvas, const Offset(20, 15), 'DIAGNOSTIC AVANT TRAITEMENT', Colors.white);
  }

  void _drawMapLayout(Canvas canvas, Size size) {
    final page = Rect.fromLTWH(size.width * .18, 22, size.width * .64, size.height - 44);
    canvas.drawRRect(RRect.fromRectAndRadius(page, const Radius.circular(12)), Paint()..color = Colors.white.withOpacity(.95));
    canvas.drawRect(Rect.fromLTWH(page.left + 18, page.top + 34, page.width * .66, page.height * .62), Paint()..color = const Color(0xFFD8EEE9));
    canvas.drawRect(Rect.fromLTWH(page.right - 64, page.top + 34, 45, page.height * .34), Paint()..color = const Color(0xFFE9EEF1));
    canvas.drawLine(Offset(page.left + 18, page.top + 19), Offset(page.right - 18, page.top + 19), Paint()..color = navy..strokeWidth = 6);
    canvas.drawRect(Rect.fromLTWH(page.left + 18, page.bottom - 28, page.width * .5, 5), Paint()..color = navy.withOpacity(.55));
    canvas.drawLine(Offset(page.right - 44, page.bottom - 42), Offset(page.right - 44, page.bottom - 16), Paint()..color = orange..strokeWidth = 3);
    canvas.drawLine(Offset(page.right - 52, page.bottom - 34), Offset(page.right - 44, page.bottom - 42), Paint()..color = orange..strokeWidth = 3);
    canvas.drawLine(Offset(page.right - 36, page.bottom - 34), Offset(page.right - 44, page.bottom - 42), Paint()..color = orange..strokeWidth = 3);
  }

  void _drawReport(Canvas canvas, Size size) {
    final page = Rect.fromLTWH(size.width * .25, 20, size.width * .5, size.height - 40);
    canvas.drawRRect(RRect.fromRectAndRadius(page, const Radius.circular(12)), Paint()..color = Colors.white);
    canvas.drawRect(Rect.fromLTWH(page.left, page.top, page.width, 42), Paint()..color = cyan);
    canvas.drawCircle(Offset(page.left + 24, page.top + 21), 11, Paint()..color = navy);
    for (var i = 0; i < 6; i++) {
      final width = i == 0 ? page.width * .7 : page.width * (.45 + (i % 3) * .15);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(page.left + 20, page.top + 66 + i * 22, width, 7), const Radius.circular(4)),
        Paint()..color = i == 0 ? navy : const Color(0xFFCAD5DA),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(page.left + 20, page.bottom - 50, page.width - 40, 28), const Radius.circular(6)),
      Paint()..color = orange.withOpacity(.28),
    );
    _label(canvas, const Offset(18, 16), 'RAPPORT DE MISSION', cyan);
  }

  void _node(Canvas canvas, Offset center, IconData icon, String label, Color color) {
    canvas.drawCircle(center, 32, Paint()..color = color.withOpacity(.16));
    canvas.drawCircle(center, 32, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);
    final painter = TextPainter(
      text: TextSpan(text: String.fromCharCode(icon.codePoint), style: TextStyle(fontFamily: icon.fontFamily, package: icon.fontPackage, color: color, fontSize: 24)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, center - Offset(painter.width / 2, painter.height / 2));
    _label(canvas, center + const Offset(-36, 38), label, color);
  }

  void _label(Canvas canvas, Offset offset, String text, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: .8,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _LearningPainter oldDelegate) => oldDelegate.visual != visual;
}

class FlightPlanPreview extends StatelessWidget {
  const FlightPlanPreview({
    super.key,
    required this.frontOverlap,
    required this.sideOverlap,
    required this.altitude,
  });

  final double frontOverlap;
  final double sideOverlap;
  final double altitude;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C2C37), Color(0xFF071824)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomPaint(
        painter: _FlightPlanPainter(frontOverlap, sideOverlap, altitude),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _FlightPlanPainter extends CustomPainter {
  _FlightPlanPainter(this.front, this.side, this.altitude);

  final double front;
  final double side;
  final double altitude;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(3);
    for (var i = 0; i < 26; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      canvas.drawCircle(p, 12 + random.nextDouble() * 22, Paint()..color = success.withOpacity(.035));
    }
    final area = RRect.fromRectAndRadius(Rect.fromLTWH(30, 30, size.width - 60, size.height - 60), const Radius.circular(25));
    canvas.drawRRect(area, Paint()..color = cyan.withOpacity(.055));
    canvas.drawRRect(area, Paint()..color = cyan.withOpacity(.4)..style = PaintingStyle.stroke..strokeWidth = 2);

    final rows = (3 + (side - 50) / 10).round().clamp(3, 7).toInt();
    final spacing = (size.height - 100) / (rows - 1);
    final linePaint = Paint()..color = orange..strokeWidth = 3..strokeCap = StrokeCap.round;
    for (var i = 0; i < rows; i++) {
      final y = 50 + i * spacing;
      final reverse = i.isOdd;
      final x1 = reverse ? size.width - 54 : 54.0;
      final x2 = reverse ? 54.0 : size.width - 54;
      canvas.drawLine(Offset(x1, y), Offset(x2, y), linePaint);
      final shots = (5 + (front - 60) / 5).round().clamp(5, 11).toInt();
      for (var j = 0; j < shots; j++) {
        final t = j / (shots - 1);
        final x = x1 + (x2 - x1) * t;
        canvas.drawCircle(Offset(x, y), 4, Paint()..color = Colors.white);
      }
    }
    final labelPainter = TextPainter(
      text: TextSpan(
        text: 'ALT ${altitude.round()} m  •  AV ${front.round()} %  •  LAT ${side.round()} %',
        style: const TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .6),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    labelPainter.paint(canvas, Offset(28, size.height - 24));
  }

  @override
  bool shouldRepaint(covariant _FlightPlanPainter oldDelegate) =>
      oldDelegate.front != front || oldDelegate.side != side || oldDelegate.altitude != altitude;
}

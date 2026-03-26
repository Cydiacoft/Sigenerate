import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/traffic_sign.dart';

class TrafficSignPainter extends CustomPainter {
  const TrafficSignPainter({required this.sign, this.scale = 1.0});

  final TrafficSign sign;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    final side = math.min(size.width, size.height) * scale;
    final center = Offset(size.width / 2, size.height / 2);

    switch (sign.shape) {
      case SignShape.circle:
        _drawCircle(canvas, center, side * 0.48);
        break;
      case SignShape.triangle:
        _drawTriangle(canvas, center, side * 0.52, inverted: false);
        break;
      case SignShape.invertedTriangle:
        _drawTriangle(canvas, center, side * 0.52, inverted: true);
        break;
      case SignShape.rectangle:
        _drawRectangle(canvas, center, side * 0.82, side * 0.54);
        break;
      case SignShape.square:
        _drawRectangle(canvas, center, side * 0.68, side * 0.68);
        break;
      case SignShape.octagon:
        _drawOctagon(canvas, center, side * 0.42);
        break;
    }
  }

  void _drawCircle(Canvas canvas, Offset center, double radius) {
    final fillPaint = Paint()
      ..color = sign.primaryColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    final border = sign.borderColor;
    if (border != null) {
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.18,
      );
    }

    _drawSymbol(canvas, center, radius * 1.45);
  }

  void _drawTriangle(
    Canvas canvas,
    Offset center,
    double side,
    {required bool inverted}
  ) {
    final halfSide = side / 2;
    final height = side * math.sqrt(3) / 2;
    final direction = inverted ? 1.0 : -1.0;

    final outerPath = Path()
      ..moveTo(center.dx, center.dy + direction * height * 0.58)
      ..lineTo(center.dx - halfSide, center.dy - direction * height * 0.42)
      ..lineTo(center.dx + halfSide, center.dy - direction * height * 0.42)
      ..close();

    canvas.drawPath(
      outerPath,
      Paint()
        ..color = sign.primaryColor
        ..style = PaintingStyle.fill,
    );

    if (sign.borderColor != null) {
      canvas.drawPath(
        outerPath,
        Paint()
          ..color = sign.borderColor!
          ..style = PaintingStyle.stroke
          ..strokeWidth = side * 0.08
          ..strokeJoin = StrokeJoin.round,
      );
    }

    _drawSymbol(canvas, center, side * 0.9);
  }

  void _drawRectangle(
    Canvas canvas,
    Offset center,
    double width,
    double height,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: width, height: height),
      Radius.circular(height * 0.12),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = sign.primaryColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = sign.borderColor ?? sign.secondaryColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = height * 0.06,
    );

    _drawSymbol(canvas, center, math.min(width, height) * 0.8);
  }

  void _drawOctagon(Canvas canvas, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 8; i++) {
      final angle = -math.pi / 8 + i * math.pi / 4;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(
      path,
      Paint()
        ..color = sign.primaryColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = sign.borderColor ?? sign.primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.1,
    );

    _drawSymbol(canvas, center, radius * 1.5);
  }

  void _drawSymbol(Canvas canvas, Offset center, double size) {
    switch (sign.symbol) {
      case SignSymbol.stopText:
        _drawCenteredText(canvas, center, '停', size * 0.34);
        break;
      case SignSymbol.yieldText:
        _drawCenteredText(canvas, center, '让', size * 0.26, color: sign.secondaryColor);
        break;
      case SignSymbol.noEntry:
        _drawNoEntry(canvas, center, size);
        break;
      case SignSymbol.noPedestrians:
        _drawWalkingPerson(canvas, center, size * 0.72, sign.secondaryColor);
        _drawSlash(canvas, center, size * 0.84, sign.borderColor ?? const Color(0xFFD92323));
        break;
      case SignSymbol.noMotorVehicles:
        _drawCar(canvas, center, size * 0.72, sign.secondaryColor);
        _drawSlash(canvas, center, size * 0.84, sign.borderColor ?? const Color(0xFFD92323));
        break;
      case SignSymbol.noParking:
        _drawCenteredText(canvas, center, 'P', size * 0.34, color: sign.secondaryColor);
        _drawSlash(canvas, center, size * 0.84, sign.borderColor ?? const Color(0xFFD92323));
        break;
      case SignSymbol.noHonking:
        _drawHorn(canvas, center, size * 0.72, sign.secondaryColor);
        _drawSlash(canvas, center, size * 0.84, sign.borderColor ?? const Color(0xFFD92323));
        break;
      case SignSymbol.speedLimit:
        _drawCenteredText(canvas, center, sign.value ?? '', size * 0.26, color: sign.secondaryColor);
        break;
      case SignSymbol.crossroad:
        _drawCross(canvas, center, size * 0.62, sign.secondaryColor);
        break;
      case SignSymbol.tJunction:
        _drawTJunction(canvas, center, size * 0.62, sign.secondaryColor);
        break;
      case SignSymbol.sharpCurveLeft:
        _drawCurve(canvas, center, size * 0.68, sign.secondaryColor, true);
        break;
      case SignSymbol.sharpCurveRight:
        _drawCurve(canvas, center, size * 0.68, sign.secondaryColor, false);
        break;
      case SignSymbol.slippery:
        _drawSlippery(canvas, center, size * 0.7, sign.secondaryColor);
        break;
      case SignSymbol.pedestrianCrossing:
      case SignSymbol.walk:
        _drawWalkingPerson(canvas, center, size * 0.72, sign.secondaryColor);
        break;
      case SignSymbol.children:
        _drawChildren(canvas, center, size * 0.72, sign.secondaryColor);
        break;
      case SignSymbol.roadWork:
        _drawWorker(canvas, center, size * 0.72, sign.secondaryColor);
        break;
      case SignSymbol.straightAhead:
        _drawArrow(canvas, center, size * 0.72, sign.secondaryColor, const Offset(0, -1));
        break;
      case SignSymbol.turnLeft:
        _drawTurnArrow(canvas, center, size * 0.72, sign.secondaryColor, true);
        break;
      case SignSymbol.turnRight:
        _drawTurnArrow(canvas, center, size * 0.72, sign.secondaryColor, false);
        break;
      case SignSymbol.straightOrLeft:
        _drawSplitArrow(canvas, center, size * 0.72, sign.secondaryColor, true);
        break;
      case SignSymbol.straightOrRight:
        _drawSplitArrow(canvas, center, size * 0.72, sign.secondaryColor, false);
        break;
      case SignSymbol.roundabout:
        _drawRoundabout(canvas, center, size * 0.72, sign.secondaryColor);
        break;
      case SignSymbol.keepRight:
        _drawArrow(canvas, center.translate(size * 0.06, 0), size * 0.66, sign.secondaryColor, const Offset(0.8, -1));
        break;
      case SignSymbol.keepLeft:
        _drawArrow(canvas, center.translate(-size * 0.06, 0), size * 0.66, sign.secondaryColor, const Offset(-0.8, -1));
        break;
      case SignSymbol.parking:
        _drawCenteredText(canvas, center, 'P', size * 0.34, color: sign.secondaryColor);
        break;
      case SignSymbol.hospital:
        _drawHospital(canvas, center, size * 0.72, sign.secondaryColor);
        break;
      case SignSymbol.serviceArea:
        _drawCenteredText(canvas, center, '服', size * 0.26, color: sign.secondaryColor);
        break;
      case SignSymbol.touristArea:
        _drawCenteredText(canvas, center, '游', size * 0.26, color: sign.secondaryColor);
        break;
      case SignSymbol.expressway:
        _drawExpressway(canvas, center, size * 0.78, sign.secondaryColor);
        break;
      case SignSymbol.none:
        _drawCenteredText(canvas, center, sign.name.characters.first, size * 0.26, color: sign.secondaryColor);
        break;
    }
  }

  void _drawCenteredText(
    Canvas canvas,
    Offset center,
    String text,
    double fontSize, {
    Color? color,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color ?? sign.secondaryColor,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    painter.paint(
      canvas,
      Offset(center.dx - painter.width / 2, center.dy - painter.height / 2),
    );
  }

  void _drawSlash(Canvas canvas, Offset center, double size, Color color) {
    canvas.drawLine(
      Offset(center.dx - size / 2, center.dy + size / 2),
      Offset(center.dx + size / 2, center.dy - size / 2),
      Paint()
        ..color = color
        ..strokeWidth = size * 0.12
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawNoEntry(Canvas canvas, Offset center, double size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size * 0.66, height: size * 0.18),
        Radius.circular(size * 0.04),
      ),
      Paint()..color = sign.secondaryColor,
    );
  }

  void _drawCross(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size * 0.14
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - size / 2),
      Offset(center.dx, center.dy + size / 2),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - size / 2, center.dy),
      Offset(center.dx + size / 2, center.dy),
      paint,
    );
  }

  void _drawTJunction(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size * 0.12
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy - size / 2),
      Offset(center.dx, center.dy + size * 0.18),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - size / 2, center.dy - size * 0.12),
      Offset(center.dx + size / 2, center.dy - size * 0.12),
      paint,
    );
  }

  void _drawCurve(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    bool left,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.1
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.36)
      ..quadraticBezierTo(
        center.dx,
        center.dy - size * 0.08,
        center.dx + (left ? -size * 0.24 : size * 0.24),
        center.dy - size * 0.22,
      );
    canvas.drawPath(path, paint);
    final tip = Offset(
      center.dx + (left ? -size * 0.24 : size * 0.24),
      center.dy - size * 0.22,
    );
    final wing = left ? -1.0 : 1.0;
    canvas.drawLine(tip, tip + Offset(wing * size * 0.16, size * 0.03), paint);
    canvas.drawLine(tip, tip + Offset(wing * size * 0.05, size * 0.16), paint);
  }

  void _drawSlippery(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.08
      ..strokeCap = StrokeCap.round;
    _drawCar(canvas, center.translate(0, size * 0.12), size * 0.48, color);
    final wave = Path()
      ..moveTo(center.dx - size * 0.2, center.dy - size * 0.02)
      ..quadraticBezierTo(center.dx - size * 0.08, center.dy + size * 0.1, center.dx, center.dy - size * 0.02)
      ..quadraticBezierTo(center.dx + size * 0.08, center.dy - size * 0.14, center.dx + size * 0.2, center.dy - size * 0.02);
    canvas.drawPath(wave, paint);
  }

  void _drawWalkingPerson(Canvas canvas, Offset center, double size, Color color) {
    final fill = Paint()..color = color;
    canvas.drawCircle(center.translate(0, -size * 0.26), size * 0.09, fill);
    final stroke = Paint()
      ..color = color
      ..strokeWidth = size * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center.translate(0, -size * 0.16), center.translate(0, size * 0.04), stroke);
    canvas.drawLine(center.translate(0, -size * 0.02), center.translate(-size * 0.18, size * 0.12), stroke);
    canvas.drawLine(center.translate(0, -size * 0.02), center.translate(size * 0.2, size * 0.08), stroke);
    canvas.drawLine(center.translate(0, size * 0.04), center.translate(-size * 0.14, size * 0.28), stroke);
    canvas.drawLine(center.translate(0, size * 0.04), center.translate(size * 0.14, size * 0.3), stroke);
  }

  void _drawChildren(Canvas canvas, Offset center, double size, Color color) {
    _drawWalkingPerson(canvas, center.translate(-size * 0.1, 0), size * 0.68, color);
    _drawWalkingPerson(canvas, center.translate(size * 0.16, size * 0.06), size * 0.54, color);
  }

  void _drawWorker(Canvas canvas, Offset center, double size, Color color) {
    final fill = Paint()..color = color;
    canvas.drawCircle(center.translate(-size * 0.08, -size * 0.22), size * 0.08, fill);
    final stroke = Paint()
      ..color = color
      ..strokeWidth = size * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center.translate(-size * 0.08, -size * 0.14), center.translate(-size * 0.02, size * 0.02), stroke);
    canvas.drawLine(center.translate(-size * 0.02, size * 0.02), center.translate(size * 0.12, size * 0.18), stroke);
    canvas.drawLine(center.translate(-size * 0.02, size * 0.02), center.translate(-size * 0.18, size * 0.18), stroke);
    canvas.drawLine(center.translate(size * 0.1, size * 0.14), center.translate(size * 0.24, size * 0.28), stroke);
    canvas.drawLine(center.translate(-size * 0.1, size * 0.14), center.translate(-size * 0.16, size * 0.32), stroke);
    canvas.drawLine(center.translate(0, size * 0.16), center.translate(size * 0.26, size * 0.05), stroke);
  }

  void _drawArrow(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    Offset direction,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size * 0.12
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final shaftEnd = center + Offset(direction.dx * size * 0.28, direction.dy * size * 0.28);
    final shaftStart = center - Offset(direction.dx * size * 0.16, direction.dy * size * 0.16);
    canvas.drawLine(shaftStart, shaftEnd, paint);

    final norm = math.sqrt(direction.dx * direction.dx + direction.dy * direction.dy);
    final ux = direction.dx / norm;
    final uy = direction.dy / norm;
    final left = Offset(-uy, ux);
    final right = Offset(uy, -ux);
    canvas.drawLine(shaftEnd, shaftEnd - Offset(ux, uy) * size * 0.18 + left * size * 0.12, paint);
    canvas.drawLine(shaftEnd, shaftEnd - Offset(ux, uy) * size * 0.18 + right * size * 0.12, paint);
  }

  void _drawTurnArrow(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    bool left,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.28)
      ..lineTo(center.dx, center.dy - size * 0.04)
      ..quadraticBezierTo(
        center.dx,
        center.dy - size * 0.28,
        center.dx + (left ? -size * 0.22 : size * 0.22),
        center.dy - size * 0.28,
      );
    canvas.drawPath(path, paint);
    final tip = Offset(
      center.dx + (left ? -size * 0.22 : size * 0.22),
      center.dy - size * 0.28,
    );
    final direction = left ? -1.0 : 1.0;
    canvas.drawLine(tip, tip + Offset(direction * size * 0.15, size * 0.04), paint);
    canvas.drawLine(tip, tip + Offset(direction * size * 0.03, size * 0.16), paint);
  }

  void _drawSplitArrow(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
    bool left,
  ) {
    _drawArrow(canvas, center.translate(0, size * 0.08), size * 0.64, color, const Offset(0, -1));
    _drawArrow(
      canvas,
      center.translate(left ? -size * 0.04 : size * 0.04, 0),
      size * 0.54,
      color,
      left ? const Offset(-0.8, -1) : const Offset(0.8, -1),
    );
  }

  void _drawRoundabout(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.1
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, size * 0.22, paint);
    for (int i = 0; i < 3; i++) {
      final angle = -math.pi / 2 + i * 2 * math.pi / 3;
      final start = center + Offset(math.cos(angle), math.sin(angle)) * size * 0.22;
      final end = center + Offset(math.cos(angle), math.sin(angle)) * size * 0.38;
      canvas.drawLine(start, end, paint);
    }
  }

  void _drawCar(Canvas canvas, Offset center, double size, Color color) {
    final stroke = Paint()
      ..color = color
      ..strokeWidth = size * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final body = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size * 0.54, height: size * 0.22),
      Radius.circular(size * 0.05),
    );
    canvas.drawRRect(body, stroke);
    final roof = Path()
      ..moveTo(center.dx - size * 0.16, center.dy - size * 0.02)
      ..lineTo(center.dx - size * 0.08, center.dy - size * 0.16)
      ..lineTo(center.dx + size * 0.08, center.dy - size * 0.16)
      ..lineTo(center.dx + size * 0.16, center.dy - size * 0.02);
    canvas.drawPath(roof, stroke);
    canvas.drawCircle(center.translate(-size * 0.16, size * 0.12), size * 0.05, Paint()..color = color);
    canvas.drawCircle(center.translate(size * 0.16, size * 0.12), size * 0.05, Paint()..color = color);
  }

  void _drawHorn(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size * 0.08
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final horn = Path()
      ..moveTo(center.dx - size * 0.24, center.dy)
      ..lineTo(center.dx - size * 0.02, center.dy - size * 0.16)
      ..lineTo(center.dx - size * 0.02, center.dy + size * 0.16)
      ..close();
    canvas.drawPath(horn, paint);
    canvas.drawLine(
      center.translate(-size * 0.28, 0),
      center.translate(-size * 0.4, 0),
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center.translate(size * 0.08, 0), radius: size * 0.16),
      -math.pi / 4,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center.translate(size * 0.18, 0), radius: size * 0.24),
      -math.pi / 4,
      math.pi / 2,
      false,
      paint,
    );
  }

  void _drawHospital(Canvas canvas, Offset center, double size, Color color) {
    final fill = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size * 0.18, height: size * 0.56),
        Radius.circular(size * 0.03),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: size * 0.56, height: size * 0.18),
        Radius.circular(size * 0.03),
      ),
      fill,
    );
  }

  void _drawExpressway(Canvas canvas, Offset center, double size, Color color) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size * 0.08
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center.translate(-size * 0.18, size * 0.3),
      center.translate(-size * 0.02, -size * 0.28),
      paint,
    );
    canvas.drawLine(
      center.translate(size * 0.18, size * 0.3),
      center.translate(size * 0.02, -size * 0.28),
      paint,
    );
    canvas.drawLine(
      center.translate(0, size * 0.3),
      center.translate(0, -size * 0.08),
      paint..strokeWidth = size * 0.05,
    );
  }

  @override
  bool shouldRepaint(covariant TrafficSignPainter oldDelegate) {
    return oldDelegate.sign != sign || oldDelegate.scale != scale;
  }
}

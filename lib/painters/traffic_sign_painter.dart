import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/traffic_sign.dart';

class TrafficSignPainter extends CustomPainter {
  final TrafficSign sign;
  final double scale;

  TrafficSignPainter({required this.sign, this.scale = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final signSize = size.width * 0.9 * scale;

    switch (sign.shape) {
      case SignShape.circle:
        _drawCircleSign(canvas, center, signSize);
        break;
      case SignShape.invertedTriangle:
        _drawInvertedTriangleSign(canvas, center, signSize);
        break;
      case SignShape.triangle:
        _drawTriangleSign(canvas, center, signSize);
        break;
      case SignShape.rectangle:
        _drawRectangleSign(canvas, center, signSize);
        break;
      case SignShape.square:
        _drawSquareSign(canvas, center, signSize);
        break;
      default:
        _drawCircleSign(canvas, center, signSize);
    }
  }

  void _drawCircleSign(Canvas canvas, Offset center, double size) {
    final borderPaint = Paint()
      ..color = sign.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.08;

    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size / 2, backgroundPaint);
    canvas.drawCircle(center, size / 2, borderPaint);

    _drawSignSymbol(canvas, center, size);
  }

  void _drawInvertedTriangleSign(Canvas canvas, Offset center, double size) {
    final borderPaint = Paint()
      ..color = sign.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.06;

    final backgroundPaint = Paint()
      ..color = sign.primaryColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final halfSize = size / 2;
    final height = halfSize * math.sqrt(3);

    path.moveTo(center.dx, center.dy + height * 0.6);
    path.lineTo(center.dx - halfSize, center.dy - height * 0.4);
    path.lineTo(center.dx + halfSize, center.dy - height * 0.4);
    path.close();

    canvas.drawPath(path, backgroundPaint);
    canvas.drawPath(path, borderPaint);

    final whiteBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.04;

    final innerPath = Path();
    final innerOffset = size * 0.06;
    innerPath.moveTo(center.dx, center.dy + height * 0.6 - innerOffset);
    innerPath.lineTo(center.dx - halfSize + innerOffset, center.dy - height * 0.4 + innerOffset);
    innerPath.lineTo(center.dx + halfSize - innerOffset, center.dy - height * 0.4 + innerOffset);
    innerPath.close();

    canvas.drawPath(innerPath, whiteBorderPaint);
  }

  void _drawTriangleSign(Canvas canvas, Offset center, double size) {
    final borderPaint = Paint()
      ..color = sign.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.06;

    final backgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    final halfSize = size / 2;
    final height = halfSize * math.sqrt(3);

    path.moveTo(center.dx, center.dy - height * 0.6);
    path.lineTo(center.dx - halfSize, center.dy + height * 0.4);
    path.lineTo(center.dx + halfSize, center.dy + height * 0.4);
    path.close();

    canvas.drawPath(path, backgroundPaint);
    canvas.drawPath(path, borderPaint);

    _drawSignSymbol(canvas, center, size);
  }

  void _drawRectangleSign(Canvas canvas, Offset center, double size) {
    final borderPaint = Paint()
      ..color = sign.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.05;

    final backgroundPaint = Paint()
      ..color = sign.primaryColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(center: center, width: size, height: size * 0.6);
    canvas.drawRect(rect, backgroundPaint);
    canvas.drawRect(rect, borderPaint);
  }

  void _drawSquareSign(Canvas canvas, Offset center, double size) {
    final borderPaint = Paint()
      ..color = sign.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.05;

    final backgroundPaint = Paint()
      ..color = sign.primaryColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(center: center, width: size * 0.7, height: size * 0.7);
    canvas.drawRect(rect, backgroundPaint);
    canvas.drawRect(rect, borderPaint);
  }

  void _drawSignSymbol(Canvas canvas, Offset center, double size) {
    final paint = Paint()
      ..color = sign.secondaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size * 0.08
      ..strokeCap = StrokeCap.round;

    final symbolSize = size * 0.5;

    switch (sign.id) {
      case 'pr001':
        _drawProhibitionBar(canvas, center, symbolSize, paint);
        break;
      case 'pr002':
        _drawEnterProhibition(canvas, center, symbolSize, paint);
        break;
      case 'wr001':
        _drawCrossroad(canvas, center, symbolSize, paint);
        break;
      case 'wr002':
      case 'wr003':
        _drawTJunction(canvas, center, symbolSize, paint, sign.id == 'wr003');
        break;
      case 'wr004':
        _drawYJunction(canvas, center, symbolSize, paint);
        break;
      case 'wr005':
        _drawRoundabout(canvas, center, symbolSize, paint);
        break;
      default:
        _drawTextSymbol(canvas, center, size);
    }
  }

  void _drawProhibitionBar(Canvas canvas, Offset center, double size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(center.dx - size / 2, center.dy + size / 2),
      Offset(center.dx + size / 2, center.dy - size / 2),
      paint,
    );
  }

  void _drawEnterProhibition(Canvas canvas, Offset center, double size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    final path = Path();
    final halfSize = size / 2;
    path.moveTo(center.dx - halfSize * 0.7, center.dy);
    path.lineTo(center.dx + halfSize * 0.7, center.dy);
    canvas.drawLine(
      Offset(center.dx - halfSize * 0.5, center.dy + halfSize * 0.6),
      Offset(center.dx + halfSize * 0.5, center.dy - halfSize * 0.6),
      paint,
    );
  }

  void _drawCrossroad(Canvas canvas, Offset center, double size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    final halfSize = size / 2;
    canvas.drawLine(Offset(center.dx, center.dy - halfSize), Offset(center.dx, center.dy + halfSize), paint);
    canvas.drawLine(Offset(center.dx - halfSize, center.dy), Offset(center.dx + halfSize, center.dy), paint);
  }

  void _drawTJunction(Canvas canvas, Offset center, double size, Paint paint, bool isLeft) {
    paint.style = PaintingStyle.stroke;
    final halfSize = size / 2;
    if (isLeft) {
      canvas.drawLine(Offset(center.dx, center.dy - halfSize), Offset(center.dx, center.dy + halfSize), paint);
      canvas.drawLine(Offset(center.dx, center.dy + halfSize), Offset(center.dx + halfSize, center.dy + halfSize), paint);
    } else {
      canvas.drawLine(Offset(center.dx, center.dy - halfSize), Offset(center.dx, center.dy + halfSize), paint);
      canvas.drawLine(Offset(center.dx, center.dy + halfSize), Offset(center.dx - halfSize, center.dy + halfSize), paint);
    }
  }

  void _drawYJunction(Canvas canvas, Offset center, double size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    final halfSize = size / 2;
    canvas.drawLine(Offset(center.dx, center.dy + halfSize), Offset(center.dx, center.dy), paint);
    canvas.drawLine(Offset(center.dx, center.dy), Offset(center.dx - halfSize, center.dy - halfSize * 0.7), paint);
    canvas.drawLine(Offset(center.dx, center.dy), Offset(center.dx + halfSize, center.dy - halfSize * 0.7), paint);
  }

  void _drawRoundabout(Canvas canvas, Offset center, double size, Paint paint) {
    paint.style = PaintingStyle.stroke;
    canvas.drawCircle(center, size * 0.35, paint);
    final halfSize = size / 2;
    canvas.drawLine(Offset(center.dx - halfSize * 0.6, center.dy - halfSize * 0.6), Offset(center.dx + halfSize * 0.6, center.dy + halfSize * 0.6), paint);
  }

  void _drawTextSymbol(Canvas canvas, Offset center, double size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: sign.name.length > 2 ? sign.name.substring(0, 2) : sign.name,
        style: TextStyle(
          fontSize: size * 0.2,
          color: sign.secondaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2, center.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

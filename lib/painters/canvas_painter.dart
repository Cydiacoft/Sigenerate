import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/design_models.dart';

class CanvasPainter extends CustomPainter {
  final List<DesignElement> elements;
  final Color backgroundColor;
  final bool showGrid;
  final bool showRulers;
  final Size canvasSize;

  CanvasPainter({
    required this.elements,
    required this.backgroundColor,
    required this.canvasSize,
    this.showGrid = true,
    this.showRulers = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    
    final scaleX = size.width / canvasSize.width;
    final scaleY = size.height / canvasSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    final offsetX = (size.width - canvasSize.width * scale) / 2;
    final offsetY = (size.height - canvasSize.height * scale) / 2;
    
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    _drawBackground(canvas);
    if (showGrid) _drawGrid(canvas);
    _drawElements(canvas);
    
    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, canvasSize.width, canvasSize.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, paint);

    final borderPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawGrid(Canvas canvas) {
    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double x = 0; x <= canvasSize.width; x += 20) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, canvasSize.height),
        gridPaint,
      );
    }

    for (double y = 0; y <= canvasSize.height; y += 20) {
      canvas.drawLine(
        Offset(0, y),
        Offset(canvasSize.width, y),
        gridPaint,
      );
    }
  }

  void _drawElements(Canvas canvas) {
    for (final element in elements) {
      switch (element.type) {
        case ElementType.text:
          _drawText(canvas, element);
          break;
        case ElementType.rectangle:
          _drawRectangle(canvas, element);
          break;
        case ElementType.line:
          _drawLine(canvas, element);
          break;
        case ElementType.arrow:
          _drawArrow(canvas, element);
          break;
        case ElementType.icon:
          _drawIcon(canvas, element);
          break;
        case ElementType.signBoard:
          _drawSignBoard(canvas, element);
          break;
      }
    }
  }

  void _drawText(Canvas canvas, DesignElement element) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: element.content,
        style: TextStyle(
          fontSize: element.fontSize,
          color: element.color,
          fontWeight: element.fontWeight,
          fontFamily: element.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    Offset textPos;
    switch (element.alignment) {
      case Alignment.topLeft:
      case Alignment.centerLeft:
      case Alignment.bottomLeft:
        textPos = element.position;
        break;
      case Alignment.topRight:
      case Alignment.centerRight:
      case Alignment.bottomRight:
        textPos = Offset(
          element.position.dx - textPainter.width,
          element.position.dy,
        );
        break;
      default:
        textPos = Offset(
          element.position.dx - textPainter.width / 2,
          element.position.dy - textPainter.height / 2,
        );
    }

    textPainter.paint(canvas, textPos);
  }

  void _drawRectangle(Canvas canvas, DesignElement element) {
    final paint = Paint()
      ..color = element.color
      ..style = element.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = element.strokeWidth;

    final rect = Rect.fromLTWH(
      element.position.dx,
      element.position.dy,
      element.size.width,
      element.size.height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );
  }

  void _drawLine(Canvas canvas, DesignElement element) {
    final paint = Paint()
      ..color = element.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = element.strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      element.position,
      Offset(
        element.position.dx + element.size.width,
        element.position.dy + element.size.height,
      ),
      paint,
    );
  }

  void _drawArrow(Canvas canvas, DesignElement element) {
    final paint = Paint()
      ..color = element.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = element.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final start = element.position;
    final end = Offset(
      element.position.dx + element.size.width,
      element.position.dy + element.size.height,
    );

    path.moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    final angle = (end - start).direction;
    const arrowSize = 12.0;
    final arrowAngle = 0.5;

    final p1 = Offset(
      end.dx - arrowSize * math.cos(angle - arrowAngle),
      end.dy - arrowSize * math.sin(angle - arrowAngle),
    );
    final p2 = Offset(
      end.dx - arrowSize * math.cos(angle + arrowAngle),
      end.dy - arrowSize * math.sin(angle + arrowAngle),
    );

    path.moveTo(end.dx, end.dy);
    path.lineTo(p1.dx, p1.dy);
    path.moveTo(end.dx, end.dy);
    path.lineTo(p2.dx, p2.dy);

    canvas.drawPath(path, paint);
  }

  void _drawIcon(Canvas canvas, DesignElement element) {
    IconData? iconData;
    switch (element.iconName) {
      case 'car':
        iconData = Icons.directions_car;
        break;
      case 'bus':
        iconData = Icons.directions_bus;
        break;
      case 'train':
        iconData = Icons.train;
        break;
      case 'exit':
        iconData = Icons.exit_to_app;
        break;
      case 'location':
        iconData = Icons.location_on;
        break;
      case 'arrow_up':
        iconData = Icons.arrow_upward;
        break;
      case 'arrow_down':
        iconData = Icons.arrow_downward;
        break;
      case 'arrow_left':
        iconData = Icons.arrow_back;
        break;
      case 'arrow_right':
        iconData = Icons.arrow_forward;
        break;
      default:
        iconData = Icons.circle;
    }

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData!.codePoint),
        style: TextStyle(
          fontSize: element.fontSize,
          fontFamily: iconData.fontFamily,
          color: element.color,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(
        element.position.dx - iconPainter.width / 2,
        element.position.dy - iconPainter.height / 2,
      ),
    );
  }

  void _drawSignBoard(Canvas canvas, DesignElement element) {
    final rect = Rect.fromLTWH(
      element.position.dx,
      element.position.dy,
      element.size.width,
      element.size.height,
    );

    final bgPaint = Paint()
      ..color = element.color
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      bgPaint,
    );

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CanvasPainter oldDelegate) => true;
}

extension on double {
  double cos() => math_cos(this);
  double sin() => math_sin(this);
}

double math_cos(double x) {
  return _cos(x);
}

double math_sin(double x) {
  return _sin(x);
}

double _cos(double x) {
  x = x % (2 * 3.141592653589793);
  double result = 1.0;
  double term = 1.0;
  for (int n = 1; n <= 10; n++) {
    term *= -x * x / ((2 * n - 1) * (2 * n));
    result += term;
  }
  return result;
}

double _sin(double x) {
  x = x % (2 * 3.141592653589793);
  double result = x;
  double term = x;
  for (int n = 1; n <= 10; n++) {
    term *= -x * x / ((2 * n) * (2 * n + 1));
    result += term;
  }
  return result;
}

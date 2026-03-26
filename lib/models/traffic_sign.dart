import 'package:flutter/material.dart';

enum SignCategory {
  prohibition,
  warning,
  mandatory,
  indication,
  information,
  auxiliary,
}

enum SignShape {
  circle,
  triangle,
  invertedTriangle,
  rectangle,
  square,
  diamond,
  octagon,
  arrow,
}

class TrafficSign {
  final String id;
  final String name;
  final String code;
  final SignCategory category;
  final SignShape shape;
  final Color primaryColor;
  final Color secondaryColor;
  final List<SignElement> elements;
  final String? description;

  const TrafficSign({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.shape,
    required this.primaryColor,
    this.secondaryColor = const Color(0xFF000000),
    this.elements = const [],
    this.description,
  });

  String get categoryName {
    switch (category) {
      case SignCategory.prohibition:
        return '禁令标志';
      case SignCategory.warning:
        return '警告标志';
      case SignCategory.mandatory:
        return '指示标志';
      case SignCategory.indication:
        return '指路标志';
      case SignCategory.information:
        return '信息标志';
      case SignCategory.auxiliary:
        return '辅助标志';
    }
  }
}

abstract class SignElement {
  void draw(Canvas canvas, Size size);
}

class TextElement extends SignElement {
  final String text;
  final double fontSize;
  final Color color;
  final Offset position;

  TextElement({
    required this.text,
    required this.fontSize,
    required this.color,
    required this.position,
  });

  @override
  void draw(Canvas canvas, Size size) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, color: color),
      ),
      textDirection: TextDirection.ltr,
    );
    painter.layout();
    painter.paint(canvas, position);
  }
}

class PathElement extends SignElement {
  final Path path;
  final Color color;
  final bool fill;
  final double strokeWidth;

  PathElement({
    required this.path,
    required this.color,
    this.fill = true,
    this.strokeWidth = 2.0,
  });

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawPath(path, paint);
  }
}

class LineElement extends SignElement {
  final Offset start;
  final Offset end;
  final Color color;
  final double strokeWidth;

  LineElement({
    required this.start,
    required this.end,
    required this.color,
    this.strokeWidth = 2.0,
  });

  @override
  void draw(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(start, end, paint);
  }
}

class ImageElement extends SignElement {
  final Offset position;
  final Size size;
  final List<PathElement> paths;

  ImageElement({
    required this.position,
    required this.size,
    required this.paths,
  });

  @override
  void draw(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(position.dx, position.dy);
    final scale = size.width / 100;
    canvas.scale(scale, scale);
    for (final element in paths) {
      element.draw(canvas, this.size);
    }
    canvas.restore();
  }
}

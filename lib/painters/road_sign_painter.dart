import 'package:flutter/material.dart';
import '../models/intersection_scene.dart';
import '../theme/app_theme.dart';

class RoadSignPainter extends CustomPainter {
  final IntersectionScene scene;
  final String direction;
  final double signWidth;
  final double signHeight;

  RoadSignPainter({
    required this.scene,
    required this.direction,
    this.signWidth = 320,
    this.signHeight = 480,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawTopBar(canvas, size);
    _drawRoadSection(canvas, size);
    _drawDivider(canvas, size);
    _drawDestinationSection(canvas, size);
    _drawBottomBar(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..color = SignColors.urbanWhite
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rrect, bgPaint);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(rrect.shift(const Offset(0, 4)), shadowPaint);
  }

  void _drawTopBar(Canvas canvas, Size size) {
    final info = _getDirectionInfo();
    final directionColor = _getDirectionColor(info.roadType);

    final barHeight = size.height * 0.12;
    final barPaint = Paint()
      ..color = directionColor
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, size.width, barHeight);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: const Radius.circular(8),
      topRight: const Radius.circular(8),
    );
    canvas.drawRRect(rrect, barPaint);

    String label = '';
    switch (direction) {
      case 'north':
        label = scene.useChineseDirection ? '北向' : 'NORTH';
        break;
      case 'east':
        label = scene.useChineseDirection ? '东向' : 'EAST';
        break;
      case 'south':
        label = scene.useChineseDirection ? '南向' : 'SOUTH';
        break;
      case 'west':
        label = scene.useChineseDirection ? '西向' : 'WEST';
        break;
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (barHeight - textPainter.height) / 2,
      ),
    );
  }

  void _drawRoadSection(Canvas canvas, Size size) {
    final info = _getDirectionInfo();
    final topOffset = size.height * 0.18;

    final labelPainter = TextPainter(
      text: TextSpan(
        text: scene.useChineseDirection ? '道路' : 'ROAD',
        style: TextStyle(
          fontSize: 11,
          color: SignColors.urbanBlack.withValues(alpha: 0.5),
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(16, topOffset));

    final namePainter = TextPainter(
      text: TextSpan(
        text: info.roadName.isEmpty ? '未命名道路' : info.roadName,
        style: TextStyle(
          fontSize: 24,
          color: _getDirectionColor(info.roadType),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(canvas, Offset(16, topOffset + 18));

    final typeLabel = _getTypeLabel(info.roadType);
    final typePainter = TextPainter(
      text: TextSpan(
        text: ' $typeLabel ',
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    typePainter.layout();

    final typeBgRect = Rect.fromLTWH(
      16,
      topOffset + 50,
      typePainter.width + 8,
      typePainter.height + 4,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(typeBgRect, const Radius.circular(4)),
      Paint()..color = _getDirectionColor(info.roadType),
    );
    typePainter.paint(canvas, Offset(20, topOffset + 52));
  }

  void _drawDivider(Canvas canvas, Size size) {
    final dividerY = size.height * 0.48;
    final dividerPaint = Paint()
      ..color = SignColors.urbanBlack.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(16, dividerY),
      Offset(size.width - 16, dividerY),
      dividerPaint,
    );
  }

  void _drawDestinationSection(Canvas canvas, Size size) {
    final info = _getDirectionInfo();
    final topOffset = size.height * 0.54;

    final labelPainter = TextPainter(
      text: TextSpan(
        text: scene.useChineseDirection ? '通往' : 'TO',
        style: TextStyle(
          fontSize: 11,
          color: SignColors.urbanBlack.withValues(alpha: 0.5),
          fontWeight: FontWeight.w500,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(16, topOffset));

    final destPainter = TextPainter(
      text: TextSpan(
        text: info.destination.isEmpty ? '请输入目的地' : info.destination,
        style: TextStyle(
          fontSize: 28,
          color: _getDestinationColor(info.destinationType),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    destPainter.layout();
    destPainter.paint(canvas, Offset(16, topOffset + 18));

    final typeLabel = _getDestinationTypeLabel(info.destinationType);
    if (typeLabel.isNotEmpty) {
      final typePainter = TextPainter(
        text: TextSpan(
          text: ' $typeLabel ',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      typePainter.layout();

      final typeBgRect = Rect.fromLTWH(
        16,
        topOffset + 55,
        typePainter.width + 8,
        typePainter.height + 4,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(typeBgRect, const Radius.circular(4)),
        Paint()..color = _getDestinationColor(info.destinationType),
      );
      typePainter.paint(canvas, Offset(20, topOffset + 57));
    }
  }

  void _drawBottomBar(Canvas canvas, Size size) {
    final info = _getDirectionInfo();
    final shapeLabel = _getShapeLabel(info.shape);

    if (shapeLabel.isNotEmpty) {
      final barHeight = size.height * 0.1;
      final barPaint = Paint()
        ..color = SignColors.urbanBlack.withValues(alpha: 0.05)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(
        0,
        size.height - barHeight,
        size.width,
        barHeight,
      );
      final rrect = RRect.fromRectAndCorners(
        rect,
        bottomLeft: const Radius.circular(8),
        bottomRight: const Radius.circular(8),
      );
      canvas.drawRRect(rrect, barPaint);

      final shapePainter = TextPainter(
        text: TextSpan(
          text: shapeLabel,
          style: TextStyle(
            fontSize: 11,
            color: SignColors.urbanBlack.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      shapePainter.layout();
      shapePainter.paint(
        canvas,
        Offset(
          (size.width - shapePainter.width) / 2,
          size.height - barHeight / 2 - shapePainter.height / 2,
        ),
      );
    }
  }

  DirectionInfo _getDirectionInfo() {
    switch (direction) {
      case 'north':
        return scene.north;
      case 'east':
        return scene.east;
      case 'south':
        return scene.south;
      case 'west':
        return scene.west;
      default:
        return scene.north;
    }
  }

  Color _getDirectionColor(RoadType type) {
    switch (type) {
      case RoadType.highway:
        return SignColors.highwayGreen;
      case RoadType.scenic:
        return SignColors.scenicBlue;
      default:
        return SignColors.urbanBlack;
    }
  }

  Color _getDestinationColor(DestinationType type) {
    switch (type) {
      case DestinationType.highway:
        return SignColors.highwayGreen;
      case DestinationType.scenic:
        return SignColors.scenicBlue;
      default:
        return SignColors.urbanBlack;
    }
  }

  String _getTypeLabel(RoadType type) {
    switch (type) {
      case RoadType.highway:
        return scene.useChineseDirection ? '高速' : 'G';
      case RoadType.scenic:
        return scene.useChineseDirection ? '景区' : 'S';
      default:
        return '';
    }
  }

  String _getDestinationTypeLabel(DestinationType type) {
    switch (type) {
      case DestinationType.highway:
        return scene.useChineseDirection ? '高速' : 'HIGHWAY';
      case DestinationType.scenic:
        return scene.useChineseDirection ? '景区' : 'SCENIC';
      default:
        return '';
    }
  }

  String _getShapeLabel(IntersectionShape shape) {
    switch (shape) {
      case IntersectionShape.crossroad:
        return '十字路口';
      case IntersectionShape.tJunctionFrontLeft:
        return 'T形路口';
      case IntersectionShape.tJunctionFrontRight:
        return 'T形路口';
      case IntersectionShape.tJunctionLeftRight:
        return 'T形路口';
      case IntersectionShape.yJunction:
        return 'Y形路口';
      case IntersectionShape.roundabout:
        return '环岛';
      default:
        return '';
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class IntersectionOverviewPainter extends CustomPainter {
  final IntersectionScene scene;

  IntersectionOverviewPainter({required this.scene});

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas, size);
    _drawRoads(canvas, size);
    _drawIntersectionCenter(canvas, size);
    _drawDirectionLabels(canvas, size);
    _drawRoadLabels(canvas, size);
  }

  void _drawBackground(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFF1F5F9),
    );
  }

  void _drawRoads(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final roadWidth = size.width * 0.12;
    final roadPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - roadWidth / 2,
        0,
        roadWidth,
        center.dy - roadWidth / 2,
      ),
      roadPaint,
    );
    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, center.dy - roadWidth / 2),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - roadWidth / 2,
        center.dy + roadWidth / 2,
        roadWidth,
        size.height - center.dy - roadWidth / 2,
      ),
      roadPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + roadWidth / 2),
      Offset(center.dx, size.height),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx + roadWidth / 2,
        center.dy - roadWidth / 2,
        size.width - center.dx - roadWidth / 2,
        roadWidth,
      ),
      roadPaint,
    );
    canvas.drawLine(
      Offset(center.dx + roadWidth / 2, center.dy),
      Offset(size.width, center.dy),
      linePaint,
    );

    canvas.drawRect(
      Rect.fromLTWH(
        0,
        center.dy - roadWidth / 2,
        center.dx - roadWidth / 2,
        roadWidth,
      ),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, center.dy),
      Offset(center.dx - roadWidth / 2, center.dy),
      linePaint,
    );
  }

  void _drawIntersectionCenter(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final roadWidth = size.width * 0.12;

    final centerPaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: roadWidth, height: roadWidth),
      centerPaint,
    );
  }

  void _drawDirectionLabels(Canvas canvas, Size size) {
    final directions = [
      ('N', Offset(size.width / 2, 16)),
      ('E', Offset(size.width - 24, size.height / 2)),
      ('S', Offset(size.width / 2, size.height - 20)),
      ('W', Offset(16, size.height / 2)),
    ];

    for (final (label, pos) in directions) {
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(pos.dx - painter.width / 2, pos.dy - painter.height / 2),
      );
    }
  }

  void _drawRoadLabels(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final roads = [
      (
        scene.north.roadName.isEmpty ? '北向道路' : scene.north.roadName,
        Offset(center.dx, size.height * 0.2),
        TextDirection.ltr,
      ),
      (
        scene.east.roadName.isEmpty ? '东向道路' : scene.east.roadName,
        Offset(size.width * 0.75, center.dy),
        TextDirection.ltr,
      ),
      (
        scene.south.roadName.isEmpty ? '南向道路' : scene.south.roadName,
        Offset(center.dx, size.height * 0.8),
        TextDirection.ltr,
      ),
      (
        scene.west.roadName.isEmpty ? '西向道路' : scene.west.roadName,
        Offset(size.width * 0.25, center.dy),
        TextDirection.ltr,
      ),
    ];

    for (final (name, pos, textDir) in roads) {
      final painter = TextPainter(
        text: TextSpan(
          text: name,
          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
        textDirection: textDir,
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(pos.dx - painter.width / 2, pos.dy - painter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

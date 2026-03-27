import 'package:flutter/material.dart';

import '../models/intersection_scene.dart';

class RoadSignPainter extends CustomPainter {
  const RoadSignPainter({required this.scene, required this.direction});

  final IntersectionScene scene;
  final String direction;

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = scene.backgroundColor;
    final fgColor = scene.foregroundColor;

    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.015),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..color = bgColor
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..color = fgColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.006,
    );

    final inset = size.width * 0.025;
    final content = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    _drawTopLeftDirection(canvas, content, fgColor, size);
    _drawTopCenterRoad(canvas, content, fgColor, size);
    _drawTopRightDestination(canvas, content, fgColor, size);
    _drawLeftRoad(canvas, content, fgColor, size);
    _drawCenterIntersection(canvas, content, fgColor, size);
    _drawRightRoad(canvas, content, fgColor, size);
    _drawBottomLeftPlace(canvas, content, fgColor, size);
    _drawBottomCenterRoad(canvas, content, fgColor, size);
    _drawBottomRightPlace(canvas, content, fgColor, size);
  }

  void _drawTopLeftDirection(
    Canvas canvas,
    Rect content,
    Color fgColor,
    Size size,
  ) {
    final boxLeft = content.left;
    final boxTop = content.top;
    final boxWidth = content.width * 0.22;
    final boxHeight = content.height * 0.18;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxLeft, boxTop, boxWidth, boxHeight),
      Radius.circular(size.width * 0.012),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    final dirText = _getDirectionText();
    _paintText(
      canvas,
      Offset(boxLeft + boxWidth * 0.15, boxTop + boxHeight * 0.15),
      dirText,
      TextStyle(
        color: scene.backgroundColor,
        fontSize: size.width * 0.08,
        fontWeight: FontWeight.w900,
      ),
    );

    _drawArrow(
      canvas,
      boxLeft + boxWidth * 0.5,
      boxTop + boxHeight * 0.45,
      size.width * 0.06,
      scene.backgroundColor,
    );

    final typeText = _getRoadTypeShort();
    _paintText(
      canvas,
      Offset(boxLeft + boxWidth * 0.15, boxTop + boxHeight * 0.65),
      typeText,
      TextStyle(
        color: scene.backgroundColor,
        fontSize: size.width * 0.035,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _drawTopCenterRoad(
    Canvas canvas,
    Rect content,
    Color fgColor,
    Size size,
  ) {
    final centerX = content.left + content.width * 0.5;
    final topY = content.top;

    final roadName = _getMainRoadName();
    _paintText(
      canvas,
      Offset(centerX - 80, topY + size.width * 0.06),
      roadName,
      TextStyle(
        color: fgColor,
        fontSize: size.width * 0.09,
        fontWeight: FontWeight.w800,
      ),
      maxWidth: content.width * 0.5,
    );

    final roadNameEn = _getMainRoadNameEn();
    if (roadNameEn.isNotEmpty) {
      _paintText(
        canvas,
        Offset(centerX - 60, topY + size.width * 0.14),
        roadNameEn,
        TextStyle(
          color: fgColor.withValues(alpha: 0.8),
          fontSize: size.width * 0.035,
        ),
        maxWidth: content.width * 0.4,
      );
    }
  }

  void _drawTopRightDestination(
    Canvas canvas,
    Rect content,
    Color fgColor,
    Size size,
  ) {
    final boxRight = content.right;
    final boxTop = content.top;
    final boxWidth = content.width * 0.25;
    final boxHeight = content.height * 0.18;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxRight - boxWidth, boxTop, boxWidth, boxHeight),
      Radius.circular(size.width * 0.012),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    final dest = _getTopDestination();
    _paintText(
      canvas,
      Offset(boxRight - boxWidth + boxWidth * 0.1, boxTop + boxHeight * 0.25),
      dest,
      TextStyle(
        color: scene.backgroundColor,
        fontSize: size.width * 0.055,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: boxWidth * 0.85,
    );

    final destEn = _getTopDestinationEn();
    if (destEn.isNotEmpty) {
      _paintText(
        canvas,
        Offset(boxRight - boxWidth + boxWidth * 0.1, boxTop + boxHeight * 0.6),
        destEn,
        TextStyle(
          color: scene.backgroundColor.withValues(alpha: 0.7),
          fontSize: size.width * 0.028,
        ),
        maxWidth: boxWidth * 0.85,
      );
    }
  }

  void _drawLeftRoad(Canvas canvas, Rect content, Color fgColor, Size size) {
    final leftX = content.left;
    final centerY = content.top + content.height * 0.5;

    final leftRoad = scene.west.roadName.isEmpty ? '道路名称' : scene.west.roadName;
    _paintText(
      canvas,
      Offset(leftX + size.width * 0.02, centerY - size.width * 0.04),
      leftRoad,
      TextStyle(
        color: fgColor,
        fontSize: size.width * 0.055,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: content.width * 0.25,
    );

    final leftRoadEn = scene.west.roadNameEn;
    if (leftRoadEn.isNotEmpty) {
      _paintText(
        canvas,
        Offset(leftX + size.width * 0.02, centerY + size.width * 0.035),
        leftRoadEn,
        TextStyle(
          color: fgColor.withValues(alpha: 0.8),
          fontSize: size.width * 0.028,
        ),
        maxWidth: content.width * 0.22,
      );
    }
  }

  void _drawCenterIntersection(
    Canvas canvas,
    Rect content,
    Color fgColor,
    Size size,
  ) {
    final center = content.center;
    final graphicSize = content.width * 0.35;

    final paint = Paint()
      ..color = fgColor
      ..strokeWidth = graphicSize * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    switch (scene.intersectionShape) {
      case IntersectionShape.crossroad:
        canvas.drawLine(
          Offset(center.dx, center.dy - graphicSize * 0.35),
          Offset(center.dx, center.dy + graphicSize * 0.35),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx - graphicSize * 0.35, center.dy),
          Offset(center.dx + graphicSize * 0.35, center.dy),
          paint,
        );
      case IntersectionShape.skewLeft:
        canvas.drawLine(
          Offset(center.dx, center.dy - graphicSize * 0.35),
          Offset(center.dx, center.dy + graphicSize * 0.35),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx - graphicSize * 0.3, center.dy + graphicSize * 0.15),
          Offset(center.dx + graphicSize * 0.3, center.dy - graphicSize * 0.15),
          paint,
        );
      case IntersectionShape.skewRight:
        canvas.drawLine(
          Offset(center.dx, center.dy - graphicSize * 0.35),
          Offset(center.dx, center.dy + graphicSize * 0.35),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx - graphicSize * 0.3, center.dy - graphicSize * 0.15),
          Offset(center.dx + graphicSize * 0.3, center.dy + graphicSize * 0.15),
          paint,
        );
      case IntersectionShape.roundabout:
        canvas.drawCircle(center, graphicSize * 0.25, paint);
        for (final offset in [
          Offset(0.0, -graphicSize * 0.35),
          Offset(graphicSize * 0.35, 0),
          Offset(0, graphicSize * 0.35),
          Offset(-graphicSize * 0.35, 0),
        ]) {
          canvas.drawLine(center + offset * 0.6, center + offset, paint);
        }
      case IntersectionShape.tJunctionFrontLeft:
      case IntersectionShape.tJunctionFrontRight:
      case IntersectionShape.tJunctionLeftRight:
        canvas.drawLine(
          Offset(center.dx, center.dy + graphicSize * 0.3),
          Offset(center.dx, center.dy - graphicSize * 0.1),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - graphicSize * 0.1),
          Offset(center.dx - graphicSize * 0.25, center.dy - graphicSize * 0.3),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx, center.dy - graphicSize * 0.1),
          Offset(center.dx + graphicSize * 0.25, center.dy - graphicSize * 0.3),
          paint,
        );
      case IntersectionShape.yJunction:
        canvas.drawLine(
          Offset(center.dx, center.dy + graphicSize * 0.3),
          center,
          paint,
        );
        canvas.drawLine(
          center,
          Offset(
            center.dx - graphicSize * 0.25,
            center.dy - graphicSize * 0.25,
          ),
          paint,
        );
        canvas.drawLine(
          center,
          Offset(
            center.dx + graphicSize * 0.25,
            center.dy - graphicSize * 0.25,
          ),
          paint,
        );
      default:
        canvas.drawLine(
          Offset(center.dx, center.dy - graphicSize * 0.35),
          Offset(center.dx, center.dy + graphicSize * 0.35),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx - graphicSize * 0.35, center.dy),
          Offset(center.dx + graphicSize * 0.35, center.dy),
          paint,
        );
    }
  }

  void _drawRightRoad(Canvas canvas, Rect content, Color fgColor, Size size) {
    final rightX = content.right;
    final centerY = content.top + content.height * 0.5;

    final rightRoad = scene.east.roadName.isEmpty
        ? '道路名称'
        : scene.east.roadName;
    _paintText(
      canvas,
      Offset(rightX - size.width * 0.28, centerY - size.width * 0.04),
      rightRoad,
      TextStyle(
        color: fgColor,
        fontSize: size.width * 0.055,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: content.width * 0.25,
    );

    final rightRoadEn = scene.east.roadNameEn;
    if (rightRoadEn.isNotEmpty) {
      _paintText(
        canvas,
        Offset(rightX - size.width * 0.25, centerY + size.width * 0.035),
        rightRoadEn,
        TextStyle(
          color: fgColor.withValues(alpha: 0.8),
          fontSize: size.width * 0.028,
        ),
        maxWidth: content.width * 0.22,
      );
    }
  }

  void _drawBottomLeftPlace(
    Canvas canvas,
    Rect content,
    Color fgColor,
    Size size,
  ) {
    final boxLeft = content.left;
    final boxBottom = content.bottom;
    final boxWidth = content.width * 0.28;
    final boxHeight = content.height * 0.2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxLeft, boxBottom - boxHeight, boxWidth, boxHeight),
      Radius.circular(size.width * 0.012),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.transparent
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = scene.scenicColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.008,
    );

    final place = _getBottomLeftPlace();
    _paintText(
      canvas,
      Offset(
        boxLeft + size.width * 0.02,
        boxBottom - boxHeight + boxHeight * 0.2,
      ),
      place,
      TextStyle(
        color: fgColor,
        fontSize: size.width * 0.045,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: boxWidth * 0.9,
    );

    final placeEn = _getBottomLeftPlaceEn();
    if (placeEn.isNotEmpty) {
      _paintText(
        canvas,
        Offset(
          boxLeft + size.width * 0.02,
          boxBottom - boxHeight + boxHeight * 0.6,
        ),
        placeEn,
        TextStyle(
          color: fgColor.withValues(alpha: 0.8),
          fontSize: size.width * 0.024,
        ),
        maxWidth: boxWidth * 0.9,
      );
    }
  }

  void _drawBottomCenterRoad(
    Canvas canvas,
    Rect content,
    Color fgColor,
    Size size,
  ) {
    final centerX = content.left + content.width * 0.5;
    final bottomY = content.bottom;

    final roadName = _getBottomRoadName();
    _paintText(
      canvas,
      Offset(centerX - 80, bottomY - size.width * 0.16),
      roadName,
      TextStyle(
        color: fgColor,
        fontSize: size.width * 0.065,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: content.width * 0.45,
    );

    final roadNameEn = _getBottomRoadNameEn();
    if (roadNameEn.isNotEmpty) {
      _paintText(
        canvas,
        Offset(centerX - 60, bottomY - size.width * 0.09),
        roadNameEn,
        TextStyle(
          color: fgColor.withValues(alpha: 0.8),
          fontSize: size.width * 0.028,
        ),
        maxWidth: content.width * 0.35,
      );
    }
  }

  void _drawBottomRightPlace(
    Canvas canvas,
    Rect content,
    Color fgColor,
    Size size,
  ) {
    final boxRight = content.right;
    final boxBottom = content.bottom;
    final boxWidth = content.width * 0.25;
    final boxHeight = content.height * 0.2;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        boxRight - boxWidth,
        boxBottom - boxHeight,
        boxWidth,
        boxHeight,
      ),
      Radius.circular(size.width * 0.012),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    final place = _getBottomRightPlace();
    _paintText(
      canvas,
      Offset(
        boxRight - boxWidth + size.width * 0.02,
        boxBottom - boxHeight + boxHeight * 0.2,
      ),
      place,
      TextStyle(
        color: scene.backgroundColor,
        fontSize: size.width * 0.045,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: boxWidth * 0.9,
    );

    final placeEn = _getBottomRightPlaceEn();
    if (placeEn.isNotEmpty) {
      _paintText(
        canvas,
        Offset(
          boxRight - boxWidth + size.width * 0.02,
          boxBottom - boxHeight + boxHeight * 0.6,
        ),
        placeEn,
        TextStyle(
          color: scene.backgroundColor.withValues(alpha: 0.7),
          fontSize: size.width * 0.024,
        ),
        maxWidth: boxWidth * 0.9,
      );
    }
  }

  void _drawArrow(
    Canvas canvas,
    double x,
    double y,
    double arrowSize,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = arrowSize * 0.25
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    switch (direction) {
      case 'north':
        path.moveTo(x, y + arrowSize * 0.5);
        path.lineTo(x, y - arrowSize * 0.4);
        path.moveTo(x, y - arrowSize * 0.4);
        path.lineTo(x - arrowSize * 0.3, y - arrowSize * 0.1);
        path.moveTo(x, y - arrowSize * 0.4);
        path.lineTo(x + arrowSize * 0.3, y - arrowSize * 0.1);
      case 'south':
        path.moveTo(x, y - arrowSize * 0.5);
        path.lineTo(x, y + arrowSize * 0.4);
        path.moveTo(x, y + arrowSize * 0.4);
        path.lineTo(x - arrowSize * 0.3, y + arrowSize * 0.1);
        path.moveTo(x, y + arrowSize * 0.4);
        path.lineTo(x + arrowSize * 0.3, y + arrowSize * 0.1);
      case 'east':
        path.moveTo(x - arrowSize * 0.5, y);
        path.lineTo(x + arrowSize * 0.4, y);
        path.moveTo(x + arrowSize * 0.4, y);
        path.lineTo(x + arrowSize * 0.1, y - arrowSize * 0.3);
        path.moveTo(x + arrowSize * 0.4, y);
        path.lineTo(x + arrowSize * 0.1, y + arrowSize * 0.3);
      case 'west':
        path.moveTo(x + arrowSize * 0.5, y);
        path.lineTo(x - arrowSize * 0.4, y);
        path.moveTo(x - arrowSize * 0.4, y);
        path.lineTo(x - arrowSize * 0.1, y - arrowSize * 0.3);
        path.moveTo(x - arrowSize * 0.4, y);
        path.lineTo(x - arrowSize * 0.1, y + arrowSize * 0.3);
      default:
        path.moveTo(x, y + arrowSize * 0.5);
        path.lineTo(x, y - arrowSize * 0.4);
    }
    canvas.drawPath(path, paint);
  }

  String _getDirectionText() {
    return switch (direction) {
      'north' => '北',
      'east' => '东',
      'south' => '南',
      'west' => '西',
      _ => '北',
    };
  }

  String _getRoadTypeShort() {
    return switch (scene.north.roadType) {
      RoadType.highway => 'R',
      _ => '',
    };
  }

  String _getMainRoadName() {
    return scene.north.roadName.isEmpty ? '主干道名称' : scene.north.roadName;
  }

  String _getMainRoadNameEn() {
    return scene.north.roadNameEn;
  }

  String _getTopDestination() {
    return scene.east.destination.isEmpty ? '地点名称' : scene.east.destination;
  }

  String _getTopDestinationEn() {
    return scene.east.destinationEn;
  }

  String _getBottomLeftPlace() {
    return scene.west.destination.isEmpty ? '地点名称' : scene.west.destination;
  }

  String _getBottomLeftPlaceEn() {
    return scene.west.destinationEn;
  }

  String _getBottomRoadName() {
    return scene.south.roadName.isEmpty ? '主干道名称' : scene.south.roadName;
  }

  String _getBottomRoadNameEn() {
    return scene.south.roadNameEn;
  }

  String _getBottomRightPlace() {
    return scene.south.destination.isEmpty ? '地点名称' : scene.south.destination;
  }

  String _getBottomRightPlaceEn() {
    return scene.south.destinationEn;
  }

  TextPainter _layoutText(String text, TextStyle style, {double? maxWidth}) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: maxWidth ?? double.infinity);
  }

  void _paintText(
    Canvas canvas,
    Offset offset,
    String text,
    TextStyle style, {
    double? maxWidth,
  }) {
    if (text.isEmpty) return;
    final painter = _layoutText(text, style, maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant RoadSignPainter oldDelegate) {
    return oldDelegate.scene != scene || oldDelegate.direction != direction;
  }
}

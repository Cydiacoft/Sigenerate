import 'package:flutter/material.dart';

import '../models/intersection_scene.dart';

class RoadSignPainter extends CustomPainter {
  const RoadSignPainter({required this.scene, required this.direction});

  final IntersectionScene scene;
  final String direction;

  @override
  void paint(Canvas canvas, Size size) {
    final info = scene.directionInfo(direction);
    final background = _guideColor(info);

    final outer = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(size.width * 0.035),
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..color = background
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      outer,
      Paint()
        ..color = scene.foregroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.014,
    );

    final inset = size.width * 0.045;
    final content = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    _drawTopBand(canvas, size, content, info);
    _drawPrimaryPanel(canvas, size, content, info);
    _drawMetaBand(canvas, size, content, info);
    _drawBottomCaption(canvas, size, content, info);
  }

  void _drawTopBand(Canvas canvas, Size size, Rect content, DirectionInfo info) {
    final bandHeight = content.height * 0.12;
    final bandRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(content.left, content.top, content.width, bandHeight),
      Radius.circular(size.width * 0.024),
    );
    canvas.drawRRect(
      bandRect,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    _paintText(
      canvas,
      Offset(content.left + content.width * 0.04, bandRect.top + bandHeight * 0.23),
      _directionLabel(),
      TextStyle(
        color: scene.foregroundColor,
        fontSize: size.width * 0.048,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
      maxWidth: content.width * 0.4,
    );

    final routeType = _roadTypeLabel(info.roadType);
    final routeBadgeWidth = content.width * 0.18;
    final routeBadgeHeight = bandHeight * 0.54;
    final routeBadgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        content.right - routeBadgeWidth,
        bandRect.top + (bandHeight - routeBadgeHeight) / 2,
        routeBadgeWidth,
        routeBadgeHeight,
      ),
      Radius.circular(routeBadgeHeight / 2),
    );
    canvas.drawRRect(
      routeBadgeRect,
      Paint()..color = scene.foregroundColor.withValues(alpha: 0.16),
    );
    final badgePainter = _layoutText(
      routeType,
      TextStyle(
        color: scene.foregroundColor,
        fontSize: size.width * 0.027,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: routeBadgeWidth * 0.8,
    );
    badgePainter.paint(
      canvas,
      Offset(
        routeBadgeRect.left + (routeBadgeRect.width - badgePainter.width) / 2,
        routeBadgeRect.top + (routeBadgeRect.height - badgePainter.height) / 2,
      ),
    );

    final intersectionName = scene.name.isEmpty ? '未命名路口' : scene.name;
    _paintText(
      canvas,
      Offset(content.left + content.width * 0.04, bandRect.bottom + content.height * 0.028),
      intersectionName,
      TextStyle(
        color: scene.foregroundColor.withValues(alpha: 0.88),
        fontSize: size.width * 0.03,
        fontWeight: FontWeight.w500,
      ),
      maxWidth: content.width * 0.7,
    );
  }

  void _drawPrimaryPanel(
    Canvas canvas,
    Size size,
    Rect content,
    DirectionInfo info,
  ) {
    final top = content.top + content.height * 0.18;
    final panelHeight = content.height * 0.42;
    final leftPanelWidth = content.width * 0.23;
    final rightPanelWidth = content.width * 0.19;

    final glyphRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(content.left, top, leftPanelWidth, panelHeight),
      Radius.circular(size.width * 0.022),
    );
    canvas.drawRRect(
      glyphRect,
      Paint()..color = scene.foregroundColor.withValues(alpha: 0.96),
    );
    _drawIntersectionGlyph(canvas, glyphRect.outerRect);

    final arrowRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        content.right - rightPanelWidth,
        top,
        rightPanelWidth,
        panelHeight,
      ),
      Radius.circular(size.width * 0.022),
    );
    canvas.drawRRect(
      arrowRect,
      Paint()..color = scene.foregroundColor.withValues(alpha: 0.1),
    );
    _drawDirectionArrow(canvas, arrowRect);

    final textLeft = glyphRect.outerRect.right + content.width * 0.05;
    final textWidth =
        content.right - rightPanelWidth - content.width * 0.05 - textLeft;

    final destination = info.destination.isEmpty ? '请输入通往地点' : info.destination;
    final roadName = info.roadName.isEmpty ? '请输入道路名称' : info.roadName;

    _paintText(
      canvas,
      Offset(textLeft, top + panelHeight * 0.06),
      destination,
      TextStyle(
        color: scene.foregroundColor,
        fontSize: size.width * 0.072,
        fontWeight: FontWeight.w800,
        height: 1.05,
      ),
      maxWidth: textWidth,
    );

    final dividerY = top + panelHeight * 0.58;
    canvas.drawLine(
      Offset(textLeft, dividerY),
      Offset(textLeft + textWidth, dividerY),
      Paint()
        ..color = scene.foregroundColor.withValues(alpha: 0.25)
        ..strokeWidth = size.width * 0.004,
    );

    _paintText(
      canvas,
      Offset(textLeft, top + panelHeight * 0.67),
      roadName,
      TextStyle(
        color: scene.foregroundColor.withValues(alpha: 0.96),
        fontSize: size.width * 0.046,
        fontWeight: FontWeight.w600,
      ),
      maxWidth: textWidth,
    );
  }

  void _drawMetaBand(Canvas canvas, Size size, Rect content, DirectionInfo info) {
    final bandTop = content.top + content.height * 0.66;
    final bandHeight = content.height * 0.11;
    final bandRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(content.left, bandTop, content.width, bandHeight),
      Radius.circular(size.width * 0.018),
    );
    canvas.drawRRect(
      bandRect,
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    final left = content.left + content.width * 0.04;
    final center = content.left + content.width * 0.39;
    final right = content.left + content.width * 0.71;

    _paintText(
      canvas,
      Offset(left, bandTop + bandHeight * 0.27),
      _destinationTypeLabel(info.destinationType),
      TextStyle(
        color: scene.foregroundColor,
        fontSize: size.width * 0.028,
        fontWeight: FontWeight.w700,
      ),
      maxWidth: content.width * 0.24,
    );
    _paintText(
      canvas,
      Offset(center, bandTop + bandHeight * 0.27),
      _shapeLabel(scene.intersectionShape),
      TextStyle(
        color: scene.foregroundColor.withValues(alpha: 0.92),
        fontSize: size.width * 0.028,
        fontWeight: FontWeight.w600,
      ),
      maxWidth: content.width * 0.28,
    );
    _paintText(
      canvas,
      Offset(right, bandTop + bandHeight * 0.27),
      '${info.signIds.length} 个关联元素',
      TextStyle(
        color: scene.foregroundColor.withValues(alpha: 0.9),
        fontSize: size.width * 0.027,
        fontWeight: FontWeight.w600,
      ),
      maxWidth: content.width * 0.22,
    );
  }

  void _drawBottomCaption(
    Canvas canvas,
    Size size,
    Rect content,
    DirectionInfo info,
  ) {
    final captionTop = content.top + content.height * 0.82;
    final captionRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        content.left,
        captionTop,
        content.width,
        content.height * 0.11,
      ),
      Radius.circular(size.width * 0.018),
    );
    canvas.drawRRect(
      captionRect,
      Paint()..color = scene.foregroundColor.withValues(alpha: 0.06),
    );

    final caption = info.signIds.isEmpty
        ? '当前未挂接路标元素'
        : '当前方向已挂接 ${info.signIds.length} 个路标元素，可在右侧素材库继续增删';
    _paintText(
      canvas,
      Offset(
        content.left + content.width * 0.04,
        captionRect.top + captionRect.height * 0.28,
      ),
      caption,
      TextStyle(
        color: scene.foregroundColor.withValues(alpha: 0.82),
        fontSize: size.width * 0.026,
        fontWeight: FontWeight.w500,
      ),
      maxWidth: content.width * 0.9,
    );
  }

  void _drawIntersectionGlyph(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = _guideColor(scene.directionInfo(direction))
      ..strokeWidth = rect.width * 0.1
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = rect.center;
    switch (scene.intersectionShape) {
      case IntersectionShape.crossroad:
        canvas.drawLine(
          Offset(center.dx, rect.top + rect.height * 0.18),
          Offset(center.dx, rect.bottom - rect.height * 0.18),
          paint,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.18, center.dy),
          Offset(rect.right - rect.width * 0.18, center.dy),
          paint,
        );
        break;
      case IntersectionShape.skewLeft:
        canvas.drawLine(
          Offset(center.dx, rect.top + rect.height * 0.16),
          Offset(center.dx, rect.bottom - rect.height * 0.16),
          paint,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.18, center.dy + rect.height * 0.1),
          Offset(rect.right - rect.width * 0.16, center.dy - rect.height * 0.1),
          paint,
        );
        break;
      case IntersectionShape.skewRight:
        canvas.drawLine(
          Offset(center.dx, rect.top + rect.height * 0.16),
          Offset(center.dx, rect.bottom - rect.height * 0.16),
          paint,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.18, center.dy - rect.height * 0.1),
          Offset(rect.right - rect.width * 0.16, center.dy + rect.height * 0.1),
          paint,
        );
        break;
      case IntersectionShape.roundabout:
        canvas.drawCircle(center, rect.width * 0.18, paint);
        for (final offset in [
          Offset(0, -rect.height * 0.26),
          Offset(rect.width * 0.26, 0),
          Offset(0, rect.height * 0.26),
          Offset(-rect.width * 0.26, 0),
        ]) {
          canvas.drawLine(center + offset * 0.55, center + offset, paint);
        }
        break;
      case IntersectionShape.yJunction:
        canvas.drawLine(
          Offset(center.dx, rect.bottom - rect.height * 0.16),
          center,
          paint,
        );
        canvas.drawLine(
          center,
          Offset(rect.left + rect.width * 0.2, rect.top + rect.height * 0.22),
          paint,
        );
        canvas.drawLine(
          center,
          Offset(rect.right - rect.width * 0.2, rect.top + rect.height * 0.22),
          paint,
        );
        break;
      default:
        canvas.drawLine(
          Offset(center.dx, rect.top + rect.height * 0.18),
          Offset(center.dx, rect.bottom - rect.height * 0.18),
          paint,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.18, center.dy),
          Offset(rect.right - rect.width * 0.18, center.dy),
          paint,
        );
        break;
    }
  }

  void _drawDirectionArrow(Canvas canvas, RRect rect) {
    final center = rect.outerRect.center;
    final size = rect.outerRect.width * 0.44;
    final paint = Paint()
      ..color = scene.foregroundColor
      ..strokeWidth = size * 0.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final path = Path();

    switch (direction) {
      case 'north':
        path
          ..moveTo(center.dx, center.dy + size * 0.9)
          ..lineTo(center.dx, center.dy - size * 0.55)
          ..lineTo(center.dx - size * 0.42, center.dy - size * 0.15)
          ..moveTo(center.dx, center.dy - size * 0.55)
          ..lineTo(center.dx + size * 0.42, center.dy - size * 0.15);
        break;
      case 'south':
        path
          ..moveTo(center.dx, center.dy - size * 0.9)
          ..lineTo(center.dx, center.dy + size * 0.55)
          ..lineTo(center.dx - size * 0.42, center.dy + size * 0.15)
          ..moveTo(center.dx, center.dy + size * 0.55)
          ..lineTo(center.dx + size * 0.42, center.dy + size * 0.15);
        break;
      case 'east':
        path
          ..moveTo(center.dx - size * 0.9, center.dy)
          ..lineTo(center.dx + size * 0.55, center.dy)
          ..lineTo(center.dx + size * 0.15, center.dy - size * 0.42)
          ..moveTo(center.dx + size * 0.55, center.dy)
          ..lineTo(center.dx + size * 0.15, center.dy + size * 0.42);
        break;
      case 'west':
        path
          ..moveTo(center.dx + size * 0.9, center.dy)
          ..lineTo(center.dx - size * 0.55, center.dy)
          ..lineTo(center.dx - size * 0.15, center.dy - size * 0.42)
          ..moveTo(center.dx - size * 0.55, center.dy)
          ..lineTo(center.dx - size * 0.15, center.dy + size * 0.42);
        break;
    }

    canvas.drawPath(path, paint);
  }

  Color _guideColor(DirectionInfo info) {
    switch (info.destinationType) {
      case DestinationType.highway:
        return scene.highwayColor;
      case DestinationType.scenic:
        return scene.scenicColor;
      case DestinationType.general:
        switch (info.roadType) {
          case RoadType.highway:
            return scene.highwayColor;
          case RoadType.scenic:
            return scene.scenicColor;
          case RoadType.general:
            return scene.backgroundColor;
        }
    }
  }

  String _directionLabel() {
    final chinese = switch (direction) {
      'north' => '北向',
      'east' => '东向',
      'south' => '南向',
      'west' => '西向',
      _ => '北向',
    };
    if (!scene.useEnglishDirection) {
      return chinese;
    }
    final english = switch (direction) {
      'north' => 'NORTH',
      'east' => 'EAST',
      'south' => 'SOUTH',
      'west' => 'WEST',
      _ => 'NORTH',
    };
    return scene.useChineseDirection ? '$chinese / $english' : english;
  }

  String _roadTypeLabel(RoadType type) {
    switch (type) {
      case RoadType.general:
        return '普通';
      case RoadType.highway:
        return '高速';
      case RoadType.scenic:
        return '景区';
    }
  }

  String _destinationTypeLabel(DestinationType type) {
    switch (type) {
      case DestinationType.general:
        return '普通道路方向';
      case DestinationType.highway:
        return '高速方向';
      case DestinationType.scenic:
        return '景区方向';
    }
  }

  String _shapeLabel(IntersectionShape shape) {
    switch (shape) {
      case IntersectionShape.crossroad:
        return '十字路口';
      case IntersectionShape.skewLeft:
        return '左高右低';
      case IntersectionShape.skewRight:
        return '左低右高';
      case IntersectionShape.roundabout:
        return '环岛';
      case IntersectionShape.tJunctionFrontLeft:
        return '丁字路口(前+左)';
      case IntersectionShape.tJunctionFrontRight:
        return '丁字路口(前+右)';
      case IntersectionShape.tJunctionLeftRight:
        return '丁字路口(左+右)';
      case IntersectionShape.yJunction:
        return '三岔路口';
      case IntersectionShape.diamondBridgeTop:
        return '菱形桥(上跨)';
      case IntersectionShape.diamondBridgeBottom:
        return '菱形桥(下穿)';
    }
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
    final painter = _layoutText(text, style, maxWidth: maxWidth);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant RoadSignPainter oldDelegate) {
    return oldDelegate.scene != scene || oldDelegate.direction != direction;
  }
}

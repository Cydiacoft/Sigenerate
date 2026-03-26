import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/intersection_scene.dart';
import '../models/traffic_sign.dart';
import '../signs/gb5768_signs.dart';
import 'traffic_sign_painter.dart';

class RoadSignPainter extends CustomPainter {
  const RoadSignPainter({required this.scene, required this.direction});

  final IntersectionScene scene;
  final String direction;

  @override
  void paint(Canvas canvas, Size size) {
    final info = scene.directionInfo(direction);
    final backgroundColor = _guideColor(info);
    final borderRadius = Radius.circular(size.width * 0.04);
    final outer = RRect.fromRectAndRadius(Offset.zero & size, borderRadius);

    canvas.drawRRect(
      outer,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.fill,
    );

    canvas.drawRRect(
      outer,
      Paint()
        ..color = scene.foregroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.018,
    );

    final innerRect = Rect.fromLTWH(
      size.width * 0.04,
      size.height * 0.04,
      size.width * 0.92,
      size.height * 0.92,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(innerRect, Radius.circular(size.width * 0.03)),
      Paint()
        ..color = scene.foregroundColor.withValues(alpha: 0.16)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.008,
    );

    _drawHeader(canvas, size, info);
    _drawBody(canvas, size, info);
    _drawFooter(canvas, size, info);
  }

  void _drawHeader(Canvas canvas, Size size, DirectionInfo info) {
    final headerHeight = size.height * 0.17;
    final headerRect = Rect.fromLTWH(
      size.width * 0.04,
      size.height * 0.04,
      size.width * 0.92,
      headerHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(headerRect, Radius.circular(size.width * 0.03)),
      Paint()..color = Colors.black.withValues(alpha: 0.12),
    );

    _paintText(
      canvas,
      Offset(size.width * 0.08, size.height * 0.075),
      _directionLabel(),
      TextStyle(
        color: scene.foregroundColor,
        fontSize: size.width * 0.055,
        fontWeight: FontWeight.w700,
      ),
    );

    _paintText(
      canvas,
      Offset(size.width * 0.08, size.height * 0.12),
      scene.name.isEmpty ? '未命名路口' : scene.name,
      TextStyle(
        color: scene.foregroundColor.withValues(alpha: 0.9),
        fontSize: size.width * 0.036,
        fontWeight: FontWeight.w500,
      ),
    );

    final badgeText = _roadTypeLabel(info.roadType);
    final badgeWidth = size.width * 0.17;
    final badgeHeight = size.height * 0.055;
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.76,
        size.height * 0.085,
        badgeWidth,
        badgeHeight,
      ),
      Radius.circular(badgeHeight / 2),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()..color = scene.foregroundColor.withValues(alpha: 0.18),
    );
    final badgePainter = _layoutText(
      badgeText,
      TextStyle(
        color: scene.foregroundColor,
        fontSize: size.width * 0.03,
        fontWeight: FontWeight.w700,
      ),
    );
    badgePainter.paint(
      canvas,
      Offset(
        badgeRect.left + (badgeRect.width - badgePainter.width) / 2,
        badgeRect.top + (badgeRect.height - badgePainter.height) / 2,
      ),
    );
  }

  void _drawBody(Canvas canvas, Size size, DirectionInfo info) {
    final symbolBox = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.27,
      size.width * 0.24,
      size.height * 0.26,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(symbolBox, Radius.circular(size.width * 0.03)),
      Paint()..color = scene.foregroundColor,
    );
    _drawIntersectionGlyph(canvas, symbolBox);

    final titleX = size.width * 0.38;
    _paintText(
      canvas,
      Offset(titleX, size.height * 0.25),
      info.destination.isEmpty ? '请输入通往地点' : info.destination,
      TextStyle(
        color: scene.foregroundColor,
        fontSize: size.width * 0.072,
        fontWeight: FontWeight.w800,
      ),
    );
    _paintText(
      canvas,
      Offset(titleX, size.height * 0.34),
      info.roadName.isEmpty ? '请输入道路名称' : info.roadName,
      TextStyle(
        color: scene.foregroundColor.withValues(alpha: 0.92),
        fontSize: size.width * 0.05,
        fontWeight: FontWeight.w600,
      ),
    );

    final arrowCenter = Offset(size.width * 0.82, size.height * 0.45);
    _drawDirectionArrow(
      canvas,
      arrowCenter,
      size.width * 0.13,
      scene.foregroundColor,
    );

    final stripRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.08,
        size.height * 0.58,
        size.width * 0.84,
        size.height * 0.12,
      ),
      Radius.circular(size.width * 0.025),
    );
    canvas.drawRRect(
      stripRect,
      Paint()..color = Colors.black.withValues(alpha: 0.14),
    );

    _paintText(
      canvas,
      Offset(size.width * 0.11, size.height * 0.615),
      _destinationTypeLabel(info.destinationType),
      TextStyle(
        color: scene.foregroundColor,
        fontSize: size.width * 0.034,
        fontWeight: FontWeight.w700,
      ),
    );

    _paintText(
      canvas,
      Offset(size.width * 0.52, size.height * 0.615),
      _shapeLabel(scene.intersectionShape),
      TextStyle(
        color: scene.foregroundColor.withValues(alpha: 0.88),
        fontSize: size.width * 0.03,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  void _drawFooter(Canvas canvas, Size size, DirectionInfo info) {
    final signs = info.signIds
        .map(Gb5768Signs.findById)
        .whereType<TrafficSign>()
        .toList();

    final footerTop = size.height * 0.75;
    _paintText(
      canvas,
      Offset(size.width * 0.08, footerTop),
      '关联路标元素',
      TextStyle(
        color: scene.foregroundColor.withValues(alpha: 0.92),
        fontSize: size.width * 0.032,
        fontWeight: FontWeight.w700,
      ),
    );

    if (signs.isEmpty) {
      _paintText(
        canvas,
        Offset(size.width * 0.08, footerTop + size.height * 0.055),
        '未选择路标元素',
        TextStyle(
          color: scene.foregroundColor.withValues(alpha: 0.72),
          fontSize: size.width * 0.03,
          fontWeight: FontWeight.w500,
        ),
      );
      return;
    }

    final iconSize = size.width * 0.12;
    final gap = size.width * 0.025;
    for (int index = 0; index < math.min(signs.length, 5); index++) {
      final sign = signs[index];
      final iconRect = Rect.fromLTWH(
        size.width * 0.08 + index * (iconSize + gap),
        footerTop + size.height * 0.04,
        iconSize,
        iconSize,
      );
      canvas.save();
      canvas.translate(iconRect.left, iconRect.top);
      TrafficSignPainter(sign: sign, scale: 0.96).paint(canvas, iconRect.size);
      canvas.restore();
    }
  }

  void _drawIntersectionGlyph(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = _guideColor(
        scene.directionInfo(direction),
      ).withValues(alpha: 0.92)
      ..strokeWidth = rect.width * 0.14
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = rect.center;
    switch (scene.intersectionShape) {
      case IntersectionShape.crossroad:
        canvas.drawLine(
          Offset(center.dx, rect.top + rect.height * 0.16),
          Offset(center.dx, rect.bottom - rect.height * 0.16),
          paint,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.16, center.dy),
          Offset(rect.right - rect.width * 0.16, center.dy),
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
          Offset(
            rect.right - rect.width * 0.16,
            center.dy - rect.height * 0.08,
          ),
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
          Offset(rect.left + rect.width * 0.18, center.dy - rect.height * 0.08),
          Offset(rect.right - rect.width * 0.16, center.dy + rect.height * 0.1),
          paint,
        );
        break;
      case IntersectionShape.roundabout:
        canvas.drawCircle(center, rect.width * 0.18, paint);
        for (final offset in [
          Offset(0, -rect.height * 0.28),
          Offset(rect.width * 0.28, 0),
          Offset(0, rect.height * 0.28),
          Offset(-rect.width * 0.28, 0),
        ]) {
          canvas.drawLine(center + offset * 0.55, center + offset, paint);
        }
        break;
      case IntersectionShape.tJunctionFrontLeft:
      case IntersectionShape.tJunctionFrontRight:
      case IntersectionShape.tJunctionLeftRight:
        canvas.drawLine(
          Offset(center.dx, rect.top + rect.height * 0.16),
          Offset(center.dx, rect.bottom - rect.height * 0.16),
          paint,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.16, center.dy),
          Offset(rect.right - rect.width * 0.16, center.dy),
          paint,
        );
        break;
      case IntersectionShape.yJunction:
        canvas.drawLine(
          Offset(center.dx, rect.bottom - rect.height * 0.16),
          center,
          paint,
        );
        canvas.drawLine(
          center,
          Offset(rect.left + rect.width * 0.18, rect.top + rect.height * 0.2),
          paint,
        );
        canvas.drawLine(
          center,
          Offset(rect.right - rect.width * 0.18, rect.top + rect.height * 0.2),
          paint,
        );
        break;
      case IntersectionShape.diamondBridgeTop:
      case IntersectionShape.diamondBridgeBottom:
        canvas.drawLine(
          Offset(center.dx, rect.top + rect.height * 0.12),
          Offset(center.dx, rect.bottom - rect.height * 0.12),
          paint,
        );
        canvas.drawLine(
          Offset(rect.left + rect.width * 0.12, center.dy),
          Offset(rect.right - rect.width * 0.12, center.dy),
          paint,
        );
        canvas.drawCircle(center, rect.width * 0.1, paint);
        break;
    }
  }

  void _drawDirectionArrow(
    Canvas canvas,
    Offset center,
    double size,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size * 0.18
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    switch (direction) {
      case 'north':
        path
          ..moveTo(center.dx, center.dy + size * 0.35)
          ..lineTo(center.dx, center.dy - size * 0.2)
          ..lineTo(center.dx - size * 0.18, center.dy - size * 0.02)
          ..moveTo(center.dx, center.dy - size * 0.2)
          ..lineTo(center.dx + size * 0.18, center.dy - size * 0.02);
        break;
      case 'south':
        path
          ..moveTo(center.dx, center.dy - size * 0.35)
          ..lineTo(center.dx, center.dy + size * 0.2)
          ..lineTo(center.dx - size * 0.18, center.dy + size * 0.02)
          ..moveTo(center.dx, center.dy + size * 0.2)
          ..lineTo(center.dx + size * 0.18, center.dy + size * 0.02);
        break;
      case 'east':
        path
          ..moveTo(center.dx - size * 0.35, center.dy)
          ..lineTo(center.dx + size * 0.2, center.dy)
          ..lineTo(center.dx + size * 0.02, center.dy - size * 0.18)
          ..moveTo(center.dx + size * 0.2, center.dy)
          ..lineTo(center.dx + size * 0.02, center.dy + size * 0.18);
        break;
      case 'west':
        path
          ..moveTo(center.dx + size * 0.35, center.dy)
          ..lineTo(center.dx - size * 0.2, center.dy)
          ..lineTo(center.dx - size * 0.02, center.dy - size * 0.18)
          ..moveTo(center.dx - size * 0.2, center.dy)
          ..lineTo(center.dx - size * 0.02, center.dy + size * 0.18);
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
    if (scene.useEnglishDirection) {
      final english = switch (direction) {
        'north' => 'NORTH',
        'east' => 'EAST',
        'south' => 'SOUTH',
        'west' => 'WEST',
        _ => 'NORTH',
      };
      return scene.useChineseDirection ? '$chinese / $english' : english;
    }
    return chinese;
  }

  String _roadTypeLabel(RoadType roadType) {
    switch (roadType) {
      case RoadType.highway:
        return '高速';
      case RoadType.scenic:
        return '景区';
      case RoadType.general:
        return '普通';
    }
  }

  String _destinationTypeLabel(DestinationType destinationType) {
    switch (destinationType) {
      case DestinationType.highway:
        return '高速方向';
      case DestinationType.scenic:
        return '景区方向';
      case DestinationType.general:
        return '普通道路方向';
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

  TextPainter _layoutText(String text, TextStyle style) {
    return TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout();
  }

  void _paintText(Canvas canvas, Offset offset, String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: 9999);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant RoadSignPainter oldDelegate) {
    return oldDelegate.scene != scene || oldDelegate.direction != direction;
  }
}

class IntersectionOverviewPainter extends CustomPainter {
  const IntersectionOverviewPainter({required this.scene});

  final IntersectionScene scene;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(18)),
      Paint()..color = const Color(0xFFEEF4FB),
    );

    final roadPaint = Paint()
      ..color = const Color(0xFF7A8CA3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.11
      ..strokeCap = StrokeCap.round;
    final lanePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.014
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final top = Offset(center.dx, size.height * 0.14);
    final bottom = Offset(center.dx, size.height * 0.86);
    final left = Offset(size.width * 0.14, center.dy);
    final right = Offset(size.width * 0.86, center.dy);

    canvas.drawLine(top, bottom, roadPaint);
    canvas.drawLine(left, right, roadPaint);
    canvas.drawLine(top, bottom, lanePaint);
    canvas.drawLine(left, right, lanePaint);

    switch (scene.intersectionShape) {
      case IntersectionShape.skewLeft:
        canvas.drawLine(
          Offset(size.width * 0.14, center.dy + size.height * 0.06),
          Offset(size.width * 0.86, center.dy - size.height * 0.04),
          roadPaint,
        );
        canvas.drawLine(
          Offset(size.width * 0.14, center.dy + size.height * 0.06),
          Offset(size.width * 0.86, center.dy - size.height * 0.04),
          lanePaint,
        );
        break;
      case IntersectionShape.skewRight:
        canvas.drawLine(
          Offset(size.width * 0.14, center.dy - size.height * 0.04),
          Offset(size.width * 0.86, center.dy + size.height * 0.06),
          roadPaint,
        );
        canvas.drawLine(
          Offset(size.width * 0.14, center.dy - size.height * 0.04),
          Offset(size.width * 0.86, center.dy + size.height * 0.06),
          lanePaint,
        );
        break;
      case IntersectionShape.roundabout:
        canvas.drawCircle(
          center,
          size.width * 0.09,
          Paint()
            ..color = const Color(0xFF7A8CA3)
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          center,
          size.width * 0.05,
          Paint()..color = const Color(0xFFEEF4FB),
        );
        break;
      default:
        break;
    }

    _paintLabel(
      canvas,
      top.translate(0, -size.height * 0.08),
      '北',
      scene.north.roadName,
    );
    _paintLabel(
      canvas,
      right.translate(size.width * 0.06, 0),
      '东',
      scene.east.roadName,
      horizontal: true,
    );
    _paintLabel(
      canvas,
      bottom.translate(0, size.height * 0.05),
      '南',
      scene.south.roadName,
    );
    _paintLabel(
      canvas,
      left.translate(-size.width * 0.06, 0),
      '西',
      scene.west.roadName,
      horizontal: true,
      alignRight: true,
    );
  }

  void _paintLabel(
    Canvas canvas,
    Offset anchor,
    String direction,
    String roadName, {
    bool horizontal = false,
    bool alignRight = false,
  }) {
    final titlePainter = TextPainter(
      text: TextSpan(
        text: direction,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final roadPainter = TextPainter(
      text: TextSpan(
        text: roadName.isEmpty ? '未命名道路' : roadName,
        style: const TextStyle(
          color: Color(0xFF475569),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 120);

    final titleOffset = horizontal
        ? Offset(
            alignRight ? anchor.dx - titlePainter.width : anchor.dx,
            anchor.dy - titlePainter.height - 4,
          )
        : Offset(anchor.dx - titlePainter.width / 2, anchor.dy);
    titlePainter.paint(canvas, titleOffset);

    final roadOffset = horizontal
        ? Offset(
            alignRight ? anchor.dx - roadPainter.width : anchor.dx,
            anchor.dy + 2,
          )
        : Offset(
            anchor.dx - roadPainter.width / 2,
            anchor.dy + titlePainter.height + 4,
          );
    roadPainter.paint(canvas, roadOffset);
  }

  @override
  bool shouldRepaint(covariant IntersectionOverviewPainter oldDelegate) {
    return oldDelegate.scene != scene;
  }
}

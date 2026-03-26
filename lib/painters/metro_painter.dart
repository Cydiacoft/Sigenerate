import 'package:flutter/material.dart';
import '../models/metro_models.dart';

class MetroTemplatePainter extends CustomPainter {
  final MetroTemplate template;
  final Map<String, dynamic> slotValues;
  final MetroCityInfo cityConfig;
  final String? selectedSlotId;

  MetroTemplatePainter({
    required this.template,
    required this.slotValues,
    required this.cityConfig,
    this.selectedSlotId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    
    final scaleX = size.width / template.canvasSize.width;
    final scaleY = size.height / template.canvasSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    final offsetX = (size.width - template.canvasSize.width * scale) / 2;
    final offsetY = (size.height - template.canvasSize.height * scale) / 2;
    
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    _drawBackground(canvas);
    
    for (final slot in template.slots) {
      _drawSlot(canvas, slot);
    }
    
    canvas.restore();
  }

  void _drawBackground(Canvas canvas) {
    final paint = Paint()
      ..color = template.defaultBgColor
      ..style = PaintingStyle.fill;
    
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, template.canvasSize.width, template.canvasSize.height),
      const Radius.circular(6),
    );
    canvas.drawRRect(rrect, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawSlot(Canvas canvas, MetroSlot slot) {
    final value = slotValues[slot.id];
    
    switch (slot.type) {
      case 'line':
        _drawLineBadge(canvas, slot, value);
        break;
      case 'arrow_right':
      case 'arrow_left':
      case 'arrow_up':
      case 'arrow_down':
        _drawArrow(canvas, slot);
        break;
      case 'text':
        _drawText(canvas, slot, value);
        break;
      case 'exit_badge':
        _drawExitBadge(canvas, slot, value);
        break;
      case 'icon':
        _drawIcon(canvas, slot);
        break;
    }

    if (selectedSlotId == slot.id) {
      _drawSelectionBorder(canvas, slot);
    }
  }

  void _drawLineBadge(Canvas canvas, MetroSlot slot, dynamic value) {
    final MetroLineInfo? line = value is MetroLineInfo ? value : slot.defaultLine;
    if (line == null) return;

    final center = Offset(
      slot.position.dx + slot.size.width / 2,
      slot.position.dy + slot.size.height / 2,
    );

    final badgePaint = Paint()
      ..color = line.lineColor
      ..style = PaintingStyle.fill;

    final radius = slot.size.width / 2;
    canvas.drawCircle(center, radius, badgePaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${line.number}',
        style: TextStyle(
          fontSize: slot.fontSize,
          color: Colors.white,
          fontWeight: slot.fontWeight,
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

  void _drawArrow(Canvas canvas, MetroSlot slot) {
    final arrowPaint = Paint()
      ..color = slot.textColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(
      slot.position.dx + slot.size.width / 2,
      slot.position.dy + slot.size.height / 2,
    );

    final arrowSize = slot.size.height * 0.4;
    
    Path path;
    final direction = slot.arrowDirection ?? 'right';
    switch (direction) {
      case 'up':
        path = Path()
          ..moveTo(center.dx, center.dy - arrowSize)
          ..lineTo(center.dx, center.dy + arrowSize * 0.6)
          ..moveTo(center.dx - arrowSize * 0.5, center.dy + arrowSize * 0.1)
          ..lineTo(center.dx, center.dy + arrowSize * 0.6)
          ..lineTo(center.dx + arrowSize * 0.5, center.dy + arrowSize * 0.1);
        break;
      case 'down':
        path = Path()
          ..moveTo(center.dx, center.dy + arrowSize)
          ..lineTo(center.dx, center.dy - arrowSize * 0.6)
          ..moveTo(center.dx - arrowSize * 0.5, center.dy - arrowSize * 0.1)
          ..lineTo(center.dx, center.dy - arrowSize * 0.6)
          ..lineTo(center.dx + arrowSize * 0.5, center.dy - arrowSize * 0.1);
        break;
      case 'left':
        path = Path()
          ..moveTo(center.dx - arrowSize, center.dy)
          ..lineTo(center.dx + arrowSize * 0.6, center.dy)
          ..moveTo(center.dx + arrowSize * 0.1, center.dy - arrowSize * 0.5)
          ..lineTo(center.dx + arrowSize * 0.6, center.dy)
          ..lineTo(center.dx + arrowSize * 0.1, center.dy + arrowSize * 0.5);
        break;
      default:
        path = Path()
          ..moveTo(center.dx + arrowSize, center.dy)
          ..lineTo(center.dx - arrowSize * 0.6, center.dy)
          ..moveTo(center.dx - arrowSize * 0.1, center.dy - arrowSize * 0.5)
          ..lineTo(center.dx - arrowSize * 0.6, center.dy)
          ..lineTo(center.dx - arrowSize * 0.1, center.dy + arrowSize * 0.5);
    }

    canvas.drawPath(path, arrowPaint);
  }

  void _drawText(Canvas canvas, MetroSlot slot, dynamic value) {
    final String text = value?.toString() ?? '';
    if (text.isEmpty) return;

    final textColor = slot.textColor;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: slot.fontSize,
          color: textColor,
          fontWeight: slot.fontWeight,
          fontFamily: cityConfig.fontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: slot.size.width);

    Offset textPos;
    switch (slot.alignment) {
      case Alignment.topCenter:
      case Alignment.center:
      case Alignment.bottomCenter:
        textPos = Offset(
          slot.position.dx + (slot.size.width - textPainter.width) / 2,
          slot.position.dy,
        );
        break;
      case Alignment.topRight:
      case Alignment.centerRight:
      case Alignment.bottomRight:
        textPos = Offset(
          slot.position.dx + slot.size.width - textPainter.width,
          slot.position.dy,
        );
        break;
      default:
        textPos = slot.position;
    }

    textPainter.paint(canvas, textPos);
  }

  void _drawExitBadge(Canvas canvas, MetroSlot slot, dynamic value) {
    final String exitText = value?.toString() ?? '出口';
    
    final center = Offset(
      slot.position.dx + slot.size.width / 2,
      slot.position.dy + slot.size.height / 2,
    );

    final badgePaint = Paint()
      ..color = const Color(0xFFE4002B)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: slot.size.width * 0.9, height: slot.size.height * 0.85),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, badgePaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: exitText,
        style: TextStyle(
          fontSize: slot.fontSize,
          color: Colors.white,
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

  void _drawIcon(Canvas canvas, MetroSlot slot) {
    IconData iconData;
    switch (slot.iconName) {
      case 'escalator_up':
        iconData = Icons.stairs;
        break;
      case 'escalator_down':
        iconData = Icons.stairs;
        break;
      case 'elevator':
        iconData = Icons.elevator;
        break;
      case 'toilet':
        iconData = Icons.wc;
        break;
      case 'info':
        iconData = Icons.info;
        break;
      case 'exit':
        iconData = Icons.exit_to_app;
        break;
      case 'ticket':
        iconData = Icons.confirmation_number;
        break;
      default:
        iconData = Icons.circle;
    }

    final center = Offset(
      slot.position.dx + slot.size.width / 2,
      slot.position.dy + slot.size.height / 2,
    );

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: slot.size.width * 0.7,
          fontFamily: iconData.fontFamily,
          color: slot.textColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    iconPainter.layout();
    iconPainter.paint(
      canvas,
      Offset(center.dx - iconPainter.width / 2, center.dy - iconPainter.height / 2),
    );
  }

  void _drawSelectionBorder(Canvas canvas, MetroSlot slot) {
    final rect = Rect.fromLTWH(
      slot.position.dx - 3,
      slot.position.dy - 3,
      slot.size.width + 6,
      slot.size.height + 6,
    );

    final fillPaint = Paint()
      ..color = const Color(0xFF6366F1).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRect(rect, fillPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF6366F1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant MetroTemplatePainter oldDelegate) => true;
}

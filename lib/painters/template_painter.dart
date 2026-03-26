import 'package:flutter/material.dart';
import '../models/templates.dart';

class TemplatePainter extends CustomPainter {
  final TemplateLayout template;
  final Map<String, String> slotValues;
  final Color backgroundColor;
  final String? selectedSlotId;
  final bool showSlotLabels;

  TemplatePainter({
    required this.template,
    required this.slotValues,
    required this.backgroundColor,
    this.selectedSlotId,
    this.showSlotLabels = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawBackground(canvas);
    
    for (final slot in template.slots) {
      _drawSlot(canvas, slot);
    }
    
    if (showSlotLabels) {
      _drawSlotLabels(canvas);
    }
  }

  void _drawBackground(Canvas canvas) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, template.canvasSize.width, template.canvasSize.height),
      const Radius.circular(4),
    );
    canvas.drawRRect(rrect, paint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(rrect, borderPaint);
  }

  void _drawSlot(Canvas canvas, TemplateSlot slot) {
    final value = slotValues[slot.id] ?? '';

    if (slot.type == 'text') {
      _drawTextSlot(canvas, slot, value);
    } else if (slot.type.startsWith('arrow')) {
      _drawArrowSlot(canvas, slot);
    }
  }

  void _drawTextSlot(Canvas canvas, TemplateSlot slot, String value) {
    final textColor = slot.textColor ?? Colors.white;
    
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${slot.prefix ?? ''}$value${slot.suffix ?? ''}',
        style: TextStyle(
          fontSize: slot.fontSize,
          color: textColor,
          fontWeight: slot.fontWeight,
          fontFamily: 'Microsoft YaHei',
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '...',
    );
    textPainter.layout(maxWidth: slot.size.width);

    Offset textPos;
    switch (slot.alignment) {
      case Alignment.topLeft:
      case Alignment.centerLeft:
      case Alignment.bottomLeft:
        textPos = slot.position;
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
        textPos = Offset(
          slot.position.dx + (slot.size.width - textPainter.width) / 2,
          slot.position.dy + (slot.size.height - textPainter.height) / 2,
        );
    }

    if (selectedSlotId == slot.id) {
      final highlightPaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(
          slot.position.dx - 4,
          slot.position.dy - 4,
          slot.size.width + 8,
          slot.size.height + 8,
        ),
        highlightPaint,
      );

      final borderPaint = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(
        Rect.fromLTWH(
          slot.position.dx - 4,
          slot.position.dy - 4,
          slot.size.width + 8,
          slot.size.height + 8,
        ),
        borderPaint,
      );
    }

    textPainter.paint(canvas, textPos);
  }

  void _drawArrowSlot(Canvas canvas, TemplateSlot slot) {
    final arrowPaint = Paint()
      ..color = slot.textColor ?? Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(
      slot.position.dx + slot.size.width / 2,
      slot.position.dy + slot.size.height / 2,
    );
    final arrowSize = slot.fontSize;

    Path path;
    switch (slot.type) {
      case 'arrow_up':
        path = Path()
          ..moveTo(center.dx, center.dy - arrowSize / 2)
          ..lineTo(center.dx, center.dy + arrowSize / 2)
          ..moveTo(center.dx - arrowSize / 3, center.dy + arrowSize / 6)
          ..lineTo(center.dx, center.dy + arrowSize / 2)
          ..lineTo(center.dx + arrowSize / 3, center.dy + arrowSize / 6);
        break;
      case 'arrow_down':
        path = Path()
          ..moveTo(center.dx, center.dy + arrowSize / 2)
          ..lineTo(center.dx, center.dy - arrowSize / 2)
          ..moveTo(center.dx - arrowSize / 3, center.dy - arrowSize / 6)
          ..lineTo(center.dx, center.dy - arrowSize / 2)
          ..lineTo(center.dx + arrowSize / 3, center.dy - arrowSize / 6);
        break;
      case 'arrow_left':
        path = Path()
          ..moveTo(center.dx - arrowSize / 2, center.dy)
          ..lineTo(center.dx + arrowSize / 2, center.dy)
          ..moveTo(center.dx + arrowSize / 6, center.dy - arrowSize / 3)
          ..lineTo(center.dx + arrowSize / 2, center.dy)
          ..lineTo(center.dx + arrowSize / 6, center.dy + arrowSize / 3);
        break;
      case 'arrow_right':
      default:
        path = Path()
          ..moveTo(center.dx + arrowSize / 2, center.dy)
          ..lineTo(center.dx - arrowSize / 2, center.dy)
          ..moveTo(center.dx - arrowSize / 6, center.dy - arrowSize / 3)
          ..lineTo(center.dx - arrowSize / 2, center.dy)
          ..lineTo(center.dx - arrowSize / 6, center.dy + arrowSize / 3);
        break;
    }

    canvas.drawPath(path, arrowPaint);

    if (selectedSlotId == slot.id) {
      final highlightPaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawRect(
        Rect.fromLTWH(
          slot.position.dx - 4,
          slot.position.dy - 4,
          slot.size.width + 8,
          slot.size.height + 8,
        ),
        highlightPaint,
      );
    }
  }

  void _drawSlotLabels(Canvas canvas) {
    for (final slot in template.slots) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: slot.label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.amber.withValues(alpha: 0.8),
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(slot.position.dx, slot.position.dy + slot.size.height + 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant TemplatePainter oldDelegate) => true;
}

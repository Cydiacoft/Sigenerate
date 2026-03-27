import 'package:flutter/material.dart';

class RoadBoardTemplateSpec {
  const RoadBoardTemplateSpec({
    required this.id,
    required this.name,
    required this.canvasSize,
    required this.slots,
  });

  final String id;
  final String name;
  final Size canvasSize;
  final Map<String, RoadBoardSlotSpec> slots;
}

class RoadBoardSlotSpec {
  const RoadBoardSlotSpec({
    required this.id,
    required this.rect,
    this.fontSize,
    this.useWhiteBox = false,
    this.useScenicBorder = false,
  });

  final String id;
  final Rect rect;
  final double? fontSize;
  final bool useWhiteBox;
  final bool useScenicBorder;
}

class RoadBoardTemplates {
  static const standardCrossroad = RoadBoardTemplateSpec(
    id: 'standard_crossroad',
    name: 'Standard Crossroad Guide Board',
    canvasSize: Size(1020, 496),
    slots: {
      'topLeft': RoadBoardSlotSpec(
        id: 'topLeft',
        rect: Rect.fromLTWH(22, 18, 134, 82),
        fontSize: 30,
        useWhiteBox: true,
      ),
      'topCenter': RoadBoardSlotSpec(
        id: 'topCenter',
        rect: Rect.fromLTWH(186, 18, 404, 84),
        fontSize: 40,
      ),
      'topRight': RoadBoardSlotSpec(
        id: 'topRight',
        rect: Rect.fromLTWH(790, 18, 192, 80),
        fontSize: 22,
        useWhiteBox: true,
      ),
      'centerLeft': RoadBoardSlotSpec(
        id: 'centerLeft',
        rect: Rect.fromLTWH(22, 128, 294, 92),
        fontSize: 38,
      ),
      'center': RoadBoardSlotSpec(
        id: 'center',
        rect: Rect.fromLTWH(414, 110, 192, 170),
      ),
      'centerRight': RoadBoardSlotSpec(
        id: 'centerRight',
        rect: Rect.fromLTWH(692, 128, 290, 92),
        fontSize: 38,
      ),
      'bottomLeft': RoadBoardSlotSpec(
        id: 'bottomLeft',
        rect: Rect.fromLTWH(22, 344, 254, 64),
        fontSize: 18,
        useWhiteBox: true,
        useScenicBorder: true,
      ),
      'bottomCenter': RoadBoardSlotSpec(
        id: 'bottomCenter',
        rect: Rect.fromLTWH(432, 354, 194, 66),
        fontSize: 36,
      ),
      'bottomRight': RoadBoardSlotSpec(
        id: 'bottomRight',
        rect: Rect.fromLTWH(790, 344, 192, 64),
        fontSize: 18,
        useWhiteBox: true,
      ),
    },
  );
}

import 'package:flutter/material.dart';

enum SignCategory { prohibition, warning, mandatory, indication, information }

enum SignShape {
  circle,
  triangle,
  invertedTriangle,
  rectangle,
  square,
  octagon,
}

enum SignSymbol {
  none,
  stopText,
  yieldText,
  noEntry,
  noPedestrians,
  noMotorVehicles,
  noParking,
  noHonking,
  speedLimit,
  crossroad,
  tJunction,
  sharpCurveLeft,
  sharpCurveRight,
  slippery,
  pedestrianCrossing,
  children,
  roadWork,
  straightAhead,
  turnLeft,
  turnRight,
  straightOrLeft,
  straightOrRight,
  roundabout,
  keepRight,
  keepLeft,
  walk,
  parking,
  hospital,
  serviceArea,
  touristArea,
  expressway,
}

class TrafficSign {
  const TrafficSign({
    required this.id,
    required this.name,
    required this.code,
    required this.category,
    required this.shape,
    required this.primaryColor,
    required this.secondaryColor,
    this.borderColor,
    this.symbol = SignSymbol.none,
    this.value,
    this.description,
  });

  final String id;
  final String name;
  final String code;
  final SignCategory category;
  final SignShape shape;
  final Color primaryColor;
  final Color secondaryColor;
  final Color? borderColor;
  final SignSymbol symbol;
  final String? value;
  final String? description;

  String get categoryLabel {
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
    }
  }
}

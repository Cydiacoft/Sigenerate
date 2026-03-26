import 'package:flutter/material.dart';

enum RoadType { general, highway, scenic }

enum DestinationType { general, highway, scenic }

enum IntersectionShape {
  crossroad,
  tJunctionFrontLeft,
  tJunctionFrontRight,
  tJunctionLeftRight,
  yJunction,
  roundabout,
  diamondBridge,
  cloverleafBridge,
  spiralBridge,
}

class DirectionInfo {
  String roadName;
  RoadType roadType;
  String destination;
  DestinationType destinationType;
  IntersectionShape shape;

  DirectionInfo({
    this.roadName = '',
    this.roadType = RoadType.general,
    this.destination = '',
    this.destinationType = DestinationType.general,
    this.shape = IntersectionShape.crossroad,
  });

  DirectionInfo copyWith({
    String? roadName,
    RoadType? roadType,
    String? destination,
    DestinationType? destinationType,
    IntersectionShape? shape,
  }) {
    return DirectionInfo(
      roadName: roadName ?? this.roadName,
      roadType: roadType ?? this.roadType,
      destination: destination ?? this.destination,
      destinationType: destinationType ?? this.destinationType,
      shape: shape ?? this.shape,
    );
  }
}

class IntersectionScene {
  String name;
  DirectionInfo north;
  DirectionInfo east;
  DirectionInfo south;
  DirectionInfo west;

  Color backgroundColor;
  Color scenicColor;
  Color foregroundColor;
  Color highwayColor;
  bool useChineseDirection;
  bool useEnglishDirection;

  IntersectionScene({
    this.name = '',
    DirectionInfo? north,
    DirectionInfo? east,
    DirectionInfo? south,
    DirectionInfo? west,
    this.backgroundColor = const Color(0xFF1A1A2E),
    this.scenicColor = const Color(0xFF4A90A4),
    this.foregroundColor = const Color(0xFFFFFFFF),
    this.highwayColor = const Color(0xFFFFD700),
    this.useChineseDirection = true,
    this.useEnglishDirection = false,
  })  : north = north ?? DirectionInfo(),
        east = east ?? DirectionInfo(),
        south = south ?? DirectionInfo(),
        west = west ?? DirectionInfo();

  IntersectionScene copyWith({
    String? name,
    DirectionInfo? north,
    DirectionInfo? east,
    DirectionInfo? south,
    DirectionInfo? west,
    Color? backgroundColor,
    Color? scenicColor,
    Color? foregroundColor,
    Color? highwayColor,
    bool? useChineseDirection,
    bool? useEnglishDirection,
  }) {
    return IntersectionScene(
      name: name ?? this.name,
      north: north ?? this.north.copyWith(),
      east: east ?? this.east.copyWith(),
      south: south ?? this.south.copyWith(),
      west: west ?? this.west.copyWith(),
      backgroundColor: backgroundColor ?? this.backgroundColor,
      scenicColor: scenicColor ?? this.scenicColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      highwayColor: highwayColor ?? this.highwayColor,
    );
  }
}

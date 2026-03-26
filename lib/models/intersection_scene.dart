import 'package:flutter/material.dart';

enum RoadType { general, highway, scenic }

enum DestinationType { general, highway, scenic }

enum IntersectionShape {
  crossroad,
  skewLeft,
  skewRight,
  roundabout,
  tJunctionFrontLeft,
  tJunctionFrontRight,
  tJunctionLeftRight,
  yJunction,
  diamondBridgeTop,
  diamondBridgeBottom,
}

class DirectionInfo {
  DirectionInfo({
    this.roadName = '',
    this.roadType = RoadType.general,
    this.destination = '',
    this.destinationType = DestinationType.general,
    this.signIds = const [],
  });

  final String roadName;
  final RoadType roadType;
  final String destination;
  final DestinationType destinationType;
  final List<String> signIds;

  DirectionInfo copyWith({
    String? roadName,
    RoadType? roadType,
    String? destination,
    DestinationType? destinationType,
    List<String>? signIds,
  }) {
    return DirectionInfo(
      roadName: roadName ?? this.roadName,
      roadType: roadType ?? this.roadType,
      destination: destination ?? this.destination,
      destinationType: destinationType ?? this.destinationType,
      signIds: signIds ?? List<String>.from(this.signIds),
    );
  }
}

class IntersectionScene {
  IntersectionScene({
    this.name = '',
    this.intersectionShape = IntersectionShape.crossroad,
    DirectionInfo? north,
    DirectionInfo? east,
    DirectionInfo? south,
    DirectionInfo? west,
    this.backgroundColor = const Color(0xFF1A5FB4),
    this.scenicColor = const Color(0xFF8C5A2B),
    this.foregroundColor = const Color(0xFFFFFFFF),
    this.highwayColor = const Color(0xFF0E8A4B),
    this.useChineseDirection = true,
    this.useEnglishDirection = false,
  }) : north = north ?? DirectionInfo(),
       east = east ?? DirectionInfo(),
       south = south ?? DirectionInfo(),
       west = west ?? DirectionInfo();

  final String name;
  final IntersectionShape intersectionShape;
  final DirectionInfo north;
  final DirectionInfo east;
  final DirectionInfo south;
  final DirectionInfo west;
  final Color backgroundColor;
  final Color scenicColor;
  final Color foregroundColor;
  final Color highwayColor;
  final bool useChineseDirection;
  final bool useEnglishDirection;

  IntersectionScene copyWith({
    String? name,
    IntersectionShape? intersectionShape,
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
      intersectionShape: intersectionShape ?? this.intersectionShape,
      north: north ?? this.north.copyWith(),
      east: east ?? this.east.copyWith(),
      south: south ?? this.south.copyWith(),
      west: west ?? this.west.copyWith(),
      backgroundColor: backgroundColor ?? this.backgroundColor,
      scenicColor: scenicColor ?? this.scenicColor,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      highwayColor: highwayColor ?? this.highwayColor,
      useChineseDirection: useChineseDirection ?? this.useChineseDirection,
      useEnglishDirection: useEnglishDirection ?? this.useEnglishDirection,
    );
  }

  DirectionInfo directionInfo(String direction) {
    switch (direction) {
      case 'north':
        return north;
      case 'east':
        return east;
      case 'south':
        return south;
      case 'west':
        return west;
      default:
        return north;
    }
  }

  Map<String, DirectionInfo> get directions => {
    'north': north,
    'east': east,
    'south': south,
    'west': west,
  };
}

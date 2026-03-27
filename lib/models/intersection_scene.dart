import 'package:flutter/material.dart';

enum RoadType { general, highway, scenic }

enum DestinationType { general, highway, scenic }

enum DirectionWordMode { chinese, english, custom }

enum IntersectionShape {
  crossroad,
  skewLeft,
  skewRight,
  skewForwardLeft,
  skewForwardRight,
  roundabout,
  tJunctionFrontLeft,
  tJunctionFrontRight,
  tJunctionLeftRight,
  yJunction,
  diamondBridgeHighTop,
  diamondBridgeHighBottom,
  diamondBridgeLowTop,
  diamondBridgeLowBottom,
  cloverleafBridgeDoubleTop,
  cloverleafBridgeDoubleBottom,
  cloverleafBridgeSingleTop,
  cloverleafBridgeSingleBottom,
  spiralBridgeDoubleTop,
  spiralBridgeDoubleBottom,
  spiralBridgeSingleTop,
  spiralBridgeSingleBottom,
  roundaboutBridgeTop,
  roundaboutBridgeBottom,
  leftLongRightShort,
  rightLongLeftShort,
  leftRightLongFrontShort,
}

class DirectionInfo {
  DirectionInfo({
    this.roadName = '',
    this.roadNameEn = '',
    this.roadType = RoadType.general,
    this.destination = '',
    this.destinationEn = '',
    this.destinationType = DestinationType.general,
    this.signIds = const [],
    this.customDirection = '',
  });

  final String roadName;
  final String roadNameEn;
  final RoadType roadType;
  final String destination;
  final String destinationEn;
  final DestinationType destinationType;
  final List<String> signIds;
  final String customDirection;

  DirectionInfo copyWith({
    String? roadName,
    String? roadNameEn,
    RoadType? roadType,
    String? destination,
    String? destinationEn,
    DestinationType? destinationType,
    List<String>? signIds,
    String? customDirection,
  }) {
    return DirectionInfo(
      roadName: roadName ?? this.roadName,
      roadNameEn: roadNameEn ?? this.roadNameEn,
      roadType: roadType ?? this.roadType,
      destination: destination ?? this.destination,
      destinationEn: destinationEn ?? this.destinationEn,
      destinationType: destinationType ?? this.destinationType,
      signIds: signIds ?? List<String>.from(this.signIds),
      customDirection: customDirection ?? this.customDirection,
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
    this.backgroundColor = const Color(0xFF0055AA),
    this.scenicColor = const Color(0xFF8B6914),
    this.foregroundColor = const Color(0xFFFFFFFF),
    this.highwayColor = const Color(0xFF006838),
    this.directionWordMode = DirectionWordMode.chinese,
    this.customDirectionWords = const {'north': 'N', 'east': 'E', 'south': 'S', 'west': 'W'},
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
  final DirectionWordMode directionWordMode;
  final Map<String, String> customDirectionWords;

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
    DirectionWordMode? directionWordMode,
    Map<String, String>? customDirectionWords,
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
      directionWordMode: directionWordMode ?? this.directionWordMode,
      customDirectionWords: customDirectionWords ?? this.customDirectionWords,
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

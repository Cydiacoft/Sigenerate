import 'package:flutter/material.dart';

import '../models/traffic_sign.dart';

class Gb5768Colors {
  static const Color red = Color(0xFFD92323);
  static const Color blue = Color(0xFF1A5FB4);
  static const Color yellow = Color(0xFFFFC72C);
  static const Color green = Color(0xFF0E8A4B);
  static const Color brown = Color(0xFF8C5A2B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
}

class Gb5768Signs {
  static const String code = 'GB 5768.2-2022';
  static const String _assetBase = 'assets/road_signs';

  static List<TrafficSign> get allSigns => [
        ...prohibitionSigns,
        ...warningSigns,
        ...mandatorySigns,
        ...indicationSigns,
        ...informationSigns,
      ];

  static List<TrafficSign> get prohibitionSigns => const [
        TrafficSign(
          id: 'pro-stop',
          name: '停车让行',
          code: code,
          category: SignCategory.prohibition,
          shape: SignShape.octagon,
          primaryColor: Gb5768Colors.red,
          secondaryColor: Gb5768Colors.white,
          assetPath: '$_assetBase/stop.svg',
          symbol: SignSymbol.stopText,
        ),
        TrafficSign(
          id: 'pro-yield',
          name: '减速让行',
          code: code,
          category: SignCategory.prohibition,
          shape: SignShape.invertedTriangle,
          primaryColor: Gb5768Colors.white,
          secondaryColor: Gb5768Colors.red,
          borderColor: Gb5768Colors.red,
          assetPath: '$_assetBase/yield.svg',
          symbol: SignSymbol.yieldText,
        ),
        TrafficSign(
          id: 'pro-no-entry',
          name: '禁止驶入',
          code: code,
          category: SignCategory.prohibition,
          shape: SignShape.circle,
          primaryColor: Gb5768Colors.red,
          secondaryColor: Gb5768Colors.white,
          assetPath: '$_assetBase/no_entry.svg',
          symbol: SignSymbol.noEntry,
        ),
        TrafficSign(
          id: 'pro-no-left-turn',
          name: '禁止向左转弯',
          code: code,
          category: SignCategory.prohibition,
          shape: SignShape.circle,
          primaryColor: Gb5768Colors.white,
          secondaryColor: Gb5768Colors.black,
          borderColor: Gb5768Colors.red,
          assetPath: '$_assetBase/no_left_turn.svg',
        ),
        TrafficSign(
          id: 'pro-no-uturn',
          name: '禁止掉头',
          code: code,
          category: SignCategory.prohibition,
          shape: SignShape.circle,
          primaryColor: Gb5768Colors.white,
          secondaryColor: Gb5768Colors.black,
          borderColor: Gb5768Colors.red,
          assetPath: '$_assetBase/no_uturn.svg',
        ),
        TrafficSign(
          id: 'pro-no-parking',
          name: '禁止长时停车',
          code: code,
          category: SignCategory.prohibition,
          shape: SignShape.circle,
          primaryColor: Gb5768Colors.white,
          secondaryColor: Gb5768Colors.blue,
          borderColor: Gb5768Colors.red,
          assetPath: '$_assetBase/no_parking.svg',
          symbol: SignSymbol.noParking,
        ),
        TrafficSign(
          id: 'pro-no-honking',
          name: '禁止鸣喇叭',
          code: code,
          category: SignCategory.prohibition,
          shape: SignShape.circle,
          primaryColor: Gb5768Colors.white,
          secondaryColor: Gb5768Colors.black,
          borderColor: Gb5768Colors.red,
          assetPath: '$_assetBase/no_honking.svg',
          symbol: SignSymbol.noHonking,
        ),
      ];

  static List<TrafficSign> get warningSigns => const [
        TrafficSign(
          id: 'warn-crossroad',
          name: '十字交叉',
          code: code,
          category: SignCategory.warning,
          shape: SignShape.triangle,
          primaryColor: Gb5768Colors.yellow,
          secondaryColor: Gb5768Colors.black,
          borderColor: Gb5768Colors.black,
          assetPath: '$_assetBase/crossroad_warning.svg',
          symbol: SignSymbol.crossroad,
        ),
        TrafficSign(
          id: 'warn-pedestrian',
          name: '注意行人',
          code: code,
          category: SignCategory.warning,
          shape: SignShape.triangle,
          primaryColor: Gb5768Colors.yellow,
          secondaryColor: Gb5768Colors.black,
          borderColor: Gb5768Colors.black,
          assetPath: '$_assetBase/pedestrian_warning.svg',
          symbol: SignSymbol.pedestrianCrossing,
        ),
        TrafficSign(
          id: 'warn-children',
          name: '注意儿童',
          code: code,
          category: SignCategory.warning,
          shape: SignShape.triangle,
          primaryColor: Gb5768Colors.yellow,
          secondaryColor: Gb5768Colors.black,
          borderColor: Gb5768Colors.black,
          assetPath: '$_assetBase/children_warning.svg',
          symbol: SignSymbol.children,
        ),
        TrafficSign(
          id: 'warn-work',
          name: '施工',
          code: code,
          category: SignCategory.warning,
          shape: SignShape.triangle,
          primaryColor: Gb5768Colors.yellow,
          secondaryColor: Gb5768Colors.black,
          borderColor: Gb5768Colors.black,
          assetPath: '$_assetBase/road_work.svg',
          symbol: SignSymbol.roadWork,
        ),
      ];

  static List<TrafficSign> get mandatorySigns => const [
        TrafficSign(
          id: 'man-straight',
          name: '直行',
          code: code,
          category: SignCategory.mandatory,
          shape: SignShape.circle,
          primaryColor: Gb5768Colors.blue,
          secondaryColor: Gb5768Colors.white,
          assetPath: '$_assetBase/straight.svg',
          symbol: SignSymbol.straightAhead,
        ),
        TrafficSign(
          id: 'man-left',
          name: '向左转弯',
          code: code,
          category: SignCategory.mandatory,
          shape: SignShape.circle,
          primaryColor: Gb5768Colors.blue,
          secondaryColor: Gb5768Colors.white,
          assetPath: '$_assetBase/turn_left.svg',
          symbol: SignSymbol.turnLeft,
        ),
        TrafficSign(
          id: 'man-right',
          name: '向右转弯',
          code: code,
          category: SignCategory.mandatory,
          shape: SignShape.circle,
          primaryColor: Gb5768Colors.blue,
          secondaryColor: Gb5768Colors.white,
          assetPath: '$_assetBase/turn_right.svg',
          symbol: SignSymbol.turnRight,
        ),
      ];

  static List<TrafficSign> get indicationSigns => const [
        TrafficSign(
          id: 'ind-parking',
          name: '停车场',
          code: code,
          category: SignCategory.indication,
          shape: SignShape.square,
          primaryColor: Gb5768Colors.blue,
          secondaryColor: Gb5768Colors.white,
          assetPath: '$_assetBase/parking.svg',
          symbol: SignSymbol.parking,
        ),
        TrafficSign(
          id: 'ind-hospital',
          name: '医院',
          code: code,
          category: SignCategory.indication,
          shape: SignShape.square,
          primaryColor: Gb5768Colors.blue,
          secondaryColor: Gb5768Colors.white,
          assetPath: '$_assetBase/hospital.svg',
          symbol: SignSymbol.hospital,
        ),
      ];

  static List<TrafficSign> get informationSigns => const [
        TrafficSign(
          id: 'info-expressway',
          name: '高速公路',
          code: code,
          category: SignCategory.information,
          shape: SignShape.rectangle,
          primaryColor: Gb5768Colors.green,
          secondaryColor: Gb5768Colors.white,
          assetPath: '$_assetBase/expressway.svg',
          symbol: SignSymbol.expressway,
        ),
        TrafficSign(
          id: 'info-tourist',
          name: '旅游区',
          code: code,
          category: SignCategory.information,
          shape: SignShape.rectangle,
          primaryColor: Gb5768Colors.brown,
          secondaryColor: Gb5768Colors.white,
          assetPath: '$_assetBase/tourist.svg',
          symbol: SignSymbol.touristArea,
        ),
      ];

  static Map<SignCategory, List<TrafficSign>> get groupedByCategory => {
        SignCategory.prohibition: prohibitionSigns,
        SignCategory.warning: warningSigns,
        SignCategory.mandatory: mandatorySigns,
        SignCategory.indication: indicationSigns,
        SignCategory.information: informationSigns,
      };

  static TrafficSign? findById(String id) {
    for (final sign in allSigns) {
      if (sign.id == id) {
        return sign;
      }
    }
    return null;
  }
}

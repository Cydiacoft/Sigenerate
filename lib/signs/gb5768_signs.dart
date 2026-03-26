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
      symbol: SignSymbol.noEntry,
    ),
    TrafficSign(
      id: 'pro-no-motor',
      name: '禁止机动车通行',
      code: code,
      category: SignCategory.prohibition,
      shape: SignShape.circle,
      primaryColor: Gb5768Colors.white,
      secondaryColor: Gb5768Colors.black,
      borderColor: Gb5768Colors.red,
      symbol: SignSymbol.noMotorVehicles,
    ),
    TrafficSign(
      id: 'pro-no-pedestrian',
      name: '禁止行人通行',
      code: code,
      category: SignCategory.prohibition,
      shape: SignShape.circle,
      primaryColor: Gb5768Colors.white,
      secondaryColor: Gb5768Colors.black,
      borderColor: Gb5768Colors.red,
      symbol: SignSymbol.noPedestrians,
    ),
    TrafficSign(
      id: 'pro-no-parking',
      name: '禁止停车',
      code: code,
      category: SignCategory.prohibition,
      shape: SignShape.circle,
      primaryColor: Gb5768Colors.white,
      secondaryColor: Gb5768Colors.blue,
      borderColor: Gb5768Colors.red,
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
      symbol: SignSymbol.noHonking,
    ),
    TrafficSign(
      id: 'pro-speed-60',
      name: '限制速度 60',
      code: code,
      category: SignCategory.prohibition,
      shape: SignShape.circle,
      primaryColor: Gb5768Colors.white,
      secondaryColor: Gb5768Colors.black,
      borderColor: Gb5768Colors.red,
      symbol: SignSymbol.speedLimit,
      value: '60',
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
      symbol: SignSymbol.crossroad,
    ),
    TrafficSign(
      id: 'warn-t-junction',
      name: 'T 形交叉',
      code: code,
      category: SignCategory.warning,
      shape: SignShape.triangle,
      primaryColor: Gb5768Colors.yellow,
      secondaryColor: Gb5768Colors.black,
      borderColor: Gb5768Colors.black,
      symbol: SignSymbol.tJunction,
    ),
    TrafficSign(
      id: 'warn-left-curve',
      name: '向左急弯路',
      code: code,
      category: SignCategory.warning,
      shape: SignShape.triangle,
      primaryColor: Gb5768Colors.yellow,
      secondaryColor: Gb5768Colors.black,
      borderColor: Gb5768Colors.black,
      symbol: SignSymbol.sharpCurveLeft,
    ),
    TrafficSign(
      id: 'warn-right-curve',
      name: '向右急弯路',
      code: code,
      category: SignCategory.warning,
      shape: SignShape.triangle,
      primaryColor: Gb5768Colors.yellow,
      secondaryColor: Gb5768Colors.black,
      borderColor: Gb5768Colors.black,
      symbol: SignSymbol.sharpCurveRight,
    ),
    TrafficSign(
      id: 'warn-slippery',
      name: '路面湿滑',
      code: code,
      category: SignCategory.warning,
      shape: SignShape.triangle,
      primaryColor: Gb5768Colors.yellow,
      secondaryColor: Gb5768Colors.black,
      borderColor: Gb5768Colors.black,
      symbol: SignSymbol.slippery,
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
      symbol: SignSymbol.turnRight,
    ),
    TrafficSign(
      id: 'man-straight-left',
      name: '直行和向左转弯',
      code: code,
      category: SignCategory.mandatory,
      shape: SignShape.circle,
      primaryColor: Gb5768Colors.blue,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.straightOrLeft,
    ),
    TrafficSign(
      id: 'man-straight-right',
      name: '直行和向右转弯',
      code: code,
      category: SignCategory.mandatory,
      shape: SignShape.circle,
      primaryColor: Gb5768Colors.blue,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.straightOrRight,
    ),
    TrafficSign(
      id: 'man-roundabout',
      name: '环岛行驶',
      code: code,
      category: SignCategory.mandatory,
      shape: SignShape.circle,
      primaryColor: Gb5768Colors.blue,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.roundabout,
    ),
    TrafficSign(
      id: 'man-keep-right',
      name: '靠右侧道路行驶',
      code: code,
      category: SignCategory.mandatory,
      shape: SignShape.circle,
      primaryColor: Gb5768Colors.blue,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.keepRight,
    ),
    TrafficSign(
      id: 'man-keep-left',
      name: '靠左侧道路行驶',
      code: code,
      category: SignCategory.mandatory,
      shape: SignShape.circle,
      primaryColor: Gb5768Colors.blue,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.keepLeft,
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
      symbol: SignSymbol.parking,
    ),
    TrafficSign(
      id: 'ind-walk',
      name: '步行',
      code: code,
      category: SignCategory.indication,
      shape: SignShape.square,
      primaryColor: Gb5768Colors.blue,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.walk,
    ),
    TrafficSign(
      id: 'ind-hospital',
      name: '医院',
      code: code,
      category: SignCategory.indication,
      shape: SignShape.square,
      primaryColor: Gb5768Colors.blue,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.hospital,
    ),
    TrafficSign(
      id: 'ind-service',
      name: '服务区',
      code: code,
      category: SignCategory.indication,
      shape: SignShape.square,
      primaryColor: Gb5768Colors.green,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.serviceArea,
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
      symbol: SignSymbol.touristArea,
    ),
    TrafficSign(
      id: 'info-hospital',
      name: '医院指路',
      code: code,
      category: SignCategory.information,
      shape: SignShape.rectangle,
      primaryColor: Gb5768Colors.blue,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.hospital,
    ),
    TrafficSign(
      id: 'info-parking',
      name: '停车引导',
      code: code,
      category: SignCategory.information,
      shape: SignShape.rectangle,
      primaryColor: Gb5768Colors.blue,
      secondaryColor: Gb5768Colors.white,
      symbol: SignSymbol.parking,
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

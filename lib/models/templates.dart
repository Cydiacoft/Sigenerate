import 'package:flutter/material.dart';

enum EditMode { free, template }

class TemplateLayout {
  final String name;
  final Size canvasSize;
  final Color defaultBgColor;
  final List<TemplateSlot> slots;

  const TemplateLayout({
    required this.name,
    required this.canvasSize,
    required this.defaultBgColor,
    required this.slots,
  });
}

class TemplateSlot {
  final String id;
  final String label;
  final String type;
  final Offset position;
  final Size size;
  final double fontSize;
  final FontWeight fontWeight;
  final Alignment alignment;
  final Color? textColor;
  final String? prefix;
  final String? suffix;
  final bool editable;

  const TemplateSlot({
    required this.id,
    required this.label,
    required this.type,
    required this.position,
    required this.size,
    this.fontSize = 20,
    this.fontWeight = FontWeight.normal,
    this.alignment = Alignment.center,
    this.textColor,
    this.prefix,
    this.suffix,
    this.editable = true,
  });
}

class TemplatePresets {
  static const TemplateLayout crossroad4Way = TemplateLayout(
    name: '十字路口指路牌',
    canvasSize: Size(600, 200),
    defaultBgColor: Color(0xFF059669),
    slots: [
      TemplateSlot(
        id: 'title',
        label: '路口名称',
        type: 'text',
        position: Offset(10, 10),
        size: Size(200, 30),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      TemplateSlot(
        id: 'north_arrow',
        label: '北向箭头',
        type: 'arrow_up',
        position: Offset(30, 60),
        size: Size(30, 30),
        fontSize: 24,
        editable: false,
      ),
      TemplateSlot(
        id: 'north_road',
        label: '北向道路',
        type: 'text',
        position: Offset(70, 60),
        size: Size(200, 30),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      TemplateSlot(
        id: 'north_dest',
        label: '北向目的地',
        type: 'text',
        position: Offset(70, 95),
        size: Size(200, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
      TemplateSlot(
        id: 'south_arrow',
        label: '南向箭头',
        type: 'arrow_down',
        position: Offset(30, 140),
        size: Size(30, 30),
        fontSize: 24,
        editable: false,
      ),
      TemplateSlot(
        id: 'south_road',
        label: '南向道路',
        type: 'text',
        position: Offset(70, 140),
        size: Size(200, 30),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      TemplateSlot(
        id: 'south_dest',
        label: '南向目的地',
        type: 'text',
        position: Offset(70, 175),
        size: Size(200, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
      TemplateSlot(
        id: 'east_arrow',
        label: '东向箭头',
        type: 'arrow_right',
        position: Offset(350, 60),
        size: Size(30, 30),
        fontSize: 24,
        editable: false,
      ),
      TemplateSlot(
        id: 'east_road',
        label: '东向道路',
        type: 'text',
        position: Offset(390, 60),
        size: Size(200, 30),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      TemplateSlot(
        id: 'east_dest',
        label: '东向目的地',
        type: 'text',
        position: Offset(390, 95),
        size: Size(200, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
      TemplateSlot(
        id: 'west_arrow',
        label: '西向箭头',
        type: 'arrow_left',
        position: Offset(350, 140),
        size: Size(30, 30),
        fontSize: 24,
        editable: false,
      ),
      TemplateSlot(
        id: 'west_road',
        label: '西向道路',
        type: 'text',
        position: Offset(390, 140),
        size: Size(200, 30),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      TemplateSlot(
        id: 'west_dest',
        label: '西向目的地',
        type: 'text',
        position: Offset(390, 175),
        size: Size(200, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
    ],
  );

  static const TemplateLayout tJunction3Way = TemplateLayout(
    name: 'T形路口指路牌',
    canvasSize: Size(500, 300),
    defaultBgColor: Color(0xFF1D4ED8),
    slots: [
      TemplateSlot(
        id: 'title',
        label: '路口名称',
        type: 'text',
        position: Offset(10, 10),
        size: Size(200, 30),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      TemplateSlot(
        id: 'north_arrow',
        label: '北向箭头',
        type: 'arrow_up',
        position: Offset(30, 60),
        size: Size(30, 30),
        fontSize: 24,
        editable: false,
      ),
      TemplateSlot(
        id: 'north_road',
        label: '北向道路',
        type: 'text',
        position: Offset(70, 60),
        size: Size(180, 30),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      TemplateSlot(
        id: 'north_dest',
        label: '北向目的地',
        type: 'text',
        position: Offset(70, 95),
        size: Size(180, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
      TemplateSlot(
        id: 'east_arrow',
        label: '东向箭头',
        type: 'arrow_right',
        position: Offset(280, 60),
        size: Size(30, 30),
        fontSize: 24,
        editable: false,
      ),
      TemplateSlot(
        id: 'east_road',
        label: '东向道路',
        type: 'text',
        position: Offset(320, 60),
        size: Size(170, 30),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      TemplateSlot(
        id: 'east_dest',
        label: '东向目的地',
        type: 'text',
        position: Offset(320, 95),
        size: Size(170, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
      TemplateSlot(
        id: 'west_arrow',
        label: '西向箭头',
        type: 'arrow_left',
        position: Offset(280, 130),
        size: Size(30, 30),
        fontSize: 24,
        editable: false,
      ),
      TemplateSlot(
        id: 'west_road',
        label: '西向道路',
        type: 'text',
        position: Offset(320, 130),
        size: Size(170, 30),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      TemplateSlot(
        id: 'west_dest',
        label: '西向目的地',
        type: 'text',
        position: Offset(320, 165),
        size: Size(170, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
    ],
  );

  static const TemplateLayout directionSign = TemplateLayout(
    name: '方向指示牌',
    canvasSize: Size(200, 400),
    defaultBgColor: Color(0xFF0284C7),
    slots: [
      TemplateSlot(
        id: 'main_road',
        label: '主路名称',
        type: 'text',
        position: Offset(10, 10),
        size: Size(180, 40),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      TemplateSlot(
        id: 'arrow',
        label: '方向箭头',
        type: 'arrow_up',
        position: Offset(85, 80),
        size: Size(30, 40),
        fontSize: 32,
        editable: false,
      ),
      TemplateSlot(
        id: 'dest1',
        label: '地点1',
        type: 'text',
        position: Offset(10, 140),
        size: Size(180, 35),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      TemplateSlot(
        id: 'dist1',
        label: '距离1',
        type: 'text',
        position: Offset(10, 180),
        size: Size(180, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
      TemplateSlot(
        id: 'dest2',
        label: '地点2',
        type: 'text',
        position: Offset(10, 220),
        size: Size(180, 35),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      TemplateSlot(
        id: 'dist2',
        label: '距离2',
        type: 'text',
        position: Offset(10, 260),
        size: Size(180, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
      TemplateSlot(
        id: 'dest3',
        label: '地点3',
        type: 'text',
        position: Offset(10, 300),
        size: Size(180, 35),
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      TemplateSlot(
        id: 'dist3',
        label: '距离3',
        type: 'text',
        position: Offset(10, 340),
        size: Size(180, 25),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
    ],
  );

  static const TemplateLayout entranceSign = TemplateLayout(
    name: '入口预告标志',
    canvasSize: Size(500, 200),
    defaultBgColor: Color(0xFF059669),
    slots: [
      TemplateSlot(
        id: 'entrance_type',
        label: '入口类型',
        type: 'text',
        position: Offset(10, 10),
        size: Size(100, 30),
        fontSize: 14,
        textColor: Color(0xFFE0E0E0),
      ),
      TemplateSlot(
        id: 'highway_name',
        label: '高速名称',
        type: 'text',
        position: Offset(10, 50),
        size: Size(480, 50),
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      TemplateSlot(
        id: 'exits',
        label: '出口信息',
        type: 'text',
        position: Offset(10, 120),
        size: Size(480, 30),
        fontSize: 16,
        textColor: Color(0xFFE0E0E0),
      ),
      TemplateSlot(
        id: 'dists',
        label: '距离',
        type: 'text',
        position: Offset(10, 160),
        size: Size(480, 30),
        fontSize: 16,
        textColor: Color(0xFFE0E0E0),
      ),
    ],
  );

  static List<TemplateLayout> get all => [
    crossroad4Way,
    tJunction3Way,
    directionSign,
    entranceSign,
  ];
}

class DirectionPreset {
  final String name;
  final String arrow;
  final Offset position;
  final bool flipHorizontal;
  final bool flipVertical;

  const DirectionPreset({
    required this.name,
    required this.arrow,
    required this.position,
    this.flipHorizontal = false,
    this.flipVertical = false,
  });
}

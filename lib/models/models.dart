import 'package:flutter/material.dart';

enum MetroCity { shanghai, guangzhou, mtr }

class MetroCityInfo {
  final MetroCity city;
  final String name;
  final Color bgColor;
  final Color textColor;
  final double lineBadgeSize;
  final double lineBadgeFontSize;
  final String fontFamily;

  const MetroCityInfo({
    required this.city,
    required this.name,
    required this.bgColor,
    required this.textColor,
    required this.lineBadgeSize,
    required this.lineBadgeFontSize,
    required this.fontFamily,
  });

  static const shanghai = MetroCityInfo(
    city: MetroCity.shanghai,
    name: '上海地铁',
    bgColor: Color(0xFF383838),
    textColor: Colors.white,
    lineBadgeSize: 60,
    lineBadgeFontSize: 22,
    fontFamily: 'Microsoft YaHei',
  );

  static const guangzhou = MetroCityInfo(
    city: MetroCity.guangzhou,
    name: '广州地铁',
    bgColor: Color(0xFF383838),
    textColor: Colors.white,
    lineBadgeSize: 55,
    lineBadgeFontSize: 20,
    fontFamily: 'Microsoft YaHei',
  );

  static const mtr = MetroCityInfo(
    city: MetroCity.mtr,
    name: '港铁 MTR',
    bgColor: Color(0xFF383838),
    textColor: Colors.white,
    lineBadgeSize: 58,
    lineBadgeFontSize: 18,
    fontFamily: 'Arial',
  );

  static const List<MetroCityInfo> all = [shanghai, guangzhou, mtr];
}

class MetroLineInfo {
  final int num;
  final String name;
  final String nameEn;
  final Color color;
  final MetroCity city;

  const MetroLineInfo({
    required this.num,
    required this.name,
    required this.nameEn,
    required this.color,
    required this.city,
  });

  static const List<MetroLineInfo> shanghaiLines = [
    MetroLineInfo(num: 1, name: '1号线', nameEn: 'Line 1', color: Color(0xFFE4002B), city: MetroCity.shanghai),
    MetroLineInfo(num: 2, name: '2号线', nameEn: 'Line 2', color: Color(0xFFA09A39), city: MetroCity.shanghai),
    MetroLineInfo(num: 3, name: '3号线', nameEn: 'Line 3', color: Color(0xFFFAC000), city: MetroCity.shanghai),
    MetroLineInfo(num: 4, name: '4号线', nameEn: 'Line 4', color: Color(0xFF008C44), city: MetroCity.shanghai),
    MetroLineInfo(num: 5, name: '5号线', nameEn: 'Line 5', color: Color(0xFF823130), city: MetroCity.shanghai),
    MetroLineInfo(num: 6, name: '6号线', nameEn: 'Line 6', color: Color(0xFFAA7F3E), city: MetroCity.shanghai),
    MetroLineInfo(num: 7, name: '7号线', nameEn: 'Line 7', color: Color(0xFFE60085), city: MetroCity.shanghai),
    MetroLineInfo(num: 8, name: '8号线', nameEn: 'Line 8', color: Color(0xFF00A1DE), city: MetroCity.shanghai),
    MetroLineInfo(num: 9, name: '9号线', nameEn: 'Line 9', color: Color(0xFF8FC2E3), city: MetroCity.shanghai),
    MetroLineInfo(num: 10, name: '10号线', nameEn: 'Line 10', color: Color(0xFF98C5A3), city: MetroCity.shanghai),
    MetroLineInfo(num: 11, name: '11号线', nameEn: 'Line 11', color: Color(0xFFDA81A6), city: MetroCity.shanghai),
    MetroLineInfo(num: 12, name: '12号线', nameEn: 'Line 12', color: Color(0xFF5F6D3F), city: MetroCity.shanghai),
    MetroLineInfo(num: 14, name: '14号线', nameEn: 'Line 14', color: Color(0xFF4D3700), city: MetroCity.shanghai),
    MetroLineInfo(num: 16, name: '16号线', nameEn: 'Line 16', color: Color(0xFF7D8B2F), city: MetroCity.shanghai),
    MetroLineInfo(num: 17, name: '17号线', nameEn: 'Line 17', color: Color(0xFF6D4C7D), city: MetroCity.shanghai),
    MetroLineInfo(num: 18, name: '18号线', nameEn: 'Line 18', color: Color(0xFFB75700), city: MetroCity.shanghai),
  ];

  static const List<MetroLineInfo> guangzhouLines = [
    MetroLineInfo(num: 1, name: '1号线', nameEn: 'Line 1', color: Color(0xFFFFD200), city: MetroCity.guangzhou),
    MetroLineInfo(num: 2, name: '2号线', nameEn: 'Line 2', color: Color(0xFF004F97), city: MetroCity.guangzhou),
    MetroLineInfo(num: 3, name: '3号线', nameEn: 'Line 3', color: Color(0xFF963B6D), city: MetroCity.guangzhou),
    MetroLineInfo(num: 4, name: '4号线', nameEn: 'Line 4', color: Color(0xFF009944), city: MetroCity.guangzhou),
    MetroLineInfo(num: 5, name: '5号线', nameEn: 'Line 5', color: Color(0xFFAD5A00), city: MetroCity.guangzhou),
    MetroLineInfo(num: 6, name: '6号线', nameEn: 'Line 6', color: Color(0xFF944B84), city: MetroCity.guangzhou),
    MetroLineInfo(num: 7, name: '7号线', nameEn: 'Line 7', color: Color(0xFFB85C00), city: MetroCity.guangzhou),
    MetroLineInfo(num: 8, name: '8号线', nameEn: 'Line 8', color: Color(0xFF00A1DE), city: MetroCity.guangzhou),
    MetroLineInfo(num: 14, name: '14号线', nameEn: 'Line 14', color: Color(0xFFCC6699), city: MetroCity.guangzhou),
    MetroLineInfo(num: 21, name: '21号线', nameEn: 'Line 21', color: Color(0xFF4DB749), city: MetroCity.guangzhou),
  ];

  static const List<MetroLineInfo> mtrLines = [
    MetroLineInfo(num: 1, name: '东铁线', nameEn: 'East Rail Line', color: Color(0xFF76B7B5), city: MetroCity.mtr),
    MetroLineInfo(num: 2, name: '荃湾线', nameEn: 'Tsuen Wan Line', color: Color(0xFFFF2D2D), city: MetroCity.mtr),
    MetroLineInfo(num: 3, name: '观塘线', nameEn: 'Kwun Tong Line', color: Color(0xFF7ACB00), city: MetroCity.mtr),
    MetroLineInfo(num: 4, name: '港岛线', nameEn: 'Island Line', color: Color(0xFF0072CE), city: MetroCity.mtr),
    MetroLineInfo(num: 5, name: '东涌线', nameEn: 'Tung Chung Line', color: Color(0xFFFFA02F), city: MetroCity.mtr),
    MetroLineInfo(num: 6, name: '迪士尼线', nameEn: 'Disneyland Resort Line', color: Color(0xFFBC8F8F), city: MetroCity.mtr),
    MetroLineInfo(num: 7, name: '南港岛线', nameEn: 'South Island Line', color: Color(0xFFD5C62B), city: MetroCity.mtr),
    MetroLineInfo(num: 10, name: '屯马线', nameEn: 'Tuen Ma Line', color: Color(0xFFAB5700), city: MetroCity.mtr),
  ];

  static List<MetroLineInfo> getLines(MetroCity city) {
    switch (city) {
      case MetroCity.shanghai: return shanghaiLines;
      case MetroCity.guangzhou: return guangzhouLines;
      case MetroCity.mtr: return mtrLines;
    }
  }
}

class MetroTemplate {
  final String id;
  final String name;
  final MetroCity city;
  final Size canvasSize;
  final List<MetroSlot> slots;

  const MetroTemplate({
    required this.id,
    required this.name,
    required this.city,
    required this.canvasSize,
    required this.slots,
  });

  static List<MetroTemplate> getTemplates(MetroCity city) {
    switch (city) {
      case MetroCity.shanghai:
        return _shanghaiTemplates;
      case MetroCity.guangzhou:
        return _guangzhouTemplates;
      case MetroCity.mtr:
        return _mtrTemplates;
    }
  }

  static const List<MetroTemplate> _shanghaiTemplates = [
    MetroTemplate(
      id: 'station',
      name: '站名牌',
      city: MetroCity.shanghai,
      canvasSize: Size(360, 90),
      slots: [
        MetroSlot(id: 'line_badge', type: 'line', x: 15, y: 15, w: 60, h: 60),
        MetroSlot(id: 'name_cn', type: 'text', x: 90, y: 22, w: 250, h: 28, fontSize: 24),
        MetroSlot(id: 'name_en', type: 'text', x: 90, y: 52, w: 250, h: 22, fontSize: 12, color: Color(0xFF999999)),
      ],
    ),
    MetroTemplate(
      id: 'direction',
      name: '方向指示牌',
      city: MetroCity.shanghai,
      canvasSize: Size(480, 120),
      slots: [
        MetroSlot(id: 'arrow', type: 'arrow_right', x: 12, y: 35, w: 36, h: 50),
        MetroSlot(id: 'dest_cn', type: 'text', x: 58, y: 25, w: 200, h: 40, fontSize: 24),
        MetroSlot(id: 'dest_en', type: 'text', x: 58, y: 65, w: 200, h: 20, fontSize: 11, color: Color(0xFF999999)),
        MetroSlot(id: 'next_cn', type: 'text', x: 290, y: 25, w: 175, h: 35, fontSize: 16),
        MetroSlot(id: 'next_en', type: 'text', x: 290, y: 60, w: 175, h: 18, fontSize: 10, color: Color(0xFF999999)),
        MetroSlot(id: 'dist', type: 'text', x: 290, y: 85, w: 175, h: 18, fontSize: 10, color: Color(0xFF777777)),
      ],
    ),
    MetroTemplate(
      id: 'exit',
      name: '出口信息牌',
      city: MetroCity.shanghai,
      canvasSize: Size(260, 160),
      slots: [
        MetroSlot(id: 'exit_badge', type: 'exit_badge', x: 80, y: 12, w: 100, h: 32),
        MetroSlot(id: 'info_cn', type: 'text', x: 15, y: 55, w: 230, h: 80, fontSize: 14),
        MetroSlot(id: 'info_en', type: 'text', x: 15, y: 120, w: 230, h: 30, fontSize: 10, color: Color(0xFF999999)),
      ],
    ),
    MetroTemplate(
      id: 'transfer',
      name: '换乘指引牌',
      city: MetroCity.shanghai,
      canvasSize: Size(380, 140),
      slots: [
        MetroSlot(id: 'transfer_label', type: 'text', x: 145, y: 8, w: 90, h: 22, fontSize: 12, color: Color(0xFF999999)),
        MetroSlot(id: 'line1', type: 'line', x: 20, y: 40, w: 55, h: 55),
        MetroSlot(id: 'line1_name', type: 'text', x: 85, y: 55, w: 110, h: 25, fontSize: 14),
        MetroSlot(id: 'arrow1', type: 'arrow_right', x: 195, y: 50, w: 25, h: 35),
        MetroSlot(id: 'line2', type: 'line', x: 230, y: 40, w: 55, h: 55),
        MetroSlot(id: 'line2_name', type: 'text', x: 295, y: 55, w: 70, h: 25, fontSize: 14),
        MetroSlot(id: 'transfer_info', type: 'text', x: 20, y: 110, w: 340, h: 22, fontSize: 11, color: Color(0xFF999999)),
      ],
    ),
  ];

  static const List<MetroTemplate> _guangzhouTemplates = [
    MetroTemplate(
      id: 'station',
      name: '站名牌',
      city: MetroCity.guangzhou,
      canvasSize: Size(340, 85),
      slots: [
        MetroSlot(id: 'line_badge', type: 'line', x: 12, y: 12, w: 55, h: 55),
        MetroSlot(id: 'name_cn', type: 'text', x: 78, y: 20, w: 240, h: 26, fontSize: 22),
        MetroSlot(id: 'name_en', type: 'text', x: 78, y: 48, w: 240, h: 20, fontSize: 11, color: Color(0xFF999999)),
      ],
    ),
  ];

  static const List<MetroTemplate> _mtrTemplates = [
    MetroTemplate(
      id: 'station',
      name: '站名牌',
      city: MetroCity.mtr,
      canvasSize: Size(380, 95),
      slots: [
        MetroSlot(id: 'line_badge', type: 'line', x: 12, y: 15, w: 62, h: 62),
        MetroSlot(id: 'name_cn', type: 'text', x: 88, y: 22, w: 270, h: 28, fontSize: 22),
        MetroSlot(id: 'name_en', type: 'text', x: 88, y: 52, w: 270, h: 24, fontSize: 14, color: Color(0xFFB0B0B0)),
      ],
    ),
  ];
}

class MetroSlot {
  final String id;
  final String type;
  final double x;
  final double y;
  final double w;
  final double h;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const MetroSlot({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color,
  });

  Offset get position => Offset(x, y);
  Size get size => Size(w, h);
}

enum RoadSignType {
  highwayNational,
  highwayProvincial,
  nationalRoad,
  provincialRoad,
  countyRoad,
  townshipRoad,
  direction,
  exitPreview,
}

class RoadSignConfig {
  final RoadSignType type;
  final String name;
  final String description;
  final Color bgColor;
  final Color textColor;
  final Size canvasSize;
  final List<RoadSignSlot> slots;

  const RoadSignConfig({
    required this.type,
    required this.name,
    required this.description,
    required this.bgColor,
    required this.textColor,
    required this.canvasSize,
    required this.slots,
  });

  static const List<RoadSignConfig> signs = [
    RoadSignConfig(
      type: RoadSignType.highwayNational,
      name: '国家高速公路',
      description: '绿底白字，G开头编号',
      bgColor: Color(0xFF008B3D),
      textColor: Colors.white,
      canvasSize: Size(400, 150),
      slots: [
        RoadSignSlot(id: 'prefix', type: 'text', x: 15, y: 35, w: 50, h: 80, fontSize: 32, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'number', type: 'text', x: 60, y: 35, w: 120, h: 80, fontSize: 56, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'name', type: 'text', x: 200, y: 45, w: 185, h: 60, fontSize: 28, fontWeight: FontWeight.w500),
      ],
    ),
    RoadSignConfig(
      type: RoadSignType.highwayProvincial,
      name: '省级高速公路',
      description: '绿底白字，S开头编号',
      bgColor: Color(0xFF008B3D),
      textColor: Colors.white,
      canvasSize: Size(400, 150),
      slots: [
        RoadSignSlot(id: 'prefix', type: 'text', x: 15, y: 35, w: 50, h: 80, fontSize: 32, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'number', type: 'text', x: 60, y: 35, w: 120, h: 80, fontSize: 56, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'name', type: 'text', x: 200, y: 45, w: 185, h: 60, fontSize: 28, fontWeight: FontWeight.w500),
      ],
    ),
    RoadSignConfig(
      type: RoadSignType.nationalRoad,
      name: '国道',
      description: '红底白字，G开头三位编号',
      bgColor: Color(0xFFE60000),
      textColor: Colors.white,
      canvasSize: Size(350, 150),
      slots: [
        RoadSignSlot(id: 'number', type: 'text', x: 15, y: 35, w: 100, h: 80, fontSize: 56, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'name', type: 'text', x: 130, y: 45, w: 205, h: 60, fontSize: 28, fontWeight: FontWeight.w500),
      ],
    ),
    RoadSignConfig(
      type: RoadSignType.provincialRoad,
      name: '省道',
      description: '黄底黑字，S开头三位编号',
      bgColor: Color(0xFFFFD100),
      textColor: Color(0xFF1F1F1F),
      canvasSize: Size(350, 150),
      slots: [
        RoadSignSlot(id: 'number', type: 'text', x: 15, y: 35, w: 100, h: 80, fontSize: 56, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'name', type: 'text', x: 130, y: 45, w: 205, h: 60, fontSize: 28, fontWeight: FontWeight.w500),
      ],
    ),
    RoadSignConfig(
      type: RoadSignType.countyRoad,
      name: '县道',
      description: '白底黑字，X开头三位编号',
      bgColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF1F1F1F),
      canvasSize: Size(350, 150),
      slots: [
        RoadSignSlot(id: 'number', type: 'text', x: 15, y: 35, w: 100, h: 80, fontSize: 56, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'name', type: 'text', x: 130, y: 45, w: 205, h: 60, fontSize: 28, fontWeight: FontWeight.w500),
      ],
    ),
    RoadSignConfig(
      type: RoadSignType.townshipRoad,
      name: '乡道',
      description: '白底黑字，Y开头三位编号',
      bgColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF1F1F1F),
      canvasSize: Size(350, 150),
      slots: [
        RoadSignSlot(id: 'number', type: 'text', x: 15, y: 35, w: 100, h: 80, fontSize: 56, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'name', type: 'text', x: 130, y: 45, w: 205, h: 60, fontSize: 28, fontWeight: FontWeight.w500),
      ],
    ),
    RoadSignConfig(
      type: RoadSignType.direction,
      name: '指路标志',
      description: '蓝底白字或绿底白字',
      bgColor: Color(0xFF0066CC),
      textColor: Colors.white,
      canvasSize: Size(500, 200),
      slots: [
        RoadSignSlot(id: 'arrow', type: 'arrow_up', x: 20, y: 60, w: 30, h: 40),
        RoadSignSlot(id: 'dest1', type: 'text', x: 60, y: 50, w: 200, h: 40, fontSize: 24, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'dist1', type: 'text', x: 60, y: 95, w: 200, h: 25, fontSize: 14),
        RoadSignSlot(id: 'dest2', type: 'text', x: 280, y: 50, w: 200, h: 40, fontSize: 20, fontWeight: FontWeight.w500),
        RoadSignSlot(id: 'dist2', type: 'text', x: 280, y: 95, w: 200, h: 25, fontSize: 12),
        RoadSignSlot(id: 'dest3', type: 'text', x: 280, y: 130, w: 200, h: 35, fontSize: 16),
        RoadSignSlot(id: 'dist3', type: 'text', x: 280, y: 165, w: 200, h: 22, fontSize: 11),
      ],
    ),
    RoadSignConfig(
      type: RoadSignType.exitPreview,
      name: '出口预告',
      description: '绿底白字，显示出口编号和方向',
      bgColor: Color(0xFF008B3D),
      textColor: Colors.white,
      canvasSize: Size(400, 180),
      slots: [
        RoadSignSlot(id: 'exit_num', type: 'text', x: 15, y: 25, w: 80, h: 50, fontSize: 36, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'exit_label', type: 'text', x: 95, y: 35, w: 60, h: 30, fontSize: 16),
        RoadSignSlot(id: 'dest1', type: 'text', x: 15, y: 85, w: 370, h: 40, fontSize: 28, fontWeight: FontWeight.bold),
        RoadSignSlot(id: 'dest2', type: 'text', x: 15, y: 130, w: 370, h: 35, fontSize: 22),
      ],
    ),
  ];
}

class RoadSignSlot {
  final String id;
  final String type;
  final double x;
  final double y;
  final double w;
  final double h;
  final double fontSize;
  final FontWeight fontWeight;
  final Color? color;

  const RoadSignSlot({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    this.fontSize = 14,
    this.fontWeight = FontWeight.normal,
    this.color,
  });

  Offset get position => Offset(x, y);
  Size get size => Size(w, h);
}

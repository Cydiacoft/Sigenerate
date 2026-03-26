import 'package:flutter/material.dart';

enum ElementType {
  text,
  arrow,
  rectangle,
  line,
  icon,
  signBoard,
}

class DesignElement {
  String id;
  ElementType type;
  Offset position;
  Size size;
  String content;
  Color color;
  double fontSize;
  String fontFamily;
  FontWeight fontWeight;
  bool filled;
  double strokeWidth;
  Alignment alignment;
  String? iconName;

  DesignElement({
    required this.id,
    required this.type,
    this.position = Offset.zero,
    this.size = const Size(100, 40),
    this.content = '',
    this.color = const Color(0xFF1F2937),
    this.fontSize = 16,
    this.fontFamily = 'Microsoft YaHei',
    this.fontWeight = FontWeight.normal,
    this.filled = false,
    this.strokeWidth = 2,
    this.alignment = Alignment.center,
    this.iconName,
  });

  DesignElement copyWith() {
    return DesignElement(
      id: id,
      type: type,
      position: position,
      size: size,
      content: content,
      color: color,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: fontWeight,
      filled: filled,
      strokeWidth: strokeWidth,
      alignment: alignment,
      iconName: iconName,
    );
  }
}

class SignBoardPreset {
  final String name;
  final String code;
  final Color bgColor;
  final Color textColor;
  final List<DesignElement> elements;

  const SignBoardPreset({
    required this.name,
    required this.code,
    required this.bgColor,
    required this.textColor,
    required this.elements,
  });
}

class SignBoardPresets {
  static const List<SignBoardPreset> highway = [
    SignBoardPreset(
      name: '高速绿底白字',
      code: 'G001',
      bgColor: Color(0xFF059669),
      textColor: Colors.white,
      elements: [],
    ),
    SignBoardPreset(
      name: '高速蓝底白字',
      code: 'G002',
      bgColor: Color(0xFF1D4ED8),
      textColor: Colors.white,
      elements: [],
    ),
  ];

  static const List<SignBoardPreset> urban = [
    SignBoardPreset(
      name: '城市蓝底白字',
      code: 'U001',
      bgColor: Color(0xFF0284C7),
      textColor: Colors.white,
      elements: [],
    ),
    SignBoardPreset(
      name: '城市绿底白字',
      code: 'U002',
      bgColor: Color(0xFF059669),
      textColor: Colors.white,
      elements: [],
    ),
  ];

  static const List<SignBoardPreset> scenic = [
    SignBoardPreset(
      name: '景区棕底白字',
      code: 'S001',
      bgColor: Color(0xFF92400E),
      textColor: Colors.white,
      elements: [],
    ),
  ];

  static List<SignBoardPreset> get all => [...highway, ...urban, ...scenic];
}

class CanvasPreset {
  final String name;
  final Size size;
  final String description;

  const CanvasPreset({
    required this.name,
    required this.size,
    required this.description,
  });

  static const List<CanvasPreset> presets = [
    CanvasPreset(name: '标准指路牌', size: Size(600, 200), description: '600x200'),
    CanvasPreset(name: '大型指路牌', size: Size(800, 300), description: '800x300'),
    CanvasPreset(name: '小型指示牌', size: Size(400, 150), description: '400x150'),
    CanvasPreset(name: '方向指示牌', size: Size(300, 400), description: '300x400'),
    CanvasPreset(name: '入口预告', size: Size(500, 250), description: '500x250'),
    CanvasPreset(name: '出口预告', size: Size(500, 250), description: '500x250'),
  ];
}

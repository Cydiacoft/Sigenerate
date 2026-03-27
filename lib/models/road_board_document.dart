import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/intersection_scene.dart';
import '../widgets/road_sign_canvas.dart';

class RoadBoardDocument {
  const RoadBoardDocument({
    required this.name,
    required this.templateId,
    required this.intersectionShape,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.scenicColor,
    required this.highwayColor,
    required this.directionWordMode,
    required this.customDirectionWords,
    required this.junctionNameEn,
    required this.activeDirection,
    required this.directions,
    required this.boards,
    required this.updatedAt,
  });

  final String name;
  final String templateId;
  final IntersectionShape intersectionShape;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color scenicColor;
  final Color highwayColor;
  final DirectionWordMode directionWordMode;
  final Map<String, String> customDirectionWords;
  final String junctionNameEn;
  final String activeDirection;
  final Map<String, DirectionInfo> directions;
  final Map<String, List<TextNode>> boards;
  final DateTime updatedAt;

  factory RoadBoardDocument.fromEditorState({
    required String templateId,
    required IntersectionScene scene,
    required String junctionNameEn,
    required String activeDirection,
    required Map<String, List<TextNode>> boards,
  }) {
    return RoadBoardDocument(
      name: scene.name,
      templateId: templateId,
      intersectionShape: scene.intersectionShape,
      backgroundColor: scene.backgroundColor,
      foregroundColor: scene.foregroundColor,
      scenicColor: scene.scenicColor,
      highwayColor: scene.highwayColor,
      directionWordMode: scene.directionWordMode,
      customDirectionWords: Map<String, String>.from(
        scene.customDirectionWords,
      ),
      junctionNameEn: junctionNameEn,
      activeDirection: activeDirection,
      directions: {
        for (final entry in scene.directions.entries)
          entry.key: entry.value.copyWith(),
      },
      boards: {
        for (final entry in boards.entries)
          entry.key: entry.value.map((node) => _copyNode(node)).toList(),
      },
      updatedAt: DateTime.now(),
    );
  }

  factory RoadBoardDocument.fromJson(Map<String, dynamic> json) {
    final directionsRaw = (json['directions'] as Map?) ?? const {};
    final boardsRaw = (json['boards'] as Map?) ?? const {};
    return RoadBoardDocument(
      name: json['name'] as String? ?? '',
      templateId: json['templateId'] as String? ?? '',
      intersectionShape: _intersectionShapeFromName(
        json['intersectionShape'] as String?,
      ),
      backgroundColor: _colorFromHex(
        json['backgroundColor'] as String? ?? '#FF20308E',
      ),
      foregroundColor: _colorFromHex(
        json['foregroundColor'] as String? ?? '#FFFFFFFF',
      ),
      scenicColor: _colorFromHex(json['scenicColor'] as String? ?? '#FF8B5A2B'),
      highwayColor: _colorFromHex(
        json['highwayColor'] as String? ?? '#FF006838',
      ),
      directionWordMode: _directionWordModeFromName(
        json['directionWordMode'] as String?,
      ),
      customDirectionWords: {
        for (final entry
            in ((json['customDirectionWords'] as Map?) ?? const {}).entries)
          entry.key.toString(): entry.value.toString(),
      },
      junctionNameEn: json['junctionNameEn'] as String? ?? '',
      activeDirection: json['activeDirection'] as String? ?? 'north',
      directions: {
        for (final entry in directionsRaw.entries)
          entry.key.toString(): _directionInfoFromJson(
            (entry.value as Map).cast<String, dynamic>(),
          ),
      },
      boards: {
        for (final entry in boardsRaw.entries)
          entry.key.toString(): [
            for (final node in (entry.value as List? ?? const []))
              _nodeFromJson((node as Map).cast<String, dynamic>()),
          ],
      },
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'templateId': templateId,
      'intersectionShape': intersectionShape.name,
      'backgroundColor': _colorToHex(backgroundColor),
      'foregroundColor': _colorToHex(foregroundColor),
      'scenicColor': _colorToHex(scenicColor),
      'highwayColor': _colorToHex(highwayColor),
      'directionWordMode': directionWordMode.name,
      'customDirectionWords': customDirectionWords,
      'junctionNameEn': junctionNameEn,
      'activeDirection': activeDirection,
      'updatedAt': updatedAt.toIso8601String(),
      'directions': {
        for (final entry in directions.entries)
          entry.key: _directionInfoToJson(entry.value),
      },
      'boards': {
        for (final entry in boards.entries)
          entry.key: entry.value.map(_nodeToJson).toList(),
      },
    };
  }

  String toPrettyJson() {
    return const JsonEncoder.withIndent('  ').convert(toJson());
  }

  IntersectionScene toScene() {
    return IntersectionScene(
      name: name,
      intersectionShape: intersectionShape,
      north: directions['north']?.copyWith() ?? DirectionInfo(),
      east: directions['east']?.copyWith() ?? DirectionInfo(),
      south: directions['south']?.copyWith() ?? DirectionInfo(),
      west: directions['west']?.copyWith() ?? DirectionInfo(),
      backgroundColor: backgroundColor,
      scenicColor: scenicColor,
      foregroundColor: foregroundColor,
      highwayColor: highwayColor,
      directionWordMode: directionWordMode,
      customDirectionWords: customDirectionWords,
    );
  }

  static TextNode _copyNode(TextNode node) {
    return node.copyWith();
  }

  static Map<String, dynamic> _directionInfoToJson(DirectionInfo info) {
    return {
      'roadName': info.roadName,
      'roadNameEn': info.roadNameEn,
      'roadType': info.roadType.name,
      'destination': info.destination,
      'destinationEn': info.destinationEn,
      'destinationType': info.destinationType.name,
      'signIds': info.signIds,
      'customDirection': info.customDirection,
    };
  }

  static DirectionInfo _directionInfoFromJson(Map<String, dynamic> json) {
    return DirectionInfo(
      roadName: json['roadName'] as String? ?? '',
      roadNameEn: json['roadNameEn'] as String? ?? '',
      roadType: _roadTypeFromName(json['roadType'] as String?),
      destination: json['destination'] as String? ?? '',
      destinationEn: json['destinationEn'] as String? ?? '',
      destinationType: _destinationTypeFromName(
        json['destinationType'] as String?,
      ),
      signIds: [
        for (final value in (json['signIds'] as List? ?? const []))
          value.toString(),
      ],
      customDirection: json['customDirection'] as String? ?? '',
    );
  }

  static Map<String, dynamic> _nodeToJson(TextNode node) {
    return {
      'id': node.id,
      'slotId': node.slotId,
      'x': node.x,
      'y': node.y,
      'width': node.width,
      'height': node.height,
      'text': node.text,
      'textEn': node.textEn,
      'textAlign': node.textAlign.name,
      'nodeType': node.nodeType.name,
      'graphicType': node.graphicType?.name,
      'fillColor': node.fillColor == null ? null : _colorToHex(node.fillColor!),
      'backgroundColor': node.backgroundColor == null
          ? null
          : _colorToHex(node.backgroundColor!),
      'borderColor': node.borderColor == null
          ? null
          : _colorToHex(node.borderColor!),
      'borderWidth': node.borderWidth,
      'style': {
        'color': node.style.color == null
            ? null
            : _colorToHex(node.style.color!),
        'fontSize': node.style.fontSize,
        'fontWeight': node.style.fontWeight?.value,
      },
    };
  }

  static TextNode _nodeFromJson(Map<String, dynamic> json) {
    final style = (json['style'] as Map?)?.cast<String, dynamic>() ?? const {};
    return TextNode(
      id: json['id'] as String? ?? 'node',
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      slotId: json['slotId'] as String?,
      width: (json['width'] as num?)?.toDouble() ?? 180,
      height: (json['height'] as num?)?.toDouble() ?? 80,
      text: json['text'] as String? ?? '',
      textEn: json['textEn'] as String?,
      textAlign: _textAlignFromName(json['textAlign'] as String?),
      style: TextStyle(
        color: style['color'] == null
            ? Colors.white
            : _colorFromHex(style['color'] as String),
        fontSize: (style['fontSize'] as num?)?.toDouble(),
        fontWeight: _fontWeightFromValue(style['fontWeight'] as int?),
      ),
      nodeType: _nodeTypeFromName(json['nodeType'] as String?),
      fillColor: json['fillColor'] == null
          ? null
          : _colorFromHex(json['fillColor'] as String),
      backgroundColor: json['backgroundColor'] == null
          ? null
          : _colorFromHex(json['backgroundColor'] as String),
      borderColor: json['borderColor'] == null
          ? null
          : _colorFromHex(json['borderColor'] as String),
      borderWidth: (json['borderWidth'] as num?)?.toDouble(),
      graphicType: json['graphicType'] == null
          ? null
          : _graphicTypeFromName(json['graphicType'] as String),
    );
  }

  static String _colorToHex(Color color) {
    final a = (color.a * 255.0).round().toRadixString(16).padLeft(2, '0');
    final r = (color.r * 255.0).round().toRadixString(16).padLeft(2, '0');
    final g = (color.g * 255.0).round().toRadixString(16).padLeft(2, '0');
    final b = (color.b * 255.0).round().toRadixString(16).padLeft(2, '0');
    return '#$a$r$g$b'.toUpperCase();
  }

  static Color _colorFromHex(String hex) {
    final value = hex.replaceAll('#', '');
    final normalized = value.length == 6 ? 'FF$value' : value.padLeft(8, 'F');
    return Color(int.parse(normalized, radix: 16));
  }

  static IntersectionShape _intersectionShapeFromName(String? name) {
    return IntersectionShape.values.firstWhere(
      (value) => value.name == name,
      orElse: () => IntersectionShape.crossroad,
    );
  }

  static DirectionWordMode _directionWordModeFromName(String? name) {
    return DirectionWordMode.values.firstWhere(
      (value) => value.name == name,
      orElse: () => DirectionWordMode.chinese,
    );
  }

  static RoadType _roadTypeFromName(String? name) {
    return RoadType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => RoadType.general,
    );
  }

  static DestinationType _destinationTypeFromName(String? name) {
    return DestinationType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => DestinationType.general,
    );
  }

  static NodeType _nodeTypeFromName(String? name) {
    return NodeType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => NodeType.text,
    );
  }

  static GraphicType _graphicTypeFromName(String? name) {
    return GraphicType.values.firstWhere(
      (value) => value.name == name,
      orElse: () => GraphicType.crossroad,
    );
  }

  static TextAlign _textAlignFromName(String? name) {
    return TextAlign.values.firstWhere(
      (value) => value.name == name,
      orElse: () => TextAlign.left,
    );
  }

  static FontWeight _fontWeightFromValue(int? value) {
    const weights = <int, FontWeight>{
      100: FontWeight.w100,
      200: FontWeight.w200,
      300: FontWeight.w300,
      400: FontWeight.w400,
      500: FontWeight.w500,
      600: FontWeight.w600,
      700: FontWeight.w700,
      800: FontWeight.w800,
      900: FontWeight.w900,
    };
    return weights[value] ?? FontWeight.w600;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_sign_generator/core/core_registry.dart';
import 'package:traffic_sign_generator/models/road_board_template.dart';

void main() {
  group('Road registry parsing', () {
    test('road editor options are parsed from layout json', () async {
      final file = File('core_standards/road_gb_5768_2_2022/layout.json');
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;

      final editor = RoadEditorRegistry.fromLayoutJson(json);

      expect(editor.tabs, isNotEmpty);
      expect(editor.signTypes, isNotEmpty);
      expect(editor.routeFontTypes, isNotEmpty);
      expect(editor.routeRoadClasses, isNotEmpty);
      expect(editor.templateIdForTab(editor.tabs.first), isNotNull);
      expect(
        editor.presetForTemplateId('route_number')?.signTypeId,
        equals('lane_guide'),
      );
    });

    test('road templates are parsed from templates json', () async {
      final file = File('core_standards/road_gb_5768_2_2022/templates.json');
      final json =
          jsonDecode(await file.readAsString()) as Map<String, dynamic>;

      final templates = RoadBoardTemplates.fromRegistryJson(json);
      final freeCompose = templates.firstWhere(
        (t) => t.id == RoadBoardTemplates.freeComposeId,
      );

      expect(templates, isNotEmpty);
      expect(freeCompose.slots, isNotEmpty);
      expect(freeCompose.canvasSize.width, greaterThan(0));
      expect(freeCompose.canvasSize.height, greaterThan(0));
    });

    test('layout and templates are consistent', () async {
      final layoutFile = File('core_standards/road_gb_5768_2_2022/layout.json');
      final templatesFile = File(
        'core_standards/road_gb_5768_2_2022/templates.json',
      );

      final layoutJson =
          jsonDecode(await layoutFile.readAsString()) as Map<String, dynamic>;
      final templatesJson =
          jsonDecode(await templatesFile.readAsString())
              as Map<String, dynamic>;

      final editor = RoadEditorRegistry.fromLayoutJson(layoutJson);
      final templates = RoadBoardTemplates.fromRegistryJson(templatesJson);
      final templateIds = templates.map((t) => t.id).toSet();

      expect(templateIds, isNotEmpty);
      expect(editor.tabTemplateMap, isNotEmpty);
      expect(editor.scenarioPresets, isNotEmpty);

      for (final entry in editor.tabTemplateMap.entries) {
        expect(
          templateIds.contains(entry.value),
          isTrue,
          reason:
              'tab "${entry.key}" maps to unknown template "${entry.value}"',
        );
      }

      for (final templateId in editor.scenarioPresets.keys) {
        expect(
          templateIds.contains(templateId),
          isTrue,
          reason: 'scenario preset points to unknown template "$templateId"',
        );
      }

      for (final preset in editor.scenarioPresets.values) {
        expect(
          editor.signTypeMap.containsKey(preset.signTypeId),
          isTrue,
          reason:
              'unknown signTypeId "${preset.signTypeId}" in scenario preset',
        );
      }
    });
  });
}

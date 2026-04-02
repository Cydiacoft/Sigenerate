import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/road_board_template.dart';

class CoreRegistry {
  CoreRegistry._();

  static final CoreRegistry instance = CoreRegistry._();

  static const String _palettesPath = 'core_assets/palettes/colors.json';
  static const String _roadLayoutPath =
      'core_standards/road_gb_5768_2_2022/layout.json';
  static const String _roadTypographyPath =
      'core_standards/road_gb_5768_2_2022/typography.json';
  static const String _roadTemplatesPath =
      'core_standards/road_gb_5768_2_2022/templates.json';
  static const String _layoutRulesPath =
      'core_canvas_model/rules/layout_rules.json';
  static const String _exportRulesPath =
      'core_canvas_model/rules/export_rules.json';

  bool _initialized = false;

  CoreAssetsRegistry assets = CoreAssetsRegistry.empty();
  CoreStandardsRegistry standards = CoreStandardsRegistry.empty();
  CoreCanvasModelRegistry canvasModel = CoreCanvasModelRegistry.empty();

  Future<void> initialize() async {
    if (_initialized) return;

    final palettes = await _loadJsonMap(_palettesPath);
    final roadLayout = await _loadJsonMap(_roadLayoutPath);
    final roadTypography = await _loadJsonMap(_roadTypographyPath);
    final roadTemplates = await _loadJsonMap(_roadTemplatesPath);
    final layoutRules = await _loadJsonMap(_layoutRulesPath);
    final exportRules = await _loadJsonMap(_exportRulesPath);

    assets = CoreAssetsRegistry.fromJson(palettes);
    standards = CoreStandardsRegistry.fromJson(
      roadLayout: roadLayout,
      roadTypography: roadTypography,
      roadTemplates: roadTemplates,
    );
    canvasModel = CoreCanvasModelRegistry.fromJson(
      layoutRules: layoutRules,
      exportRules: exportRules,
    );

    if (standards.road.templates.isNotEmpty) {
      RoadBoardTemplates.replaceAll(standards.road.templates);
    }
    _initialized = true;
  }

  Future<Map<String, dynamic>> _loadJsonMap(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return decoded.cast<String, dynamic>();
      }
      return const <String, dynamic>{};
    } catch (_) {
      return const <String, dynamic>{};
    }
  }
}

class CoreAssetsRegistry {
  const CoreAssetsRegistry({required this.palettes});

  factory CoreAssetsRegistry.empty() =>
      const CoreAssetsRegistry(palettes: <String, AssetPalette>{});

  factory CoreAssetsRegistry.fromJson(Map<String, dynamic> json) {
    final rawPalettes =
        (json['palettes'] as List?)?.cast<Map>() ?? const <Map>[];
    final parsed = <String, AssetPalette>{};
    for (final raw in rawPalettes) {
      final palette = AssetPalette.fromJson(raw.cast<String, dynamic>());
      parsed[palette.id] = palette;
    }
    return CoreAssetsRegistry(palettes: Map.unmodifiable(parsed));
  }

  final Map<String, AssetPalette> palettes;

  AssetPalette? paletteById(String id) => palettes[id];

  Map<String, Color> gbRoadColorMap() {
    final palette = paletteById('gb_road');
    if (palette == null || palette.colors.isEmpty) {
      return Map.unmodifiable(<String, Color>{
        '缁胯壊': const Color(0xFF007A22),
        '钃濊壊': const Color(0xFF20308E),
        '妫曡壊': const Color(0xFF8B5A2B),
      });
    }
    final mapped = <String, Color>{};
    for (final color in palette.colors) {
      final parsed = parseHexColor(color.hex);
      if (parsed == null) continue;
      mapped[color.label] = parsed;
    }
    if (mapped.isEmpty) {
      return Map.unmodifiable(<String, Color>{
        '缁胯壊': const Color(0xFF007A22),
        '钃濊壊': const Color(0xFF20308E),
        '妫曡壊': const Color(0xFF8B5A2B),
      });
    }
    return Map.unmodifiable(mapped);
  }

  Color gbRoadColorById(String id, Color fallback) {
    final palette = paletteById('gb_road');
    if (palette == null) return fallback;
    for (final color in palette.colors) {
      if (color.id == id) {
        return parseHexColor(color.hex) ?? fallback;
      }
    }
    return fallback;
  }
}

class AssetPalette {
  const AssetPalette({
    required this.id,
    required this.name,
    required this.colors,
  });

  factory AssetPalette.fromJson(Map<String, dynamic> json) {
    final rawColors = (json['colors'] as List?)?.cast<Map>() ?? const <Map>[];
    final parsedColors = <AssetPaletteColor>[];
    for (final raw in rawColors) {
      parsedColors.add(AssetPaletteColor.fromJson(raw.cast<String, dynamic>()));
    }
    return AssetPalette(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      colors: List.unmodifiable(parsedColors),
    );
  }

  final String id;
  final String name;
  final List<AssetPaletteColor> colors;
}

class AssetPaletteColor {
  const AssetPaletteColor({
    required this.id,
    required this.label,
    required this.hex,
  });

  factory AssetPaletteColor.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? '').toString();
    return AssetPaletteColor(
      id: id,
      label: (json['label'] ?? id).toString(),
      hex: (json['hex'] ?? '').toString(),
    );
  }

  final String id;
  final String label;
  final String hex;
}

class CoreStandardsRegistry {
  const CoreStandardsRegistry({required this.road});

  factory CoreStandardsRegistry.empty() =>
      CoreStandardsRegistry(road: RoadStandardRegistry.empty());

  factory CoreStandardsRegistry.fromJson({
    required Map<String, dynamic> roadLayout,
    required Map<String, dynamic> roadTypography,
    required Map<String, dynamic> roadTemplates,
  }) {
    return CoreStandardsRegistry(
      road: RoadStandardRegistry.fromJson(
        layout: roadLayout,
        typography: roadTypography,
        templates: roadTemplates,
      ),
    );
  }

  final RoadStandardRegistry road;
}

class RoadStandardRegistry {
  const RoadStandardRegistry({
    required this.layout,
    required this.typography,
    required this.templates,
    required this.editor,
  });

  factory RoadStandardRegistry.empty() => RoadStandardRegistry(
    layout: const <String, dynamic>{},
    typography: const <String, dynamic>{},
    templates: const <RoadBoardTemplateSpec>[],
    editor: RoadEditorRegistry.empty(),
  );

  factory RoadStandardRegistry.fromJson({
    required Map<String, dynamic> layout,
    required Map<String, dynamic> typography,
    required Map<String, dynamic> templates,
  }) {
    final parsedTemplates = RoadBoardTemplates.fromRegistryJson(templates);
    return RoadStandardRegistry(
      layout: UnmodifiableMapView<String, dynamic>(layout),
      typography: UnmodifiableMapView<String, dynamic>(typography),
      templates: List.unmodifiable(parsedTemplates),
      editor: RoadEditorRegistry.fromLayoutJson(layout),
    );
  }

  final Map<String, dynamic> layout;
  final Map<String, dynamic> typography;
  final List<RoadBoardTemplateSpec> templates;
  final RoadEditorRegistry editor;
}

class RoadEditorRegistry {
  const RoadEditorRegistry({
    required this.defaultTab,
    required this.tabs,
    required this.signTypes,
    required this.routeFontTypes,
    required this.routeRoadClasses,
    required this.tabTemplateMap,
    required this.signTypeMap,
    required this.scenarioPresets,
  });

  factory RoadEditorRegistry.empty() => const RoadEditorRegistry(
    defaultTab: 'Free Compose',
    tabs: <String>[
      'Place Distance',
      'Service Distance',
      'Service Advance',
      'Route Number',
      'Free Compose',
    ],
    signTypes: <String>[
      'Free',
      'Left Exit UpLeft',
      'Left Exit Up',
      'Straight Up',
      'Lane Guide Down',
      'Right Exit UpRight',
      'Right Exit Up',
    ],
    routeFontTypes: <String>['Road Font B', 'Road Font A'],
    routeRoadClasses: <String>[
      'National Expressway',
      'Provincial Expressway',
      'National Highway',
      'Provincial Highway',
      'County/Township Road',
    ],
    tabTemplateMap: <String, String>{
      'Place Distance': 'place_distance',
      'Service Distance': 'service_distance',
      'Service Advance': 'service_advance',
      'Route Number': 'route_number',
      'Free Compose': 'free_compose',
    },
    signTypeMap: <String, String>{
      'free': 'Free',
      'straight': 'Straight',
      'lane_guide': 'Lane Guide',
    },
    scenarioPresets: <String, RoadScenarioPreset>{
      'place_distance': RoadScenarioPreset(
        showExitDistance: true,
        showTopInfoBar: false,
        signTypeId: 'straight',
      ),
      'service_distance': RoadScenarioPreset(
        showExitDistance: true,
        showTopInfoBar: true,
        signTypeId: 'straight',
      ),
      'service_advance': RoadScenarioPreset(
        showExitDistance: false,
        showTopInfoBar: true,
        signTypeId: 'straight',
      ),
      'route_number': RoadScenarioPreset(
        showExitDistance: false,
        showTopInfoBar: true,
        signTypeId: 'lane_guide',
      ),
      'free_compose': RoadScenarioPreset(
        showExitDistance: false,
        showTopInfoBar: false,
        signTypeId: 'free',
      ),
    },
  );

  factory RoadEditorRegistry.fromLayoutJson(Map<String, dynamic> layout) {
    final editor = (layout['roadEditor'] as Map?)?.cast<String, dynamic>();
    if (editor == null) {
      return RoadEditorRegistry.empty();
    }

    final tabs =
        (editor['tabs'] as List?)?.map((e) => '$e').toList() ??
        RoadEditorRegistry.empty().tabs;
    final signTypes =
        (editor['signTypes'] as List?)?.map((e) => '$e').toList() ??
        RoadEditorRegistry.empty().signTypes;
    final routeFontTypes =
        (editor['routeFontTypes'] as List?)?.map((e) => '$e').toList() ??
        RoadEditorRegistry.empty().routeFontTypes;
    final routeRoadClasses =
        (editor['routeRoadClasses'] as List?)?.map((e) => '$e').toList() ??
        RoadEditorRegistry.empty().routeRoadClasses;
    final defaultTab = (editor['defaultTab'] ?? '').toString().trim();
    final rawMap =
        (editor['tabTemplateMap'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final rawSignTypeMap =
        (editor['signTypeMap'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final rawPresets =
        (editor['scenarioPresets'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};

    final tabTemplateMap = <String, String>{};
    rawMap.forEach((key, value) {
      final k = key.trim();
      final v = '$value'.trim();
      if (k.isEmpty || v.isEmpty) return;
      tabTemplateMap[k] = v;
    });

    final Map<String, String> normalizedMap = tabTemplateMap.isEmpty
        ? RoadEditorRegistry.empty().tabTemplateMap
        : Map<String, String>.unmodifiable(tabTemplateMap);
    final signTypeMap = <String, String>{};
    rawSignTypeMap.forEach((key, value) {
      final k = key.trim();
      final v = '$value'.trim();
      if (k.isEmpty || v.isEmpty) return;
      signTypeMap[k] = v;
    });
    final Map<String, String> normalizedSignTypeMap = signTypeMap.isEmpty
        ? RoadEditorRegistry.empty().signTypeMap
        : Map<String, String>.unmodifiable(signTypeMap);
    final List<String> normalizedTabs = tabs.isEmpty
        ? RoadEditorRegistry.empty().tabs
        : List<String>.unmodifiable(tabs);
    final List<String> normalizedSignTypes = signTypes.isEmpty
        ? RoadEditorRegistry.empty().signTypes
        : List<String>.unmodifiable(signTypes);
    final List<String> normalizedRouteFontTypes = routeFontTypes.isEmpty
        ? RoadEditorRegistry.empty().routeFontTypes
        : List<String>.unmodifiable(routeFontTypes);
    final List<String> normalizedRouteRoadClasses = routeRoadClasses.isEmpty
        ? RoadEditorRegistry.empty().routeRoadClasses
        : List<String>.unmodifiable(routeRoadClasses);
    final scenarioPresets = <String, RoadScenarioPreset>{};
    rawPresets.forEach((key, value) {
      if (key.trim().isEmpty || value is! Map) return;
      scenarioPresets[key] = RoadScenarioPreset.fromJson(
        value.cast<String, dynamic>(),
      );
    });
    final Map<String, RoadScenarioPreset> normalizedScenarioPresets =
        scenarioPresets.isEmpty
        ? RoadEditorRegistry.empty().scenarioPresets
        : Map<String, RoadScenarioPreset>.unmodifiable(scenarioPresets);

    return RoadEditorRegistry(
      defaultTab: defaultTab.isEmpty ? normalizedTabs.last : defaultTab,
      tabs: normalizedTabs,
      signTypes: normalizedSignTypes,
      routeFontTypes: normalizedRouteFontTypes,
      routeRoadClasses: normalizedRouteRoadClasses,
      tabTemplateMap: normalizedMap,
      signTypeMap: normalizedSignTypeMap,
      scenarioPresets: normalizedScenarioPresets,
    );
  }

  final String defaultTab;
  final List<String> tabs;
  final List<String> signTypes;
  final List<String> routeFontTypes;
  final List<String> routeRoadClasses;
  final Map<String, String> tabTemplateMap;
  final Map<String, String> signTypeMap;
  final Map<String, RoadScenarioPreset> scenarioPresets;

  String? templateIdForTab(String tab) => tabTemplateMap[tab];

  String? tabForTemplateId(String templateId) {
    for (final entry in tabTemplateMap.entries) {
      if (entry.value == templateId) return entry.key;
    }
    return null;
  }

  RoadScenarioPreset? presetForTemplateId(String templateId) {
    return scenarioPresets[templateId];
  }

  String? signTypeLabelForId(String signTypeId) => signTypeMap[signTypeId];
}

class RoadScenarioPreset {
  const RoadScenarioPreset({
    required this.showExitDistance,
    required this.showTopInfoBar,
    required this.signTypeId,
  });

  factory RoadScenarioPreset.fromJson(Map<String, dynamic> json) {
    return RoadScenarioPreset(
      showExitDistance: json['showExitDistance'] == true,
      showTopInfoBar: json['showTopInfoBar'] == true,
      signTypeId: (json['signTypeId'] ?? 'free').toString(),
    );
  }

  final bool showExitDistance;
  final bool showTopInfoBar;
  final String signTypeId;
}

class CoreCanvasModelRegistry {
  const CoreCanvasModelRegistry({
    required this.layoutRules,
    required this.exportRules,
  });

  factory CoreCanvasModelRegistry.empty() => const CoreCanvasModelRegistry(
    layoutRules: <String, dynamic>{},
    exportRules: <String, dynamic>{},
  );

  factory CoreCanvasModelRegistry.fromJson({
    required Map<String, dynamic> layoutRules,
    required Map<String, dynamic> exportRules,
  }) {
    return CoreCanvasModelRegistry(
      layoutRules: UnmodifiableMapView<String, dynamic>(layoutRules),
      exportRules: UnmodifiableMapView<String, dynamic>(exportRules),
    );
  }

  final Map<String, dynamic> layoutRules;
  final Map<String, dynamic> exportRules;
}

Color? parseHexColor(String? hex) {
  if (hex == null || hex.isEmpty) return null;
  final cleaned = hex.replaceFirst('#', '').trim();
  if (cleaned.length != 6 && cleaned.length != 8) return null;
  final value = int.tryParse(
    cleaned.length == 6 ? 'FF$cleaned' : cleaned,
    radix: 16,
  );
  if (value == null) return null;
  return Color(value);
}

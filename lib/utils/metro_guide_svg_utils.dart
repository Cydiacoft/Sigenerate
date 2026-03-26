import 'package:flutter/services.dart';

class MetroGuideSvgUtils {
  MetroGuideSvgUtils._();

  static const String assetDirectory = 'assets/metro_guide';
  static final Map<String, Future<String>> _svgCache = {};

  static String assetPath(String fileName) => '$assetDirectory/$fileName';

  static Future<String> loadSvg(String fileName) {
    return _svgCache.putIfAbsent(
      fileName,
      () => rootBundle.loadString(assetPath(fileName)),
    );
  }

  static Future<String> loadColoredSvg(String fileName, String color) async {
    final rawSvg = await loadSvg(fileName);
    return applyColor(rawSvg, color);
  }

  static String applyColor(String svg, String color) {
    var output = svg;

    final colorGroupPattern = RegExp(
      r'(<g[^>]*id="c"[^>]*>)([\s\S]*?)(</g>)',
      multiLine: true,
    );
    if (colorGroupPattern.hasMatch(output)) {
      output = output.replaceAllMapped(colorGroupPattern, (match) {
        final content = match.group(2) ?? '';
        final coloredContent = _replaceColorTokens(content, color);
        return '${match.group(1)}$coloredContent${match.group(3)}';
      });
    } else {
      output = _replaceColorTokens(output, color);
    }

    return output;
  }

  static String _replaceColorTokens(String svg, String color) {
    return svg
        .replaceAll(RegExp(r'#003670', caseSensitive: false), color)
        .replaceAll(RegExp(r'#3670', caseSensitive: false), color)
        .replaceAllMapped(
          RegExp("""fill=["']#[0-9a-fA-F]{3,8}["']"""),
          (match) =>
              match.group(0)!.contains('#fff') ||
                  match.group(0)!.contains('#FFF')
              ? match.group(0)!
              : 'fill="$color"',
        )
        .replaceAllMapped(
          RegExp(r'(fill:\s*)(#[0-9a-fA-F]{3,8})', caseSensitive: false),
          (match) => '${match.group(1)}$color',
        );
  }
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:traffic_sign_generator/signs/china_information_signs.dart';

void main() {
  group('China information signs integrity', () {
    test('entries are non-empty and unique', () {
      expect(chinaInformationSigns, isNotEmpty);

      final ids = <String>{};
      final assetPaths = <String>{};

      for (final sign in chinaInformationSigns) {
        expect(sign.id, isNotEmpty);
        expect(ids.add(sign.id), isTrue, reason: 'Duplicate id: ${sign.id}');

        expect(sign.assetPath, isNotNull);
        final path = sign.assetPath!;
        expect(path, startsWith('assets/road_signs_info/svg/'));
        expect(path.toLowerCase(), endsWith('.svg'));
        expect(
          assetPaths.add(path),
          isTrue,
          reason: 'Duplicate assetPath: $path',
        );
      }
    });

    test('asset files exist on disk', () {
      for (final sign in chinaInformationSigns) {
        final assetPath = sign.assetPath!;
        final file = File(assetPath);
        expect(
          file.existsSync(),
          isTrue,
          reason: 'Missing SVG file: $assetPath for sign ${sign.id}',
        );
      }
    });
  });
}

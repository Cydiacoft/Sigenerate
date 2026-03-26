import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../models/intersection_scene.dart';

class ExportUtils {
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  static Future<String?> saveImage(
    Uint8List imageBytes,
    String filename,
  ) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/traffic_signs';
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      final file = File('$path/$filename');
      await file.writeAsBytes(imageBytes);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  static Future<List<String>> exportAllSigns(
    GlobalKey northKey,
    GlobalKey eastKey,
    GlobalKey southKey,
    GlobalKey westKey,
    IntersectionScene scene,
  ) async {
    final paths = <String>[];

    final directions = ['north', 'east', 'south', 'west'];
    final keys = [northKey, eastKey, southKey, westKey];

    for (int i = 0; i < 4; i++) {
      final bytes = await captureWidget(keys[i]);
      if (bytes != null) {
        final filename =
            '${scene.name.isEmpty ? "intersection" : scene.name}_${directions[i]}.png';
        final path = await saveImage(bytes, filename);
        if (path != null) {
          paths.add(path);
        }
      }
    }

    return paths;
  }
}

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final String title;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.title,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late TextEditingController _hexController;
  late Color _selectedColor;

  final List<Color> _presetColors = [
    const Color(0xFF1A1A2E),
    const Color(0xFF16213E),
    const Color(0xFF0F3460),
    const Color(0xFF533483),
    const Color(0xFFE94560),
    const Color(0xFFFFD700),
    const Color(0xFF4A90A4),
    const Color(0xFF2ECC71),
    const Color(0xFFE74C3C),
    const Color(0xFF3498DB),
    const Color(0xFF9B59B6),
    const Color(0xFF1ABC9C),
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
    _hexController = TextEditingController(text: _colorToHex(_selectedColor));
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2).toUpperCase()}';
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _presetColors.map((color) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedColor = color;
                      _hexController.text = _colorToHex(color);
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: _selectedColor == color
                            ? Colors.white
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _hexController,
              decoration: const InputDecoration(
                labelText: 'HEX颜色值',
                border: OutlineInputBorder(),
                prefixText: '#',
              ),
              onChanged: (value) {
                try {
                  setState(() {
                    _selectedColor = _hexToColor(value);
                  });
                } catch (_) {}
              },
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedColor),
          child: const Text('确认'),
        ),
      ],
    );
  }
}

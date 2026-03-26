import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models/traffic_sign.dart';
import '../painters/traffic_sign_painter.dart';

class RoadSignGlyph extends StatelessWidget {
  const RoadSignGlyph({
    super.key,
    required this.sign,
    this.size = 72,
    this.padding = const EdgeInsets.all(4),
  });

  final TrafficSign sign;
  final double size;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final child = sign.hasSvgAsset
        ? SvgPicture.asset(
            sign.assetPath!,
            width: size,
            height: size,
            fit: BoxFit.contain,
          )
        : CustomPaint(
            size: Size.square(size),
            painter: TrafficSignPainter(sign: sign, scale: 0.92),
          );

    return Padding(
      padding: padding,
      child: SizedBox(width: size, height: size, child: child),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../utils/metro_guide_svg_utils.dart';

class MetroGuideToolbarItem extends StatelessWidget {
  final String fileName;
  final VoidCallback? onTap;
  final bool compact;

  const MetroGuideToolbarItem({
    super.key,
    required this.fileName,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Container(
      height: compact ? 42 : 60,
      width: compact ? 42 : null,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.darkBgSecondary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Center(
        child: SvgPicture.asset(
          MetroGuideSvgUtils.assetPath(fileName),
          fit: BoxFit.contain,
          placeholderBuilder: (_) => const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );

    if (compact) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: child,
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: child,
    );
  }
}

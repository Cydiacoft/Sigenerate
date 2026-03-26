import 'package:flutter/material.dart';

import '../models/metro_guide_models.dart';
import '../theme/app_theme.dart';
import 'metro_guide_toolbar_item.dart';

class MetroGuideToolbar extends StatelessWidget {
  final Function(MetroGuideItem) onAddItem;
  final Function(String) onEditItem;
  final VoidCallback onAddText;
  final VoidCallback onAddColorBand;

  const MetroGuideToolbar({
    super.key,
    required this.onAddItem,
    required this.onEditItem,
    required this.onAddText,
    required this.onAddColorBand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: AppTheme.darkBgSecondary,
        border: Border(right: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final type in GuideItemAssets.orderedTypes)
                  _CategoryPanel(
                    type: type,
                    onAddItem: onAddItem,
                    onAddText: onAddText,
                    onAddColorBand: onAddColorBand,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(
        children: [
          const Icon(Icons.widgets_outlined, size: 18, color: Colors.white70),
          const SizedBox(width: 8),
          const Text(
            '素材库',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: onAddText,
            icon: const Icon(Icons.add, size: 14),
            label: const Text('文本'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: AppTheme.primaryColor),
              minimumSize: const Size(0, 34),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPanel extends StatefulWidget {
  final GuideItemType type;
  final Function(MetroGuideItem) onAddItem;
  final VoidCallback onAddText;
  final VoidCallback onAddColorBand;

  const _CategoryPanel({
    required this.type,
    required this.onAddItem,
    required this.onAddText,
    required this.onAddColorBand,
  });

  @override
  State<_CategoryPanel> createState() => _CategoryPanelState();
}

class _CategoryPanelState extends State<_CategoryPanel> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.type == GuideItemType.line;
  }

  @override
  Widget build(BuildContext context) {
    final items = GuideItemAssets.groupedItems[widget.type] ?? const <String>[];
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(
                  _iconForType(widget.type),
                  size: 18,
                  color: _colorForType(widget.type),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        GuideItemTypeNames.getName(widget.type),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${items.length} 个元素',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                if (widget.type == GuideItemType.sub)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: widget.onAddColorBand,
                            icon: const Icon(Icons.horizontal_rule, size: 14),
                            label: const Text('自定义色带'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                              side: const BorderSide(
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 1.8,
                  ),
                  itemBuilder: (context, index) {
                    final fileName = items[index];
                    final item = MetroGuideItem(
                      fileName: fileName,
                      type: GuideItemAssets.getTypeFromFileName(fileName),
                    );
                    return Draggable<MetroGuideItem>(
                      data: item,
                      feedback: Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          width: 96,
                          child: MetroGuideToolbarItem(fileName: fileName),
                        ),
                      ),
                      childWhenDragging: Opacity(
                        opacity: 0.35,
                        child: MetroGuideToolbarItem(fileName: fileName),
                      ),
                      child: MetroGuideToolbarItem(
                        fileName: fileName,
                        onTap: () => widget.onAddItem(item),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _iconForType(GuideItemType type) {
    switch (type) {
      case GuideItemType.line:
        return Icons.route_outlined;
      case GuideItemType.way:
        return Icons.turn_right_outlined;
      case GuideItemType.stn:
        return Icons.subway_outlined;
      case GuideItemType.oth:
        return Icons.text_fields_outlined;
      case GuideItemType.sub:
        return Icons.horizontal_rule_outlined;
      case GuideItemType.text:
        return Icons.notes_outlined;
      case GuideItemType.cls:
        return Icons.palette_outlined;
      case GuideItemType.clss:
        return Icons.view_week_outlined;
    }
  }

  Color _colorForType(GuideItemType type) {
    switch (type) {
      case GuideItemType.line:
        return const Color(0xFFE4002B);
      case GuideItemType.way:
        return const Color(0xFF00A1DE);
      case GuideItemType.stn:
        return const Color(0xFF00C48C);
      case GuideItemType.oth:
        return const Color(0xFFFAC000);
      case GuideItemType.sub:
        return const Color(0xFF98C5A3);
      case GuideItemType.text:
        return Colors.white70;
      case GuideItemType.cls:
        return const Color(0xFFDA81A6);
      case GuideItemType.clss:
        return const Color(0xFF7D8B2F);
    }
  }
}

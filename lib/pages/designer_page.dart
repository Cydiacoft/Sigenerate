import 'package:flutter/material.dart';
import '../models/templates.dart';
import '../models/design_models.dart';
import '../painters/template_painter.dart';
import '../painters/canvas_painter.dart';
import '../theme/app_theme.dart';

class DesignerPage extends StatefulWidget {
  const DesignerPage({super.key});

  @override
  State<DesignerPage> createState() => _DesignerPageState();
}

class _DesignerPageState extends State<DesignerPage> {
  EditMode _editMode = EditMode.template;

  TemplateLayout? _selectedTemplate;
  Map<String, String> _slotValues = {};
  String? _selectedSlotId;

  final List<DesignElement> _elements = [];
  DesignElement? _selectedElement;
  Color _backgroundColor = const Color(0xFF059669);
  Size _canvasSize = const Size(600, 200);
  bool _showGrid = true;
  bool _showSlotLabels = false;
  int _nextId = 1;

  final List<_ToolItem> _freeTools = [
    _ToolItem(Icons.text_fields, '文字', ElementType.text),
    _ToolItem(Icons.arrow_forward, '箭头', ElementType.arrow),
    _ToolItem(Icons.crop_square, '矩形', ElementType.rectangle),
    _ToolItem(Icons.horizontal_rule, '线条', ElementType.line),
    _ToolItem(Icons.emoji_symbols, '图标', ElementType.icon),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          _buildLeftPanel(),
          Expanded(child: _buildMainArea()),
          _buildRightPanel(),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Container(
      width: 72,
      color: AppTheme.darkBgSecondary,
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildModeToggle(),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.darkBorder),
          const SizedBox(height: 12),
          if (_editMode == EditMode.template) ...[
            _buildTemplateList(),
          ] else ...[
            ..._freeTools.map((tool) => _buildToolButton(tool)),
            const Divider(height: 32, color: AppTheme.darkBorder),
            _buildToolButton(_ToolItem(Icons.save, '保存', ElementType.text)),
            _buildToolButton(_ToolItem(Icons.download, '导出', ElementType.text)),
          ],
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        children: [
          _buildModeButton(Icons.dashboard_customize, '模板', EditMode.template),
          const SizedBox(height: 4),
          _buildModeButton(Icons.edit, '自由', EditMode.free),
        ],
      ),
    );
  }

  Widget _buildModeButton(IconData icon, String label, EditMode mode) {
    final isSelected = _editMode == mode;
    return InkWell(
      onTap: () => setState(() {
        _editMode = mode;
        if (mode == EditMode.template && _selectedTemplate == null) {
          _selectedTemplate = TemplatePresets.all.first;
          _initSlotValues();
        }
      }),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 56,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: AppTheme.primaryColor) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.textSecondaryDark,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateList() {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: TemplatePresets.all
            .map((t) => _buildTemplateItem(t))
            .toList(),
      ),
    );
  }

  Widget _buildTemplateItem(TemplateLayout template) {
    final isSelected = _selectedTemplate?.name == template.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTemplate = template;
            _backgroundColor = template.defaultBgColor;
            _canvasSize = template.canvasSize;
            _initSlotValues();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : AppTheme.darkBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: template.defaultBgColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Icon(
                    _getTemplateIcon(template),
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                template.name,
                style: TextStyle(
                  fontSize: 8,
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.textSecondaryDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTemplateIcon(TemplateLayout template) {
    if (template.name.contains('十字')) return Icons.add_circle;
    if (template.name.contains('T形')) return Icons.architecture;
    if (template.name.contains('方向')) return Icons.signpost;
    if (template.name.contains('入口')) return Icons.login;
    return Icons.signpost;
  }

  Widget _buildToolButton(_ToolItem tool) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: InkWell(
        onTap: () => _addElement(tool.type),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppTheme.darkBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(tool.icon, size: 22, color: AppTheme.textPrimaryDark),
              const SizedBox(height: 2),
              Text(
                tool.label,
                style: const TextStyle(
                  fontSize: 9,
                  color: AppTheme.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainArea() {
    return Container(
      color: AppTheme.darkBg,
      child: Column(
        children: [
          _buildToolbar(),
          Expanded(child: _buildCanvas()),
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.darkBgSecondary,
        border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(
        children: [
          const Text(
            '导视图设计器',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryDark,
            ),
          ),
          const SizedBox(width: 32),
          if (_editMode == EditMode.template && _selectedTemplate != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _backgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedTemplate!.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            _buildColorButton(
              '背景',
              _backgroundColor,
              (c) => setState(() => _backgroundColor = c),
            ),
          ] else ...[
            _buildDropdown<Size>(
              value: _canvasSize,
              items: CanvasPreset.presets
                  .map(
                    (p) => DropdownMenuItem(
                      value: p.size,
                      child: Text(
                        '${p.name} (${p.size.width.toInt()}x${p.size.height.toInt()})',
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _canvasSize = v!),
            ),
            const SizedBox(width: 16),
            _buildColorButton(
              '背景',
              _backgroundColor,
              (c) => setState(() => _backgroundColor = c),
            ),
            const SizedBox(width: 16),
            ToggleButtons(
              isSelected: [_showGrid],
              onPressed: (i) => setState(() => _showGrid = !_showGrid),
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minHeight: 36, minWidth: 36),
              children: const [Icon(Icons.grid_on, size: 18)],
            ),
          ],
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _showSlotLabels = !_showSlotLabels),
            icon: Icon(
              _showSlotLabels ? Icons.label : Icons.label_off,
              color: _showSlotLabels
                  ? AppTheme.accentColor
                  : AppTheme.textSecondaryDark,
            ),
            tooltip: '显示标签',
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _exportImage,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('导出PNG'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: DropdownButton<T>(
        value: value,
        items: items,
        onChanged: onChanged,
        underline: const SizedBox(),
        dropdownColor: AppTheme.darkBgSecondary,
        style: const TextStyle(fontSize: 13, color: AppTheme.textPrimaryDark),
        icon: const Icon(
          Icons.expand_more,
          size: 18,
          color: AppTheme.textSecondaryDark,
        ),
      ),
    );
  }

  Widget _buildColorButton(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    final colors = [
      const Color(0xFF059669),
      const Color(0xFF1D4ED8),
      const Color(0xFF0284C7),
      const Color(0xFF92400E),
      const Color(0xFF1F2937),
      const Color(0xFFDC2626),
      const Color(0xFF7C3AED),
      const Color(0xFFF59E0B),
      const Color(0xFF111827),
    ];

    return PopupMenuButton<Color>(
      onSelected: onChanged,
      offset: const Offset(0, 40),
      color: AppTheme.darkBgSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (ctx) => colors
          .map(
            (c) => PopupMenuItem(
              value: c,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(6),
                  border: c == color
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.darkBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCanvas() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GestureDetector(
              onTapDown: (details) =>
                  _handleCanvasTap(details.localPosition, constraints.biggest),
              child: _editMode == EditMode.template && _selectedTemplate != null
                  ? CustomPaint(
                      size: constraints.biggest,
                      painter: TemplatePainter(
                        template: _selectedTemplate!,
                        slotValues: _slotValues,
                        backgroundColor: _backgroundColor,
                        selectedSlotId: _selectedSlotId,
                        showSlotLabels: _showSlotLabels,
                      ),
                    )
                  : CustomPaint(
                      size: constraints.biggest,
                      painter: CanvasPainter(
                        elements: _elements,
                        backgroundColor: _backgroundColor,
                        canvasSize: _canvasSize,
                        showGrid: _showGrid,
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  void _handleCanvasTap(Offset position, Size containerSize) {
    final scaleX = containerSize.width / _canvasSize.width;
    final scaleY = containerSize.height / _canvasSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final offsetX = (containerSize.width - _canvasSize.width * scale) / 2;
    final offsetY = (containerSize.height - _canvasSize.height * scale) / 2;

    final canvasPos = Offset(
      (position.dx - offsetX) / scale,
      (position.dy - offsetY) / scale,
    );

    if (_editMode == EditMode.template && _selectedTemplate != null) {
      TemplateSlot? hitSlot;
      for (final slot in _selectedTemplate!.slots) {
        if (slot.editable && _isPointInSlot(canvasPos, slot)) {
          hitSlot = slot;
          break;
        }
      }
      setState(() => _selectedSlotId = hitSlot?.id);
    } else {
      DesignElement? hit;
      for (final element in _elements.reversed) {
        final rect = Rect.fromLTWH(
          element.position.dx,
          element.position.dy,
          element.size.width,
          element.size.height,
        );
        if (rect.contains(canvasPos)) {
          hit = element;
          break;
        }
      }
      setState(() => _selectedElement = hit);
    }
  }

  bool _isPointInSlot(Offset point, TemplateSlot slot) {
    return point.dx >= slot.position.dx &&
        point.dx <= slot.position.dx + slot.size.width &&
        point.dy >= slot.position.dy &&
        point.dy <= slot.position.dy + slot.size.height;
  }

  Widget _buildStatusBar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppTheme.darkBgSecondary,
        border: Border(top: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(
        children: [
          Text(
            '画布: ${_canvasSize.width.toInt()} x ${_canvasSize.height.toInt()}',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const SizedBox(width: 24),
          if (_editMode == EditMode.template) ...[
            Text(
              _selectedSlotId != null
                  ? '已选中: ${_getSlotLabel(_selectedSlotId!)}'
                  : '点击编辑区域',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryDark,
              ),
            ),
          ] else ...[
            Text(
              '元素: ${_elements.length}',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryDark,
              ),
            ),
            const SizedBox(width: 24),
            Text(
              _selectedElement != null
                  ? '已选中: ${_selectedElement!.type.name}'
                  : '未选中元素',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondaryDark,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getSlotLabel(String slotId) {
    final slot = _selectedTemplate?.slots.firstWhere(
      (s) => s.id == slotId,
      orElse: () => const TemplateSlot(
        id: '',
        label: '',
        type: '',
        position: Offset.zero,
        size: Size.zero,
      ),
    );
    return slot?.label ?? '';
  }

  Widget _buildRightPanel() {
    return Container(
      width: 300,
      color: AppTheme.darkBgSecondary,
      child: Column(
        children: [
          _buildPropertyHeader(
            _editMode == EditMode.template ? '模板编辑' : '属性面板',
          ),
          Expanded(
            child: _editMode == EditMode.template
                ? _buildTemplateEditPanel()
                : _buildFreeEditPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyHeader(String title) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateEditPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildColorPresetSection(),
          const SizedBox(height: 24),
          _buildEditableSlotsSection(),
        ],
      ),
    );
  }

  Widget _buildColorPresetSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '快速配色',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildColorPreset('高速绿', const Color(0xFF059669)),
            _buildColorPreset('高速蓝', const Color(0xFF1D4ED8)),
            _buildColorPreset('城市蓝', const Color(0xFF0284C7)),
            _buildColorPreset('景区棕', const Color(0xFF92400E)),
            _buildColorPreset('深灰', const Color(0xFF1F2937)),
            _buildColorPreset('黑色', const Color(0xFF111827)),
          ],
        ),
      ],
    );
  }

  Widget _buildColorPreset(String name, Color color) {
    final isSelected = _backgroundColor == color;
    return InkWell(
      onTap: () => setState(() => _backgroundColor = color),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(color: AppTheme.accentColor, width: 2)
              : null,
        ),
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEditableSlotsSection() {
    if (_selectedTemplate == null) {
      return const Center(
        child: Text(
          '请选择模板',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '编辑内容',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        ..._selectedTemplate!.slots
            .where((s) => s.editable)
            .map((slot) => _buildSlotEditor(slot)),
      ],
    );
  }

  Widget _buildSlotEditor(TemplateSlot slot) {
    final isSelected = _selectedSlotId == slot.id;
    final controller = TextEditingController(text: _slotValues[slot.id] ?? '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedSlotId = slot.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : AppTheme.darkBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: slot.textColor ?? Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slot.label,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.edit,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimaryDark,
                ),
                decoration: InputDecoration(
                  hintText: '输入${slot.label}...',
                  hintStyle: const TextStyle(color: AppTheme.textSecondaryDark),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppTheme.darkBgSecondary,
                ),
                onChanged: (value) {
                  setState(() => _slotValues[slot.id] = value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFreeEditPanel() {
    if (_selectedElement == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快捷操作',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickAction(
              '添加文字',
              Icons.text_fields,
              () => _addElement(ElementType.text),
            ),
            _buildQuickAction(
              '添加箭头',
              Icons.arrow_forward,
              () => _addElement(ElementType.arrow),
            ),
            _buildQuickAction(
              '添加矩形',
              Icons.crop_square,
              () => _addElement(ElementType.rectangle),
            ),
            _buildQuickAction(
              '添加线条',
              Icons.horizontal_rule,
              () => _addElement(ElementType.line),
            ),
            const SizedBox(height: 24),
            const Text(
              '清空画布',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => setState(() {
                  _elements.clear();
                  _selectedElement = null;
                }),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('清空所有元素'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                  side: const BorderSide(color: AppTheme.errorColor),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final el = _selectedElement!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPropertySection('基础属性', [
            _buildPropertyRow('类型', el.type.name),
            _buildPropertyRow('X', '${el.position.dx.toInt()}'),
            _buildPropertyRow('Y', '${el.position.dy.toInt()}'),
            _buildPropertyRow('宽度', '${el.size.width.toInt()}'),
            _buildPropertyRow('高度', '${el.size.height.toInt()}'),
          ]),
          const SizedBox(height: 16),
          if (el.type == ElementType.text || el.type == ElementType.icon) ...[
            _buildPropertySection('文字', [
              _buildTextField('内容', el.content, (v) {
                setState(() => el.content = v);
              }),
              _buildPropertyRow('字号', '${el.fontSize.toInt()}'),
            ]),
            const SizedBox(height: 16),
          ],
          _buildPropertySection('样式', [
            _buildColorRow('颜色', el.color, (c) => setState(() => el.color = c)),
            if (el.type == ElementType.rectangle)
              _buildPropertyRow('线宽', '${el.strokeWidth.toInt()}'),
            if (el.type == ElementType.rectangle)
              _buildSwitchRow(
                '填充',
                el.filled,
                (v) => setState(() => el.filled = v),
              ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => setState(() {
                _elements.removeWhere((e) => e.id == el.id);
                _selectedElement = null;
              }),
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('删除元素'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertySection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return TextField(
      controller: TextEditingController(text: value),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 12),
        isDense: true,
      ),
      style: const TextStyle(fontSize: 12),
      onChanged: onChanged,
    );
  }

  Widget _buildColorRow(
    String label,
    Color color,
    ValueChanged<Color> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => _showColorPicker(color, onChanged),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow(
    String label,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryDark,
            ),
          ),
          const Spacer(),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildQuickAction(String label, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.darkBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.textPrimaryDark),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showColorPicker(Color current, ValueChanged<Color> onChanged) {
    final colors = [
      Colors.white,
      Colors.black,
      const Color(0xFF059669),
      const Color(0xFF1D4ED8),
      const Color(0xFFDC2626),
      const Color(0xFFF59E0B),
      const Color(0xFF7C3AED),
      const Color(0xFF0284C7),
      const Color(0xFF92400E),
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkBgSecondary,
        title: const Text(
          '选择颜色',
          style: TextStyle(color: AppTheme.textPrimaryDark),
        ),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors
              .map(
                (c) => InkWell(
                  onTap: () {
                    onChanged(c);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(8),
                      border: c == current
                          ? Border.all(color: AppTheme.accentColor, width: 3)
                          : null,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _initSlotValues() {
    _slotValues = {};
    for (final slot in _selectedTemplate?.slots ?? []) {
      _slotValues[slot.id] = '';
    }
  }

  void _addElement(ElementType type) {
    final element = DesignElement(
      id: 'el_${_nextId++}',
      type: type,
      position: Offset(_canvasSize.width / 2 - 50, _canvasSize.height / 2 - 20),
      size: const Size(100, 40),
      content: type == ElementType.text ? '文字' : '',
      fontSize: type == ElementType.text ? 20 : 24,
      color: Colors.white,
    );

    setState(() {
      _elements.add(element);
      _selectedElement = element;
    });
  }

  void _exportImage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('导出功能开发中...')));
  }
}

class _ToolItem {
  final IconData icon;
  final String label;
  final ElementType type;

  _ToolItem(this.icon, this.label, this.type);
}

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/metro_models.dart';
import '../models/templates.dart';
import '../painters/metro_painter.dart';
import '../painters/template_painter.dart';
import '../theme/app_theme.dart';

enum EditorMode { road, metro }

class CombinedEditorPage extends StatefulWidget {
  const CombinedEditorPage({super.key});

  @override
  State<CombinedEditorPage> createState() => _CombinedEditorPageState();
}

class _CombinedEditorPageState extends State<CombinedEditorPage> {
  EditorMode _editorMode = EditorMode.metro;

  String? _currentFilePath;
  String _projectName = '新项目';
  bool _hasUnsavedChanges = false;

  MetroCityStyle _selectedCity = MetroCityStyle.shanghai;
  MetroCityConfig _cityConfig = MetroCityConfig.shanghai;
  MetroTemplate? _selectedMetroTemplate;
  Map<String, dynamic> _metroSlotValues = {};
  String? _selectedMetroSlotId;

  TemplateLayout? _selectedRoadTemplate;
  Map<String, String> _roadSlotValues = {};
  String? _selectedRoadSlotId;
  Color _roadBackgroundColor = const Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    _selectedMetroTemplate = MetroTemplatePresets.getByCity(
      _selectedCity,
    ).first;
    _initMetroSlotValues();
  }

  void _initMetroSlotValues() {
    _metroSlotValues = {};
    for (final slot in _selectedMetroTemplate?.slots ?? []) {
      _metroSlotValues[slot.id] = slot.type == 'line_badge'
          ? MetroLine.shanghaiLines.first
          : '';
    }
  }

  void _initRoadSlotValues() {
    _roadSlotValues = {};
    for (final slot in _selectedRoadTemplate?.slots ?? []) {
      _roadSlotValues[slot.id] = '';
    }
  }

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
      width: 220,
      color: AppTheme.darkBgSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildModeSelector(),
          const Divider(height: 1, color: AppTheme.darkBorder),
          Expanded(
            child: _editorMode == EditorMode.metro
                ? _buildMetroTemplateList()
                : _buildRoadTemplateList(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择类型',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondaryDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildModeTab('轨道交通', Icons.train, EditorMode.metro),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildModeTab('道路路牌', Icons.signpost, EditorMode.road),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, IconData icon, EditorMode mode) {
    final isSelected = _editorMode == mode;
    return InkWell(
      onTap: () => setState(() {
        _editorMode = mode;
        if (mode == EditorMode.metro) {
          _selectedMetroTemplate = MetroTemplatePresets.getByCity(
            _selectedCity,
          ).first;
          _initMetroSlotValues();
        } else if (_selectedRoadTemplate == null) {
          _selectedRoadTemplate = TemplatePresets.all.first;
          _initRoadSlotValues();
        }
      }),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : AppTheme.darkBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : AppTheme.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetroTemplateList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text(
          '选择城市',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildCitySelector(),
        const SizedBox(height: 16),
        const Text(
          '选择模板',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...MetroTemplatePresets.getByCity(
          _selectedCity,
        ).map((t) => _buildMetroTemplateItem(t)),
      ],
    );
  }

  Widget _buildCitySelector() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: MetroCityConfig.all.map((city) {
        final isSelected = _selectedCity == city.style;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedCity = city.style;
              _cityConfig = city;
              _selectedMetroTemplate = MetroTemplatePresets.getByCity(
                _selectedCity,
              ).first;
              _initMetroSlotValues();
            });
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor : AppTheme.darkBg,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
              ),
            ),
            child: Text(
              city.name,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : AppTheme.textPrimaryDark,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetroTemplateItem(MetroTemplate template) {
    final isSelected = _selectedMetroTemplate?.id == template.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMetroTemplate = template;
            _initMetroSlotValues();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : AppTheme.darkBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: template.defaultBgColor,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getMetroIcon(template),
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${template.canvasSize.width.toInt()}x${template.canvasSize.height.toInt()}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppTheme.primaryColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getMetroIcon(MetroTemplate template) {
    if (template.name.contains('站名')) return Icons.subway;
    if (template.name.contains('方向')) return Icons.signpost;
    if (template.name.contains('出口')) return Icons.exit_to_app;
    if (template.name.contains('换乘')) return Icons.sync_alt;
    if (template.name.contains('线路')) return Icons.route;
    if (template.name.contains('设施')) return Icons.wc;
    return Icons.signpost;
  }

  Widget _buildRoadTemplateList() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Text(
          '选择模板',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ...TemplatePresets.all.map((t) => _buildRoadTemplateItem(t)),
      ],
    );
  }

  Widget _buildRoadTemplateItem(TemplateLayout template) {
    final isSelected = _selectedRoadTemplate?.name == template.name;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedRoadTemplate = template;
            _roadBackgroundColor = template.defaultBgColor;
            _initRoadSlotValues();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryColor.withValues(alpha: 0.2)
                : AppTheme.darkBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : AppTheme.darkBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: template.defaultBgColor,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(Icons.signpost, size: 18, color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected
                            ? AppTheme.primaryColor
                            : AppTheme.textPrimaryDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${template.canvasSize.width.toInt()}x${template.canvasSize.height.toInt()}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: AppTheme.primaryColor,
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
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: AppTheme.darkBgSecondary,
        border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            tooltip: '返回',
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.darkBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.folder_open,
                    size: 16,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 150),
                    child: Text(
                      '$_projectName${_hasUnsavedChanges ? ' *' : ''}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_drop_down,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 18, color: Colors.white70),
                    SizedBox(width: 12),
                    Text('新建项目', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.folder_open, size: 18, color: Colors.white70),
                    SizedBox(width: 12),
                    Text('打开项目', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save, size: 18, color: Colors.white70),
                    SizedBox(width: 12),
                    Text('保存', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'saveas',
                child: Row(
                  children: [
                    Icon(Icons.save_as, size: 18, color: Colors.white70),
                    SizedBox(width: 12),
                    Text('另存为...', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18, color: Colors.white70),
                    SizedBox(width: 12),
                    Text('项目设置', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'new':
                  _newProject();
                  break;
                case 'open':
                  _openProject();
                  break;
                case 'save':
                  _saveProject();
                  break;
                case 'saveas':
                  _saveProjectAs();
                  break;
                case 'settings':
                  _showProjectSettings();
                  break;
              }
            },
          ),
          const SizedBox(width: 12),
          if (_editorMode == EditorMode.metro)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _cityConfig.defaultBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _cityConfig.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else if (_selectedRoadTemplate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _roadBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _selectedRoadTemplate!.name,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _exportImage,
            icon: const Icon(Icons.download, size: 18),
            label: const Text('导出PNG'),
          ),
        ],
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
              child: _buildCanvasContent(constraints.biggest),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCanvasContent(Size size) {
    if (_editorMode == EditorMode.metro && _selectedMetroTemplate != null) {
      return CustomPaint(
        size: size,
        painter: MetroTemplatePainter(
          template: _selectedMetroTemplate!,
          slotValues: _metroSlotValues,
          cityConfig: _cityConfig,
          selectedSlotId: _selectedMetroSlotId,
        ),
      );
    } else if (_editorMode == EditorMode.road &&
        _selectedRoadTemplate != null) {
      return CustomPaint(
        size: size,
        painter: TemplatePainter(
          template: _selectedRoadTemplate!,
          slotValues: _roadSlotValues,
          backgroundColor: _roadBackgroundColor,
          selectedSlotId: _selectedRoadSlotId,
        ),
      );
    }
    return const Center(
      child: Text('请选择模板', style: TextStyle(color: AppTheme.textSecondaryDark)),
    );
  }

  void _handleCanvasTap(Offset position, Size containerSize) {
    if (_editorMode == EditorMode.metro && _selectedMetroTemplate != null) {
      final canvasPos = _screenToCanvas(
        position,
        containerSize,
        _selectedMetroTemplate!.canvasSize,
      );
      String? hitSlotId;
      for (final slot in _selectedMetroTemplate!.slots) {
        if (slot.editable && _isPointInSlot(canvasPos, slot)) {
          hitSlotId = slot.id;
          break;
        }
      }
      setState(() => _selectedMetroSlotId = hitSlotId);
    } else if (_editorMode == EditorMode.road &&
        _selectedRoadTemplate != null) {
      final canvasPos = _screenToCanvas(
        position,
        containerSize,
        _selectedRoadTemplate!.canvasSize,
      );
      String? hitSlotId;
      for (final slot in _selectedRoadTemplate!.slots) {
        if (slot.editable && _isPointInTemplateSlot(canvasPos, slot)) {
          hitSlotId = slot.id;
          break;
        }
      }
      setState(() => _selectedRoadSlotId = hitSlotId);
    }
  }

  Offset _screenToCanvas(
    Offset screenPos,
    Size containerSize,
    Size canvasSize,
  ) {
    final scaleX = containerSize.width / canvasSize.width;
    final scaleY = containerSize.height / canvasSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    final offsetX = (containerSize.width - canvasSize.width * scale) / 2;
    final offsetY = (containerSize.height - canvasSize.height * scale) / 2;
    return Offset(
      (screenPos.dx - offsetX) / scale,
      (screenPos.dy - offsetY) / scale,
    );
  }

  bool _isPointInSlot(Offset point, MetroSlot slot) {
    return point.dx >= slot.position.dx &&
        point.dx <= slot.position.dx + slot.size.width &&
        point.dy >= slot.position.dy &&
        point.dy <= slot.position.dy + slot.size.height;
  }

  bool _isPointInTemplateSlot(Offset point, TemplateSlot slot) {
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
          if (_currentFilePath != null)
            Expanded(
              child: Text(
                _currentFilePath!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondaryDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Expanded(
              child: Text(
                '新建项目 - 点击左上角菜单保存',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondaryDark,
                ),
              ),
            ),
          if (_editorMode == EditorMode.metro && _selectedMetroTemplate != null)
            Text(
              '${_selectedMetroTemplate!.name} ${_selectedMetroTemplate!.canvasSize.width.toInt()}x${_selectedMetroTemplate!.canvasSize.height.toInt()}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryDark,
              ),
            ),
          if (_editorMode == EditorMode.road && _selectedRoadTemplate != null)
            Text(
              '${_selectedRoadTemplate!.name} ${_selectedRoadTemplate!.canvasSize.width.toInt()}x${_selectedRoadTemplate!.canvasSize.height.toInt()}',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryDark,
              ),
            ),
          if (_hasUnsavedChanges) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '未保存',
                style: TextStyle(fontSize: 10, color: Colors.orange),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Container(
      width: 340,
      color: AppTheme.darkBgSecondary,
      child: Column(
        children: [
          _buildPropertyHeader('编辑内容'),
          Expanded(
            child: _editorMode == EditorMode.metro
                ? _buildMetroEditPanel()
                : _buildRoadEditPanel(),
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

  Widget _buildMetroEditPanel() {
    if (_selectedMetroTemplate == null) {
      return const Center(
        child: Text(
          '请选择模板',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMetroColorPresets(),
          const SizedBox(height: 24),
          ..._selectedMetroTemplate!.slots
              .where((s) => s.editable)
              .map((slot) => _buildMetroSlotEditor(slot)),
        ],
      ),
    );
  }

  Widget _buildMetroColorPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '城市风格',
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
          children: MetroCityConfig.all.map((city) {
            final isSelected = _selectedCity == city.style;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedCity = city.style;
                  _cityConfig = city;
                  _selectedMetroTemplate =
                      MetroTemplatePresets.getByCity(_selectedCity).firstWhere(
                        (t) => t.id == _selectedMetroTemplate?.id,
                        orElse: () =>
                            MetroTemplatePresets.getByCity(_selectedCity).first,
                      );
                  _initMetroSlotValues();
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? city.defaultBgColor : AppTheme.darkBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primaryColor
                        : AppTheme.darkBorder,
                  ),
                ),
                child: Text(
                  city.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.white : AppTheme.textPrimaryDark,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMetroSlotEditor(MetroSlot slot) {
    final isSelected = _selectedMetroSlotId == slot.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedMetroSlotId = slot.id),
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
                  Icon(
                    _getSlotIcon(slot.type),
                    size: 14,
                    color: AppTheme.textSecondaryDark,
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
              if (slot.type == 'line_badge')
                _buildLineSelector(slot)
              else if (slot.type == 'arrow')
                _buildArrowSelector(slot)
              else
                _buildTextInput(slot),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getSlotIcon(String type) {
    switch (type) {
      case 'line_badge':
        return Icons.circle;
      case 'arrow':
        return Icons.arrow_forward;
      case 'exit_badge':
        return Icons.exit_to_app;
      case 'icon':
        return Icons.wc;
      default:
        return Icons.text_fields;
    }
  }

  Widget _buildLineSelector(MetroSlot slot) {
    final lines = MetroLine.getLines(_selectedCity);
    final selectedLine = _metroSlotValues[slot.id] as MetroLine?;

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: lines.take(10).map((line) {
        final isSelected =
            selectedLine?.number == line.number &&
            selectedLine?.city == line.city;
        return InkWell(
          onTap: () {
            setState(() {
              _metroSlotValues[slot.id] = line;
            });
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: line.lineColor,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: Colors.white, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '${line.number}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildArrowSelector(MetroSlot slot) {
    final directions = ['up', 'down', 'left', 'right'];
    final labels = ['↑', '↓', '←', '→'];
    final currentDir = slot.arrowDirection ?? 'right';

    return Row(
      children: List.generate(4, (i) {
        final isSelected = currentDir == directions[i];
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _metroSlotValues['${slot.id}_dir'] = directions[i];
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryColor
                    : AppTheme.darkBgSecondary,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryColor
                      : AppTheme.darkBorder,
                ),
              ),
              child: Center(
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : AppTheme.textPrimaryDark,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextInput(MetroSlot slot) {
    return TextField(
      style: const TextStyle(fontSize: 14, color: AppTheme.textPrimaryDark),
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
      controller: TextEditingController(
        text: _metroSlotValues[slot.id]?.toString() ?? '',
      ),
      onChanged: (v) {
        setState(() {
          _metroSlotValues[slot.id] = v;
        });
      },
    );
  }

  Widget _buildRoadEditPanel() {
    if (_selectedRoadTemplate == null) {
      return const Center(
        child: Text(
          '请选择模板',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRoadColorPresets(),
          const SizedBox(height: 24),
          ..._selectedRoadTemplate!.slots
              .where((s) => s.editable)
              .map((slot) => _buildRoadSlotEditor(slot)),
        ],
      ),
    );
  }

  Widget _buildRoadColorPresets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '背景配色',
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
          ],
        ),
      ],
    );
  }

  Widget _buildColorPreset(String name, Color color) {
    final isSelected = _roadBackgroundColor == color;
    return InkWell(
      onTap: () => setState(() => _roadBackgroundColor = color),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 70,
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
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildRoadSlotEditor(TemplateSlot slot) {
    final isSelected = _selectedRoadSlotId == slot.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _selectedRoadSlotId = slot.id),
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
                controller: TextEditingController(
                  text: _roadSlotValues[slot.id] ?? '',
                ),
                onChanged: (v) {
                  setState(() {
                    _roadSlotValues[slot.id] = v;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportImage() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('导出功能开发中...')));
  }

  void _newProject() {
    if (_hasUnsavedChanges) {
      _showUnsavedChangesDialog().then((result) {
        if (result == true) {
          _saveProject().then((saved) {
            if (saved) _doNewProject();
          });
        } else if (result == false) {
          _doNewProject();
        }
      });
    } else {
      _doNewProject();
    }
  }

  void _doNewProject() {
    setState(() {
      _projectName = '新项目';
      _currentFilePath = null;
      _editorMode = EditorMode.metro;
      _selectedCity = MetroCityStyle.shanghai;
      _cityConfig = MetroCityConfig.shanghai;
      _selectedMetroTemplate = MetroTemplatePresets.getByCity(
        _selectedCity,
      ).first;
      _metroSlotValues = {};
      _selectedMetroSlotId = null;
      _selectedRoadTemplate = null;
      _roadSlotValues = {};
      _selectedRoadSlotId = null;
      _roadBackgroundColor = const Color(0xFF059669);
      _hasUnsavedChanges = false;
    });
    _initMetroSlotValues();
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkBgSecondary,
        title: const Text('未保存的更改', style: TextStyle(color: Colors.white)),
        content: const Text(
          '当前项目有未保存的更改，是否要保存？',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('不保存'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  Future<bool> _openProject() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['ved', 'json'],
        dialogTitle: '打开项目',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;

        setState(() {
          _projectName = json['name'] as String? ?? '新项目';
          _currentFilePath = file.path;
          _hasUnsavedChanges = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('项目已打开'),
              backgroundColor: AppTheme.primaryColor,
            ),
          );
        }
        return true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开文件失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
    return false;
  }

  Future<bool> _saveProject() async {
    try {
      String? filePath = _currentFilePath;

      if (filePath == null) {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: '保存项目',
          fileName: '$_projectName.ved',
          allowedExtensions: ['ved'],
          type: FileType.custom,
        );

        if (result == null) return false;
        filePath = result.endsWith('.ved') ? result : '$result.ved';
      }

      final json = {
        'name': _projectName,
        'version': '1.0.0',
        'editorMode': _editorMode.name,
        'city': _selectedCity.name,
        'metroTemplateId': _selectedMetroTemplate?.id ?? '',
        'metroSlotValues': _metroSlotValues,
        'roadTemplateId': _selectedRoadTemplate?.name ?? '',
        'roadSlotValues': _roadSlotValues,
        'roadBackgroundColor': _colorToHex(_roadBackgroundColor),
        'savedAt': DateTime.now().toIso8601String(),
      };

      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      setState(() {
        _currentFilePath = filePath;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('项目已保存到: $filePath'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  Future<bool> _saveProjectAs() async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '另存为',
        fileName: '$_projectName.ved',
        allowedExtensions: ['ved'],
        type: FileType.custom,
      );

      if (result == null) return false;

      String filePath = result.endsWith('.ved') ? result : '$result.ved';

      final json = {
        'name': _projectName,
        'version': '1.0.0',
        'editorMode': _editorMode.name,
        'city': _selectedCity.name,
        'metroTemplateId': _selectedMetroTemplate?.id ?? '',
        'metroSlotValues': _metroSlotValues,
        'roadTemplateId': _selectedRoadTemplate?.name ?? '',
        'roadSlotValues': _roadSlotValues,
        'roadBackgroundColor': _colorToHex(_roadBackgroundColor),
        'savedAt': DateTime.now().toIso8601String(),
      };

      final file = File(filePath);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );

      setState(() {
        _currentFilePath = filePath;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('项目已保存到: $filePath'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('另存失败: $e'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  void _showProjectSettings() {
    final nameController = TextEditingController(text: _projectName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkBgSecondary,
        title: const Text('项目设置', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: '项目名称',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.darkBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isEmpty) return;
              setState(() {
                _projectName = nameController.text.trim();
                _hasUnsavedChanges = true;
              });
              Navigator.pop(context);
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  String _colorToHex(Color color) {
    final argb = color.toARGB32().toRadixString(16).padLeft(8, '0');
    return '#${argb.substring(2)}';
  }
}

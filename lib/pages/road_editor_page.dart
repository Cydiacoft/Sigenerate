import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/templates.dart';
import '../painters/template_painter.dart';
import '../theme/app_theme.dart';

class RoadEditorPage extends StatefulWidget {
  const RoadEditorPage({super.key});

  @override
  State<RoadEditorPage> createState() => _RoadEditorPageState();
}

class _RoadEditorPageState extends State<RoadEditorPage> {
  String? _currentFilePath;
  String _projectName = '新项目';
  bool _hasUnsavedChanges = false;

  TemplateLayout? _selectedTemplate;
  Map<String, String> _slotValues = {};
  String? _selectedSlotId;
  Color _backgroundColor = const Color(0xFF059669);

  @override
  void initState() {
    super.initState();
    _selectedTemplate = TemplatePresets.all.first;
    _initSlotValues();
  }

  void _initSlotValues() {
    _slotValues = {};
    for (final slot in _selectedTemplate?.slots ?? []) {
      _slotValues[slot.id] = '';
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
      width: 260,
      color: AppTheme.darkBgSecondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              '选择模板',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: TemplatePresets.all.length,
              itemBuilder: (context, index) {
                final template = TemplatePresets.all[index];
                final isSelected = _selectedTemplate?.name == template.name;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTemplate = template;
                        _backgroundColor = template.defaultBgColor;
                        _initSlotValues();
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
                          color: isSelected
                              ? AppTheme.primaryColor
                              : AppTheme.darkBorder,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withValues(
                                    alpha: 0.2,
                                  ),
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
                              child: Icon(
                                Icons.signpost,
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
              },
            ),
          ),
        ],
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
                    Icon(Icons.add, size: 18),
                    SizedBox(width: 12),
                    Text('新建项目'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'open',
                child: Row(
                  children: [
                    Icon(Icons.folder_open, size: 18),
                    SizedBox(width: 12),
                    Text('打开项目'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.save, size: 18),
                    SizedBox(width: 12),
                    Text('保存'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'saveas',
                child: Row(
                  children: [
                    Icon(Icons.save_as, size: 18),
                    SizedBox(width: 12),
                    Text('另存为...'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 18),
                    SizedBox(width: 12),
                    Text('项目设置'),
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
          if (_selectedTemplate != null)
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
    if (_selectedTemplate == null) {
      return const Center(
        child: Text(
          '请选择模板',
          style: TextStyle(color: AppTheme.textSecondaryDark),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          size: Size.infinite,
          painter: TemplatePainter(
            template: _selectedTemplate!,
            slotValues: _slotValues,
            backgroundColor: _backgroundColor,
            selectedSlotId: _selectedSlotId,
          ),
        ),
      ),
    );
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
          Expanded(
            child: Text(
              _currentFilePath ?? '新建项目 - 点击左上角菜单保存',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondaryDark,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (_selectedTemplate != null)
            Text(
              '${_selectedTemplate!.name} ${_selectedTemplate!.canvasSize.width.toInt()}x${_selectedTemplate!.canvasSize.height.toInt()}',
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
    if (_selectedTemplate == null) {
      return Container(
        width: 300,
        color: AppTheme.darkBgSecondary,
        child: const Center(
          child: Text(
            '请选择模板',
            style: TextStyle(color: AppTheme.textSecondaryDark),
          ),
        ),
      );
    }

    return Container(
      width: 300,
      color: AppTheme.darkBgSecondary,
      child: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.darkBorder)),
            ),
            child: const Row(
              children: [
                Text(
                  '编辑内容',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimaryDark,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildColorPresets(),
                  const SizedBox(height: 24),
                  ..._selectedTemplate!.slots.map(
                    (slot) => _buildSlotEditor(slot),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPresets() {
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
    final isSelected = _backgroundColor == color;
    return InkWell(
      onTap: () => setState(() {
        _backgroundColor = color;
        _hasUnsavedChanges = true;
      }),
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

  Widget _buildSlotEditor(TemplateSlot slot) {
    final isSelected = _selectedSlotId == slot.id;
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
                  text: _slotValues[slot.id] ?? '',
                ),
                onChanged: (v) => setState(() {
                  _slotValues[slot.id] = v;
                  _hasUnsavedChanges = true;
                }),
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
    setState(() {
      _projectName = '新项目';
      _currentFilePath = null;
      _selectedTemplate = TemplatePresets.all.first;
      _initSlotValues();
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _openProject() async {
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('项目已打开')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('打开失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveProject() async {
    try {
      String? filePath = _currentFilePath;
      if (filePath == null) {
        final result = await FilePicker.platform.saveFile(
          dialogTitle: '保存项目',
          fileName: '$_projectName.ved',
          allowedExtensions: ['ved'],
          type: FileType.custom,
        );
        if (result == null) return;
        filePath = result.endsWith('.ved') ? result : '$result.ved';
      }

      final json = {
        'name': _projectName,
        'version': '1.0.0',
        'templateName': _selectedTemplate?.name ?? '',
        'slotValues': _slotValues,
        'backgroundColor': _colorToHex(_backgroundColor),
        'savedAt': DateTime.now().toIso8601String(),
      };

      await File(
        filePath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));

      setState(() {
        _currentFilePath = filePath;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已保存到: $filePath')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _saveProjectAs() async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: '另存为',
        fileName: '$_projectName.ved',
        allowedExtensions: ['ved'],
        type: FileType.custom,
      );
      if (result == null) return;

      String filePath = result.endsWith('.ved') ? result : '$result.ved';

      final json = {
        'name': _projectName,
        'version': '1.0.0',
        'templateName': _selectedTemplate?.name ?? '',
        'slotValues': _slotValues,
        'backgroundColor': _colorToHex(_backgroundColor),
        'savedAt': DateTime.now().toIso8601String(),
      };

      await File(
        filePath,
      ).writeAsString(const JsonEncoder.withIndent('  ').convert(json));

      setState(() {
        _currentFilePath = filePath;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('已保存到: $filePath')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showProjectSettings() {
    final nameController = TextEditingController(text: _projectName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkBgSecondary,
        title: const Text('项目设置', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: '项目名称',
            labelStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                setState(() {
                  _projectName = nameController.text.trim();
                  _hasUnsavedChanges = true;
                });
              }
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

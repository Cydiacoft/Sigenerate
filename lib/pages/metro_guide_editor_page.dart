import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/metro_guide_models.dart';
import '../models/metro_models.dart';
import '../theme/app_theme.dart';
import '../widgets/metro_guide_toolbar.dart';
import '../widgets/metro_guide_canvas.dart';

class MetroGuideEditorPage extends StatefulWidget {
  const MetroGuideEditorPage({super.key});

  @override
  State<MetroGuideEditorPage> createState() => _MetroGuideEditorPageState();
}

class _MetroGuideEditorPageState extends State<MetroGuideEditorPage> {
  final GlobalKey<MetroGuideCanvasState> _canvasKey = GlobalKey();

  MetroGuideProject? _currentProject;
  String? _currentFilePath;
  List<MetroGuideItem> _items = [];
  MetroCityStyle _selectedCity = MetroCityStyle.shanghai;
  String _backgroundColor = '#001D31';
  bool _hasUnsavedChanges = false;
  bool _canUndo = false;
  final bool _canRedo = false;

  @override
  void initState() {
    super.initState();
    _createNewProject();
  }

  void _createNewProject() {
    setState(() {
      _currentProject = MetroGuideProject.createNew(
        name: '新项目',
        city: _selectedCity.name,
      );
      _currentFilePath = null;
      _items = [];
      _hasUnsavedChanges = false;
    });
  }

  Future<void> _newProject() async {
    if (_hasUnsavedChanges) {
      final result = await _showUnsavedChangesDialog();
      if (result == null) return;
      if (result) {
        final saved = await _saveProject();
        if (!saved) return;
      }
    }
    _createNewProject();
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
    if (_hasUnsavedChanges) {
      final result = await _showUnsavedChangesDialog();
      if (result == null) return false;
      if (result) {
        final saved = await _saveProject();
        if (!saved) return false;
      }
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['vgp', 'json'],
        dialogTitle: '打开项目',
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final project = MetroGuideProject.fromJson(json);

        setState(() {
          _currentProject = project;
          _currentFilePath = file.path;
          _items = project.items;
          _selectedCity = MetroCityStyle.values.firstWhere(
            (s) => s.name == project.city,
            orElse: () => MetroCityStyle.shanghai,
          );
          _backgroundColor = project.backgroundColor;
          _hasUnsavedChanges = false;
        });
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
    if (_currentFilePath == null) {
      return await _saveProjectAs();
    }

    try {
      final project = _buildCurrentProject();
      final file = File(_currentFilePath!);
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(project.toJson()),
      );
      setState(() {
        _currentProject = project;
        _hasUnsavedChanges = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('项目已保存'),
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
        dialogTitle: '保存项目',
        fileName: '${_currentProject?.name ?? '新项目'}.vgp',
        allowedExtensions: ['vgp'],
        type: FileType.custom,
      );

      if (result != null) {
        String filePath = result;
        if (!filePath.endsWith('.vgp')) {
          filePath = '$filePath.vgp';
        }

        final project = _buildCurrentProject();
        final file = File(filePath);
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(project.toJson()),
        );
        setState(() {
          _currentProject = project;
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e'), backgroundColor: Colors.red),
        );
      }
    }
    return false;
  }

  MetroGuideProject _buildCurrentProject() {
    return MetroGuideProject(
      name: _currentProject?.name ?? '新项目',
      description: _currentProject?.description,
      city: _selectedCity.name,
      backgroundColor: _backgroundColor,
      items: _items,
      createdAt: _currentProject?.createdAt ?? DateTime.now(),
      lastModified: DateTime.now(),
    );
  }

  void _showProjectSettings() {
    final nameController = TextEditingController(
      text: _currentProject?.name ?? '',
    );
    final descController = TextEditingController(
      text: _currentProject?.description ?? '',
    );

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
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
              decoration: InputDecoration(
                labelText: '项目描述（可选）',
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
                _currentProject = _currentProject?.copyWith(
                  name: nameController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                );
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

  void _addItem(MetroGuideItem item) {
    setState(() {
      _items = [..._items, item];
      _hasUnsavedChanges = true;
    });
  }

  void _onItemsChanged(List<MetroGuideItem> items) {
    setState(() {
      _items = items;
      _hasUnsavedChanges = true;
    });
  }

  void _onEditItem(String itemId) {
    _showEditDialog(itemId);
  }

  void _onAddText() {
    _showTextDialog();
  }

  void _onAddColorBand() {
    _showColorBandDialog();
  }

  void _showEditDialog(String itemId) {
    final item = _items.firstWhere((i) => i.id == itemId);
    if (item.type == GuideItemType.line ||
        item.type == GuideItemType.cls ||
        item.type == GuideItemType.clss) {
      _showColorEditDialog(item);
    } else if (item.type == GuideItemType.text ||
        item.fileName.contains('text')) {
      _showTextEditDialog(item);
    } else if (item.type == GuideItemType.sub) {
      _showColorBandEditDialog(item);
    }
  }

  void _showTextDialog() {
    final cnController = TextEditingController();
    final enController = TextEditingController();
    TextAlignment alignment = TextAlignment.start;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkBgSecondary,
          title: const Text('添加文本框', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cnController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '中文文本',
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
              const SizedBox(height: 16),
              TextField(
                controller: enController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '英文文本',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('对齐:', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('左'),
                    selected: alignment == TextAlignment.start,
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() => alignment = TextAlignment.start);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('中'),
                    selected: alignment == TextAlignment.middle,
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() => alignment = TextAlignment.middle);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('右'),
                    selected: alignment == TextAlignment.end,
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() => alignment = TextAlignment.end);
                      }
                    },
                  ),
                ],
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
                final item = MetroGuideItem(
                  fileName: 'text@custom.svg',
                  type: GuideItemType.text,
                  customText: CustomText(
                    cn: cnController.text,
                    en: enController.text,
                    alignment: alignment,
                  ),
                );
                _addItem(item);
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorBandDialog() {
    String selectedColor = '#E4002B';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkBgSecondary,
          title: const Text('添加色带', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      '#E4002B',
                      '#A09A39',
                      '#FAC000',
                      '#008C44',
                      '#823130',
                      '#AA7F3E',
                      '#E60085',
                      '#00A1DE',
                      '#8FC2E3',
                      '#98C5A3',
                    ].map((color) {
                      final isSelected = selectedColor == color;
                      return InkWell(
                        onTap: () =>
                            setDialogState(() => selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(color),
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
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
                final item = MetroGuideItem(
                  fileName: 'sub@custom.svg',
                  type: GuideItemType.sub,
                  hasColorBand: true,
                  colorBandColor: selectedColor,
                );
                _addItem(item);
                Navigator.pop(context);
              },
              child: const Text('添加'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextEditDialog(MetroGuideItem item) {
    final cnController = TextEditingController(text: item.customText?.cn ?? '');
    final enController = TextEditingController(text: item.customText?.en ?? '');
    TextAlignment alignment = item.customText?.alignment ?? TextAlignment.start;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkBgSecondary,
          title: const Text('编辑文本', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: cnController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '中文文本',
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
              const SizedBox(height: 16),
              TextField(
                controller: enController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: '英文文本',
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
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('对齐:', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 16),
                  ChoiceChip(
                    label: const Text('左'),
                    selected: alignment == TextAlignment.start,
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() => alignment = TextAlignment.start);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('中'),
                    selected: alignment == TextAlignment.middle,
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() => alignment = TextAlignment.middle);
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('右'),
                    selected: alignment == TextAlignment.end,
                    onSelected: (selected) {
                      if (selected) {
                        setDialogState(() => alignment = TextAlignment.end);
                      }
                    },
                  ),
                ],
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
                final index = _items.indexWhere((i) => i.id == item.id);
                if (index != -1) {
                  final updatedItem = item.copyWith(
                    customText: CustomText(
                      cn: cnController.text,
                      en: enController.text,
                      alignment: alignment,
                    ),
                  );
                  final newItems = List<MetroGuideItem>.from(_items);
                  newItems[index] = updatedItem;
                  _onItemsChanged(newItems);
                }
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorEditDialog(MetroGuideItem item) {
    String selectedColor = item.customColor ?? '#E4002B';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkBgSecondary,
          title: const Text('更改颜色', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      '#E4002B',
                      '#A09A39',
                      '#FAC000',
                      '#008C44',
                      '#823130',
                      '#AA7F3E',
                      '#E60085',
                      '#00A1DE',
                      '#8FC2E3',
                      '#98C5A3',
                      '#DA81A6',
                      '#5F6D3F',
                      '#8E3700',
                      '#4D3700',
                      '#BF83BC',
                      '#7D8B2F',
                      '#6D4C7D',
                      '#B75700',
                    ].map((color) {
                      final isSelected = selectedColor == color;
                      return InkWell(
                        onTap: () =>
                            setDialogState(() => selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(color),
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
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
                final index = _items.indexWhere((i) => i.id == item.id);
                if (index != -1) {
                  final updatedItem = item.copyWith(customColor: selectedColor);
                  final newItems = List<MetroGuideItem>.from(_items);
                  newItems[index] = updatedItem;
                  _onItemsChanged(newItems);
                }
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorBandEditDialog(MetroGuideItem item) {
    String selectedColor = item.colorBandColor ?? '#E4002B';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.darkBgSecondary,
          title: const Text('编辑色带', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '选择色带颜色',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    [
                      '#E4002B',
                      '#A09A39',
                      '#FAC000',
                      '#008C44',
                      '#823130',
                      '#AA7F3E',
                      '#E60085',
                      '#00A1DE',
                      '#8FC2E3',
                      '#98C5A3',
                    ].map((color) {
                      final isSelected = selectedColor == color;
                      return InkWell(
                        onTap: () =>
                            setDialogState(() => selectedColor = color),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _parseColor(color),
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 2)
                                : null,
                          ),
                        ),
                      );
                    }).toList(),
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
                final index = _items.indexWhere((i) => i.id == item.id);
                if (index != -1) {
                  final updatedItem = item.copyWith(
                    colorBandColor: selectedColor,
                  );
                  final newItems = List<MetroGuideItem>.from(_items);
                  newItems[index] = updatedItem;
                  _onItemsChanged(newItems);
                }
                Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorStr) {
    try {
      if (colorStr.startsWith('#')) {
        final hex = colorStr.substring(1);
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        }
      }
      return const Color(0xFF001D31);
    } catch (e) {
      return const Color(0xFF001D31);
    }
  }

  void _undo() {
    _canvasKey.currentState?.undo();
  }

  void _redo() {
    _canvasKey.currentState?.redo();
  }

  void _clearCanvas() {
    if (_items.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.darkBgSecondary,
        title: const Text('清空画板', style: TextStyle(color: Colors.white)),
        content: const Text(
          '确定要清空画板吗？此操作无法撤销。',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              _onItemsChanged([]);
              Navigator.pop(context);
            },
            child: const Text('清空'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          MetroGuideToolbar(
            onAddItem: _addItem,
            onEditItem: _onEditItem,
            onAddText: _onAddText,
            onAddColorBand: _onAddColorBand,
          ),
          Expanded(
            child: Container(
              color: AppTheme.darkBg,
              child: Column(
                children: [
                  _buildToolbar(),
                  Expanded(
                    child: MetroGuideCanvas(
                      key: _canvasKey,
                      items: _items,
                      onItemsChanged: _onItemsChanged,
                      onEditItem: _onEditItem,
                      onHistoryChanged: (canUndo) {
                        setState(() {
                          _canUndo = canUndo;
                        });
                      },
                    ),
                  ),
                  _buildStatusBar(),
                ],
              ),
            ),
          ),
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
                      _currentProject?.name ?? '新项目',
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _parseColor(_backgroundColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getCityName(_selectedCity),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          _buildToolbarButton(
            icon: Icons.undo,
            tooltip: '撤销 (Ctrl+Z)',
            onPressed: _canUndo ? _undo : null,
          ),
          _buildToolbarButton(
            icon: Icons.redo,
            tooltip: '重做 (Ctrl+Shift+Z)',
            onPressed: _canRedo ? _redo : null,
          ),
          Container(
            width: 1,
            height: 24,
            color: AppTheme.darkBorder,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          _buildToolbarButton(
            icon: Icons.delete_outline,
            tooltip: '清空画板',
            onPressed: _items.isNotEmpty ? _clearCanvas : null,
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String tooltip,
    VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: 20,
          color: onPressed != null ? Colors.white70 : Colors.white24,
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
          Text(
            '${_items.length} 个元素',
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

  String _getCityName(MetroCityStyle style) {
    switch (style) {
      case MetroCityStyle.shanghai:
        return '上海地铁';
      case MetroCityStyle.guangzhou:
        return '广州地铁';
      case MetroCityStyle.mtr:
        return '港铁 MTR';
    }
  }
}

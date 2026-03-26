import 'package:flutter/material.dart';

import '../models/intersection_scene.dart';
import '../models/traffic_sign.dart';
import '../painters/road_sign_painter.dart';
import '../painters/traffic_sign_painter.dart';
import '../signs/gb5768_signs.dart';
import '../theme/app_theme.dart';
import '../utils/export_utils.dart';

class RoadEditorPage extends StatefulWidget {
  const RoadEditorPage({super.key});

  @override
  State<RoadEditorPage> createState() => _RoadEditorPageState();
}

class _RoadEditorPageState extends State<RoadEditorPage> {
  final GlobalKey _northKey = GlobalKey();
  final GlobalKey _eastKey = GlobalKey();
  final GlobalKey _southKey = GlobalKey();
  final GlobalKey _westKey = GlobalKey();

  IntersectionScene _scene = IntersectionScene(
    name: '学院路与滨江大道交叉口',
    north: DirectionInfo(
      roadName: '学院路',
      destination: '高铁站',
      signIds: ['pro-stop', 'warn-pedestrian', 'ind-hospital'],
    ),
    east: DirectionInfo(
      roadName: '滨江大道',
      roadType: RoadType.highway,
      destination: '高速入口',
      destinationType: DestinationType.highway,
      signIds: ['man-straight', 'info-expressway'],
    ),
    south: DirectionInfo(
      roadName: '学院路',
      destination: '老城中心',
      signIds: ['pro-no-parking', 'warn-children'],
    ),
    west: DirectionInfo(
      roadName: '滨江大道',
      roadType: RoadType.scenic,
      destination: '湿地公园',
      destinationType: DestinationType.scenic,
      signIds: ['warn-crossroad', 'info-tourist'],
    ),
  );

  String _activeDirection = 'north';
  SignCategory _activeCategory = SignCategory.prohibition;

  late final TextEditingController _nameController;
  final Map<String, TextEditingController> _roadControllers = {};
  final Map<String, TextEditingController> _destinationControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _scene.name);
    for (final entry in _scene.directions.entries) {
      _roadControllers[entry.key] = TextEditingController(
        text: entry.value.roadName,
      );
      _destinationControllers[entry.key] = TextEditingController(
        text: entry.value.destination,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final controller in _roadControllers.values) {
      controller.dispose();
    }
    for (final controller in _destinationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: Column(
          children: [
            _buildToolbar(context),
            Expanded(
              child: Row(
                children: [
                  _buildConfigPanel(),
                  Expanded(child: _buildPreviewArea()),
                  _buildLibraryPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(bottom: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            tooltip: '返回',
          ),
          const SizedBox(width: 8),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '道路编辑器',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '参考 lupai 交互重构，路标元素按 GB 5768.2-2022 分类',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _exportAllSigns,
            icon: const Icon(Icons.download),
            label: const Text('导出全部 PNG'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigPanel() {
    final info = _scene.directionInfo(_activeDirection);
    return Container(
      width: 360,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(right: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('基础设置', '按参考页改成路口配置驱动，而不是旧模板编辑。'),
            const SizedBox(height: 14),
            TextField(
              controller: _nameController,
              decoration: _inputDecoration('路口名称', '例如：学院路与滨江大道交叉口'),
              onChanged: (value) {
                setState(() {
                  _scene = _scene.copyWith(name: value);
                });
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<IntersectionShape>(
              initialValue: _scene.intersectionShape,
              decoration: _inputDecoration('路口形状', ''),
              dropdownColor: const Color(0xFF0F172A),
              items: IntersectionShape.values.map((shape) {
                return DropdownMenuItem(
                  value: shape,
                  child: Text(_shapeLabel(shape)),
                );
              }).toList(),
              onChanged: (shape) {
                if (shape == null) {
                  return;
                }
                setState(() {
                  _scene = _scene.copyWith(intersectionShape: shape);
                });
              },
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('中文方向词'),
                  selected: _scene.useChineseDirection,
                  onSelected: (selected) {
                    setState(() {
                      _scene = _scene.copyWith(useChineseDirection: selected);
                    });
                  },
                ),
                FilterChip(
                  label: const Text('英文方向词'),
                  selected: _scene.useEnglishDirection,
                  onSelected: (selected) {
                    setState(() {
                      _scene = _scene.copyWith(useEnglishDirection: selected);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('方向配置', '和参考页一致，按四个方向分别录入道路与通往地点。'),
            const SizedBox(height: 14),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'north', label: Text('北')),
                ButtonSegment(value: 'east', label: Text('东')),
                ButtonSegment(value: 'south', label: Text('南')),
                ButtonSegment(value: 'west', label: Text('西')),
              ],
              selected: {_activeDirection},
              onSelectionChanged: (selection) {
                setState(() {
                  _activeDirection = selection.first;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _roadControllers[_activeDirection],
              decoration: _inputDecoration('道路名称', '例如：学院路'),
              onChanged: (value) => _updateDirection(
                _activeDirection,
                info.copyWith(roadName: value),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<RoadType>(
              key: ValueKey('roadType-$_activeDirection-${info.roadType.name}'),
              initialValue: info.roadType,
              decoration: _inputDecoration('道路类型', ''),
              dropdownColor: const Color(0xFF0F172A),
              items: RoadType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_roadTypeLabel(type)),
                );
              }).toList(),
              onChanged: (type) {
                if (type == null) {
                  return;
                }
                _updateDirection(
                  _activeDirection,
                  info.copyWith(roadType: type),
                );
              },
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _destinationControllers[_activeDirection],
              decoration: _inputDecoration('通往地点', '例如：高铁站 / 高速入口 / 湿地公园'),
              onChanged: (value) => _updateDirection(
                _activeDirection,
                info.copyWith(destination: value),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<DestinationType>(
              key: ValueKey(
                'destinationType-$_activeDirection-${info.destinationType.name}',
              ),
              initialValue: info.destinationType,
              decoration: _inputDecoration('地点类型', ''),
              dropdownColor: const Color(0xFF0F172A),
              items: DestinationType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(_destinationTypeLabel(type)),
                );
              }).toList(),
              onChanged: (type) {
                if (type == null) {
                  return;
                }
                _updateDirection(
                  _activeDirection,
                  info.copyWith(destinationType: type),
                );
              },
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('配色约束', '普通道路蓝底白字，高速绿底白字，景区棕底白字。'),
            const SizedBox(height: 12),
            _buildColorHint('普通道路', _scene.backgroundColor),
            _buildColorHint('高速道路', _scene.highwayColor),
            _buildColorHint('景区道路', _scene.scenicColor),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewArea() {
    return Container(
      color: const Color(0xFF0B1120),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSceneCard(),
            const SizedBox(height: 20),
            _buildPreviewGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '路口总览',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _scene.name.isEmpty ? '未命名路口' : _scene.name,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 2.3,
            child: CustomPaint(
              painter: IntersectionOverviewPainter(scene: _scene),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewGrid() {
    final cards = [
      ('north', '北向', _northKey),
      ('east', '东向', _eastKey),
      ('south', '南向', _southKey),
      ('west', '西向', _westKey),
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: cards.map((card) {
        return _buildDirectionPreviewCard(card.$1, card.$2, card.$3);
      }).toList(),
    );
  }

  Widget _buildDirectionPreviewCard(
    String direction,
    String label,
    GlobalKey key,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _activeDirection = direction;
        });
      },
      child: Container(
        width: 340,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF111827),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _activeDirection == direction
                ? AppTheme.primaryColor
                : const Color(0xFF1F2937),
            width: _activeDirection == direction ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_scene.directionInfo(direction).signIds.length} 个路标元素',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 14),
            RepaintBoundary(
              key: key,
              child: AspectRatio(
                aspectRatio: 0.85,
                child: CustomPaint(
                  painter: RoadSignPainter(scene: _scene, direction: direction),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryPanel() {
    final activeInfo = _scene.directionInfo(_activeDirection);
    final categorySigns =
        Gb5768Signs.groupedByCategory[_activeCategory] ?? const [];

    return Container(
      width: 360,
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        border: Border(left: BorderSide(color: Color(0xFF1F2937))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '路标元素库',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '当前挂接方向：${_directionName(_activeDirection)}',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SignCategory.values.map((category) {
                    return ChoiceChip(
                      label: Text(_categoryLabel(category)),
                      selected: _activeCategory == category,
                      onSelected: (_) {
                        setState(() {
                          _activeCategory = category;
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          if (activeInfo.signIds.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: activeInfo.signIds.map((id) {
                  final sign = Gb5768Signs.findById(id);
                  if (sign == null) {
                    return const SizedBox.shrink();
                  }
                  return InputChip(
                    label: Text(sign.name),
                    onDeleted: () => _toggleSign(id),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.88,
              ),
              itemCount: categorySigns.length,
              itemBuilder: (context, index) {
                final sign = categorySigns[index];
                final isSelected = activeInfo.signIds.contains(sign.id);
                return InkWell(
                  onTap: () => _toggleSign(sign.id),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor
                            : const Color(0xFF253046),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: CustomPaint(
                              painter: TrafficSignPainter(
                                sign: sign,
                                scale: 0.92,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                        Text(
                          sign.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sign.code,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
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

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildColorHint(String title, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint.isEmpty ? null : hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      filled: true,
      fillColor: const Color(0xFF0F172A),
    );
  }

  void _updateDirection(String direction, DirectionInfo info) {
    setState(() {
      switch (direction) {
        case 'north':
          _scene = _scene.copyWith(north: info);
          break;
        case 'east':
          _scene = _scene.copyWith(east: info);
          break;
        case 'south':
          _scene = _scene.copyWith(south: info);
          break;
        case 'west':
          _scene = _scene.copyWith(west: info);
          break;
      }
    });
  }

  void _toggleSign(String signId) {
    final info = _scene.directionInfo(_activeDirection);
    final updatedIds = List<String>.from(info.signIds);
    if (updatedIds.contains(signId)) {
      updatedIds.remove(signId);
    } else {
      updatedIds.add(signId);
    }
    _updateDirection(_activeDirection, info.copyWith(signIds: updatedIds));
  }

  Future<void> _exportAllSigns() async {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('正在导出 PNG...')));

    final paths = await ExportUtils.exportAllSigns(
      _northKey,
      _eastKey,
      _southKey,
      _westKey,
      _scene,
    );

    if (!mounted) {
      return;
    }

    if (paths.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('导出失败')));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已导出 ${paths.length} 个 PNG 到文档目录 traffic_signs')),
    );
  }

  String _directionName(String direction) {
    return switch (direction) {
      'north' => '北向',
      'east' => '东向',
      'south' => '南向',
      'west' => '西向',
      _ => '北向',
    };
  }

  String _roadTypeLabel(RoadType type) {
    return switch (type) {
      RoadType.general => '普通道路',
      RoadType.highway => '高速道路',
      RoadType.scenic => '景区道路',
    };
  }

  String _destinationTypeLabel(DestinationType type) {
    return switch (type) {
      DestinationType.general => '普通',
      DestinationType.highway => '高速',
      DestinationType.scenic => '景区',
    };
  }

  String _shapeLabel(IntersectionShape shape) {
    return switch (shape) {
      IntersectionShape.crossroad => '十字路口',
      IntersectionShape.skewLeft => '左高右低',
      IntersectionShape.skewRight => '左低右高',
      IntersectionShape.roundabout => '环岛',
      IntersectionShape.tJunctionFrontLeft => '丁字路口(前+左)',
      IntersectionShape.tJunctionFrontRight => '丁字路口(前+右)',
      IntersectionShape.tJunctionLeftRight => '丁字路口(左+右)',
      IntersectionShape.yJunction => '三岔路口',
      IntersectionShape.diamondBridgeTop => '菱形桥(上跨)',
      IntersectionShape.diamondBridgeBottom => '菱形桥(下穿)',
    };
  }

  String _categoryLabel(SignCategory category) {
    return switch (category) {
      SignCategory.prohibition => '禁令',
      SignCategory.warning => '警告',
      SignCategory.mandatory => '指示',
      SignCategory.indication => '指路',
      SignCategory.information => '信息',
    };
  }
}

import 'package:flutter/material.dart';

import '../models/intersection_scene.dart';
import '../models/traffic_sign.dart';
import '../painters/road_sign_painter.dart';
import '../signs/gb5768_signs.dart';
import '../theme/app_theme.dart';
import '../utils/export_utils.dart';
import '../widgets/road_sign_glyph.dart';

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
  String _keyword = '';

  late final TextEditingController _nameController;
  final Map<String, TextEditingController> _roadControllers = {};
  final Map<String, TextEditingController> _destinationControllers = {};

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _scene.name);
    _syncControllers();
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

  void _syncControllers() {
    for (final entry in _scene.directions.entries) {
      _roadControllers.putIfAbsent(
        entry.key,
        () => TextEditingController(text: entry.value.roadName),
      );
      _destinationControllers.putIfAbsent(
        entry.key,
        () => TextEditingController(text: entry.value.destination),
      );
      _roadControllers[entry.key]!.text = entry.value.roadName;
      _destinationControllers[entry.key]!.text = entry.value.destination;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeInfo = _scene.directionInfo(_activeDirection);
    final categorySigns =
        Gb5768Signs.groupedByCategory[_activeCategory] ?? const <TrafficSign>[];
    final filteredSigns = categorySigns.where((sign) {
      return _keyword.trim().isEmpty ||
          sign.name.toLowerCase().contains(_keyword.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: SafeArea(
        child: Column(
          children: [
            _buildToolbar(context),
            Expanded(
              child: Row(
                children: [
                  _buildConfigPanel(activeInfo),
                  Expanded(child: _buildPreviewPanel()),
                  _buildLibraryPanel(activeInfo, filteredSigns),
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
      height: 76,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
                'SVG 素材优先渲染，逐步替换旧的手绘近似图标',
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

  Widget _buildConfigPanel(DirectionInfo info) {
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
            _buildSectionTitle('路口设置', '先定义路口，再针对当前方向细化内容。'),
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
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('中文方向词'),
                  selected: _scene.useChineseDirection,
                  onSelected: (value) {
                    setState(() {
                      _scene = _scene.copyWith(useChineseDirection: value);
                    });
                  },
                ),
                FilterChip(
                  label: const Text('英文方向词'),
                  selected: _scene.useEnglishDirection,
                  onSelected: (value) {
                    setState(() {
                      _scene = _scene.copyWith(useEnglishDirection: value);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle('当前方向', '把修改集中在当前方向，减少来回跳转。'),
            const SizedBox(height: 12),
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
              onChanged: (value) {
                _updateDirection(_activeDirection, info.copyWith(roadName: value));
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RoadType>(
              key: ValueKey('road-$_activeDirection-${info.roadType.name}'),
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
                _updateDirection(_activeDirection, info.copyWith(roadType: type));
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _destinationControllers[_activeDirection],
              decoration: _inputDecoration('通往地点', '例如：高铁站 / 高速入口 / 湿地公园'),
              onChanged: (value) {
                _updateDirection(
                  _activeDirection,
                  info.copyWith(destination: value),
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DestinationType>(
              key: ValueKey(
                'destination-$_activeDirection-${info.destinationType.name}',
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
            const SizedBox(height: 24),
            _buildSectionTitle('已选路标元素', '直接在这里删除，不用回素材库反向查找。'),
            const SizedBox(height: 12),
            _buildSelectedSigns(info),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSigns(DirectionInfo info) {
    if (info.signIds.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF1F2937)),
        ),
        child: const Text(
          '当前方向还没有添加路标元素',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: info.signIds.map((id) {
        final sign = Gb5768Signs.findById(id);
        if (sign == null) {
          return const SizedBox.shrink();
        }
        return InputChip(
          avatar: RoadSignGlyph(sign: sign, size: 24, padding: EdgeInsets.zero),
          label: Text(sign.name),
          onDeleted: () => _toggleSign(id),
        );
      }).toList(),
    );
  }

  Widget _buildPreviewPanel() {
    return Container(
      color: const Color(0xFF0B1120),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildDirectionCard('north', '北向', _northKey),
                _buildDirectionCard('east', '东向', _eastKey),
                _buildDirectionCard('south', '南向', _southKey),
                _buildDirectionCard('west', '西向', _westKey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1F2937)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _scene.name.isEmpty ? '未命名路口' : _scene.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '牌面预览仍在继续校正比例，但路标元素现在优先使用 SVG 资产。',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectionCard(String direction, String label, GlobalKey key) {
    final info = _scene.directionInfo(direction);
    final signs = info.signIds
        .map(Gb5768Signs.findById)
        .whereType<TrafficSign>()
        .toList();

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeDirection = direction;
        });
      },
      child: Container(
        width: 360,
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
                  '${signs.length} 个路标元素',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RepaintBoundary(
              key: key,
              child: AspectRatio(
                aspectRatio: 0.86,
                child: CustomPaint(
                  painter: RoadSignPainter(scene: _scene, direction: direction),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 68,
              child: signs.isEmpty
                  ? const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '未挂接路标元素',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    )
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: signs.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final sign = signs[index];
                        return Tooltip(
                          message: sign.name,
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFF253046)),
                            ),
                            child: Center(
                              child: RoadSignGlyph(
                                sign: sign,
                                size: 44,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLibraryPanel(
    DirectionInfo activeInfo,
    List<TrafficSign> filteredSigns,
  ) {
    return Container(
      width: 380,
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
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: _inputDecoration('搜索元素', '按名称过滤当前分类'),
                  onChanged: (value) {
                    setState(() {
                      _keyword = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 10),
                Text(
                  '已选 ${activeInfo.signIds.length} 个元素',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filteredSigns.length,
              itemBuilder: (context, index) {
                final sign = filteredSigns[index];
                final selected = activeInfo.signIds.contains(sign.id);
                return InkWell(
                  onTap: () => _toggleSign(sign.id),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primaryColor
                            : const Color(0xFF253046),
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: RoadSignGlyph(
                              sign: sign,
                              size: 86,
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        Text(
                          sign.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          sign.hasSvgAsset ? 'SVG 资产' : 'Fallback',
                          style: TextStyle(
                            color: sign.hasSvgAsset
                                ? const Color(0xFF86EFAC)
                                : Colors.orange,
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
      _syncControllers();
    });
  }

  void _toggleSign(String signId) {
    final info = _scene.directionInfo(_activeDirection);
    final updated = List<String>.from(info.signIds);
    if (updated.contains(signId)) {
      updated.remove(signId);
    } else {
      updated.add(signId);
    }
    _updateDirection(_activeDirection, info.copyWith(signIds: updated));
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
    switch (direction) {
      case 'north':
        return '北向';
      case 'east':
        return '东向';
      case 'south':
        return '南向';
      case 'west':
        return '西向';
      default:
        return '北向';
    }
  }

  String _roadTypeLabel(RoadType type) {
    switch (type) {
      case RoadType.general:
        return '普通道路';
      case RoadType.highway:
        return '高速道路';
      case RoadType.scenic:
        return '景区道路';
    }
  }

  String _destinationTypeLabel(DestinationType type) {
    switch (type) {
      case DestinationType.general:
        return '普通';
      case DestinationType.highway:
        return '高速';
      case DestinationType.scenic:
        return '景区';
    }
  }

  String _shapeLabel(IntersectionShape shape) {
    switch (shape) {
      case IntersectionShape.crossroad:
        return '十字路口';
      case IntersectionShape.skewLeft:
        return '左高右低';
      case IntersectionShape.skewRight:
        return '左低右高';
      case IntersectionShape.roundabout:
        return '环岛';
      case IntersectionShape.tJunctionFrontLeft:
        return '丁字路口(前+左)';
      case IntersectionShape.tJunctionFrontRight:
        return '丁字路口(前+右)';
      case IntersectionShape.tJunctionLeftRight:
        return '丁字路口(左+右)';
      case IntersectionShape.yJunction:
        return '三岔路口';
      case IntersectionShape.diamondBridgeTop:
        return '菱形桥(上跨)';
      case IntersectionShape.diamondBridgeBottom:
        return '菱形桥(下穿)';
    }
  }

  String _categoryLabel(SignCategory category) {
    switch (category) {
      case SignCategory.prohibition:
        return '禁令';
      case SignCategory.warning:
        return '警告';
      case SignCategory.mandatory:
        return '指示';
      case SignCategory.indication:
        return '指路';
      case SignCategory.information:
        return '信息';
    }
  }
}

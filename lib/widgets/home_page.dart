import 'package:flutter/material.dart';
import '../models/intersection_scene.dart';
import '../painters/road_sign_painter.dart';
import '../painters/traffic_sign_painter.dart';
import '../signs/gb5768_signs.dart';
import '../models/traffic_sign.dart';
import '../utils/export_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final IntersectionScene _scene = IntersectionScene();
  TrafficSign? _selectedSign;

  final GlobalKey _northKey = GlobalKey();
  final GlobalKey _eastKey = GlobalKey();
  final GlobalKey _southKey = GlobalKey();
  final GlobalKey _westKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('道路交通标志生成器'),
        backgroundColor: const Color(0xFF1A1A2E),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.signpost), text: '路口标志'),
            Tab(icon: Icon(Icons.warning_amber), text: '国标标志'),
            Tab(icon: Icon(Icons.settings), text: '样式设置'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildIntersectionTab(),
          _buildSignLibraryTab(),
          _buildSettingsTab(),
        ],
      ),
    );
  }

  Widget _buildIntersectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildIntersectionPreview(),
          const SizedBox(height: 24),
          _buildIntersectionConfig(),
          const SizedBox(height: 24),
          _buildDirectionCards(),
          const SizedBox(height: 24),
          _buildExportButtons(),
        ],
      ),
    );
  }

  Widget _buildIntersectionPreview() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.map, color: Color(0xFF4A90A4)),
                const SizedBox(width: 8),
                Text(
                  '路口预览 - ${_scene.name.isEmpty ? "未命名路口" : _scene.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            RepaintBoundary(
              child: CustomPaint(
                size: const Size(double.infinity, 200),
                painter: IntersectionOverviewPainter(scene: _scene),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntersectionConfig() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit, color: Color(0xFF4A90A4)),
                SizedBox(width: 8),
                Text('路口配置', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: '路口名称',
                border: OutlineInputBorder(),
                hintText: '例如: XX大道与XX路交叉口',
              ),
              onChanged: (value) {
                setState(() {
                  _scene.name = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('方向标签: '),
                const SizedBox(width: 16),
                ChoiceChip(
                  label: const Text('中文'),
                  selected: _scene.useChineseDirection,
                  onSelected: (selected) {
                    setState(() {
                      _scene.useChineseDirection = true;
                      _scene.useEnglishDirection = !selected;
                    });
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('英文'),
                  selected: _scene.useEnglishDirection,
                  onSelected: (selected) {
                    setState(() {
                      _scene.useEnglishDirection = true;
                      _scene.useChineseDirection = !selected;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '各方向道路信息',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
          children: [
            _buildDirectionCard('north', '北向', 'N', Icons.north),
            _buildDirectionCard('east', '东向', 'E', Icons.east),
            _buildDirectionCard('south', '南向', 'S', Icons.south),
            _buildDirectionCard('west', '西向', 'W', Icons.west),
          ],
        ),
      ],
    );
  }

  Widget _buildDirectionCard(String direction, String label, String abbr, IconData icon) {
    final info = _getDirectionInfo(direction);
    
    return RepaintBoundary(
      key: _getDirectionKey(direction),
      child: Card(
        elevation: 4,
        color: _scene.backgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: _scene.foregroundColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _scene.foregroundColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: CustomPaint(
                  size: const Size(double.infinity, double.infinity),
                  painter: RoadSignPainter(scene: _scene, direction: direction),
                ),
              ),
              const Divider(color: Colors.white24),
              TextField(
                style: TextStyle(color: _scene.foregroundColor),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: '道路名称',
                  labelStyle: TextStyle(color: _scene.foregroundColor.withValues(alpha: 0.7)),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: _scene.backgroundColor.withValues(alpha: 0.5),
                ),
                controller: TextEditingController(text: info.roadName),
                onChanged: (value) {
                  setState(() {
                    info.roadName = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextField(
                style: TextStyle(color: _scene.foregroundColor),
                decoration: InputDecoration(
                  isDense: true,
                  labelText: '通往地点',
                  labelStyle: TextStyle(color: _scene.foregroundColor.withValues(alpha: 0.7)),
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: _scene.backgroundColor.withValues(alpha: 0.5),
                ),
                controller: TextEditingController(text: info.destination),
                onChanged: (value) {
                  setState(() {
                    info.destination = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<RoadType>(
                      value: info.roadType,
                      decoration: InputDecoration(
                        isDense: true,
                        labelText: '道路类型',
                        labelStyle: TextStyle(color: _scene.foregroundColor.withValues(alpha: 0.7)),
                        border: const OutlineInputBorder(),
                        filled: true,
                        fillColor: _scene.backgroundColor.withValues(alpha: 0.5),
                      ),
                      dropdownColor: _scene.backgroundColor,
                      style: TextStyle(color: _scene.foregroundColor),
                      items: RoadType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getRoadTypeText(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          info.roadType = value ?? RoadType.general;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExportButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: _exportAllSigns,
          icon: const Icon(Icons.download),
          label: const Text('导出全部PNG'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90A4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSignLibraryTab() {
    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          Container(
            color: const Color(0xFF1A1A2E),
            child: const TabBar(
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white70,
              tabs: [
                Tab(text: '禁令'),
                Tab(text: '警告'),
                Tab(text: '指示'),
                Tab(text: '指路'),
                Tab(text: '信息'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildSignGrid(Gb5768Signs.prohibitionSigns),
                _buildSignGrid(Gb5768Signs.warningSigns),
                _buildSignGrid(Gb5768Signs.mandatorySigns),
                _buildSignGrid(Gb5768Signs.indicationSigns),
                _buildSignGrid(Gb5768Signs.informationSigns),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignGrid(List<TrafficSign> signs) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: signs.length,
      itemBuilder: (context, index) {
        final sign = signs[index];
        return _buildSignTile(sign);
      },
    );
  }

  Widget _buildSignTile(TrafficSign sign) {
    final isSelected = _selectedSign?.id == sign.id;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSign = sign;
        });
      },
      child: Card(
        elevation: isSelected ? 8 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? Colors.amber : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CustomPaint(
                  size: const Size(80, 80),
                  painter: TrafficSignPainter(sign: sign, scale: 0.8),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                sign.name,
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '颜色设置',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildColorSetting('背景色', _scene.backgroundColor, (color) {
            setState(() {
              _scene.backgroundColor = color;
            });
          }),
          _buildColorSetting('前景色', _scene.foregroundColor, (color) {
            setState(() {
              _scene.foregroundColor = color;
            });
          }),
          _buildColorSetting('景区色', _scene.scenicColor, (color) {
            setState(() {
              _scene.scenicColor = color;
            });
          }),
          _buildColorSetting('高速色', _scene.highwayColor, (color) {
            setState(() {
              _scene.highwayColor = color;
            });
          }),
          const SizedBox(height: 32),
          const Text(
            '关于',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '道路交通标志生成器',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('遵循 GB 5768.2-2022 国家标准'),
                  Text('支持多种路口场景'),
                  Text('可生成路口指路标志'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSetting(String label, Color color, Function(Color) onColorChanged) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: GestureDetector(
          onTap: () async {
            final newColor = await showDialog<Color>(
              context: context,
              builder: (context) => ColorPickerDialog(
                initialColor: color,
                title: label,
              ),
            );
            if (newColor != null) {
              onColorChanged(newColor);
            }
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  DirectionInfo _getDirectionInfo(String direction) {
    switch (direction) {
      case 'north':
        return _scene.north;
      case 'east':
        return _scene.east;
      case 'south':
        return _scene.south;
      case 'west':
        return _scene.west;
      default:
        return _scene.north;
    }
  }

  GlobalKey _getDirectionKey(String direction) {
    switch (direction) {
      case 'north':
        return _northKey;
      case 'east':
        return _eastKey;
      case 'south':
        return _southKey;
      case 'west':
        return _westKey;
      default:
        return _northKey;
    }
  }

  String _getRoadTypeText(RoadType type) {
    switch (type) {
      case RoadType.highway:
        return '高速';
      case RoadType.scenic:
        return '景区';
      default:
        return '一般';
    }
  }

  Future<void> _exportAllSigns() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在导出...')),
    );

    final paths = await ExportUtils.exportAllSigns(
      _northKey,
      _eastKey,
      _southKey,
      _westKey,
      _scene,
    );

    if (paths.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('已导出 ${paths.length} 个文件到文档目录'),
            action: SnackBarAction(
              label: '确定',
              onPressed: () {},
            ),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导出失败')),
        );
      }
    }
  }
}

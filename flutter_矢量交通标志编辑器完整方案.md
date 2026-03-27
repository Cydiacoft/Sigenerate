# Flutter 矢量交通标志编辑器完整方案

## 📌 项目定位
一个类似 **PPT / Figma 的轻量矢量编辑器**，用于绘制交通标志（SVG为核心）。

---

# 🧩 一、整体架构

```
UI层（Canvas + 工具栏）
↓
交互层（拖拽 / 选中 / 编辑）
↓
数据模型层（CanvasItem）
↓
渲染层（Widget / CustomPainter）
```

---

# 🧱 二、项目目录结构（推荐）

```
lib/
├── main.dart
├── core/
│   ├── models/
│   │   ├── canvas_item.dart
│   │   ├── text_item.dart
│   │   ├── svg_item.dart
│   │   └── shape_item.dart
│   ├── services/
│   │   ├── history_service.dart
│   │   ├── export_service.dart
│   │   └── import_service.dart
│   └── utils/
│       └── geometry.dart
│
├── features/
│   ├── canvas/
│   │   ├── canvas_page.dart
│   │   ├── canvas_view.dart
│   │   └── canvas_controller.dart
│   │
│   ├── editor/
│   │   ├── selection_overlay.dart
│   │   ├── transform_controls.dart
│   │   └── alignment_guides.dart
│   │
│   ├── widgets/
│   │   ├── editable_text.dart
│   │   ├── svg_widget.dart
│   │   └── shape_widget.dart
│   │
│   └── asset_panel/
│       ├── asset_sidebar.dart
│       └── draggable_item.dart
│
└── state/
    └── app_state.dart
```

---

# 🧠 三、核心数据模型

## 1. 抽象基类

```dart
abstract class CanvasItem {
  String id;
  double x;
  double y;
  double width;
  double height;
  double rotation;
  int zIndex;
}
```

## 2. 文本

```dart
class TextItem extends CanvasItem {
  String text;
  double fontSize;
  Color color;
  String fontFamily;
}
```

## 3. SVG

```dart
class SvgItem extends CanvasItem {
  String assetPath;
}
```

## 4. 图形（路口）

```dart
enum ShapeType { cross, t, y }

class ShapeItem extends CanvasItem {
  ShapeType type;
}
```

---

# 🎨 四、画布实现

```dart
Stack(
  children: [
    Container(color: Colors.blue),
    ...items.map(renderItem),
  ],
)
```

---

# ✏️ 五、文本编辑（功能1）

```dart
class EditableTextItem extends StatefulWidget {
  final TextItem model;

  const EditableTextItem(this.model);

  @override
  State createState() => _EditableTextItemState();
}

class _EditableTextItemState extends State<EditableTextItem> {
  late TextEditingController controller;

  @override
  void initState() {
    controller = TextEditingController(text: widget.model.text);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.model.x,
      top: widget.model.y,
      child: GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            widget.model.x += d.delta.dx;
            widget.model.y += d.delta.dy;
          });
        },
        child: SizedBox(
          width: widget.model.width,
          child: TextField(
            controller: controller,
            decoration: InputDecoration(border: InputBorder.none),
            onChanged: (v) => widget.model.text = v,
          ),
        ),
      ),
    );
  }
}
```

---

# 🧲 六、拖拽 SVG（功能2）

## Draggable

```dart
Draggable<SvgItem>(
  data: item,
  feedback: SvgPicture.asset(item.assetPath),
  child: SvgPicture.asset(item.assetPath),
)
```

## Canvas 接收

```dart
DragTarget<SvgItem>(
  onAccept: (item) {
    items.add(item);
  },
  builder: (_, __, ___) => Container(),
)
```

---

# ✏️ 七、路口绘制（功能3）

```dart
class RoadPainter extends CustomPainter {
  final ShapeType type;

  RoadPainter(this.type);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    if (type == ShapeType.cross) {
      canvas.drawLine(Offset(0, size.height/2), Offset(size.width, size.height/2), paint);
      canvas.drawLine(Offset(size.width/2, 0), Offset(size.width/2, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
```

---

# 🔵 八、背景初始化（功能4）

```dart
class CanvasConfig {
  final Color background;
  final Size size;
}
```

---

# 🧲 九、选中 & 变换系统

## 选中框

```dart
Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.blue),
  ),
)
```

## 缩放控制点

- 四角拖拽
- 更新 width / height

---

# 📏 十、对齐辅助线

逻辑：

```dart
if ((item.x - centerX).abs() < 5) {
  showGuideLine();
}
```

---

# 🔁 十一、撤销 / 重做

```dart
class HistoryService {
  final undoStack = <List<CanvasItem>>[];
  final redoStack = <List<CanvasItem>>[];

  void save(List<CanvasItem> state) {
    undoStack.add(clone(state));
  }

  List<CanvasItem> undo() {
    final last = undoStack.removeLast();
    redoStack.add(last);
    return last;
  }
}
```

---

# 📤 十二、导出 SVG

核心思路：

```dart
String exportSvg(List<CanvasItem> items) {
  return '''
<svg>
  ${items.map(toSvg).join()}
</svg>
''';
}
```

文本：

```xml
<text x="10" y="20">甘城路</text>
```

SVG：

```xml
<image href="xxx.svg" />
```

---

# 📸 十三、导出 PNG

```dart
RepaintBoundary(
  key: globalKey,
  child: Canvas(),
)
```

---

# 🧰 十四、状态管理（推荐 Riverpod）

```dart
final canvasProvider = StateNotifierProvider<CanvasController, List<CanvasItem>>(...);
```

---

# 🚀 十五、进阶优化

## 1. 图层系统
- zIndex排序

## 2. 网格系统
- 吸附

## 3. 字体系统
- 思源黑体 / 交通标志字体

## 4. 性能优化
- 使用 CustomPainter 批量绘制

---

# 🌐 十六、Flutter vs Web

| 方案 | 优点 | 缺点 |
|------|------|------|
| Flutter | 跨平台 | Canvas能力稍弱 |
| Web(Canvas/Fabric.js) | 更强编辑能力 | 桌面支持差 |

👉 推荐：
- 纯客户端 → Flutter
- 专业编辑器 → Web

---

# 🎯 最终总结

本项目核心 =

✔ 元素模型化
✔ 自由画布（Stack）
✔ 拖拽 + 编辑 + 渲染分离

---

# 📌 如果继续做

可以继续扩展：

- 自动排版（交通规则）
- AI生成标志
- SVG模板市场

---

**这是一个可以做到商业级的项目。**

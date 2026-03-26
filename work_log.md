# 开发工作日志 (Work Log)

## 项目概述

**项目名称**: 导视图设计器 (Traffic Sign Designer)  
**项目路径**: D:\road_creator  
**创建日期**: 2026-03-22  
**项目状态**: 开发中

## 项目目标

开发一款 Flutter Windows 应用程序，用于设计：
1. **轨道交通导视图** - 参考 railmapgen.org 样式标准
   - 上海地铁
   - 广州地铁
   - 港铁 MTR
2. **道路标志** - 参考 GB 5768.2-2022 国家标准
   - 国道、省道、县道、乡道
   - 高速公路标志
   - 方向指示牌

## 新增功能 - vi-tool 风格导向标志编辑器

### 参考项目
- **vi-tool** (https://github.com/mercutiojohn/vi-tool) - 北轨导向标志生成器
- 采用类似的拖拽式导向标志编辑模式

### 新增文件

| 文件 | 说明 |
|------|------|
| `lib/models/metro_guide_models.dart` | 导向标志数据模型 |
| `lib/widgets/metro_guide_toolbar.dart` | 左侧工具栏组件 |
| `lib/widgets/metro_guide_canvas.dart` | 水平排列画布 |
| `lib/widgets/metro_guide_item.dart` | 单个导向标志组件 |
| `lib/pages/metro_guide_editor_page.dart` | 主编辑器页面 |

### 功能特性

1. **拖拽式添加**：从左侧工具栏添加导向标志
2. **水平排列画布**：类似 vi-tool 的横向排列方式
3. **素材分类**：
   - 线路 (line@01-31)
   - 方向与站台 (way@01-26)
   - 车站设施 (stn@01-29)
   - 字母与其他 (oth@01-30, A, Dot, space, yl)
   - 色带信息 (sub@exit, text, 03-21)
   - 经典素材 (cls@01-37)
   - 经典线路标 (clss@01-31)
4. **右键菜单操作**：
   - 左移/右移
   - 复制
   - 编辑文本
   - 更改颜色
   - 删除
5. **自定义文本**：中英双语文本框，支持左/中/右对齐
6. **颜色自定义**：支持为色带和素材着色
7. **撤销/重做**：Ctrl+Z / Ctrl+Shift+Z 快捷键
8. **导入/导出配置**：JSON 格式保存到本地

## 工作记录

### 2026-03-22 (今天) - 第二部分

#### vi-tool 风格导向标志编辑器完善

**2026-03-22 更新**

1. **添加返回按钮**
   - 在工具栏左侧添加返回按钮
   - 点击可返回主页

2. **优化工具栏布局**
   - 调整标签按钮样式，增大间距
   - 改用 Row + SingleChildScrollView 替代 ListView
   - 增加按钮内边距，使标签文字完整显示
   - 修复工具栏收起按钮位置问题

3. **完善预览图标**
   - 修复工具栏图标预览显示
   - 线路：显示彩色圆形编号
   - 方向与站台：显示箭头和图标
   - 车站设施：显示设施图标
   - 色带信息：显示色带预览
   - 经典素材：显示彩色方块
   - 字母与其他：显示字母和数字

4. **工具栏布局重构**
   - 移除收起/展开按钮，固定宽度
   - 改用可折叠分类面板（ExpansionTile 风格）
   - 每个分类显示素材数量
   - 点击分类标题展开/折叠
   - 紧凑网格布局展示素材缩略图
   - 顶部新增"文本"快捷按钮

**构建状态**: `flutter build windows --release` 成功

**生成文件**: `build/windows/x64/runner/Release/traffic_sign_generator.exe`

#### 项目文件管理功能

**2026-03-22 更新**

1. **新增项目模型 (MetroGuideProject)**
   - 项目名称 (name)
   - 项目描述 (description)
   - 版本号 (version)
   - 城市样式 (city)
   - 背景颜色 (backgroundColor)
   - 导向元素列表 (items)
   - 创建时间 (createdAt)
   - 最后修改时间 (lastModified)
   - JSON 序列化/反序列化支持

2. **新增文件操作功能**
   - 新建项目 (Ctrl+N)
   - 打开项目 (Ctrl+O) - 支持 .vgp 和 .json 格式
   - 保存项目 (Ctrl+S)
   - 另存为... (Ctrl+Shift+S)
   - 项目设置（名称、描述）

3. **新增依赖**
   - file_picker: ^8.0.0+1 - 文件选择器

4. **界面改进**
   - 左上角添加项目下拉菜单
   - 显示当前项目名称
   - 状态栏显示文件路径
   - 未保存更改指示器（橙色标签）
   - 支持快捷键操作

**项目文件格式 (.vgp)**
```json
{
  "name": "项目名称",
  "description": "项目描述",
  "version": "1.0.0",
  "city": "shanghai",
  "backgroundColor": "#001D31",
  "items": [...],
  "createdAt": "2026-03-22T...",
  "lastModified": "2026-03-22T..."
}
```

#### 功能整合重构

**2026-03-22 更新**

1. **编辑器整合**
   - 轨道交通编辑器：模板模式 + 拖拽模式
   - 道路编辑器：独立的模板式编辑器
   - 移除重复的 combined_editor_page.dart

2. **新文件结构**
   | 文件 | 说明 |
   |------|------|
   | `metro_editor_page.dart` | 轨道交通编辑器（模板+拖拽） |
   | `road_editor_page.dart` | 道路编辑器 |

3. **轨道交通编辑器功能**
   - 模板模式：站名牌、方向指示牌、出口信息牌等
   - 拖拽模式：vi-tool 风格导向标志生成
   - 城市切换：上海/广州/港铁

4. **道路编辑器功能**
   - 独立模板选择
   - 背景颜色预设
   - 插槽内容编辑

5. **主页简化**
   - 两个入口：轨道交通 / 道路
   - 清晰的分类选择

#### 问题修复工作

**问题描述**:
项目存在多处类型不匹配和引用错误，主要因为：
1. 模型类名称多次重构（MetroCityConfig → MetroCityInfo, MetroLine → MetroLineInfo 等）
2. 模型类缺少必要属性（defaultBgColor, editable, label 等）
3. 页面和绘制器仍在引用旧的类名和属性

**修复内容**:

1. **metro_models.dart 更新**
   - 添加 `MetroCityStyle` 枚举（shanghai, guangzhou, mtr）
   - 在 `MetroCityInfo` 中添加 `style` 属性
   - 添加 `defaultBgColor` getter
   - 在 `MetroTemplate` 中添加 `defaultBgColor` 属性
   - 在 `MetroSlot` 中添加缺失属性：
     - `label`
     - `alignment`
     - `editable`
     - `textColor`
     - `defaultLine`
     - `arrowDirection`
     - `iconName`
   - 在 `MetroLineInfo` 中添加：
     - `lineColor` getter
     - `number` getter（alias for num）
   - 添加 `MetroLine` 类型别名
   - 添加 `MetroCityConfig` 类型别名
   - 添加 `MetroTemplatePresets` 类
   - 添加 `MetroTemplateSlot` 类

2. **metro_painter.dart 修复**
   - 更新类型引用：`MetroCityConfig` → `MetroCityInfo`
   - 修复槽位类型处理：添加对 'arrow_right', 'arrow_left', 'arrow_up', 'arrow_down' 的支持
   - 更新绘制方法参数类型：`MetroTemplateSlot` → `MetroSlot`

3. **combined_editor_page.dart 修复**
   - 修复 `_isPointInSlot` 函数参数类型
   - 修复 `_buildMetroSlotEditor` 函数参数类型
   - 修复 `_buildLineSelector` 函数参数类型
   - 修复 `_buildArrowSelector` 函数参数类型
   - 修复 `_buildTextInput` 函数参数类型

**构建验证**:
```
flutter build windows --release
```

构建成功，生成文件：
`build/windows/x64/runner/Release/traffic_sign_generator.exe`

#### 文档工作

1. **更新 README.md**
   - 项目功能介绍
   - 技术栈说明
   - 项目结构
   - 快速开始指南
   - 使用说明
   - 设计规范参考

2. **创建 work_log.md**
   - 开发工作记录
   - 问题修复详情
   - 后续开发计划

## 文件结构

```
D:\road_creator\
├── lib\
│   ├── main.dart                  # 应用入口
│   ├── models\
│   │   ├── metro_models.dart      # 轨道交通数据模型
│   │   ├── metro_guide_models.dart # 导向标志数据模型 (新增)
│   │   ├── templates.dart          # 道路标志模板
│   │   └── models.dart            # 统一模型文件
│   ├── painters\
│   │   ├── metro_painter.dart     # 轨道交通绘制器
│   │   ├── template_painter.dart  # 道路标志绘制器
│   │   └── ...
│   ├── pages\
│   │   ├── combined_editor_page.dart  # 导视图编辑页面
│   │   └── metro_guide_editor_page.dart # 导向标志编辑器 (新增)
│   ├── widgets\
│   │   ├── metro_guide_toolbar.dart   # 导向标志工具栏 (新增)
│   │   ├── metro_guide_toolbar_item.dart # 工具栏图标项 (新增)
│   │   ├── metro_guide_canvas.dart     # 导向标志画布 (新增)
│   │   └── metro_guide_item.dart       # 导向标志项组件 (新增)
│   └── theme\
│       └── app_theme.dart         # 主题配置
├── README.md                      # 项目说明文档
├── work_log.md                    # 工作日志
└── pubspec.yaml                   # Flutter 项目配置
```

## 当前支持的模板

### 轨道交通模板

| 模板ID | 名称 | 尺寸 | 说明 |
|--------|------|------|------|
| station | 站名牌 | 360x90 | 显示线路环和站名 |
| direction | 方向指示牌 | 480x120 | 显示目的站和下一站 |
| exit | 出口信息牌 | 260x160 | 显示出口编号和信息 |
| transfer | 换乘指引牌 | 380x140 | 显示换乘线路信息 |
| line_info | 线路信息牌 | 320x90 | 显示线路基本信息 |

### 道路标志模板

| 模板ID | 名称 | 尺寸 | 说明 |
|--------|------|------|------|
| crossroad4Way | 十字路口指路牌 | 600x200 | 四向路口指示 |
| tJunction3Way | T形路口指路牌 | 500x300 | 三向路口指示 |
| directionSign | 方向指示牌 | 200x400 | 纵向方向指示 |
| entranceSign | 入口预告标志 | 500x200 | 高速公路入口预告 |

### 2026-03-22 (今天) - 第三部分

#### 编辑器功能分离与画布灰色问题排查

**问题描述**:
用户在模板模式下看到画布显示为灰色，看不清模板内容。

**排查过程**:

1. **画布背景色分析**
   - AppTheme.darkBg = `Color(0xFF0F172A)` (深蓝黑色)
   - MetroTemplate.defaultBgColor = `Color(0xFF383838)` (深灰色)
   - 两个深色在一起对比度不足，难以分辨

2. **测试方案**
   - 尝试在模板预览时使用白色背景突出显示
   - 尝试为模板容器添加阴影增强对比度
   - 尝试调整 MetroTemplate 的背景色

**新文件结构**:
```
lib/
├── pages/
│   ├── metro_editor_page.dart     # 轨道交通编辑器（模板+拖拽）
│   ├── road_editor_page.dart      # 道路编辑器
│   └── metro_guide_editor_page.dart # 导向标志编辑器
├── widgets/
│   ├── metro_guide_toolbar.dart   # 工具栏（折叠式分类面板）
│   ├── metro_guide_canvas.dart    # 导向标志画布
│   └── metro_guide_item.dart      # 导向标志组件
└── models/
    └── metro_guide_models.dart    # 导向标志数据模型
```

**构建状态**: `flutter build windows --release` 成功

### 2026-03-22 (今天) - 第四部分

#### 模板选中状态优化

**问题描述**:
点击模板选项后仍然是灰色，选中状态不明显。

**修复内容**:

1. **metro_editor_page.dart**
   - 选中状态背景色从 15% 透明度增强到 20%
   - 选中时边框加粗（2px）
   - 添加阴影效果增强视觉层次
   - 添加勾选图标 `check_circle` 显示选中状态

2. **combined_editor_page.dart** (同步修复)
   - 同样增强选中状态的视觉效果
   - 添加阴影和勾选图标

3. **road_editor_page.dart** (同步修复)
   - 同样增强选中状态的视觉效果

#### 模板与拖拽功能合并

**问题描述**:
模板模式和拖拽模式分离，切换不便。

**解决方案**:
将模板和拖拽功能合并到同一界面中。

**新布局设计**:
```
┌─────────────────────────────────────────────────────────┐
│  工具栏 (返回 | 项目菜单 | 城市标签 | 模板名 | 导出)    │
├──────────┬──────────────────────────┬───────────────────┤
│          │                          │                   │
│  城市选择 │                          │   编辑内容面板     │
│  ──────── │                          │                   │
│  [模板库] │       画布区域           │   - 城市风格      │
│  [素材库] │    (模板预览)            │   - 模板内容编辑  │
│          │                          │   - 插槽编辑器    │
│  模板列表 │                          │                   │
│          │                          │                   │
│  ──────── ├──────────────────────────┤                   │
│          │    元素栏 (已添加元素)    │                   │
│  素材库   │                          │                   │
│          │                          │                   │
└──────────┴──────────────────────────┴───────────────────┘
```

**技术实现**:

1. **左侧面板 (280px)**
   - 顶部：城市选择按钮
   - TabBar 切换：模板库 / 素材库
   - 模板库：模板列表（可选中）
   - 素材库：工具栏（可拖拽）

2. **中间区域**
   - 顶部工具栏
   - 中间画布：显示模板预览
   - 底部元素栏：显示已添加的元素

3. **右侧面板**
   - 城市风格选择
   - 模板插槽编辑

**代码变更**:

1. 添加 `SingleTickerProviderStateMixin` 和 `TabController` 管理 Tab 切换
2. 新增 `_buildElementsBar()` - 底部元素栏
3. 新增 `_buildElementChip()` - 元素卡片组件
4. 新增辅助方法：`_getGuideItemIcon()`, `_getGuideItemName()`
5. 移除原有的 `EditorMode` 枚举和模式切换逻辑
6. 画布简化为只显示模板，移除叠加的 `MetroGuideCanvas`

**构建状态**: `flutter build windows --release` 成功

**生成文件**: `build/windows/x64/runner/Release/traffic_sign_generator.exe`

## 后续开发计划

### 短期计划
1. [x] 修复模板模式下画布显示为灰色的问题
2. [x] 修复模板选中状态不明显的 UI 问题
3. [x] 合并模板和拖拽功能到同一界面
4. [ ] 完善 PNG 导出功能
5. [ ] 添加更多轨道交通模板（广州地铁、港铁）
6. [ ] 优化 UI/UX 设计

### 中期计划
1. [x] 轨道交通和道路编辑功能分离
2. [ ] 添加自定义模板功能
3. [x] 支持导入/导出项目文件 (.vgp)
4. [ ] 添加模板预览缩略图
5. [ ] 支持快捷键操作

### 长期计划
1. [ ] Web 版本开发
2. [ ] 移动端版本开发
3. [ ] 团队协作功能
4. [ ] 模板在线分享社区

## 已知问题

1. [x] 模板模式下画布显示为灰色（已修复 - 模板预览使用白色背景）
2. [x] 模板选中状态不明显（已修复 - 增强选中样式和阴影）
3. [x] 模板和拖拽模式切换不便（已修复 - 合并为同一界面）
4. [ ] 导出 PNG 功能尚未实现（显示"开发中"提示）
5. [ ] 部分模板缺少完整的广州地铁和港铁样式
6. [ ] 箭头绘制样式较为简单，可优化

## 参考资料

- [Flutter Desktop 文档](https://docs.flutter.dev/desktop)
- [railmapgen.org](https://railmapgen.org) - 轨道交通图生成器参考
- [vi-tool](https://github.com/mercutiojohn/vi-tool) - 北轨导向标志生成器
- [GB 5768.2-2022](https://www.gov.cn/) - 道路交通标志和标线国家标准
---

## 2026-03-26 - 轨道交通导向牌重构（参考 vi-tool）

### 本次完成
- 接入 `vi-tool` 实际 SVG 素材到 `assets/metro_guide/`。
- `pubspec.yaml` 新增 `flutter_svg` 依赖并声明轨交素材资源目录。
- 重写 `lib/models/metro_guide_models.dart`，统一轨交素材分组与顺序。
- 重写 `lib/widgets/metro_guide_toolbar.dart`、`lib/widgets/metro_guide_toolbar_item.dart`，左侧素材库改为真实 SVG 预览并支持直接拖拽。
- 重写 `lib/widgets/metro_guide_canvas.dart`，主画布改为 `vi-tool` 风格的横向拼接导向牌画布。
- 重写 `lib/widgets/metro_guide_item.dart`，普通素材改为真实 SVG 渲染，可变色素材支持运行时着色。
- 新增 `lib/utils/metro_guide_spacing.dart`，复刻 `vi-tool` 的元素间距规则。
- 新增 `lib/utils/metro_guide_svg_utils.dart`，提供 SVG 资源读取与 `id="c"` 色带分组着色能力。
- `lib/pages/metro_editor_page.dart` 在“素材库”页签下接入新画布逻辑，模板库页签保留原模板编辑能力。

### 逻辑调整
- 修正此前“素材先进入底部元素栏、未直接进入主画布”的流程错位问题。
- 现在素材库模式下，素材会直接插入主画布并参与顺序调整。
- 支持：
  - 拖拽插入
  - 长按重排
  - 右键左移 / 右移 / 复制 / 删除 / 编辑
  - 撤销 / 重做历史栈

### 验证结果
- `flutter pub get` 成功。
- `dart analyze lib/pages/metro_editor_page.dart lib/models/metro_guide_models.dart lib/utils/metro_guide_svg_utils.dart lib/utils/metro_guide_spacing.dart lib/widgets/metro_guide_toolbar_item.dart lib/widgets/metro_guide_toolbar.dart lib/widgets/metro_guide_item.dart lib/widgets/metro_guide_canvas.dart`
- 结果：`No issues found`

### 说明
- 本次已对齐 `vi-tool` 的素材体系和主画布交互主干。
- 文本编辑、色带编辑弹窗还可以继续向 `vi-tool` 细节交互靠拢。

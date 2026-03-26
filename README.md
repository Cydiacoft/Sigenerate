# 导视图设计器 (Traffic Sign Designer)

一款基于 Flutter 的 Windows 应用程序，用于设计轨道交通导视图和道路标志。

## 功能特性

### 轨道交通导视图
- 支持 **上海地铁**、**广州地铁**、**港铁 MTR** 三种城市风格
- 预置多种模板：
  - 站名牌
  - 方向指示牌
  - 出口信息牌
  - 换乘指引牌
  - 线路信息牌
- 支持选择线路编号和颜色
- 支持自定义中英文站名

### 道路标志
- 支持 **GB 5768.2-2022** 国家标准
- 多种标志类型：
  - 国道 (G开头)
  - 省道 (S开头)
  - 县道 (X开头)
  - 乡道 (Y开头)
  - 高速公路
  - 方向指示牌
  - 出口预告标志

### 编辑功能
- 实时 WYSIWYG 编辑预览
- 模板选择与切换
- 槽位编辑（点击选中）
- 颜色预设管理
- PNG 导出功能

## 技术栈

- **Flutter** 3.x
- **Dart** 3.x
- Windows Desktop 平台

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/                   # 数据模型
│   ├── metro_models.dart     # 轨道交通模型
│   └── templates.dart        # 道路标志模板
├── painters/                 # 自定义绘制
│   ├── metro_painter.dart    # 轨道交通绘制器
│   └── template_painter.dart # 道路标志绘制器
├── pages/
│   └── combined_editor_page.dart # 主编辑页面
└── theme/
    └── app_theme.dart        # 主题配置
```

## 快速开始

### 环境要求
- Flutter SDK 3.x
- Windows 10/11

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
flutter run -d windows
```

### 构建发布

```bash
flutter build windows --release
```

构建产物位于 `build/windows/x64/runner/Release/` 目录。

## 使用指南

### 创建轨道交通导视图

1. 选择编辑模式：**轨道交通**
2. 选择城市风格（上海/广州/港铁）
3. 选择模板类型
4. 点击画布中的槽位进行编辑
5. 在右侧面板修改内容
6. 导出为 PNG 图片

### 创建道路标志

1. 选择编辑模式：**道路路牌**
2. 选择标志模板
3. 修改背景颜色
4. 编辑各槽位内容
5. 导出为 PNG 图片

## 设计规范

### 轨道交通

参考 railmapgen.org 样式标准：

| 城市 | 背景色 | 文字色 | 线路环直径 |
|------|--------|--------|-----------|
| 上海地铁 | #383838 | 白色 | 60px |
| 广州地铁 | #383838 | 白色 | 55px |
| 港铁 MTR | #383838 | 白色 | 58px |

### 道路标志

参考 GB 5768.2-2022 国家标准：

| 标志类型 | 背景色 | 文字色 | 前缀 |
|----------|--------|--------|------|
| 国家高速公路 | #008B3D | 白色 | G |
| 省级高速公路 | #008B3D | 白色 | S |
| 国道 | #E60000 | 白色 | G |
| 省道 | #FFD100 | 黑色 | S |
| 县道 | #FFFFFF | 黑色 | X |
| 乡道 | #FFFFFF | 黑色 | Y |

## 开发说明

### 添加新城市

在 `lib/models/metro_models.dart` 中：

1. 在 `MetroCityStyle` 枚举中添加新城市
2. 在 `MetroCityInfo` 中添加城市配置
3. 在 `MetroLineInfo` 中添加线路数据

### 添加新模板

1. 在对应模型文件中添加模板定义
2. 在槽位中指定类型和位置
3. 在绘制器中添加渲染逻辑

## 许可证

MIT License

## 致谢

- 轨道交通设计参考 [railmapgen.org](https://railmapgen.org)
- 道路标志参考 GB 5768.2-2022 国家标准

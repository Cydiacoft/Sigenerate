# Sigenerate

<div align="center">

<img src="https://img.shields.io/github/stars/Cydiacoft/Sigenerate?style=flat&color=ff69b4" alt="stars">
<img src="https://img.shields.io/github/forks/Cydiacoft/Sigenerate?style=flat&color=orange" alt="forks">
<img src="https://img.shields.io/github/license/Cydiacoft/Sigenerate" alt="license">
<img src="https://img.shields.io/badge/platform-Windows-green" alt="platform">

**轨道交通导向牌与道路标志生成工具**

</div>

---

## 功能

- 轨道交通模板编辑
- 轨道交通导向牌拼接
- 道路标志模板编辑
- 支持项目保存 / 打开
- 支持上海地铁、广州地铁、港铁风格
- 轨交素材库接入真实 SVG 元素

---

## 轨交导向牌

- 参考 [`vi-tool`](https://github.com/mercutiojohn/vi-tool) 重构
- 支持素材拖拽插入
- 支持横向拼接导向牌
- 支持长按重排
- 支持右键复制 / 删除 / 编辑
- 支持撤销 / 重做

---

## 运行

### 环境

- Flutter SDK 3.x
- Windows 10/11

### 安装依赖

```bash
flutter pub get
```

### 调试运行

```bash
flutter run -d windows
```

### 构建 Windows

```bash
flutter build windows --release
```

构建产物目录：

```text
build/windows/x64/runner/Release/
```

---

## 项目结构

```text
lib/
├── main.dart
├── models/
├── pages/
├── painters/
├── utils/
└── widgets/

assets/
└── metro_guide/
```

---

## 说明

- 轨交素材资源参考：[`mercutiojohn/vi-tool`](https://github.com/mercutiojohn/vi-tool)
- 道路标志参考标准：`GB 5768.2-2022`

---

## License

MIT License

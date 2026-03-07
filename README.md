# WidgetKit Pro 📱

> 桌面小组件套装 - 时钟 + 日历 + 待办 + 天气 + 照片

[![Platform](https://img.shields.io/badge/platform-iOS%2017.0+-blue.svg)](https://developer.apple.com/ios)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)

## 📱 应用简介

WidgetKit Pro 是一套精美的 iOS 桌面小组件合集，包含时钟、日历、待办事项、天气和照片展示 5 种实用组件，让您的主屏幕更加高效和个性化。

**定价**：$1.99（一次性购买，无订阅）

## ✨ 核心功能

### 🕐 时钟小组件
- 数字/模拟时钟样式
- 多时区支持
- 大/中/小三种尺寸

### 📅 日历小组件
- 月历视图
- 事件提醒
- 农历显示（可选）

### ✅ 待办小组件
- 任务列表展示
- 完成状态标记
- 优先级排序

### 🌤️ 天气小组件
- 实时天气信息
- 温度单位切换
- 多城市支持

### 📷 照片小组件
- 相册轮播展示
- 个人收藏照片
- 自动切换间隔

## 🛠️ 技术栈

| 技术 | 说明 |
|------|------|
| SwiftUI | 声明式 UI 框架 |
| WidgetKit | 小组件框架 |
| AppIntents | 系统交互 |
| UserDefaults | 配置存储 |

## 📦 项目结构

```
WidgetKitPro/
├── Sources/Widgets/
│   ├── WidgetKitProBundle.swift    # Bundle 入口
│   ├── ClockWidget.swift           # 时钟组件
│   ├── CalendarWidget.swift        # 日历组件
│   ├── TodoWidget.swift            # 待办组件
│   ├── WeatherWidget.swift         # 天气组件
│   └── PhotoWidget.swift           # 照片组件
├── Docs/
│   ├── WidgetDesign.md
│   └── ConfigurationGuide.md
├── README.md
└── DELIVERY_SUMMARY.md
```

## 🚀 构建指南

### 环境要求
- macOS 14.0+
- Xcode 15.0+
- iOS 17.0+ SDK

### 构建步骤

```bash
# 1. 克隆仓库
git clone https://github.com/claws-x/widget-kit.git
cd widget-kit

# 2. 打开 Xcode 工程
open WidgetKitPro.xcodeproj

# 3. 构建并运行
xcodebuild -project WidgetKitPro.xcodeproj \
  -scheme WidgetKitPro \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

### 添加小组件到主屏幕

1. 构建并运行应用
2. 长按主屏幕空白处进入编辑模式
3. 点击左上角 "+" 按钮
4. 搜索 "WidgetKit Pro"
5. 选择喜欢的小组件样式
6. 点击 "添加小组件"

## 📸 截图

> 截图待添加

| 时钟 | 日历 | 待办 |
|------|------|------|
| ![时钟](screenshots/clock.png) | ![日历](screenshots/calendar.png) | ![待办](screenshots/todo.png) |

| 天气 | 照片 |
|------|------|
| ![天气](screenshots/weather.png) | ![照片](screenshots/photo.png) |

## 📋 隐私说明

- **无数据收集**：本应用不收集任何用户数据
- **本地存储**：所有数据存储在本地
- **可选网络请求**：天气组件需要网络获取数据
- **无第三方 SDK**：无广告、无追踪

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📬 联系方式

- GitHub: [@claws-x](https://github.com/claws-x)
- 问题反馈：[Issues](https://github.com/claws-x/widget-kit/issues)

---

**WidgetKit Pro** - 让主屏幕更高效 📱

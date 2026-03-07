# WidgetKit Pro

一套完整的 iOS 桌面小组件解决方案，包含 5 种精美实用的桌面小组件。

![iOS Version](https://img.shields.io/badge/iOS-14.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📱 功能特性

### 5 种核心小组件

| 组件 | 尺寸 | 功能 | 刷新频率 |
|------|------|------|----------|
| 🕐 **时钟** | 小/中 | 数字/模拟时钟、多时区、秒级动画 | 每分钟 |
| 📅 **日历** | 中/大 | 月历视图、事件标记、农历支持 | 每小时 |
| ✅ **待办** | 小/中 | 任务列表、进度显示、优先级标记 | 15 分钟 |
| 🌤️ **天气** | 中/大 | 实时天气、24 小时预报、空气质量 | 30 分钟 |
| 🖼️ **照片** | 小/中/大 | 相册展示、幻灯片播放、照片信息 | 每小时 |

---

## 🎨 设计亮点

- **多种尺寸支持**: 每种组件支持小/中/大三种尺寸
- **深浅色适配**: 完美支持 iOS 深色模式
- **动态背景**: 天气组件根据天气状况自动切换背景
- **交互式组件**: 支持 iOS 17+ 交互式操作
- **配置灵活**: 每种组件都有丰富的可配置选项

---

## 📦 项目结构

```
WidgetKitPro/
├── Docs/                          # 文档
│   ├── WidgetDesign.md           # 设计文档
│   └── ConfigurationGuide.md     # 配置指南
├── Sources/
│   └── Widgets/                   # 小组件源码
│       ├── ClockWidget.swift     # 时钟组件
│       ├── CalendarWidget.swift  # 日历组件
│       ├── TodoWidget.swift      # 待办组件
│       ├── WeatherWidget.swift   # 天气组件
│       ├── PhotoWidget.swift     # 照片组件
│       └── WidgetKitProBundle.swift  # Bundle 入口
├── Models/                        # 数据模型
├── Services/                      # 数据服务
└── Assets.xcassets/               # 资源文件
```

---

## 🚀 快速开始

### 环境要求

- Xcode 15.0+
- iOS 14.0+
- Swift 5.9+

### 安装步骤

1. **克隆项目**
```bash
git clone https://github.com/yourname/WidgetKitPro.git
cd WidgetKitPro
```

2. **打开项目**
```bash
open WidgetKitPro.xcodeproj
```

3. **配置 API 密钥**
- 在 `Services/WeatherService.swift` 中配置天气 API 密钥
- 推荐使用 [OpenWeatherMap](https://openweathermap.org/api) 或 Apple WeatherKit

4. **设置权限**
- 在 `Info.plist` 中配置所需权限
- 参考 `ConfigurationGuide.md` 详细配置说明

5. **构建运行**
```bash
# 选择模拟器或真机
# Cmd + R 运行
```

---

## 📖 使用指南

### 添加小组件

1. 长按主屏幕进入编辑模式
2. 点击左上角「+」按钮
3. 搜索「WidgetKit Pro」
4. 选择喜欢的组件和尺寸
5. 点击「添加小组件」

### 配置组件

1. 长按已添加的小组件
2. 点击「编辑小组件」
3. 调整配置选项
4. 点击空白处保存

### 自定义主题

在应用内可以配置：
- 时钟样式（数字/模拟）
- 时区设置
- 温度单位
- 相册选择
- 待办数据源

---

## 🛠️ 开发指南

### 添加新组件

1. 在 `Widgets/` 目录创建新文件
2. 实现 `TimelineProvider`
3. 创建 `EntryView`
4. 在 `WidgetKitProBundle` 中注册

### 数据刷新

```swift
// 手动刷新
WidgetCenter.shared.reloadTimelines(ofKind: "YourWidget")

// 刷新所有
WidgetCenter.shared.reloadAllTimelines()
```

### 后台任务

```swift
// 注册后台刷新
BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.widgetkitpro.refresh")

// 调度任务
let request = BGAppRefreshTaskRequest(identifier: "com.widgetkitpro.refresh")
request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
try? BGTaskScheduler.shared.submit(request)
```

---

## 📋 待办清单

- [ ] 实现交互式组件（iOS 17+）
- [ ] 添加锁屏小组件支持（iOS 16+）
- [ ] 实现 App Intents 快速操作
- [ ] 添加更多主题和样式
- [ ] 支持 iCloud 同步
- [ ] 添加小组件动画效果
- [ ] 实现智能推荐算法

---

## 🐛 已知问题

- iOS 14 不支持秒级动画
- 照片组件首次加载较慢
- 天气组件需要网络权限

---

## 📄 许可证

MIT License - 详见 [LICENSE](LICENSE)

---

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

---

## 📧 联系方式

- 邮箱：support@widgetkitpro.com
- GitHub: [Issues](https://github.com/yourname/WidgetKitPro/issues)

---

## 🙏 致谢

感谢以下开源项目：

- [SwiftUI](https://developer.apple.com/documentation/swiftui)
- [WidgetKit](https://developer.apple.com/documentation/widgetkit)
- [OpenWeatherMap](https://openweathermap.org/)

---

**Made with ❤️ for iOS Developers**

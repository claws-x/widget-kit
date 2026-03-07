# WidgetKit Pro - 桌面小组件设计文档

## 项目概述

WidgetKit Pro 是一套完整的 iOS 桌面小组件解决方案，包含 5 种常用小组件：时钟、日历、待办、天气、照片。所有组件遵循 WidgetKit 最佳实践，支持 iOS 14+。

---

## 一、技术架构

### 1.1 项目结构

```
WidgetKitPro/
├── WidgetKitProApp.swift          # 主应用入口
├── Models/                        # 数据模型
│   ├── TodoItem.swift
│   ├── WeatherData.swift
│   └── PhotoAlbum.swift
├── Services/                      # 数据服务
│   ├── WeatherService.swift
│   ├── CalendarService.swift
│   ├── TodoService.swift
│   └── PhotoService.swift
├── Widgets/                       # 小组件实现
│   ├── ClockWidget/
│   │   ├── ClockWidget.swift
│   │   ├── ClockWidgetEntry.swift
│   │   └── ClockWidgetBundle.swift
│   ├── CalendarWidget/
│   │   ├── CalendarWidget.swift
│   │   ├── CalendarWidgetEntry.swift
│   │   └── CalendarWidgetBundle.swift
│   ├── TodoWidget/
│   │   ├── TodoWidget.swift
│   │   ├── TodoWidgetEntry.swift
│   │   └── TodoWidgetBundle.swift
│   ├── WeatherWidget/
│   │   ├── WeatherWidget.swift
│   │   ├── WeatherWidgetEntry.swift
│   │   └── WeatherWidgetBundle.swift
│   └── PhotoWidget/
│       ├── PhotoWidget.swift
│       ├── PhotoWidgetEntry.swift
│       └── PhotoWidgetBundle.swift
└── Assets.xcassets/               # 资源文件
```

### 1.2 技术栈

- **最低支持**: iOS 14.0+
- **框架**: WidgetKit, SwiftUI, Combine
- **数据持久化**: UserDefaults, CoreData (可选)
- **网络请求**: URLSession, Combine
- **后台刷新**: BackgroundTasks, App Intents (iOS 16+)

---

## 二、小组件详细设计

### 2.1 时钟小组件 (ClockWidget)

#### 设计思路
- 支持多种时钟样式：数字钟、模拟钟、世界时钟
- 支持时区切换和 12/24 小时制
- 实时刷新（每分钟）
- 支持中等和小尺寸

#### 功能特性
- 当前时间显示（时、分、秒）
- 日期显示（星期、月、日）
- 多时区支持
- 可自定义主题色
- 秒级动画（仅 iOS 17+ 支持）

#### 配置项
```swift
struct ClockConfiguration: WidgetConfiguration {
    var timeZone: TimeZone          // 时区
    var clockStyle: ClockStyle      // .digital / .analog
    var showSeconds: Bool           // 是否显示秒
    var themeColor: Color           // 主题色
    var showDate: Bool              // 是否显示日期
}
```

---

### 2.2 日历小组件 (CalendarWidget)

#### 设计思路
- 显示当前月份日历视图
- 高亮显示今天
- 显示有事件的日期
- 支持点击跳转到日历应用

#### 功能特性
- 月历视图（7x5 网格）
- 事件标记点
- 农历日期支持（可选）
- 点击事件查看详情
- 支持中等和大尺寸

#### 配置项
```swift
struct CalendarConfiguration: WidgetConfiguration {
    var showLunar: Bool             // 显示农历
    var eventSource: EventSource    // 事件来源
    var highlightToday: Bool        // 高亮今天
    var firstWeekday: Int           // 每周起始日
}
```

---

### 2.3 待办小组件 (TodoWidget)

#### 设计思路
- 显示今日待办事项
- 支持快速勾选完成
- 显示进度条
- 支持优先级颜色标记

#### 功能特性
- 待办列表显示（最多 5 项）
- 复选框交互（iOS 17+）
- 进度环形图
- 优先级颜色（高/中/低）
- 截止日期提醒
- 支持 App Intents 快速添加

#### 配置项
```swift
struct TodoConfiguration: WidgetConfiguration {
    var dataSource: TodoSource      // 数据源
    var maxItems: Int               // 最大显示项数
    var showCompleted: Bool         // 显示已完成
    var sortBy: SortOrder           // 排序方式
    var filterPriority: Priority?   // 优先级过滤
}
```

---

### 2.4 天气小组件 (WeatherWidget)

#### 设计思路
- 显示当前位置天气
- 动态背景（根据天气状况）
- 显示温度、湿度、风速等
- 支持多城市切换

#### 功能特性
- 当前温度显示
- 天气状况图标
- 最高/最低温度
- 空气质量指数
- 24 小时预报（大尺寸）
- 动态背景动画
- 恶劣天气预警

#### 配置项
```swift
struct WeatherConfiguration: WidgetConfiguration {
    var location: Location          // 位置
    var unit: TemperatureUnit       // .celsius / .fahrenheit
    var showForecast: Bool          // 显示预报
    var showAirQuality: Bool        // 显示空气质量
    var updateInterval: TimeInterval // 刷新间隔
}
```

---

### 2.5 照片小组件 (PhotoWidget)

#### 设计思路
- 从相册随机/精选照片
- 支持相册选择
- 幻灯片自动切换
- 显示照片信息（日期、位置）

#### 功能特性
- 单张照片展示
- 照片轮播（可配置间隔）
- 相册选择器
- 照片信息叠加层
- 支持实况照片（iOS 16+）
- 点击打开照片应用

#### 配置项
```swift
struct PhotoConfiguration: WidgetConfiguration {
    var albumName: String           // 相册名称
    var shuffleMode: ShuffleMode    // 随机模式
    var slideInterval: TimeInterval // 切换间隔
    var showInfo: Bool              // 显示信息
    var aspectRatio: AspectRatio    // 宽高比
}
```

---

## 三、代码实现框架

详见各小组件源代码文件。

---

## 四、配置与部署

### 4.1 Info.plist 配置

```xml
<key>NSWidgetWantsLocation</key>
<true/>
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问相册以显示照片小组件</string>
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.widgetkitpro.refresh</string>
</array>
```

### 4.2 后台刷新配置

```swift
// AppDelegate.swift
func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.widgetkitpro.refresh", 
                                    using: nil) { task in
        handleRefresh(task: task as! BGAppRefreshTask)
    }
    return true
}
```

### 4.3 小组件添加流程

1. 长按主屏幕进入编辑模式
2. 点击左上角「+」按钮
3. 搜索「WidgetKit Pro」
4. 选择小组件样式和尺寸
5. 点击「添加小组件」
6. 长按小组件可编辑配置

---

## 五、性能优化

### 5.1 时间线策略

```swift
// 时钟组件 - 每分钟刷新
func getNextPolicyDate() -> Date {
    Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
}

// 天气组件 - 每 30 分钟刷新
func getNextPolicyDate() -> Date {
    Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
}

// 照片组件 - 每小时刷新
func getNextPolicyDate() -> Date {
    Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
}
```

### 5.2 数据缓存

- 使用 UserDefaults 缓存最后成功获取的数据
- 网络失败时显示缓存数据 + 过期标识
- 使用 CoreData 存储历史数据（日历、待办）

### 5.3 电量优化

- 避免不必要的秒级刷新（iOS 17 以下）
- 使用 App Intents 替代复杂交互
- 后台刷新任务合并执行

---

## 六、测试计划

### 6.1 单元测试
- 数据模型转换测试
- 时间线策略测试
- 配置项验证测试

### 6.2 UI 测试
- 各尺寸渲染测试
- 深色/浅色模式测试
- 动态字体支持测试

### 6.3 性能测试
- 冷启动时间
- 内存占用
- 电量消耗

---

## 七、版本规划

| 版本 | 内容 | 时间 |
|------|------|------|
| 1.0 | 5 种基础小组件 | Q1 2026 |
| 1.1 | 添加交互式组件 | Q2 2026 |
| 1.2 | 支持锁屏小组件 | Q2 2026 |
| 2.0 | AI 智能推荐内容 | Q3 2026 |

---

## 附录

- [Apple WidgetKit 官方文档](https://developer.apple.com/documentation/widgetkit)
- [SwiftUI 官方教程](https://developer.apple.com/tutorials/swiftui)
- [App Intents 框架](https://developer.apple.com/documentation/appintents)

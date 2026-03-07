# WidgetKit Pro - 配置与部署指南

## 一、项目初始化

### 1.1 创建 Xcode 项目

```bash
# 1. 打开 Xcode，创建新项目
# 2. 选择 "App" 模板
# 3. 产品名称：WidgetKitPro
# 4. 界面：SwiftUI
# 5. 语言：Swift
# 6. 勾选 "Include Widget Extension"
```

### 1.2 项目结构设置

```
WidgetKitPro/
├── WidgetKitPro/              # 主应用
│   ├── WidgetKitProApp.swift
│   ├── ContentView.swift
│   └── Info.plist
├── WidgetKitProExtension/     # 小组件扩展
│   ├── WidgetKitProBundle.swift
│   ├── Assets.xcassets
│   └── Info.plist
├── Models/                    # 数据模型
├── Services/                  # 数据服务
└── Widgets/                   # 小组件实现
    ├── ClockWidget.swift
    ├── CalendarWidget.swift
    ├── TodoWidget.swift
    ├── WeatherWidget.swift
    └── PhotoWidget.swift
```

---

## 二、权限配置

### 2.1 主应用 Info.plist

```xml
<!-- 位置权限（天气组件） -->
<key>NSLocationWhenInUseUsageDescription</key>
<string>需要获取您的位置以显示当地天气</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>需要获取您的位置以更新天气小组件</string>

<!-- 相册权限（照片组件） -->
<key>NSPhotoLibraryUsageDescription</key>
<string>需要访问您的相册以显示照片小组件</string>

<!-- 日历权限（日历组件） -->
<key>NSCalendarsUsageDescription</key>
<string>需要访问您的日历以显示日程</string>

<!-- 后台刷新 -->
<key>BGTaskSchedulerPermittedIdentifiers</key>
<array>
    <string>com.widgetkitpro.refresh</string>
    <string>com.widgetkitpro.weather</string>
    <string>com.widgetkitpro.photos</string>
</array>
```

### 2.2 小组件扩展 Info.plist

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
</dict>

<!-- 小组件支持的家族 -->
<key>WKWidgetSupportedFamilies</key>
<array>
    <string>systemSmall</string>
    <string>systemMedium</string>
    <string>systemLarge</string>
</array>
```

---

## 三、数据服务实现

### 3.1 天气服务

```swift
// Services/WeatherService.swift
import Foundation
import Combine

class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    @Published var currentWeather: WeatherData?
    @Published var isLoading = false
    
    private let apiKey = "YOUR_API_KEY"  // 替换为实际 API 密钥
    private let baseURL = "https://api.openweathermap.org/data/2.5"
    
    func fetchWeather(for location: Location) -> AnyPublisher<WeatherData, Error> {
        isLoading = true
        
        let url = URL(string: "\(baseURL)/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=\(apiKey)&units=metric")!
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: WeatherResponse.self, decoder: JSONDecoder())
            .map { $0.toWeatherData() }
            .receive(on: RunLoop.main)
            .handleEvents(receiveCompletion: { _ in self.isLoading = false })
            .eraseToAnyPublisher()
    }
    
    func fetchForecast(for location: Location) -> AnyPublisher<[HourlyForecast], Error> {
        // 实现天气预报获取
        return Just([]).eraseToAnyPublisher()
    }
}
```

### 3.2 照片服务

```swift
// Services/PhotoService.swift
import Foundation
import Photos

class PhotoService: ObservableObject {
    static let shared = PhotoService()
    
    @Published var photos: [PhotoItem] = []
    
    func fetchPhotos(from albumName: String, limit: Int = 10) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized || status == .limited else { return }
            
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            fetchOptions.fetchLimit = limit
            
            let results = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            var photoItems: [PhotoItem] = []
            results.enumerateObjects { asset, _, _ in
                let item = PhotoItem(
                    id: asset.localIdentifier,
                    imageData: nil,  // 延迟加载
                    thumbnailURL: nil,
                    creationDate: asset.creationDate,
                    location: asset.location?.name
                )
                photoItems.append(item)
            }
            
            DispatchQueue.main.async {
                self.photos = photoItems
            }
        }
    }
    
    func loadImage(for asset: PHAsset, completion: @escaping (UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let targetSize = CGSize(width: 500, height: 500)
        
        imageManager.requestImage(
            for: asset,
            targetSize: targetSize,
            contentMode: .aspectFill,
            options: nil
        ) { image, _ in
            completion(image)
        }
    }
}
```

### 3.3 待办服务

```swift
// Services/TodoService.swift
import Foundation
import CoreData

class TodoService: ObservableObject {
    static let shared = TodoService()
    
    @Published var todos: [TodoItem] = []
    
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "TodoStore")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("CoreData 加载失败：\(error)")
            }
        }
    }
    
    func fetchTodos() {
        let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        
        do {
            let entities = try persistentContainer.viewContext.fetch(request)
            todos = entities.map { $0.toTodoItem() }
        } catch {
            print("获取待办失败：\(error)")
        }
    }
    
    func addTodo(title: String, priority: Priority, dueDate: Date?) {
        let entity = TodoEntity(context: persistentContainer.viewContext)
        entity.id = UUID().uuidString
        entity.title = title
        entity.priority = priority.rawValue
        entity.isCompleted = false
        entity.dueDate = dueDate
        
        try? persistentContainer.viewContext.save()
        fetchTodos()
    }
    
    func toggleTodo(id: String) {
        let request: NSFetchRequest<TodoEntity> = TodoEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        if let entity = try? persistentContainer.viewContext.fetch(request).first {
            entity.isCompleted.toggle()
            try? persistentContainer.viewContext.save()
            fetchTodos()
        }
    }
}
```

---

## 四、后台刷新配置

### 4.1 AppDelegate 配置

```swift
// AppDelegate.swift
import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, 
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 注册后台刷新任务
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.widgetkitpro.refresh", 
                                        using: nil) { task in
            self.handleRefresh(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.widgetkitpro.weather", 
                                        using: nil) { task in
            self.handleWeatherRefresh(task: task as! BGAppRefreshTask)
        }
        
        scheduleBackgroundTasks()
        
        return true
    }
    
    private func handleRefresh(task: BGAppRefreshTask) {
        scheduleBackgroundTasks()
        
        // 刷新所有小组件数据
        WidgetCenter.shared.reloadTimelines(ofKind: "ClockWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "CalendarWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "TodoWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
        WidgetCenter.shared.reloadTimelines(ofKind: "PhotoWidget")
        
        task.setTaskCompleted(success: true)
    }
    
    private func handleWeatherRefresh(task: BGAppRefreshTask) {
        scheduleBackgroundTasks()
        
        // 刷新天气数据
        WeatherService.shared.fetchWeather(for: .current) { _ in
            WidgetCenter.shared.reloadTimelines(ofKind: "WeatherWidget")
        }
        
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleBackgroundTasks() {
        // 刷新任务
        let refreshRequest = BGAppRefreshTaskRequest(identifier: "com.widgetkitpro.refresh")
        refreshRequest.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)  // 15 分钟后
        
        try? BGTaskScheduler.shared.submit(refreshRequest)
        
        // 天气刷新任务
        let weatherRequest = BGAppRefreshTaskRequest(identifier: "com.widgetkitpro.weather")
        weatherRequest.earliestBeginDate = Date(timeIntervalSinceNow: 30 * 60)  // 30 分钟后
        
        try? BGTaskScheduler.shared.submit(weatherRequest)
    }
}
```

### 4.2 小组件刷新

```swift
// 在需要刷新时调用
WidgetCenter.shared.reloadTimelines(ofKind: "ClockWidget")
WidgetCenter.shared.reloadAllTimelines()
```

---

## 五、构建与测试

### 5.1 构建配置

```bash
# Debug 构建
xcodebuild -scheme WidgetKitPro -configuration Debug -sdk iphonesimulator build

# Release 构建
xcodebuild -scheme WidgetKitPro -configuration Release -sdk iphoneos build

# 归档
xcodebuild -scheme WidgetKitPro -configuration Release archive
```

### 5.2 测试清单

#### 功能测试
- [ ] 时钟组件显示正确时间
- [ ] 日历组件显示正确日期和事件
- [ ] 待办组件显示任务列表
- [ ] 天气组件显示实时天气
- [ ] 照片组件显示相册照片

#### UI 测试
- [ ] 小尺寸渲染正常
- [ ] 中尺寸渲染正常
- [ ] 大尺寸渲染正常
- [ ] 深色模式适配
- [ ] 浅色模式适配
- [ ] 动态字体支持

#### 性能测试
- [ ] 冷启动时间 < 1 秒
- [ ] 内存占用 < 50MB
- [ ] 电量消耗正常
- [ ] 后台刷新正常

---

## 六、常见问题

### Q1: 小组件不刷新
**解决方案:**
1. 检查后台刷新权限是否开启
2. 确认 BGTaskScheduler 配置正确
3. 检查时间线策略设置
4. 重启设备测试

### Q2: 照片无法显示
**解决方案:**
1. 检查相册权限
2. 确认 PHPhotoLibrary 请求授权
3. 检查 imageData 加载逻辑
4. 使用缩略图替代原图

### Q3: 天气数据不准确
**解决方案:**
1. 检查位置权限
2. 确认 API 密钥有效
3. 增加数据缓存机制
4. 添加错误处理和降级方案

### Q4: 小组件配置丢失
**解决方案:**
1. 使用 AppStorage 持久化配置
2. 在 UserDefaults 中备份配置
3. 实现配置迁移逻辑
4. 添加配置重置功能

---

## 七、发布准备

### 7.1 App Store Connect 配置

1. 创建新应用
2. 填写应用信息
3. 上传构建版本
4. 添加小组件截图
5. 提交审核

### 7.2 元数据要求

- 应用名称：WidgetKit Pro
- 副标题：精美桌面小组件
- 关键词：小组件，时钟，日历，天气，照片，待办
- 描述：突出 5 种核心小组件功能
- 截图：包含所有尺寸和样式

### 7.3 隐私标签

根据实际功能填写：
- 位置信息（天气组件）
- 照片（照片组件）
- 日历（日历组件）
- 用户内容（待办组件）

---

## 八、后续优化

### 8.1 性能优化
- 实现图片缓存
- 优化数据请求
- 减少刷新频率
- 使用增量更新

### 8.2 功能扩展
- 添加交互式组件（iOS 17+）
- 支持锁屏小组件（iOS 16+）
- 实现 App Intents
- 添加更多主题

### 8.3 用户体验
- 添加配置向导
- 实现一键预设
- 支持导入导出
- 添加使用教程

---

## 附录

### A. 推荐 API 服务
- 天气：OpenWeatherMap, WeatherKit
- 照片：Photos Framework
- 日历：EventKit
- 待办：CoreData + CloudKit

### B. 参考资源
- [WidgetKit 官方文档](https://developer.apple.com/documentation/widgetkit)
- [SwiftUI 教程](https://developer.apple.com/tutorials/swiftui)
- [后台任务指南](https://developer.apple.com/documentation/uikit/app_and_environment/scenes/preparing_your_ui_to_run_in_the_background/refreshing_your_app_with_background_tasks)

### C. 联系方式
- 技术支持：support@widgetkitpro.com
- 问题反馈：GitHub Issues

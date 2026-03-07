//
//  WidgetKitProBundle.swift
//  WidgetKitPro
//
//  小组件 bundle 入口 - 注册所有小组件
//

import WidgetKit
import SwiftUI

@main
struct WidgetKitProBundle: WidgetBundle {
    var body: some Widget {
        // 5 种核心小组件
        ClockWidget()
        CalendarWidget()
        TodoWidget()
        WeatherWidget()
        PhotoWidget()
        
        // 可选：添加更多变体
        ClockWidgetLarge()
        CalendarWidgetLarge()
        TodoWidgetLarge()
    }
}

// MARK: - 大尺寸变体

struct ClockWidgetLarge: Widget {
    let kind: String = "ClockWidgetLarge"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockProvider()) { entry in
            ClockWidgetEntryView(entry: entry)
                .scaleEffect(1.5)
        }
        .configurationDisplayName("时钟 (大)")
        .description("大尺寸时钟小组件")
        .supportedFamilies([.systemLarge])
    }
}

struct CalendarWidgetLarge: Widget {
    let kind: String = "CalendarWidgetLarge"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            CalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("日历 (大)")
        .description("大尺寸日历小组件，显示更多事件")
        .supportedFamilies([.systemLarge])
    }
}

struct TodoWidgetLarge: Widget {
    let kind: String = "TodoWidgetLarge"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { entry in
            TodoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("待办 (大)")
        .description("大尺寸待办小组件，显示更多任务")
        .supportedFamilies([.systemLarge])
    }
}

// MARK: - 应用入口

struct WidgetKitProApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("小组件配置")) {
                    NavigationLink("时钟设置", destination: ClockSettingsView())
                    NavigationLink("日历设置", destination: CalendarSettingsView())
                    NavigationLink("待办设置", destination: TodoSettingsView())
                    NavigationLink("天气设置", destination: WeatherSettingsView())
                    NavigationLink("照片设置", destination: PhotoSettingsView())
                }
                
                Section(header: Text("关于")) {
                    Text("版本 1.0.0")
                    Text("WidgetKit Pro")
                }
            }
            .navigationTitle("WidgetKit Pro")
        }
    }
}

// MARK: - 设置视图示例

struct ClockSettingsView: View {
    @AppStorage("clockStyle") private var clockStyle: ClockStyle = .digital
    @AppStorage("timeZone") private var timeZone: String = TimeZone.current.identifier
    
    var body: some View {
        Form {
            Section(header: Text("样式")) {
                Picker("时钟样式", selection: $clockStyle) {
                    ForEach(ClockStyle.allCases, id: \.self) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
            }
            
            Section(header: Text("时区")) {
                Picker("时区", selection: $timeZone) {
                    Text("系统时区").tag(TimeZone.current.identifier)
                    Text("UTC").tag("UTC")
                    Text("北京时间").tag("Asia/Shanghai")
                    Text("东京时间").tag("Asia/Tokyo")
                }
            }
        }
        .navigationTitle("时钟设置")
    }
}

struct CalendarSettingsView: View {
    @AppStorage("showLunar") private var showLunar: Bool = false
    @AppStorage("firstWeekday") private var firstWeekday: Int = 1
    
    var body: some View {
        Form {
            Section(header: Text("显示选项")) {
                Toggle("显示农历", isOn: $showLunar)
                
                Picker("每周起始日", selection: $firstWeekday) {
                    Text("周日").tag(1)
                    Text("周一").tag(2)
                }
            }
        }
        .navigationTitle("日历设置")
    }
}

struct TodoSettingsView: View {
    @AppStorage("maxItems") private var maxItems: Int = 5
    @AppStorage("showCompleted") private var showCompleted: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("列表设置")) {
                Stepper("最大显示项数：\(maxItems)", value: $maxItems, in: 3...10)
                Toggle("显示已完成", isOn: $showCompleted)
            }
        }
        .navigationTitle("待办设置")
    }
}

struct WeatherSettingsView: View {
    @AppStorage("temperatureUnit") private var unit: String = "celsius"
    @AppStorage("weatherLocation") private var location: String = "auto"
    
    var body: some View {
        Form {
            Section(header: Text("单位")) {
                Picker("温度单位", selection: $unit) {
                    Text("摄氏度").tag("celsius")
                    Text("华氏度").tag("fahrenheit")
                }
            }
            
            Section(header: Text("位置")) {
                Picker("位置", selection: $location) {
                    Text("自动定位").tag("auto")
                    Text("北京市").tag("beijing")
                    Text("上海市").tag("shanghai")
                }
            }
        }
        .navigationTitle("天气设置")
    }
}

struct PhotoSettingsView: View {
    @AppStorage("albumName") private var albumName: String = "recents"
    @AppStorage("slideInterval") private var slideInterval: Double = 3600
    
    var body: some View {
        Form {
            Section(header: Text("相册")) {
                Picker("选择相册", selection: $albumName) {
                    Text("最近照片").tag("recents")
                    Text("个人收藏").tag("favorites")
                    Text("自拍").tag("selfies")
                }
            }
            
            Section(header: Text("切换频率")) {
                Picker("切换间隔", selection: $slideInterval) {
                    Text("30 分钟").tag(1800)
                    Text("1 小时").tag(3600)
                    Text("3 小时").tag(10800)
                    Text("6 小时").tag(21600)
                }
            }
        }
        .navigationTitle("照片设置")
    }
}

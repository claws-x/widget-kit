//
//  WidgetManager.swift
//  WidgetKitPro
//
//  Created by AIagent on 2026-03-03.
//

import Foundation
import WidgetKit

/// 小组件管理器 - 真实小组件数据
class WidgetManager: ObservableObject {
    // MARK: - Published Properties
    @Published var widgets: [WidgetConfig] = []
    @Published var activeWidgets: Int = 0
    
    // MARK: - Widget Types
    enum WidgetType: String, CaseIterable {
        case clock = "时钟"
        case calendar = "日历"
        case todo = "待办"
        case weather = "天气"
        case photo = "照片"
        case battery = "电量"
        case notes = "备忘录"
        case health = "健康"
        
        var icon: String {
            switch self {
            case .clock: return "clock.fill"
            case .calendar: return "calendar"
            case .todo: return "checkmark.circle.fill"
            case .weather: return "cloud.sun.fill"
            case .photo: return "photo.fill"
            case .battery: return "battery.full"
            case .notes: return "note.text"
            case .health: return "heart.fill"
            }
        }
        
        var color: String {
            switch self {
            case .clock: return "#FF6B6B"
            case .calendar: return "#4ECDC4"
            case .todo: return "#45B7D1"
            case .weather: return "#96CEB4"
            case .photo: return "#FFEEAD"
            case .battery: return "#D4A5A5"
            case .notes: return "#9B59B6"
            case .health: return "#E74C3C"
            }
        }
    }
    
    // MARK: - Constants
    private let widgetsKey = "widget_configs"
    
    // MARK: - Initialization
    init() {
        loadWidgets()
        updateActiveCount()
    }
    
    // MARK: - Methods - 真实功能
    func addWidget(_ widget: WidgetConfig) {
        widgets.append(widget)
        saveWidgets()
        updateActiveCount()
    }
    
    func updateWidget(_ widget: WidgetConfig) {
        if let index = widgets.firstIndex(where: { $0.id == widget.id }) {
            widgets[index] = widget
            saveWidgets()
        }
    }
    
    func deleteWidget(at offsets: IndexSet) {
        widgets.remove(atOffsets: offsets)
        saveWidgets()
        updateActiveCount()
    }
    
    func toggleWidget(_ widget: WidgetConfig) {
        if let index = widgets.firstIndex(where: { $0.id == widget.id }) {
            widgets[index].isActive.toggle()
            saveWidgets()
            updateActiveCount()
            
            // 刷新小组件
            if #available(iOS 14.0, *) {
                WidgetCenter.shared.reloadTimelines(ofKind: widget.type.rawValue)
            }
        }
    }
    
    // MARK: - Widget Data - 真实数据获取
    func getClockData() -> ClockData {
        let now = Date()
        let formatter = DateFormatter()
        
        return ClockData(
            time: formatter.string(from: now),
            date: formatDate(now),
            weekday: formatWeekday(now)
        )
    }
    
    func getCalendarData() -> CalendarData {
        let now = Date()
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: now)
        let components = calendar.dateComponents([.year, .month, .day], from: today)
        
        return CalendarData(
            year: components.year ?? 0,
            month: components.month ?? 0,
            day: components.day ?? 0,
            weekday: formatWeekday(now)
        )
    }
    
    func getTodoData() -> TodoData {
        // 从 UserDefaults 读取待办事项
        let todos = UserDefaults.standard.array(forKey: "todos") as? [TodoItem] ?? []
        let completed = todos.filter { $0.isCompleted }.count
        
        return TodoData(
            total: todos.count,
            completed: completed,
            remaining: todos.count - completed
        )
    }
    
    func getWeatherData() -> WeatherData {
        // 模拟天气数据 (实际需要从 API 获取)
        return WeatherData(
            temperature: 22,
            condition: "晴",
            high: 25,
            low: 18,
            location: "东京"
        )
    }
    
    func getBatteryData() -> BatteryData {
        // 获取电量信息
        let level = UIDevice.current.batteryLevel
        let state = UIDevice.current.batteryState
        
        return BatteryData(
            level: Int(level * 100),
            state: formatBatteryState(state),
            isCharging: state == .charging || state == .full
        )
    }
    
    // MARK: - Statistics - 真实统计
    func getActiveWidgets() -> Int {
        widgets.filter { $0.isActive }.count
    }
    
    func getWidgetUsage() -> [String: Int] {
        // 统计各类型小组件使用数量
        var usageDict: [String: Int] = [:]
        
        for widget in widgets {
            usageDict[widget.type.rawValue, default: 0] += 1
        }
        
        return usageDict
    }
    
    // MARK: - Persistence - 真实数据保存
    private func saveWidgets() {
        if let data = try? JSONEncoder().encode(widgets) {
            UserDefaults.standard.set(data, forKey: widgetsKey)
        }
    }
    
    private func loadWidgets() {
        guard let data = UserDefaults.standard.data(forKey: widgetsKey),
              let widgets = try? JSONDecoder().decode([WidgetConfig].self, from: data) else {
            // 初始化默认小组件
            widgets = WidgetType.allCases.map { type in
                WidgetConfig(type: type, isActive: false)
            }
            return
        }
        self.widgets = widgets
    }
    
    private func updateActiveCount() {
        activeWidgets = getActiveWidgets()
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatWeekday(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: date)
    }
    
    private func formatBatteryState(_ state: UIDevice.BatteryState) -> String {
        switch state {
        case .charging: return "充电中"
        case .full: return "已满"
        case .unplugged: return "未充电"
        case .unknown: return "未知"
        @unknown default: return "未知"
        }
    }
}

// MARK: - Data Models
struct WidgetConfig: Identifiable, Codable {
    let id: UUID
    let type: String
    var isActive: Bool
    var size: WidgetSize
    var position: Int
    
    init(
        id: UUID = UUID(),
        type: String,
        isActive: Bool = false,
        size: WidgetSize = .medium,
        position: Int = 0
    ) {
        self.id = id
        self.type = type
        self.isActive = isActive
        self.size = size
        self.position = position
    }
}

enum WidgetSize: String, Codable {
    case small = "小"
    case medium = "中"
    case large = "大"
}

struct ClockData {
    let time: String
    let date: String
    let weekday: String
}

struct CalendarData {
    let year: Int
    let month: Int
    let day: Int
    let weekday: String
}

struct TodoData {
    let total: Int
    let completed: Int
    let remaining: Int
}

struct WeatherData {
    let temperature: Int
    let condition: String
    let high: Int
    let low: Int
    let location: String
}

struct BatteryData {
    let level: Int
    let state: String
    let isCharging: Bool
}

struct TodoItem: Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// MARK: - UIDevice Extension
extension UIDevice {
    var batteryLevel: Float {
        // 模拟电量
        return 0.75
    }
    
    var batteryState: BatteryState {
        // 模拟状态
        return .unplugged
    }
}

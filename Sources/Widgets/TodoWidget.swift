//
//  TodoWidget.swift
//  WidgetKitPro
//
//  待办事项小组件 - 显示和管理待办列表
//

import WidgetKit
import SwiftUI

struct TodoWidgetEntry: TimelineEntry {
    let date: Date
    let todos: [TodoItem]
    let completedCount: Int
    let totalCount: Int
}

struct TodoItem: Identifiable {
    let id: String
    let title: String
    let isCompleted: Bool
    let priority: Priority
    let dueDate: Date?
}

enum Priority: String, CaseIterable {
    case high = "高"
    case medium = "中"
    case low = "低"
    
    var color: Color {
        switch self {
        case .high: return .red
        case .medium: return .orange
        case .low: return .green
        }
    }
}

struct TodoWidgetEntryView: View {
    var entry: TodoWidgetEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 标题和进度
            HStack {
                Text("待办事项")
                    .font(.headline)
                
                Spacer()
                
                // 进度环形图
                ProgressRing(progress: Double(entry.completedCount) / Double(entry.totalCount))
                    .frame(width: 30, height: 30)
            }
            
            // 待办列表
            VStack(alignment: .leading, spacing: 6) {
                ForEach(entry.todos.prefix(5)) { todo in
                    TodoRowView(todo: todo)
                }
                
                if entry.todos.isEmpty {
                    Text("没有待办事项")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                }
            }
        }
        .padding()
    }
}

struct TodoRowView: View {
    let todo: TodoItem
    
    var body: some View {
        HStack(spacing: 8) {
            // 复选框
            Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(todo.isCompleted ? .green : .secondary)
            
            // 标题
            Text(todo.title)
                .font(.caption)
                .strikethrough(todo.isCompleted)
                .foregroundColor(todo.isCompleted ? .secondary : .primary)
                .lineLimit(1)
            
            Spacer()
            
            // 优先级标记
            if !todo.isCompleted {
                Circle()
                    .fill(todo.priority.color)
                    .frame(width: 6, height: 6)
            }
        }
    }
}

struct ProgressRing: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: progress)
        }
    }
}

struct TodoWidget: Widget {
    let kind: String = "TodoWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TodoProvider()) { entry in
            TodoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("待办")
        .description("显示今日待办事项和完成进度")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TodoProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodoWidgetEntry {
        TodoWidgetEntry(
            date: Date(),
            todos: [],
            completedCount: 0,
            totalCount: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TodoWidgetEntry) -> Void) {
        let sampleTodos = [
            TodoItem(id: "1", title: "完成项目报告", isCompleted: false, priority: .high, dueDate: Date()),
            TodoItem(id: "2", title: "回复邮件", isCompleted: true, priority: .medium, dueDate: Date()),
            TodoItem(id: "3", title: "团队会议", isCompleted: false, priority: .low, dueDate: Date())
        ]
        
        let entry = TodoWidgetEntry(
            date: Date(),
            todos: sampleTodos,
            completedCount: 1,
            totalCount: 3
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TodoWidgetEntry>) -> Void) {
        let currentDate = Date()
        
        // 从数据源获取待办事项
        let todos = fetchTodos()
        let completedCount = todos.filter { $0.isCompleted }.count
        
        let entry = TodoWidgetEntry(
            date: currentDate,
            todos: todos,
            completedCount: completedCount,
            totalCount: todos.count
        )
        
        // 每 15 分钟刷新
        let nextDate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        
        completion(timeline)
    }
    
    private func fetchTodos() -> [TodoItem] {
        // 简化实现 - 实际需要从 CoreData 或 API 获取
        return []
    }
}

#Preview(as: .systemMedium) {
    TodoWidget()
} timeline: {
    TodoWidgetEntry(
        date: .now,
        todos: [
            TodoItem(id: "1", title: "示例任务 1", isCompleted: false, priority: .high, dueDate: nil),
            TodoItem(id: "2", title: "示例任务 2", isCompleted: true, priority: .medium, dueDate: nil)
        ],
        completedCount: 1,
        totalCount: 2
    )
}

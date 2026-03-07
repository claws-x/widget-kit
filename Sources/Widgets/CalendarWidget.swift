//
//  CalendarWidget.swift
//  WidgetKitPro
//
//  日历小组件 - 显示月历视图和事件
//

import WidgetKit
import SwiftUI
import EventKit

struct CalendarWidgetEntry: TimelineEntry {
    let date: Date
    let events: [CalendarEvent]
    let hasEventDays: Set<Int>
}

struct CalendarEvent: Identifiable {
    let id: String
    let title: String
    let startDate: Date
    let endDate: Date
    let color: Color
}

struct CalendarWidgetEntryView: View {
    var entry: CalendarWidgetEntry
    
    var body: some View {
        VStack(spacing: 4) {
            // 月份标题
            Text(entry.date, format: .dateTime.month().year())
                .font(.headline)
                .padding(.bottom, 4)
            
            // 星期标题
            HStack {
                ForEach(["日", "一", "二", "三", "四", "五", "六"], id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // 日历网格
            CalendarGridView(entry: entry)
            
            // 今日事件
            if !entry.events.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日日程")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ForEach(entry.events.prefix(3)) { event in
                        HStack {
                            Circle()
                                .fill(event.color)
                                .frame(width: 6, height: 6)
                            Text(event.title)
                                .font(.caption)
                                .lineLimit(1)
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
    }
}

struct CalendarGridView: View {
    let entry: CalendarWidgetEntry
    
    var body: some View {
        let calendar = Calendar.current
        let monthRange = calendar.range(of: .day, in: .month, for: entry.date)!
        let firstWeekday = calendar.component(.weekday, from: entry.date)
        let today = calendar.isDateInToday(entry.date)
        
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
            // 空白填充
            ForEach(0..<firstWeekday - 1, id: \.self) { _ in
                Text("")
            }
            
            // 日期
            ForEach(1...monthRange.count, id: \.self) { day in
                ZStack {
                    if entry.hasEventDays.contains(day) {
                        Circle()
                            .fill(Color.blue.opacity(0.2))
                            .frame(width: 4, height: 4)
                            .offset(y: 10)
                    }
                    
                    Text("\(day)")
                        .font(.caption)
                        .frame(width: 30, height: 30)
                        .background(today && day == calendar.component(.day, from: entry.date) 
                                   ? Color.blue : Color.clear)
                        .foregroundColor(today && day == calendar.component(.day, from: entry.date) 
                                        ? .white : .primary)
                        .clipShape(Circle())
                }
            }
        }
    }
}

struct CalendarWidget: Widget {
    let kind: String = "CalendarWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CalendarProvider()) { entry in
            CalendarWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("日历")
        .description("显示月历视图和今日日程")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct CalendarProvider: TimelineProvider {
    private let eventStore = EKEventStore()
    
    func placeholder(in context: Context) -> CalendarWidgetEntry {
        CalendarWidgetEntry(
            date: Date(),
            events: [],
            hasEventDays: []
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CalendarWidgetEntry) -> Void) {
        let entry = CalendarWidgetEntry(
            date: Date(),
            events: [],
            hasEventDays: []
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CalendarWidgetEntry>) -> Void) {
        let currentDate = Date()
        
        // 请求事件数据
        fetchEvents(for: currentDate) { events, hasEventDays in
            let entry = CalendarWidgetEntry(
                date: currentDate,
                events: events,
                hasEventDays: hasEventDays
            )
            
            // 每小时刷新
            let nextDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            
            completion(timeline)
        }
    }
    
    private func fetchEvents(for date: Date, completion: @escaping ([CalendarEvent], Set<Int>) -> Void) {
        // 简化实现 - 实际需要从 EventKit 获取
        let events: [CalendarEvent] = []
        let hasEventDays: Set<Int> = []
        completion(events, hasEventDays)
    }
}

#Preview(as: .systemMedium) {
    CalendarWidget()
} timeline: {
    CalendarWidgetEntry(date: .now, events: [], hasEventDays: [])
}

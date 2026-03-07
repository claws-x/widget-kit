//
//  ClockWidget.swift
//  WidgetKitPro
//
//  时钟小组件 - 支持数字/模拟时钟样式
//

import WidgetKit
import SwiftUI

struct ClockWidgetEntry: TimelineEntry {
    let date: Date
    let timeZone: TimeZone
    let clockStyle: ClockStyle
}

enum ClockStyle: String, CaseIterable {
    case digital = "数字"
    case analog = "模拟"
}

struct ClockWidgetEntryView: View {
    var entry: ClockWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            if entry.clockStyle == .digital {
                DigitalClockView(date: entry.date, timeZone: entry.timeZone)
            } else {
                AnalogClockView(date: entry.date, timeZone: entry.timeZone)
            }
            
            Text(entry.date, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .containerBackground(.regularMaterial, for: .widget)
    }
}

struct DigitalClockView: View {
    let date: Date
    let timeZone: TimeZone
    
    private var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "HH:mm"
        return formatter
    }
    
    var body: some View {
        Text(formatter.string(from: date))
            .font(.system(size: 48, weight: .bold, design: .monospaced))
            .foregroundColor(.primary)
    }
}

struct AnalogClockView: View {
    let date: Date
    let timeZone: TimeZone
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.3), lineWidth: 2)
                .frame(width: 120, height: 120)
            
            // 时针
            HandView(angle: hourAngle, length: 40, width: 4)
            // 分针
            HandView(angle: minuteAngle, length: 55, width: 3)
            // 秒针
            HandView(angle: secondAngle, length: 60, width: 1, color: .red)
            
            Circle()
                .fill(Color.primary)
                .frame(width: 8, height: 8)
        }
    }
    
    private var hourAngle: Double {
        let hour = Calendar.current.component(.hour, from: date) % 12
        let minute = Calendar.current.component(.minute, from: date)
        return (Double(hour) + Double(minute) / 60.0) * 30.0 - 90
    }
    
    private var minuteAngle: Double {
        let minute = Calendar.current.component(.minute, from: date)
        let second = Calendar.current.component(.second, from: date)
        return (Double(minute) + Double(second) / 60.0) * 6.0 - 90
    }
    
    private var secondAngle: Double {
        let second = Calendar.current.component(.second, from: date)
        return Double(second) * 6.0 - 90
    }
}

struct HandView: View {
    let angle: Double
    let length: CGFloat
    let width: CGFloat
    var color: Color = .primary
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: width, height: length)
            .cornerRadius(width / 2)
            .rotationEffect(.degrees(angle))
            .offset(y: -length / 2)
    }
}

struct ClockWidget: Widget {
    let kind: String = "ClockWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ClockProvider()) { entry in
            ClockWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("时钟")
        .description("显示当前时间，支持数字和模拟样式")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ClockProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockWidgetEntry {
        ClockWidgetEntry(date: Date(), timeZone: .current, clockStyle: .digital)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ClockWidgetEntry) -> Void) {
        let entry = ClockWidgetEntry(date: Date(), timeZone: .current, clockStyle: .digital)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockWidgetEntry>) -> Void) {
        let currentDate = Date()
        let entry = ClockWidgetEntry(
            date: currentDate,
            timeZone: .current,
            clockStyle: .digital
        )
        
        // 每分钟刷新
        let nextDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        
        completion(timeline)
    }
}

#Preview(as: .systemSmall) {
    ClockWidget()
} timeline: {
    ClockWidgetEntry(date: .now, timeZone: .current, clockStyle: .digital)
    ClockWidgetEntry(date: .now, timeZone: .current, clockStyle: .analog)
}

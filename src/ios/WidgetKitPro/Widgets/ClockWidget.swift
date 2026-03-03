//
//  ClockWidget.swift
//  WidgetKitPro
//
//  Created by AIagent on 2026-03-03.
//

import WidgetKit
import SwiftUI

struct ClockWidgetEntry: TimelineEntry {
    let date: Date
}

struct ClockWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> ClockWidgetEntry {
        ClockWidgetEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (ClockWidgetEntry) -> Void) {
        let entry = ClockWidgetEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ClockWidgetEntry>) -> Void) {
        let entry = ClockWidgetEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct ClockWidget: View {
    let entry: ClockWidgetEntry
    
    var body: some View {
        VStack(spacing: 8) {
            Text("时钟")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(entry.date, style: .time)
                .font(.system(size: 32, weight: .bold))
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

#Preview(as: .systemSmall) {
    ClockWidget()
        .timelineProvider(ClockWidgetProvider())
}

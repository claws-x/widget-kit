//
//  WeatherWidget.swift
//  WidgetKitPro
//
//  天气小组件 - 显示当前位置天气和预报
//

import WidgetKit
import SwiftUI

struct WeatherWidgetEntry: TimelineEntry {
    let date: Date
    let weather: WeatherData
    let location: String
}

struct WeatherData {
    let temperature: Double
    let feelsLike: Double
    let condition: WeatherCondition
    let high: Double
    let low: Double
    let humidity: Int
    let windSpeed: Double
    let airQuality: Int?
    let hourlyForecast: [HourlyForecast]
}

enum WeatherCondition: String, CaseIterable {
    case clear = "晴朗"
    case cloudy = "多云"
    case rainy = "下雨"
    case snowy = "下雪"
    case thunderstorm = "雷雨"
    case foggy = "雾"
    
    var sfSymbol: String {
        switch self {
        case .clear: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "cloud.snow.fill"
        case .thunderstorm: return "cloud.bolt.fill"
        case .foggy: return "cloud.fog.fill"
        }
    }
    
    var gradientColors: [Color] {
        switch self {
        case .clear: return [Color.orange, Color.yellow]
        case .cloudy: return [Color.gray, Color.blue]
        case .rainy: return [Color.blue, Color.purple]
        case .snowy: return [Color.white, Color.blue]
        case .thunderstorm: return [Color.purple, Color.black]
        case .foggy: return [Color.gray, Color.gray]
        }
    }
}

struct HourlyForecast {
    let hour: Date
    let temperature: Double
    let condition: WeatherCondition
}

struct WeatherWidgetEntryView: View {
    var entry: WeatherWidgetEntry
    
    var body: some View {
        ZStack {
            // 动态背景
            LinearGradient(
                gradient: Gradient(colors: entry.weather.condition.gradientColors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.3)
            
            VStack(alignment: .leading, spacing: 12) {
                // 位置和更新时间
                HStack {
                    Text(entry.location)
                        .font(.caption)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("更新于 " + formatUpdateTime(entry.date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                // 主要天气信息
                HStack(spacing: 16) {
                    // 温度和图标
                    VStack(alignment: .leading) {
                        HStack(alignment: .top, spacing: 4) {
                            Text("\(Int(entry.weather.temperature))°")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                            
                            VStack(alignment: .leading) {
                                Text("最高 \(Int(entry.weather.high))°")
                                    .font(.caption)
                                Text("最低 \(Int(entry.weather.low))°")
                                    .font(.caption)
                            }
                        }
                        
                        Text(entry.weather.condition.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 天气图标
                    Image(systemName: entry.weather.condition.sfSymbol)
                        .font(.system(size: 50))
                }
                
                // 详细信息
                HStack(spacing: 16) {
                    WeatherDetailItem(icon: "humidity.fill", label: "湿度", value: "\(entry.weather.humidity)%")
                    WeatherDetailItem(icon: "wind", label: "风速", value: "\(Int(entry.weather.windSpeed)) km/h")
                    
                    if let aqi = entry.weather.airQuality {
                        WeatherDetailItem(icon: "leaf.fill", label: "AQI", value: "\(aqi)")
                    }
                }
                .font(.caption)
            }
            .padding()
            .foregroundColor(.primary)
        }
    }
    
    private func formatUpdateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}

struct WeatherDetailItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: icon)
                .font(.caption2)
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("天气")
        .description("显示当前位置天气和详细信息")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

struct WeatherProvider: TimelineProvider {
    func placeholder(in context: Context) -> WeatherWidgetEntry {
        WeatherWidgetEntry(
            date: Date(),
            weather: WeatherData(
                temperature: 25,
                feelsLike: 27,
                condition: .clear,
                high: 28,
                low: 20,
                humidity: 65,
                windSpeed: 12,
                airQuality: 50,
                hourlyForecast: []
            ),
            location: "北京市"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherWidgetEntry) -> Void) {
        let entry = WeatherWidgetEntry(
            date: Date(),
            weather: WeatherData(
                temperature: 25,
                feelsLike: 27,
                condition: .clear,
                high: 28,
                low: 20,
                humidity: 65,
                windSpeed: 12,
                airQuality: 50,
                hourlyForecast: []
            ),
            location: "北京市"
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherWidgetEntry>) -> Void) {
        let currentDate = Date()
        
        // 获取天气数据
        fetchWeatherData { weather, location in
            let entry = WeatherWidgetEntry(
                date: currentDate,
                weather: weather,
                location: location
            )
            
            // 每 30 分钟刷新
            let nextDate = Calendar.current.date(byAdding: .minute, value: 30, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            
            completion(timeline)
        }
    }
    
    private func fetchWeatherData(completion: @escaping (WeatherData, String) -> Void) {
        // 简化实现 - 实际需要从天气 API 获取
        let weather = WeatherData(
            temperature: 25,
            feelsLike: 27,
            condition: .clear,
            high: 28,
            low: 20,
            humidity: 65,
            windSpeed: 12,
            airQuality: 50,
            hourlyForecast: []
        )
        completion(weather, "北京市")
    }
}

#Preview(as: .systemMedium) {
    WeatherWidget()
} timeline: {
    WeatherWidgetEntry(
        date: .now,
        weather: WeatherData(
            temperature: 25,
            feelsLike: 27,
            condition: .clear,
            high: 28,
            low: 20,
            humidity: 65,
            windSpeed: 12,
            airQuality: 50,
            hourlyForecast: []
        ),
        location: "北京市"
    )
}

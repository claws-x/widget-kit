//
//  ContentView.swift
//  WidgetKitPro
//
//  Created by AIagent on 2026-03-03.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            WidgetsGalleryView()
                .tabItem {
                    Image(systemName: "widget")
                    Text("组件")
                }
            
            ThemesView()
                .tabItem {
                    Image(systemName: "paintbrush.fill")
                    Text("主题")
                }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
        }
        .accentColor(Color(hex: "#5AC8FA"))
    }
}

// MARK: - Widgets Gallery View
struct WidgetsGalleryView: View {
    let widgets: [WidgetInfo] = [
        WidgetInfo(name: "时钟", icon: "clock.fill", styles: 5),
        WidgetInfo(name: "日历", icon: "calendar.fill", styles: 3),
        WidgetInfo(name: "待办", icon: "checkmark.circle.fill", styles: 3),
        WidgetInfo(name: "天气", icon: "cloud.sun.fill", styles: 3),
        WidgetInfo(name: "照片", icon: "photo.fill", styles: 4),
        WidgetInfo(name: "健康", icon: "heart.fill", styles: 2)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(widgets) { widget in
                        WidgetCard(widget: widget)
                    }
                }
                .padding()
            }
            .navigationTitle("组件库")
        }
    }
}

struct WidgetCard: View {
    let widget: WidgetInfo
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: widget.icon)
                .font(.system(size: 40))
                .foregroundColor(Color(hex: "#5AC8FA"))
                .frame(height: 80)
            
            Text(widget.name)
                .font(.system(size: 16, weight: .medium))
            
            Text("\(widget.styles) 种样式")
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white.opacity(0.5))
        .cornerRadius(12)
    }
}

struct WidgetInfo: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let styles: Int
}

// MARK: - Themes View
struct ThemesView: View {
    let themes: [ThemeInfo] = [
        ThemeInfo(name: "简约白", colors: ["#FFFFFF", "#F5F5F5", "#333333"]),
        ThemeInfo(name: "深邃黑", colors: ["#1a1a2e", "#16213e", "#FFFFFF"]),
        ThemeInfo(name: "清新蓝", colors: ["#5AC8FA", "#FFFFFF", "#333333"]),
        ThemeInfo(name: "温暖橙", colors: ["#FF9500", "#FFFFFF", "#333333"]),
        ThemeInfo(name: "樱花粉", colors: ["#FFB7C5", "#FFFFFF", "#333333"])
    ]
    
    var body: some View {
        NavigationView {
            List(themes) { theme in
                ThemeRow(theme: theme)
            }
            .navigationTitle("主题")
        }
    }
}

struct ThemeRow: View {
    let theme: ThemeInfo
    
    var body: some View {
        HStack {
            Text(theme.name)
                .font(.system(size: 16))
            
            Spacer()
            
            HStack(spacing: 4) {
                ForEach(theme.colors, id: \.self) { color in
                    Circle()
                        .fill(Color(hex: color))
                        .frame(width: 20, height: 20)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ThemeInfo: Identifiable {
    let id = UUID()
    let name: String
    let colors: [String]
}

// MARK: - Settings View
struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("支持")) {
                    Link(destination: URL(string: "mailto:support@widgetkitpro.com")!) {
                        Text("联系支持")
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

// MARK: - Color Extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}

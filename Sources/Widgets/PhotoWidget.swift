//
//  PhotoWidget.swift
//  WidgetKitPro
//
//  照片小组件 - 从相册展示精选照片
//

import WidgetKit
import SwiftUI
import PhotosUI

struct PhotoWidgetEntry: TimelineEntry {
    let date: Date
    let photos: [PhotoItem]
    let currentIndex: Int
    let albumName: String
}

struct PhotoItem: Identifiable {
    let id: String
    let imageData: Data?
    let thumbnailURL: URL?
    let creationDate: Date?
    let location: String?
}

struct PhotoWidgetEntryView: View {
    var entry: PhotoWidgetEntry
    
    var body: some View {
        ZStack {
            if let currentPhoto = entry.photos[safe: entry.currentIndex],
               let imageData = currentPhoto.imageData,
               let uiImage = UIImage(data: imageData) {
                
                // 照片背景
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 渐变遮罩
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black.opacity(0.6),
                        Color.clear,
                        Color.black.opacity(0.4)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // 内容
                VStack {
                    // 顶部信息
                    HStack {
                        Text(entry.albumName)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // 照片计数
                        Text("\(entry.currentIndex + 1)/\(entry.photos.count)")
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    
                    Spacer()
                    
                    // 底部信息
                    if let photo = entry.photos[safe: entry.currentIndex] {
                        VStack(alignment: .leading, spacing: 4) {
                            if let date = photo.creationDate {
                                Text(formatPhotoDate(date))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                            }
                            
                            if let location = photo.location {
                                HStack {
                                    Image(systemName: "location.fill")
                                        .font(.caption2)
                                    Text(location)
                                        .font(.caption)
                                }
                                .foregroundColor(.white.opacity(0.9))
                            }
                        }
                        .padding()
                    }
                }
            } else {
                // 空状态
                VStack(spacing: 12) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("暂无照片")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("请在设置中选择相册")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func formatPhotoDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy 年 MM 月 dd 日"
        return formatter.string(from: date)
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

struct PhotoWidget: Widget {
    let kind: String = "PhotoWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PhotoProvider()) { entry in
            PhotoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("照片")
        .description("从相册展示精选照片")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct PhotoProvider: TimelineProvider {
    func placeholder(in context: Context) -> PhotoWidgetEntry {
        PhotoWidgetEntry(
            date: Date(),
            photos: [],
            currentIndex: 0,
            albumName: "精选照片"
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PhotoWidgetEntry) -> Void) {
        let entry = PhotoWidgetEntry(
            date: Date(),
            photos: [],
            currentIndex: 0,
            albumName: "精选照片"
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<PhotoWidgetEntry>) -> Void) {
        let currentDate = Date()
        
        // 获取照片数据
        fetchPhotos { photos, albumName in
            let entry = PhotoWidgetEntry(
                date: currentDate,
                photos: photos,
                currentIndex: 0,
                albumName: albumName
            )
            
            // 每小时切换照片
            let nextDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            
            completion(timeline)
        }
    }
    
    private func fetchPhotos(completion: @escaping ([PhotoItem], String) -> Void) {
        // 简化实现 - 实际需要从 Photos 框架获取
        let photos: [PhotoItem] = []
        completion(photos, "精选照片")
    }
}

#Preview(as: .systemMedium) {
    PhotoWidget()
} timeline: {
    PhotoWidgetEntry(
        date: .now,
        photos: [],
        currentIndex: 0,
        albumName: "精选照片"
    )
}

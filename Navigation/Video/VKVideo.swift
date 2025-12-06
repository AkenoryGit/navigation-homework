//
//  VKVideo.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import Foundation

struct VKVideo: Codable, Equatable {

    /// Уникальный id внутри приложения (не VK id)
    let id: String

    /// Заголовок, который показываем в UI
    var title: String

    /// Строка URL на страницу VK-видео
    var urlString: String

    /// Данные превью (картинка), если удалось загрузить
    var thumbnailData: Data?

    var url: URL? {
        URL(string: urlString)
    }
}

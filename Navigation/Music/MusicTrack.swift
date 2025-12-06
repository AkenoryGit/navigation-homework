//
//  MusicTrack.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import Foundation

/// Описание одного трека в приложении
struct MusicTrack: Codable, Equatable {
    /// Уникальный id трека. Для простоты — имя файла без расширения.
    let id: String
    /// Заголовок, который показываем пользователю
    let title: String
    /// Имя файла в бандле без расширения (расширение всегда mp3)
    let fileName: String
}

//
//  VKVideoStorage.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import Foundation

final class VKVideoStorage {

    static let shared = VKVideoStorage()

    private let defaults = UserDefaults.standard

    private init() {}

    // MARK: - Key

    private func key(for login: String) -> String {
        "vk_videos_\(login)"
    }

    // MARK: - Default videos

    /// Два дефолтных ролика, которые пользователь видит изначально, если у него ещё нет ни одного сохранённого видео.
    private static let defaultVideos: [VKVideo] = [
        VKVideo(
            id: UUID().uuidString,
            title: "Ошуительное Хоу",
            urlString: "https://vkvideo.ru/video-165221845_456239061",
            thumbnailData: nil
        ),
        VKVideo(
            id: UUID().uuidString,
            title: "Шоу Разгон",
            urlString: "https://vkvideo.ru/video-221130436_456239787",
            thumbnailData: nil
        )
    ]

    // MARK: - Public API

    func loadVideos(for login: String) -> [VKVideo] {
        let key = key(for: login)

        // Если данных ещё нет — кладём дефолтные ролики и возвращаем их.
        guard let data = defaults.data(forKey: key) else {
            let defaultsForUser = Self.defaultVideos
            saveVideos(defaultsForUser, for: login)
            return defaultsForUser
        }

        // Если данные есть — пробуем декодировать.
        do {
            let videos = try JSONDecoder().decode([VKVideo].self, from: data)
            return videos
        } catch {
            print("VKVideoStorage decode error: \(error)")

            let defaultsForUser = Self.defaultVideos
            saveVideos(defaultsForUser, for: login)
            return defaultsForUser
        }
    }

    func saveVideos(_ videos: [VKVideo], for login: String) {
        let key = key(for: login)
        do {
            let data = try JSONEncoder().encode(videos)
            defaults.set(data, forKey: key)
        } catch {
            print("VKVideoStorage encode error: \(error)")
        }
    }
}

//
//  PostStorage.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import Foundation

/// Хранилище пользовательских постов по логину
final class PostStorage {

    static let shared = PostStorage()
    private init() { }

    // Теневая модель для хранения на диске
    private struct StoredPost: Codable {
        let id: String
        let author: String
        let text: String
        let imageName: String
        let likes: Int
        let views: Int
        let trackId: String?
    }

    private func fileURL(for login: String) -> URL {
        let fm = FileManager.default
        let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("posts_\(login).json")
    }

    // MARK: - Public API

    func loadPosts(for login: String) -> [ProfilePost] {
        let url = fileURL(for: login)
        guard FileManager.default.fileExists(atPath: url.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let stored = try JSONDecoder().decode([StoredPost].self, from: data)
            return stored.map {
                ProfilePost(
                    id: $0.id,
                    author: $0.author,
                    description: $0.text,
                    image: $0.imageName,
                    likes: $0.likes,
                    views: $0.views,
                    trackId: $0.trackId
                )
            }
        } catch {
            print("PostStorage: ошибка загрузки для \(login): \(error)")
            return []
        }
    }

    func savePosts(_ posts: [ProfilePost], for login: String) {
        let url = fileURL(for: login)
        let stored: [StoredPost] = posts.map {
            StoredPost(
                id: $0.id,
                author: $0.author,
                text: $0.description,
                imageName: $0.image,
                likes: $0.likes,
                views: $0.views,
                trackId: $0.trackId
            )
        }

        do {
            let data = try JSONEncoder().encode(stored)
            try data.write(to: url, options: [.atomic])
        } catch {
            print("PostStorage: ошибка сохранения для \(login): \(error)")
        }
    }

    func addPost(_ post: ProfilePost, for login: String) {
        var current = loadPosts(for: login)
        // новый пост наверх ленты
        current.insert(post, at: 0)
        savePosts(current, for: login)
    }

    func deletePost(withId id: String, for login: String) {
        var current = loadPosts(for: login)
        current.removeAll { $0.id == id }
        savePosts(current, for: login)
    }
}

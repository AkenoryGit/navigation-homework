//
//  Post.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import Foundation

// Основной тип поста профиля
public struct ProfilePost: Codable, Equatable {
    public let id: String
    public let author: String
    public let description: String
    public let image: String
    public let likes: Int
    public let views: Int
    /// Опциональный id трека из MusicStorage
    public let trackId: String?

    public init(
        id: String = UUID().uuidString,
        author: String,
        description: String,
        image: String,
        likes: Int,
        views: Int,
        trackId: String? = nil
    ) {
        self.id = id
        self.author = author
        self.description = description
        self.image = image
        self.likes = likes
        self.views = views
        self.trackId = trackId
    }
}

// Дефолтные посты (без треков, trackId по умолчанию = nil)
public let posts: [ProfilePost] = [
    ProfilePost(
        author: "catlover23",
        description: "Мой кот снова спит в раковине",
        image: "sleep_cat",
        likes: 128,
        views: 200
    ),
    ProfilePost(
        author: "travelmaniac",
        description: "Закат на Бали был нереальным",
        image: "bali_sunset",
        likes: 456,
        views: 870
    ),
    ProfilePost(
        author: "fitness_guru",
        description: "Сделал 100 отжиманий подряд",
        image: "pushups",
        likes: 342,
        views: 500
    ),
    ProfilePost(
        author: "nature_lover",
        description: "Утренняя прогулка по лесу",
        image: "forest_walk",
        likes: 215,
        views: 430
    )
]

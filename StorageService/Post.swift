//
//  Post.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import Foundation

public struct Post {
    public let title: String
    
    public init(title: String) {
        self.title = title
    }
}

public struct ProfilePost {
    public let author: String
    public let description: String
    public let image: String
    public let likes: Int
    public let views: Int
    
    public init(author: String, description: String, image: String, likes: Int, views: Int) {
        self.author = author
        self.description = description
        self.image = image
        self.likes = likes
        self.views = views
    }
}

public let posts: [ProfilePost] = [
    ProfilePost(author: "catlover23",
         description: "Мой кот снова спит в раковине",
         image: "sleep_cat",
         likes: 128,
         views: 200),
    
    ProfilePost(author: "travelmaniac",
         description: "Закат на Бали был нереальным",
         image: "bali_sunset",
         likes: 456,
         views: 870),
    
    ProfilePost(author: "fitness_guru",
         description: "Сделал 100 отжиманий подряд",
         image: "pushups",
         likes: 342,
         views: 500),
    
    ProfilePost(author: "nature_lover",
         description: "Утренняя прогулка по лесу",
         image: "forest_walk",
         likes: 215,
         views: 430)
]

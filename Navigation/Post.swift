//
//  Post.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import Foundation

struct Post {
    let title: String
}

struct ProfilePost {
    let author: String
    let description: String
    let image: String
    let likes: Int
    let views: Int
}

let posts: [ProfilePost] = [
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

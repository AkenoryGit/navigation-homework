//
//  TodoItem.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 18.08.2025.
//

import Foundation

struct TodoItem: Decodable {
    let userId: Int
    let id: Int
    let title: String
    let completed: Bool
}
    

//
//  Planet.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 15.08.2025.
//

import Foundation

struct Planet: Decodable {
    let name: String
    let climate: String?
    let terrain: String?
    let population: String?
    let url: String?
    
    enum CodingKeys: String, CodingKey {
        case name, climate, terrain, population, url
    }
}

struct PlanetResponse: Decodable {
    let results: [Planet]
}

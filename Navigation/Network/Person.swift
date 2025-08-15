//
//  Person.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 15.08.2025.
//

import Foundation

struct Person: Decodable {
    let name: String
    let height: String?
    let mass: String?
    let gender: String?
    let hairColor: String?
    let skinColor: String?
    let eyeColor: String?
    let birthYear: String?
    let homeworld: String?
    let films: [String]?
    let species: [String]?
    let vehicles: [String]?
    let starships: [String]?
    let url: String?
    let created: String?
    let edited: String?

    enum CodingKeys: String, CodingKey {
        case name
        case height
        case mass
        case gender
        case hairColor = "hair_color"
        case skinColor = "skin_color"
        case eyeColor = "eye_color"
        case birthYear = "birth_year"
        case homeworld
        case films
        case species
        case vehicles
        case starships
        case url
        case created
        case edited
    }
}

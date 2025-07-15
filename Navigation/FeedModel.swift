//
//  FeedModel.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 15.07.2025.
//

import UIKit

final class FeedModel {
    
    private let secretWord = "secret" 

    func check(word: String) -> Bool {
        return word.lowercased() == secretWord.lowercased()
    }
}

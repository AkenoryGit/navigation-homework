//
//  FeedViewModel.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 17.07.2025.
//

import Foundation

final class FeedViewModel {
    private let secretWord = "secret"

    func check(word: String) -> Bool {
        return word.lowercased() == secretWord.lowercased()
    }
}

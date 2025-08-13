//
//  PasswordBruteForcer.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 29.07.2025.
//

import Foundation

final class PasswordBruteForcer {

    private let allowedCharacters: [String] = {
        String().printable.map { String($0) }
    }()

    func bruteForce(passwordToUnlock: String, completion: @escaping (String) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var password = ""

            while password != passwordToUnlock {
                password = self.generateNextPassword(password)
            }

            DispatchQueue.main.async {
                completion(password)
            }
        }
    }
    
    func generateRandomPassword(length: Int) -> Result<String, PasswordError> {
        guard length > 0 else {
            return .failure(.invalidLeingth)
        }
        
        let characters = allowedCharacters.map { Character($0) }
        let password = String((0..<length).compactMap { _ in characters.randomElement() })
            
            return .success(password)
    }

    private func generateNextPassword(_ current: String) -> String {
        var str = current

        if str.isEmpty {
            return String(characterAt(0))
        } else {
            let lastChar = str.last!
            let lastIndex = indexOf(lastChar)
            str.replace(at: str.count - 1, with: characterAt((lastIndex + 1) % allowedCharacters.count))

            if indexOf(str.last!) == 0 {
                return generateNextPassword(String(str.dropLast())) + String(str.last!)
            }

            return str
        }
    }

    private func indexOf(_ character: Character?) -> Int {
        guard let char = character else { return 0 }
        return allowedCharacters.firstIndex(of: String(char)) ?? 0
    }

    private func characterAt(_ index: Int) -> Character {
        Character(allowedCharacters[index % allowedCharacters.count])
    }
}

extension String {
    var digits: String      { "0123456789" }
    var lowercase: String   { "abcdefghijklmnopqrstuvwxyz" }
    var uppercase: String   { "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var letters: String     { lowercase + uppercase }
    var printable: String   { digits + letters }

    mutating func replace(at index: Int, with character: Character) {
        var array = Array(self)
        array[index] = character
        self = String(array)
    }
}

enum PasswordError: Error {
    case invalidLeingth
}


//
//  Checker.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 07.07.2025.
//

import UIKit

final class Checker {
    
    static let shared = Checker() // Синглтон
    
    private let validLogin = "cat"
    private let validPassword = "1234"
    
    private init() {}
    
    func check(login: String, password: String) -> Bool {
        return login == validLogin && password == validPassword
    }
}

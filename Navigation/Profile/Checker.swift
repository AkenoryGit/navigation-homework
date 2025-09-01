//
//  Checker.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 07.07.2025.
//

import UIKit

final class Checker {
    static let shared = Checker()
    
    private let validLogin: String
    private let validPassword: String
    
    private init() {
#if DEBUG
        self.validLogin = "test@gmail.com"
        self.validPassword = "123456"
#else
        self.validLogin = "cat"
        self.validPassword = "1234"
#endif
    }
    
    func check(login: String, password: String) -> Bool {
        return login == validLogin && password == validPassword
    }
}

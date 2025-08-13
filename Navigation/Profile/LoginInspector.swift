//
//  LoginInspector.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 07.07.2025.
//

import Foundation

struct LoginInspector: LoginViewControllerDelegate {
    func check(login: String, password: String) -> Bool {
        return Checker.shared.check(login: login, password: password)
    }
}

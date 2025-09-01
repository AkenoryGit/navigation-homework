//
//  LoginFactory.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 07.07.2025.
//

import Foundation

protocol LoginFactory {
    func makeLoginInspector() -> LoginViewControllerDelegate
}

struct MyLoginFactory: LoginFactory {
    func makeLoginInspector() -> LoginViewControllerDelegate {
        let checkerService = CheckerService()
        return LoginInspector(checkerService: checkerService)
    }
}

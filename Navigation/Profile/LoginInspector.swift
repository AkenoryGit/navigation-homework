//
//  LoginInspector.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 07.07.2025.
//

import Foundation

final class LoginInspector: LoginViewControllerDelegate {
    private let checkerService: CheckerService

    init(checkerService: CheckerService) {
        self.checkerService = checkerService
    }

    func checkCredentials(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        checkerService.checkCredentials(email: email, password: password, completion: completion)
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        checkerService.signUp(email: email, password: password, completion: completion)
    }
}

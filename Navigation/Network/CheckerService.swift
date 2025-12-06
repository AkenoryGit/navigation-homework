//
//  CheckerService.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 21.08.2025.
//

import Foundation
import FirebaseAuth

final class CheckerService: CheckerServiceProtocol {

    func checkCredentials(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                print("Firebase sign up error:", error.localizedDescription)
                print("Полная ошибка:", error)
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}


//
//  CheckerServiceProtocol.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 21.08.2025.
//

import Foundation

protocol CheckerServiceProtocol {
    func checkCredentials(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

//
//  LoginViewControllerDelegate.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 07.07.2025.
//

import Foundation

protocol LoginViewControllerDelegate: AnyObject {
    func checkCredentials(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void)
}

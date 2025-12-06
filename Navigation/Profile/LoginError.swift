//
//  LoginError.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 07.08.2025.
//

import Foundation

enum LoginError: LocalizedError {
    case emptyLogin
    case emptyPassword
    case invalidCredentials
    case userNotFound
    case firebaseError(String)

    var errorDescription: String? {
        switch self {
        case .emptyLogin: return "Введите логин"
        case .emptyPassword: return "Введите пароль"
        case .invalidCredentials: return "Неверный логин или пароль"
        case .userNotFound: return "Пользователь не найден"
        case .firebaseError(let msg): return msg
        }
    }
}

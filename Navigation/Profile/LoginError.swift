//
//  LoginError.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 07.08.2025.
//

import Foundation

enum LoginError: Error {
    case emptyLogin
    case emptyPassword
    case invalidCredentials
    case userNotFound
}

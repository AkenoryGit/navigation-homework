//
//  User.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 03.07.2025.
//

import UIKit

class User {
    let login: String
    let fullName: String
    let avatar: UIImage
    let status: String

    init(login: String, fullName: String, avatar: UIImage, status: String) {
        self.login = login
        self.fullName = fullName
        self.avatar = avatar
        self.status = status
    }
}

protocol UserService {
    func getUser(login: String) -> User?
}

class CurrentUserService: UserService {
    private let currentUser: User

    init(user: User) {
        self.currentUser = user
    }

    func getUser(login: String) -> User? {
        return login == currentUser.login ? currentUser : nil
    }
}

final class TestUserService: UserService {
    
    private let testUser = User(
        login: "test",
        fullName: "Тестовый Пользователь",
        avatar: UIImage(named: "cat") ?? UIImage(),
        status: "Это тестовый статус"
    )
    
    func getUser(login: String) -> User? {
        return login == testUser.login ? testUser : nil
    }
}

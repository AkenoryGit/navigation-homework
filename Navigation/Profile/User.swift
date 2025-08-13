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
    var user: User { get set }
    func getUser(login: String) -> User?
}

extension UserService {
    func getUser(login: String) -> User? {
        return login == user.login ? user : nil
    }
}

class CurrentUserService: UserService {
    var user: User

    init(user: User) {
        self.user = user
    }
}

final class TestUserService: UserService {
    var user: User = User(
        login: "test",
        fullName: "Тестовый Пользователь",
        avatar: UIImage(named: "cat") ?? UIImage(),
        status: "Это тестовый статус"
    )
}

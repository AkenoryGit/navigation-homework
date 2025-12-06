//
//  UserRealm.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.09.2025.
//

import Foundation
import RealmSwift

final class UserRealm: Object {

    // MARK: - Поля

    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var login: String           // email/логин
    @Persisted var password: String        // пароль
    @Persisted var nickname: String        // никнейм для отображения
    @Persisted var status: String          // статус в профиле
    @Persisted var avatarData: Data?       // аватар

    // MARK: - Инициализатор

    convenience init(
        login: String,
        password: String,
        nickname: String = "",
        status: String = "",
        avatarData: Data? = nil
    ) {
        self.init()
        self.login = login
        self.password = password
        self.nickname = nickname
        self.status = status
        self.avatarData = avatarData
    }
}

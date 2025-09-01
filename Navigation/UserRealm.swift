//
//  UserRealm.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.09.2025.
//

import Foundation
import RealmSwift

class UserRealm: Object {
    @Persisted(primaryKey: true) var login: String
    @Persisted var password: String
}

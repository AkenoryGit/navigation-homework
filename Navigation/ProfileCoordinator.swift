//
//  ProfileCoordinator.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 22.07.2025.
//

import UIKit

/// Координатор экрана профиля
final class ProfileCoordinator {

    // MARK: - Public

    /// Навигационный контроллер с профилем
    private(set) var controller: UINavigationController = UINavigationController()

    /// Колбэк, который должен вызывать переход к экрану логина
    var onLogout: (() -> Void)?

    // MARK: - Public methods

    func start(with user: User) {
        let profileVC = ProfileViewController()
        profileVC.user = user

        // Пробрасываем событие "Выйти" выше, в координатор
        profileVC.onLogout = { [weak self] in
            self?.onLogout?()
        }

        controller = UINavigationController(rootViewController: profileVC)
    }
}

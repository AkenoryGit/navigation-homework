//
//  ProfileCoordinator.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 22.07.2025.
//

import UIKit

final class ProfileCoordinator {
    let navigationController = UINavigationController()

    func start() {
    #if DEBUG
        let userService = TestUserService()
    #else
        let userService = CurrentUserService(user: User(
            login: "cat",
            fullName: "Hipster Cat",
            avatar: UIImage(named: "cat") ?? UIImage(),
            status: "Waiting for something..."
        ))
    #endif

        let loginFactory = MyLoginFactory()
        let loginInspector = loginFactory.makeLoginInspector()

        let loginVC = LogInViewController(userService: userService)
        loginVC.loginDelegate = loginInspector
        loginVC.onLoginSuccess = { [weak self] user in
            self?.showProfile(user: user)
        }

        navigationController.viewControllers = [loginVC]
    }

    private func showProfile(user: User) {
        let profileVC = ProfileViewController()
        profileVC.user = user
        navigationController.setViewControllers([profileVC], animated: true)
    }
}

//
//  AppCoordinator.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 22.07.2025.
//

import UIKit
import RealmSwift

final class AppCoordinator {
    private let window: UIWindow
    private let configuration: AppConfiguration
    private let tabBarController = UITabBarController()

    private let feedCoordinator = FeedCoordinator()
    private let profileCoordinator = ProfileCoordinator()

    init(window: UIWindow, configuration: AppConfiguration) {
        self.window = window
        self.configuration = configuration
    }

    func start() {
        do {
            let realm = try Realm()
            if let savedUser = realm.objects(UserRealm.self).first {
                print("Найден сохранённый пользователь: \(savedUser.login)")
                let user = User(
                    login: savedUser.login,
                    fullName: savedUser.login,
                    avatar: UIImage(named: "cat") ?? UIImage(),
                    status: "Автовход"
                )
                launchTabBarFlow(savedUser: user)
            } else {
                launchLoginFlow()
            }
        } catch {
            print("Ошибка при работе с Realm: \(error.localizedDescription)")
            launchLoginFlow()
        }
    }

    private func launchTabBarFlow(savedUser: User) {
        feedCoordinator.setup()
        profileCoordinator.start(with: savedUser)

        profileCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(systemName: "person"),
            tag: 1
        )

        tabBarController.viewControllers = [
            profileCoordinator.navigationController,
            feedCoordinator.controller
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func launchLoginFlow() {
        let checkerService = CheckerService()
        let inspector = LoginInspector(checkerService: checkerService)
        let userService = TestUserService()

        let loginVC = LogInViewController(userService: userService, loginDelegate: inspector)
        loginVC.onLoginSuccess = { [weak self] user in
            self?.launchTabBarFlow(savedUser: user)
        }

        let navController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
}

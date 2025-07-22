//
//  AppCoordinator.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 22.07.2025.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let tabBarController = UITabBarController()

    private let feedCoordinator = FeedCoordinator()
    private let profileCoordinator = ProfileCoordinator()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        feedCoordinator.start()
        profileCoordinator.start()

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

        profileCoordinator.navigationController.viewControllers = [loginVC]

        feedCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Лента", image: UIImage(systemName: "list.bullet"), tag: 0)
        profileCoordinator.navigationController.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person"), tag: 1)

        tabBarController.viewControllers = [
            feedCoordinator.navigationController,
            profileCoordinator.navigationController
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

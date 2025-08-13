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
        feedCoordinator.setup()
        profileCoordinator.start()

        profileCoordinator.navigationController.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(systemName: "person"),
            tag: 1
        )

        tabBarController.viewControllers = [
            feedCoordinator.controller,
            profileCoordinator.navigationController
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

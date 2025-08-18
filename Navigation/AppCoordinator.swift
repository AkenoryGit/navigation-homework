//
//  AppCoordinator.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 22.07.2025.
//


import UIKit

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
        switch configuration {
        case .people:
            NetworkService.request(url: AppConfiguration.people.url) { (people: [Person]) in
                print("Загружено людей: \(people.count)")
            }
        case .starships:
            NetworkService.request(url: AppConfiguration.starships.url) { (starships: [Starship]) in
                print("Загружено кораблей: \(starships.count)")
            }
        case .planets:
            NetworkService.request(url: AppConfiguration.planets.url) { (planets: [Planet]) in
                print("Загружено планет: \(planets.count)")
            }
        }

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

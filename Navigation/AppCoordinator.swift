//
//  AppCoordinator.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 22.07.2025.
//

import UIKit
import RealmSwift

final class AppCoordinator {

    // MARK: - Private properties

    private let window: UIWindow
    private let tabBarController = UITabBarController()

    private let profileCoordinator = ProfileCoordinator()

    // MARK: - Init

    init(window: UIWindow) {
        self.window = window
    }

    // MARK: - Public methods

    func start() {
        do {
            let realm = try Realm()

            if let savedUser = realm.objects(UserRealm.self).first {
                print("Найден сохранённый пользователь: \(savedUser.login)")

                // Аватар
                let avatarImage: UIImage
                if let data = savedUser.avatarData,
                   let image = UIImage(data: data) {
                    avatarImage = image
                } else {
                    avatarImage = UIImage(systemName: "person.crop.circle") ?? UIImage()
                }

                // Никнейм
                let displayName: String
                if !savedUser.nickname.isEmpty {
                    displayName = savedUser.nickname
                } else {
                    let nicknameKey = "nickname_\(savedUser.login)"
                    displayName = UserDefaults.standard.string(forKey: nicknameKey) ?? savedUser.login
                }

                // Статус
                let statusText: String
                if !savedUser.status.isEmpty {
                    statusText = savedUser.status
                } else {
                    let statusKey = "status_\(savedUser.login)"
                    statusText = UserDefaults.standard.string(forKey: statusKey) ?? "Online"
                }

                // 4. Собираем модель User для UI
                let user = User(
                    login: savedUser.login,
                    fullName: displayName,
                    avatar: avatarImage,
                    status: statusText
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

    // MARK: - Private methods

    private func launchTabBarFlow(savedUser: User) {
        // Профиль
        profileCoordinator.start(with: savedUser)

        // Подписываемся на logout из профиля
        profileCoordinator.onLogout = { [weak self] in
            print("AppCoordinator: logout из профиля")
            self?.launchLoginFlow()
        }

        let profileController = profileCoordinator.controller
        profileController.tabBarItem = UITabBarItem(
            title: "Профиль",
            image: UIImage(systemName: "person"),
            tag: 0
        )

        // Настройки
        let settingsVC = SettingsViewController()
        settingsVC.currentLogin = savedUser.login
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(
            title: "Настройки",
            image: UIImage(systemName: "gearshape"),
            tag: 1
        )

        // Карта
        let mapVC = MapViewController()
        let mapNav = UINavigationController(rootViewController: mapVC)
        mapNav.tabBarItem = UITabBarItem(
            title: "Карта",
            image: UIImage(systemName: "map"),
            tag: 2
        )

        // Избранное
        let favoritesVC = FavoritesViewController()
        favoritesVC.currentLogin = savedUser.login
        let favoritesNav = UINavigationController(rootViewController: favoritesVC)
        favoritesNav.tabBarItem = UITabBarItem(
            title: "Избранное",
            image: UIImage(systemName: "star"),
            tag: 3
        )

        tabBarController.viewControllers = [
            profileController,
            favoritesNav,
            mapNav,
            settingsNav
        ]

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }

    private func launchLoginFlow() {
        let loginFactory = MyLoginFactory()
        let loginInspector = loginFactory.makeLoginInspector()
        let userService = TestUserService()

        let loginVC = LogInViewController(
            userService: userService,
            loginDelegate: loginInspector
        )

        loginVC.onLoginSuccess = { [weak self] user in
            self?.launchTabBarFlow(savedUser: user)
        }

        let navController = UINavigationController(rootViewController: loginVC)
        window.rootViewController = navController
        window.makeKeyAndVisible()
    }
}

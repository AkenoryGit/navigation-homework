//
//  SceneDelegate.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let coordinator = AppCoordinator(window: window)
        self.appCoordinator = coordinator
        coordinator.start()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        try? Auth.auth().signOut()
    }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }
}

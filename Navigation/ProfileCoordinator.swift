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
        let profileVC = ProfileViewController()
        navigationController.viewControllers = [profileVC]
    }
}

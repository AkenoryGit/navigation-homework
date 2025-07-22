//
//  FeedCoordinator.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 22.07.2025.
//

import UIKit

final class FeedCoordinator {
    let navigationController = UINavigationController()

    func start() {
        let feedVC = FeedViewController()
        navigationController.viewControllers = [feedVC]
    }
}

//
//  FeedCoordinator.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 22.07.2025.
//

import UIKit
import StorageService

final class FeedCoordinator {
    let navigationController = UINavigationController()

    func start() {
        let feedVC = FeedViewController()
        feedVC.coordinator = self
        navigationController.viewControllers = [feedVC]
    }

    func showPost(post: Post) {
        let postVC = PostViewController(post: post)
        navigationController.pushViewController(postVC, animated: true)
    }
    
}

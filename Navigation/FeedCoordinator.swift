//
//  FeedCoordinator.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 22.07.2025.
//

import UIKit

protocol Coordinator: AnyObject {
    var controller: UIViewController { get }
    var children: [Coordinator] { get set }
    
    func setup()
}

final class FeedCoordinator: Coordinator {
    var controller: UIViewController
    var children: [Coordinator]

    private let feedVC = FeedViewController()
    private let feedNC: UINavigationController

    enum Presentation {
        case post1
        case post2
    }

    init() {
        self.children = []
        self.feedNC = UINavigationController(rootViewController: feedVC)
        self.feedNC.tabBarItem = UITabBarItem(title: "Лента", image: UIImage(systemName: "list.bullet"), tag: 0)
        self.controller = feedNC
    }

    func setup() {
        feedVC.coordinator = self
    }

    func present(_ presentation: Presentation) {
        switch presentation {
        case .post1:
            let post = Post(title: "Пост №1")
            let postVC = PostViewController(post: post)
            feedNC.pushViewController(postVC, animated: true)
        case .post2:
            let post = Post(title: "Пост №2")
            let postVC = PostViewController(post: post)
            feedNC.pushViewController(postVC, animated: true)
        }
    }
}

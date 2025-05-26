//
//  FeedViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit

class FeedViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Лента"
        
        let button1 = UIButton(type: .system)
        button1.setTitle("Пост 1", for: .normal)
        button1.addTarget(self, action: #selector(openPost1), for: .touchUpInside)
        
        let button2 = UIButton(type: .system)
        button2.setTitle("Пост 2", for: .normal)
        button2.addTarget(self, action: #selector(openPost2), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [button1, button2])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
        
    @objc func openPost1() {
        let post = Post(title: "Пост №1")
        let postVC = PostViewController(post: post)
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    @objc func openPost2() {
        let post = Post(title: "Пост №2")
        let postVC = PostViewController(post: post)
        navigationController?.pushViewController(postVC, animated: true)
    }
    
    
}


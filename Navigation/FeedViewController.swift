//
//  FeedViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit

class FeedViewController: UIViewController {
    
    private let firstPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Post 1", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let secondPostButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Open Post 2", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [firstPostButton, secondPostButton])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        title = "Feed"
        
        view.addSubview(stackView)

        firstPostButton.addTarget(self, action: #selector(openPost), for: .touchUpInside)
        secondPostButton.addTarget(self, action: #selector(openPost), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            firstPostButton.heightAnchor.constraint(equalToConstant: 44),
            secondPostButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func openPost() {
        let post = Post(title: "Пример поста")
        let postVC = PostViewController(post: post)
        navigationController?.pushViewController(postVC, animated: true)
    }
    
}

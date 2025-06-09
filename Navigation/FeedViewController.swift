//
//  FeedViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit

class FeedViewController: UIViewController {

    private let button1: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Пост 1", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let button2: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Пост 2", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Лента"

        button1.addTarget(self, action: #selector(openPost1), for: .touchUpInside)
        button2.addTarget(self, action: #selector(openPost2), for: .touchUpInside)

        setupView()
        setupConstraints()
    }

    private func setupView() {
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        view.addSubview(stackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc private func openPost1() {
        let post = Post(title: "Пост №1")
        let postVC = PostViewController(post: post)
        navigationController?.pushViewController(postVC, animated: true)
    }

    @objc private func openPost2() {
        let post = Post(title: "Пост №2")
        let postVC = PostViewController(post: post)
        navigationController?.pushViewController(postVC, animated: true)
    }
}


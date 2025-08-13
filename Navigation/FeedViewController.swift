//
//  FeedViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit
import StorageService

class FeedViewController: UIViewController {
    
    private let viewModel = FeedViewModel()
    
    weak var coordinator: FeedCoordinator?

    private lazy var button1 = CustomButton(title: "Открыть пост 1") { [weak self] in
        self?.coordinator?.present(.post1)
    }
    
    private lazy var button2 = CustomButton(title: "Открыть пост 2") { [weak self] in
        self?.coordinator?.present(.post2)
    }
    
    private let guessTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите пароль"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var checkGuessButton = CustomButton(title: "Проверить") { [weak self] in
        guard let self = self else { return }
        let guess = self.guessTextField.text ?? ""
        let isCorrect = self.viewModel.check(word: guess)
        
        self.resultLabel.text = isCorrect ? "Верно!" : "Неверно!"
        self.resultLabel.textColor = isCorrect ? .systemGreen : .systemRed
        UIView.animate(withDuration: 0.3) {
            self.resultLabel.alpha = 1
        }
    }

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 10
        sv.alignment = .center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        label.alpha = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Лента"

        setupView()
        setupConstraints()
    }

    private func setupView() {
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(guessTextField)
        stackView.addArrangedSubview(checkGuessButton)
        stackView.addArrangedSubview(resultLabel)
        view.addSubview(stackView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            resultLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }

}


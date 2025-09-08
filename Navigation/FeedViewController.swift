//
//  FeedViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit

class FeedViewController: UIViewController {
    
    private let viewModel = FeedViewModel()
    
    weak var coordinator: FeedCoordinator?
    
    private let planetsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Планеты", for: .normal)
        return button
    }()

    private let peopleButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Люди", for: .normal)
        return button
    }()

    private let starshipsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Корабли", for: .normal)
        return button
    }()

    private lazy var buttonsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [planetsButton, peopleButton, starshipsButton])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

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
        stackView.addArrangedSubview(buttonsStack)
        stackView.addArrangedSubview(button1)
        stackView.addArrangedSubview(button2)
        stackView.addArrangedSubview(guessTextField)
        stackView.addArrangedSubview(checkGuessButton)
        stackView.addArrangedSubview(resultLabel)
        view.addSubview(stackView)
        
        planetsButton.addTarget(self, action: #selector(openPlanets), for: .touchUpInside)
        peopleButton.addTarget(self, action: #selector(openPeople), for: .touchUpInside)
        starshipsButton.addTarget(self, action: #selector(openStarships), for: .touchUpInside)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            resultLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc private func openPlanets() {
        let planetsVC = PlanetsViewController()
        navigationController?.pushViewController(planetsVC, animated: true)
    }

    @objc private func openPeople() {
        let peopleVC = PeopleViewController()
        navigationController?.pushViewController(peopleVC, animated: true)
    }

    @objc private func openStarships() {
        let starshipsVC = StarshipsViewController()
        navigationController?.pushViewController(starshipsVC, animated: true)
    }

}


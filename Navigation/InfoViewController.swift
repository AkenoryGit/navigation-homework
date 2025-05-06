//
//  InfoViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit

class InfoViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        title = "Инфо"
        
        let button = UIButton(type: .system)
        button.setTitle("Показать алерт", for: .normal)
        button.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
    @objc func showAlert() {
        let alert = UIAlertController(title: "Заголовок", message: "Сообщение", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "ОК", style: .default) { _ in
            print("Нажали ОК")
        }
        let action2 = UIAlertAction(title: "Отмена", style: .default) { _ in
            print("Нажали Отмена")
        }
        alert.addAction(action1)
        alert.addAction(action2)
        present(alert, animated: true)
    }
}

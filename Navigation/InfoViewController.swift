//
//  InfoViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit

class InfoViewController: UIViewController {
    
    private let residentsTableView = UITableView()

    private var residents: [Resident] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let orbitalPeriodLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        title = "Инфо"
        
        let button = UIButton(type: .system)
        button.setTitle("Показать алерт", for: .normal)
        button.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        
        residentsTableView.dataSource = self
        residentsTableView.translatesAutoresizingMaskIntoConstraints = false
        residentsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "ResidentCell")
        
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        view.addSubview(titleLabel)
        view.addSubview(orbitalPeriodLabel)
        view.addSubview(residentsTableView)
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: button.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            orbitalPeriodLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            orbitalPeriodLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            orbitalPeriodLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            residentsTableView.topAnchor.constraint(equalTo: orbitalPeriodLabel.bottomAnchor, constant: 20),
            residentsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            residentsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            residentsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        fetchTodoUsingJSONSerialization()
        fetchPlanetData()
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
    
    func fetchTodoUsingJSONSerialization() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1") else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Ошибка: \(error?.localizedDescription ?? "нет данных")")
                return
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions()) as? [String: Any],
                   let title = json["title"] as? String {
                    print("Заголовок: \(title)")
                    
                    DispatchQueue.main.async {
                        self.titleLabel.text = title
                    }

                }
            } catch {
                print("Ошибка при парсинге JSON: \(error)")
            }
        }

        task.resume()
    }
    
    func fetchPlanetData() {
        guard let url = URL(string: "https://swapi.py4e.com/api/planets/1") else { return }

        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Ошибка при получении данных планеты: \(error?.localizedDescription ?? "нет данных")")
                return
            }

            do {
                let planet = try JSONDecoder().decode(PlanetSingle.self, from: data)
                print("Планета: \(planet.name), Период обращения: \(planet.orbitalPeriod)")

                DispatchQueue.main.async {
                    self.orbitalPeriodLabel.text = "Orbital Period: \(planet.orbitalPeriod)"
                    self.loadResidents(from: planet.residents)
                }
            } catch {
                print("Ошибка декодирования планеты: \(error)")
            }
        }

        task.resume()
    }
    
    func loadResidents(from urls: [String]) {
        for urlString in urls {
            guard let url = URL(string: urlString) else { continue }

            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else {
                    print("Ошибка при загрузке жителя: \(error?.localizedDescription ?? "нет данных")")
                    return
                }

                do {
                    let resident = try JSONDecoder().decode(Resident.self, from: data)
                    DispatchQueue.main.async {
                        self.residents.append(resident)
                        self.residentsTableView.reloadData()
                    }
                } catch {
                    print("Ошибка декодирования жителя: \(error)")
                }
            }

            task.resume()
        }
    }
}

extension InfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return residents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResidentCell", for: indexPath)
        cell.textLabel?.text = residents[indexPath.row].name
        return cell
    }
}

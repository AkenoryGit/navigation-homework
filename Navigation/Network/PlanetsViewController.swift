//
//  PlanetsViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 15.08.2025.
//

import UIKit

class PlanetsViewController: UIViewController {

    private var planets: [Planet] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Планеты"

        setupTableView()
        fetchPlanets()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.dataSource = self
    }

    private func fetchPlanets() {
        NetworkService.request(url: AppConfiguration.planets.url) { [weak self] planets in
            DispatchQueue.main.async {
                self?.planets = planets
                self?.tableView.reloadData()
            }
        }
    }
}

extension PlanetsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        planets.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let planet = planets[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = planet.name
        return cell
    }
}

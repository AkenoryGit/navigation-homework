//
//  StarshipsViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 15.08.2025.
//

import UIKit

class StarshipsViewController: UIViewController {

    private var starships: [Starship] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Корабли"
        view.backgroundColor = .systemBackground

        setupTableView()

        NetworkService.request(for: .starships) { (starships: [Starship]) in
            DispatchQueue.main.async {
                self.starships = starships
                self.tableView.reloadData()
            }
        }
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StarshipCell")
    }
}

extension StarshipsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return starships.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let starship = starships[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "StarshipCell", for: indexPath)
        cell.textLabel?.text = "\(starship.name) — \(starship.model)"
        return cell
    }
}

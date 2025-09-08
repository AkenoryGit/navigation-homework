//
//  FavoritesViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 05.09.2025.
//

import UIKit
import CoreData

class FavoritesViewController: UIViewController {

    private var savedPosts: [SavedPost] = []
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Избранное"
        view.backgroundColor = .white

        setupTableView()
        fetchSavedPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchSavedPosts()
    }

    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: "PostCell")
        view.addSubview(tableView)
    }

    private func fetchSavedPosts() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<SavedPost> = SavedPost.fetchRequest()

        do {
            savedPosts = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Не удалось загрузить посты: \(error.localizedDescription)")
        }
    }
}

extension FavoritesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return savedPosts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as? PostTableViewCell else {
            return UITableViewCell()
        }

        let saved = savedPosts[indexPath.row]

        let profilePost = ProfilePost(
            id: saved.id ?? UUID().uuidString,
            author: saved.author ?? "Автор неизвестен",
            description: saved.text ?? "",
            image: saved.imageName ?? "",
            likes: Int(saved.likes),
            views: Int(saved.views)
        )

        cell.configure(with: profilePost)
        cell.delegate = nil

        return cell
    }
}

extension FavoritesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let postToDelete = savedPosts[indexPath.row]

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let context = appDelegate.persistentContainer.viewContext

            context.delete(postToDelete)

            do {
                try context.save()
                savedPosts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                print("Ошибка при удалении поста: \(error.localizedDescription)")
            }
        }
    }
}


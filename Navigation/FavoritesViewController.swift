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
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Сбросить", style: .plain, target: self, action: #selector(resetFilter)),
            UIBarButtonItem(title: "Поиск", style: .plain, target: self, action: #selector(showAuthorSearchAlert))
        ]

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

    private func fetchSavedPosts(filterByAuthor: String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext

        let fetchRequest: NSFetchRequest<SavedPost> = SavedPost.fetchRequest()

        if let author = filterByAuthor {
            fetchRequest.predicate = NSPredicate(format: "author CONTAINS[cd] %@", author)
        }

        do {
            savedPosts = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Не удалось загрузить посты: \(error.localizedDescription)")
        }
    }
    
    @objc private func showAuthorSearchAlert() {
        let alert = UIAlertController(title: "Поиск по автору", message: "Введите имя автора", preferredStyle: .alert)
        alert.addTextField()

        let searchAction = UIAlertAction(title: "Найти", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let author = alert.textFields?.first?.text, !author.isEmpty {
                self.fetchSavedPosts(filterByAuthor: author)
            }
        }

        alert.addAction(searchAction)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func resetFilter() {
        fetchSavedPosts()
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
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            guard let self = self else { return }
            let postToDelete = self.savedPosts[indexPath.row]

            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let backgroundContext = appDelegate.persistentContainer.newBackgroundContext()
            backgroundContext.perform {
                if let objectID = postToDelete.objectID as? NSManagedObjectID,
                   let backgroundPost = try? backgroundContext.existingObject(with: objectID) {
                    backgroundContext.delete(backgroundPost)

                    do {
                        try backgroundContext.save()
                        DispatchQueue.main.async {
                            self.savedPosts.remove(at: indexPath.row)
                            tableView.deleteRows(at: [indexPath], with: .automatic)
                            completion(true)
                        }
                    } catch {
                        print("Ошибка удаления в backgroundContext: \(error)")
                        DispatchQueue.main.async {
                            completion(false)
                        }
                    }
                }
            }
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}


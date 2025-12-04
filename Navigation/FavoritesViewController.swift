//
//  FavoritesViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 05.09.2025.
//

import UIKit
import CoreData
import RealmSwift

/// Экран избранных постов, сохранённых в Core Data (FavoritePost)
final class FavoritesViewController: UIViewController {

    // MARK: - Public

    /// Логин текущего пользователя, чтобы показывать только его избранное
    var currentLogin: String?

    // MARK: - Data

    private var favoritePosts: [FavoritePost] = []

    // MARK: - UI

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = AppColors.background
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.register(PostTableViewCell.self,
                           forCellReuseIdentifier: PostTableViewCell.identifier)
        return tableView
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Избранное"
        view.backgroundColor = AppColors.background

        setupNavigationItems()
        setupTableView()
        fetchFavoritePosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavoritePosts()
    }

    // MARK: - Setup

    private func setupNavigationItems() {
        let resetItem = UIBarButtonItem(
            title: "Сбросить",
            style: .plain,
            target: self,
            action: #selector(resetFilter)
        )

        let searchItem = UIBarButtonItem(
            title: "Поиск",
            style: .plain,
            target: self,
            action: #selector(showSearchAlert)
        )

        navigationItem.rightBarButtonItems = [resetItem, searchItem]
    }

    private func setupTableView() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    // MARK: - Core Data

    private func fetchFavoritePosts(filterText: String? = nil) {
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<FavoritePost> = FavoritePost.fetchRequest()

        var predicates: [NSPredicate] = []

        if let login = currentLogin {
            predicates.append(NSPredicate(format: "login == %@", login))
        }

        if let text = filterText, !text.isEmpty {
            predicates.append(
                NSPredicate(format: "(author CONTAINS[cd] %@) OR (text CONTAINS[cd] %@)", text, text)
            )
        }

        if !predicates.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }

        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            favoritePosts = try context.fetch(fetchRequest)
            tableView.reloadData()
        } catch {
            print("Не удалось загрузить избранные посты: \(error.localizedDescription)")
        }
    }

    // MARK: - Nickname helper

    /// Актуальное отображаемое имя пользователя
    private func currentDisplayName() -> String {
        guard let login = currentLogin else { return "" }

        do {
            let realm = try Realm()
            if let userObject = realm.objects(UserRealm.self)
                .filter("login == %@", login)
                .first {

                let nicknameKey = "nickname_\(login)"
                let nicknameFromDefaults = UserDefaults.standard.string(forKey: nicknameKey)

                if !userObject.nickname.isEmpty {
                    return userObject.nickname
                } else if let stored = nicknameFromDefaults, !stored.isEmpty {
                    return stored
                } else {
                    return login
                }
            }
        } catch {
            print("FavoritesVC: ошибка чтения Realm для никнейма: \(error)")
        }

        let nicknameKey = "nickname_\(login)"
        if let stored = UserDefaults.standard.string(forKey: nicknameKey),
           !stored.isEmpty {
            return stored
        } else {
            return login
        }
    }

    // MARK: - Actions

    @objc private func showSearchAlert() {
        let alert = UIAlertController(
            title: "Поиск",
            message: "Введите автора или слово из описания",
            preferredStyle: .alert
        )
        alert.addTextField { textField in
            textField.placeholder = "Автор или фраза из поста"
            textField.font = AppFonts.body()
        }

        let searchAction = UIAlertAction(title: "Найти", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let query = alert.textFields?.first?.text ?? ""
            self.fetchFavoritePosts(filterText: query)
        }

        alert.addAction(searchAction)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    @objc private func resetFilter() {
        fetchFavoritePosts()
    }
}

// MARK: - UITableViewDataSource

extension FavoritesViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        favoritePosts.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: PostTableViewCell.identifier,
            for: indexPath
        ) as? PostTableViewCell else {
            return UITableViewCell()
        }

        let favorite = favoritePosts[indexPath.row]

        // Автор — всегда текущий никнейм пользователя
        let defaultAuthor = favorite.author ?? "Автор неизвестен"
        let displayAuthor: String
        let name = currentDisplayName()
        if !name.isEmpty {
            displayAuthor = name
        } else {
            displayAuthor = defaultAuthor
        }

        let profilePost = ProfilePost(
            id: favorite.id ?? UUID().uuidString,
            author: displayAuthor,
            description: favorite.text ?? "",
            image: favorite.imageName ?? "",
            likes: Int(favorite.likes),
            views: Int(favorite.views),
            trackId: favorite.trackId
        )

        cell.configure(with: profilePost)
        cell.delegate = nil   // В избранном двойной тап ничего не должен менять
        cell.isLikeInteractionEnabled = false

        cell.onTrackTapped = { [weak self] in
            guard
                let self = self,
                let trackId = favorite.trackId,
                let startIndex = MusicStorage.shared.allTracks.firstIndex(where: { $0.id == trackId })
            else {
                return
            }

            let playerVC = MusicTrackPlayerViewController()
            playerVC.tracks = MusicStorage.shared.allTracks
            playerVC.startIndex = startIndex
            self.navigationController?.pushViewController(playerVC, animated: true)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension FavoritesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Удалить"
        ) { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }

            let postToDelete = self.favoritePosts[indexPath.row]
            let context = CoreDataManager.shared.context
            context.delete(postToDelete)

            do {
                try context.save()
                self.favoritePosts.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completion(true)
            } catch {
                print("Ошибка удаления из Core Data: \(error)")
                completion(false)
            }
        }

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

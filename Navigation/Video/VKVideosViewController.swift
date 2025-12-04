//
//  VKVideosViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import UIKit

final class VKVideosViewController: UIViewController {

    // MARK: - Public

    /// Логин текущего пользователя, обязателен
    var userLogin: String!

    // MARK: - Private

    private var videos: [VKVideo] = []
    private var filteredVideos: [VKVideo] = []

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let searchController = UISearchController(searchResultsController: nil)

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "VK Видео"
        view.backgroundColor = AppColors.background

        setupTableView()
        setupNavigation()
        setupSearch()

        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.largeTitleDisplayMode = .never
    }

    // MARK: - Setup

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.register(VKVideoTableViewCell.self,
                           forCellReuseIdentifier: VKVideoTableViewCell.reuseId)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 86
        tableView.tableFooterView = UIView()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigation() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addVideoTapped)
        )
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по названию или ссылке"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Data

    private func loadData() {
        guard let login = userLogin else {
            assertionFailure("userLogin должен быть установлен перед показом VKVideosViewController")
            return
        }
        videos = VKVideoStorage.shared.loadVideos(for: login)
        applyFilterAndReload()
    }

    private func saveData() {
        guard let login = userLogin else { return }
        VKVideoStorage.shared.saveVideos(videos, for: login)
    }

    private func applyFilterAndReload() {
        let searchText = searchController.searchBar.text?.lowercased() ?? ""

        if searchText.isEmpty {
            filteredVideos = videos
        } else {
            filteredVideos = videos.filter {
                $0.title.lowercased().contains(searchText)
                || $0.urlString.lowercased().contains(searchText)
            }
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Actions

    @objc private func addVideoTapped() {
        let alert = UIAlertController(
            title: "Добавить VK-видео",
            message: "Вставьте ссылку на страницу видео",
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = "Ссылка на видео (https://vk.com/...)"
            tf.keyboardType = .URL
            tf.autocapitalizationType = .none
        }

        alert.addTextField { tf in
            tf.placeholder = "Название (опционально)"
        }

        let addAction = UIAlertAction(title: "Добавить", style: .default) { [weak self] _ in
            guard let self = self else { return }

            let urlString = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let titleText = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines)

            guard !urlString.isEmpty, let url = URL(string: urlString) else {
                self.showSimpleAlert("Некорректная ссылка", "Проверьте URL VK-видео.")
                return
            }

            let title = titleText?.isEmpty == false ? titleText! : "VK Video"

            var newVideo = VKVideo(
                id: UUID().uuidString,
                title: title,
                urlString: url.absoluteString,
                thumbnailData: nil
            )

            self.videos.append(newVideo)
            self.saveData()
            self.applyFilterAndReload()

            let insertedIndex = self.videos.count - 1

            // Асинхронно подтягиваем превью
            self.fetchThumbnail(for: url) { [weak self] data in
                guard let self = self else { return }
                guard let data = data else {
                    return
                }

                // Безопасно убеждаемся, что индекс ещё валиден
                guard insertedIndex < self.videos.count,
                      self.videos[insertedIndex].id == newVideo.id else {
                    return
                }

                self.videos[insertedIndex].thumbnailData = data
                self.saveData()
                self.applyFilterAndReload()
            }
        }

        alert.addAction(addAction)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    private func showSimpleAlert(_ title: String, _ message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Thumbnail fetching (og:image)

    private func fetchThumbnail(for url: URL, completion: @escaping (Data?) -> Void) {
        // Загружаем HTML страницы видео
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard error == nil, let data = data,
                  let html = String(data: data, encoding: .utf8) else {
                completion(nil)
                return
            }

            // Пытаемся вытащить og:image
            guard let imageURLString = self.extractOGImage(from: html),
                  let imageURL = URL(string: imageURLString) else {
                completion(nil)
                return
            }

            // Скачиваем саму картинку
            URLSession.shared.dataTask(with: imageURL) { imageData, _, _ in
                completion(imageData)
            }.resume()

        }.resume()
    }

    private func extractOGImage(from html: String) -> String? {
        let pattern = #"property=\"og:image\"[^\>]*content=\"([^\"]+)\""#
        guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
            return nil
        }

        let range = NSRange(html.startIndex..<html.endIndex, in: html)
        guard let match = regex.firstMatch(in: html, options: [], range: range),
              match.numberOfRanges >= 2,
              let urlRange = Range(match.range(at: 1), in: html) else {
            return nil
        }

        return String(html[urlRange])
    }
}

// MARK: - UITableViewDataSource

extension VKVideosViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        filteredVideos.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: VKVideoTableViewCell.reuseId,
            for: indexPath
        ) as? VKVideoTableViewCell else {
            return UITableViewCell()
        }

        let video = filteredVideos[indexPath.row]
        cell.configure(with: video)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension VKVideosViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let video = filteredVideos[indexPath.row]
        guard let url = video.url else { return }

        let playerVC = VKVideoPlayerViewController(url: url)
        navigationController?.pushViewController(playerVC, animated: true)
    }

    // Удаление свайпом
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        let delete = UIContextualAction(style: .destructive, title: "Удалить") { [weak self] _, _, completion in
            guard let self = self else { return }

            let videoToDelete = self.filteredVideos[indexPath.row]

            if let index = self.videos.firstIndex(where: { $0.id == videoToDelete.id }) {
                self.videos.remove(at: index)
            }

            self.saveData()
            self.applyFilterAndReload()
            completion(true)
        }

        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - UISearchResultsUpdating

extension VKVideosViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        applyFilterAndReload()
    }
}

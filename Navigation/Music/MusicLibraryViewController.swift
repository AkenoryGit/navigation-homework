//
//  MusicLibraryViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import UIKit

final class MusicLibraryViewController: UIViewController {

    // MARK: - Public

    /// Логин текущего пользователя – обязателен для корректной работы избранного
    var userLogin: String!

    /// Опциональный колбэк выбора трека (режим "выбрать трек для поста"). Если установлен, то при тапе по треку не открывается плеер, а вызывается этот колбэк и контроллер закрывается.
    var onTrackSelected: ((MusicTrack) -> Void)?

    // MARK: - Private

    private let tableView = UITableView(frame: .zero, style: .plain)
    private let segmentedControl = UISegmentedControl(items: ["Все треки", "Избранное"])
    private let searchController = UISearchController(searchResultsController: nil)

    private var displayedTracks: [MusicTrack] = []

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = AppColors.background
        title = "Музыка"

        setupSegmentedControl()
        setupTableView()
        setupSearch()

        rebuildDataAndReload()
    }

    // MARK: - Setup

    private func setupSegmentedControl() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(segmentedControl)

        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        tableView.register(MusicEntryTableViewCell.self,
                           forCellReuseIdentifier: MusicEntryTableViewCell.reuseId)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск по названию трека"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Data

    @objc private func segmentChanged() {
        rebuildDataAndReload()
    }

    private func rebuildDataAndReload() {
        guard let login = userLogin else {
            assertionFailure("userLogin должен быть установлен")
            return
        }

        let searchText = (searchController.searchBar.text ?? "").lowercased()

        let source: [MusicTrack]
        if segmentedControl.selectedSegmentIndex == 0 {
            source = MusicStorage.shared.allTracks
        } else {
            source = MusicStorage.shared.favoriteTracks(for: login)
        }

        if searchText.isEmpty {
            displayedTracks = source
        } else {
            displayedTracks = source.filter { $0.title.lowercased().contains(searchText) }
        }

        tableView.reloadData()
    }

    // MARK: - Helpers

    private func toggleFavorite(for track: MusicTrack) {
        guard let login = userLogin else { return }
        MusicStorage.shared.toggleFavorite(track, for: login)
        rebuildDataAndReload()
    }
}

// MARK: - UITableViewDataSource

extension MusicLibraryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        displayedTracks.count
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MusicEntryTableViewCell.reuseId,
            for: indexPath
        ) as? MusicEntryTableViewCell else {
            return UITableViewCell()
        }

        let track = displayedTracks[indexPath.row]
        let isFavorite = userLogin.map { MusicStorage.shared.isFavorite(track, for: $0) } ?? false
        cell.configure(with: track, isFavorite: isFavorite)

        cell.onToggleFavorite = { [weak self] in
            self?.toggleFavorite(for: track)
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension MusicLibraryViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let track = displayedTracks[indexPath.row]

        if let handler = onTrackSelected {
            // Режим выбора трека для поста
            handler(track)
            navigationController?.popViewController(animated: true)
        } else {
            // Обычный режим – открываем плеер
            let playerVC = MusicTrackPlayerViewController()
            playerVC.tracks = displayedTracks
            playerVC.startIndex = indexPath.row
            navigationController?.pushViewController(playerVC, animated: true)
        }
    }
}

// MARK: - UISearchResultsUpdating

extension MusicLibraryViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        rebuildDataAndReload()
    }
}

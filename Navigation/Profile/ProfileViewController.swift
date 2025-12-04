//
//  ProfileViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 06.05.2025.
//

import UIKit
import CoreData
import RealmSwift

final class ProfileViewController: UIViewController {

    // MARK: - Public properties

    var user: User?
    var onLogout: (() -> Void)?

    // MARK: - Private UI

    private let tableView = UITableView()
    private let profileHeaderView = ProfileHeaderView()
    private var avatarOriginalFrame: CGRect = .zero
    private var avatarSnapshotView: UIImageView?

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .bold)
        let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.alpha = 0
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Data

    private var userPosts: [ProfilePost] = []
    private var likesOverrides: [String: Int] = [:]

    private var allPosts: [ProfilePost] {
        userPosts + posts
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Profile"
        setupTableView()

        view.addSubview(overlayView)
        view.addSubview(closeButton)

        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 44),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])

        profileHeaderView.onAvatarTap = { [weak self] in
            self?.showAvatarActionSheet()
        }

        profileHeaderView.onLogoutTapped = { [weak self] in
            self?.logoutButtonTapped()
        }

        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)

        // Первичная настройка профиля из уже переданного User
        if let user = user {
            applyUserToUI(user)
        }

        loadUserPostsIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)

        // Каждый раз, когда экран появляется, подтягиваем актуальные данные пользователя из Realm: ник, статус, аватар.
        reloadUserInfoFromRealmIfPossible()

        loadUserPostsIfNeeded()
        tableView.reloadData()
    }

    // MARK: - Data

    private func loadUserPostsIfNeeded() {
        guard let login = user?.login else { return }
        userPosts = PostStorage.shared.loadPosts(for: login)
    }

    // MARK: - User / Realm sync

    /// Применяет объект User к UI (аватар, имя, статус, заголовок таббара)
    private func applyUserToUI(_ user: User) {
        title = user.fullName
        profileHeaderView.avatarImageView.image = user.avatar
        profileHeaderView.fullNameLabel.text = user.fullName
        profileHeaderView.statusLabel.text = user.status
        // Обновляем подпись вкладки таббара
        navigationController?.tabBarItem.title = user.fullName
    }

    /// Тянем свежие данные из Realm по логину, обновляем self.user и UI
    private func reloadUserInfoFromRealmIfPossible() {
        guard let login = user?.login else { return }

        do {
            let realm = try Realm()
            if let userObject = realm.objects(UserRealm.self)
                .filter("login == %@", login)
                .first {

                var avatarImage: UIImage = user?.avatar ?? UIImage(systemName: "person.crop.circle")!
                if let data = userObject.avatarData,
                   let img = UIImage(data: data) {
                    avatarImage = img
                }

                let displayName = userObject.nickname.isEmpty ? login : userObject.nickname
                let statusText = userObject.status.isEmpty ? (user?.status ?? "Online") : userObject.status

                let updatedUser = User(
                    login: login,
                    fullName: displayName,
                    avatar: avatarImage,
                    status: statusText
                )

                self.user = updatedUser
                applyUserToUI(updatedUser)
            }
        } catch {
            print("ProfileViewController: ошибка чтения UserRealm: \(error)")
        }
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        setupTableViewConstraints()
        configureTableView()
    }

    private func setupTableViewConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(PostTableViewCell.self, forCellReuseIdentifier: PostTableViewCell.identifier)
        tableView.register(PhotosTableViewCell.self, forCellReuseIdentifier: PhotosTableViewCell.identifier)
        tableView.register(VKVideosTableViewCell.self, forCellReuseIdentifier: VKVideosTableViewCell.identifier)
        tableView.register(MusicPlayerTableViewCell.self, forCellReuseIdentifier: MusicPlayerTableViewCell.identifier)
        tableView.register(AddPostTableViewCell.self, forCellReuseIdentifier: AddPostTableViewCell.identifier)

        tableView.estimatedRowHeight = 300
        tableView.rowHeight = UITableView.automaticDimension
    }

    // MARK: - Avatar action sheet / picker

    /// Экшен-лист при тапе по аватару: Просмотреть / Изменить фото
    private func showAvatarActionSheet() {
        let alert = UIAlertController(title: "Аватар", message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Просмотреть", style: .default, handler: { [weak self] _ in
            self?.animateAvatarExpansion()
        }))

        alert.addAction(UIAlertAction(title: "Изменить фото", style: .default, handler: { [weak self] _ in
            self?.presentAvatarPicker()
        }))

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        // Для iPad
        if let popover = alert.popoverPresentationController {
            popover.sourceView = profileHeaderView.avatarImageView
            popover.sourceRect = profileHeaderView.avatarImageView.bounds
        }

        present(alert, animated: true)
    }

    private func presentAvatarPicker() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self

        present(picker, animated: true)
    }

    // MARK: - Avatar zoom animation

    private func animateAvatarExpansion() {
        guard let avatarImage = profileHeaderView.avatarImage else { return }
        guard let window = view.window else { return }

        let avatarFrameInWindow = profileHeaderView.convert(profileHeaderView.avatarFrame, to: window)
        avatarOriginalFrame = avatarFrameInWindow

        let avatarView = UIImageView(image: avatarImage)
        avatarView.frame = avatarFrameInWindow
        avatarView.layer.cornerRadius = profileHeaderView.avatarCornerRadius
        avatarView.clipsToBounds = true
        avatarView.contentMode = .scaleAspectFill
        avatarView.layer.masksToBounds = true
        avatarSnapshotView = avatarView

        window.addSubview(avatarView)
        view.bringSubviewToFront(overlayView)
        view.bringSubviewToFront(closeButton)

        let targetWidth = window.bounds.width
        let targetHeight = avatarImage.size.height * (targetWidth / avatarImage.size.width)
        let targetY = (window.bounds.height - targetHeight) / 2

        UIView.animate(withDuration: 0.5, animations: {
            avatarView.frame = CGRect(x: 0, y: targetY, width: targetWidth, height: targetHeight)
            let radiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
            radiusAnimation.fromValue = avatarView.layer.cornerRadius
            radiusAnimation.toValue = 0
            radiusAnimation.duration = 0.5
            avatarView.layer.add(radiusAnimation, forKey: "cornerRadius")
            avatarView.layer.cornerRadius = 0
            self.overlayView.alpha = 1
        }, completion: { _ in
            UIView.animate(withDuration: 0.3) {
                self.closeButton.alpha = 1
            }
        })
    }

    @objc private func closeButtonTapped() {
        guard let avatarView = avatarSnapshotView else { return }

        UIView.animate(withDuration: 0.3, animations: {
            self.closeButton.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, animations: {
                avatarView.frame = self.avatarOriginalFrame
                let radiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
                radiusAnimation.fromValue = avatarView.layer.cornerRadius
                radiusAnimation.toValue = self.profileHeaderView.avatarCornerRadius
                radiusAnimation.duration = 0.5
                avatarView.layer.add(radiusAnimation, forKey: "cornerRadius")
                avatarView.layer.cornerRadius = self.profileHeaderView.avatarCornerRadius
                self.overlayView.alpha = 0
            }, completion: { _ in
                avatarView.removeFromSuperview()
                self.avatarSnapshotView = nil
            })
        })
    }

    // MARK: - Logout

    @objc private func logoutButtonTapped() {
        onLogout?()
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // 0: VK, 1: Music, 2: Photos, 3: AddPost, далее посты
        return 4 + allPosts.count
    }

    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        profileHeaderView
    }

    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        let targetSize = CGSize(width: tableView.bounds.width,
                                height: UIView.layoutFittingCompressedSize.height)
        return profileHeaderView.systemLayoutSizeFitting(targetSize).height
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: VKVideosTableViewCell.identifier,
                for: indexPath
            ) as! VKVideosTableViewCell

            cell.onOpenVKVideos = { [weak self] in
                guard let self = self else { return }
                let vc = VKVideosViewController()
                vc.userLogin = self.user?.login
                self.navigationController?.pushViewController(vc, animated: true)
            }
            return cell

        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: MusicPlayerTableViewCell.identifier,
                for: indexPath
            ) as! MusicPlayerTableViewCell

            cell.onOpenMusic = { [weak self] in
                guard
                    let self = self,
                    let login = self.user?.login
                else { return }

                let musicVC = MusicLibraryViewController()
                musicVC.userLogin = login
                self.navigationController?.pushViewController(musicVC, animated: true)
            }
            return cell

        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PhotosTableViewCell.identifier,
                for: indexPath
            ) as! PhotosTableViewCell

            if let login = user?.login {
                cell.configure(with: login)
            }

            cell.onArrowTapped = { [weak self] in
                guard
                    let self = self,
                    let login = self.user?.login
                else { return }

                let photosVC = PhotosViewController()
                photosVC.userLogin = login
                self.navigationController?.pushViewController(photosVC, animated: true)
            }

            return cell

        case 3:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AddPostTableViewCell.identifier,
                for: indexPath
            ) as! AddPostTableViewCell

            cell.onCreatePost = { [weak self] in
                guard let self = self,
                      let login = self.user?.login else { return }

                let newPostVC = NewPostViewController()
                newPostVC.userLogin = login
                newPostVC.authorName = self.user?.fullName ?? login
                newPostVC.onPostCreated = { [weak self] in
                    self?.loadUserPostsIfNeeded()
                    self?.tableView.reloadData()
                }
                self.navigationController?.pushViewController(newPostVC, animated: true)
            }

            return cell

        default:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: PostTableViewCell.identifier,
                for: indexPath
            ) as! PostTableViewCell

            let postIndex = indexPath.row - 4
            if postIndex >= 0 && postIndex < allPosts.count {
                var post = allPosts[postIndex]

                // Подменяем лайки из overrides, если уже были нажатия
                if let overrideLikes = likesOverrides[post.id] {
                    post = ProfilePost(
                        id: post.id,
                        author: post.author,
                        description: post.description,
                        image: post.image,
                        likes: overrideLikes,
                        views: post.views,
                        trackId: post.trackId
                    )
                }

                // Подменяем author у постов текущего пользователя на актуальный nickname
                if let login = user?.login,
                   userPosts.contains(where: { $0.id == post.id }) {
                    post = ProfilePost(
                        id: post.id,
                        author: user?.fullName ?? post.author,
                        description: post.description,
                        image: post.image,
                        likes: post.likes,
                        views: post.views,
                        trackId: post.trackId
                    )
                }

                cell.configure(with: post)
                cell.delegate = self
                cell.isLikeInteractionEnabled = true

                cell.onTrackTapped = { [weak self] in
                    guard let self = self,
                          let trackId = post.trackId,
                          let startIndex = MusicStorage.shared.allTracks.firstIndex(where: { $0.id == trackId }) else {
                        return
                    }

                    let playerVC = MusicTrackPlayerViewController()
                    playerVC.tracks = MusicStorage.shared.allTracks
                    playerVC.startIndex = startIndex
                    self.navigationController?.pushViewController(playerVC, animated: true)
                }
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {

        guard indexPath.row >= 4,
              let login = user?.login else {
            return nil
        }

        let postIndex = indexPath.row - 4
        guard postIndex >= 0 && postIndex < allPosts.count else { return nil }
        let post = allPosts[postIndex]

        guard userPosts.contains(where: { $0.id == post.id }) else {
            return nil
        }

        let deleteAction = UIContextualAction(style: .destructive,
                                              title: "Удалить") { [weak self] _, _, completion in
            guard let self = self else {
                completion(false)
                return
            }

            PostStorage.shared.deletePost(withId: post.id, for: login)
            self.loadUserPostsIfNeeded()
            tableView.reloadData()
            completion(true)
        }

        deleteAction.image = UIImage(systemName: "trash")

        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}

// MARK: - PostTableViewCellDelegate

extension ProfileViewController: PostTableViewCellDelegate {

    func didDoubleTap(postId: String) {
        guard let login = user?.login else { return }

        let all = allPosts
        guard let index = all.firstIndex(where: { $0.id == postId }) else { return }
        let basePost = all[index]

        let currentLikes = likesOverrides[postId] ?? basePost.likes
        let newLikes = currentLikes + 1
        likesOverrides[postId] = newLikes

        let updatedPost = ProfilePost(
            id: basePost.id,
            author: basePost.author,
            description: basePost.description,
            image: basePost.image,
            likes: newLikes,
            views: basePost.views,
            trackId: basePost.trackId
        )

        print("Пост с id \(postId) добавлен в избранное для пользователя \(login), лайков: \(newLikes)")

        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<FavoritePost> = FavoritePost.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@ AND login == %@", postId, login)

        do {
            let results = try context.fetch(request)
            let favorite = results.first ?? FavoritePost(context: context)

            favorite.id = updatedPost.id
            favorite.author = updatedPost.author
            favorite.text = updatedPost.description
            favorite.imageName = updatedPost.image
            favorite.likes = Int64(updatedPost.likes)
            favorite.views = Int64(updatedPost.views)
            favorite.login = login
            favorite.trackId = updatedPost.trackId
            if favorite.createdAt == nil {
                favorite.createdAt = Date()
            }

            CoreDataManager.shared.saveContext()
        } catch {
            print("Ошибка upsert FavoritePost: \(error)")
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        guard let login = user?.login else { return }

        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        guard let avatar = image else { return }

        // Обновляем UI
        profileHeaderView.avatarImageView.image = avatar

        // Обновляем Realm
        do {
            let realm = try Realm()
            if let userObject = realm.objects(UserRealm.self)
                .filter("login == %@", login)
                .first {
                let data = avatar.jpegData(compressionQuality: 0.9)
                try realm.write {
                    userObject.avatarData = data
                }
            }
        } catch {
            print("ProfileViewController: ошибка сохранения аватара в Realm: \(error)")
        }

        // Обновляем in-memory User
        if let current = user {
            user = User(
                login: current.login,
                fullName: current.fullName,
                avatar: avatar,
                status: current.status
            )
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

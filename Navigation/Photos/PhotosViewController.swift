//
//  PhotosViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 09.06.2025.
//

import UIKit

final class PhotosViewController: UIViewController,
                                  UICollectionViewDataSource,
                                  UICollectionViewDelegateFlowLayout {

    // MARK: - Public

    /// Логин текущего пользователя перед показом экрана
    var userLogin: String!

    // MARK: - Private models

    private struct BasePhoto {
        let id: String
        let image: UIImage
    }

    // MARK: - Private properties

    private var collectionView: UICollectionView!

    /// Все стандартные фотографии (из ассетов)
    private var allBasePhotos: [BasePhoto] = []

    /// ID стандартных фото, скрытых для текущего пользователя
    private var hiddenBasePhotoIDs: Set<String> = []

    /// Пользовательские сохранённые фотографии
    private var userPhotos: [PhotoStorage.StoredPhoto] = []

    /// Имена стандартных картинок в ассетах
    private let imageNames = (1...18).map { "photo\($0)" }

    /// Стандартные фото, которые показываем (без скрытых)
    private var visibleBasePhotos: [BasePhoto] {
        allBasePhotos.filter { !hiddenBasePhotoIDs.contains($0.id) }
    }

    // MARK: - Fullscreen state

    private var fullscreenImageView: UIImageView?
    private var fullscreenOverlayView: UIView?
    private var fullscreenCloseButton: UIButton?
    private var fullscreenDeleteButton: UIButton?
    private var fullscreenOriginalFrame: CGRect = .zero
    private var fullscreenIndexPath: IndexPath?
    private var fullscreenIsBasePhoto: Bool = false

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        title = "Photo Gallery"

        setupCollectionView()
        setupNavigation()

        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Setup

    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            PhotosCollectionViewCell.self,
            forCellWithReuseIdentifier: PhotosCollectionViewCell.identifier
        )

        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigation() {
        // Кнопка добавления фото из галереи
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addPhotoTapped)
        )
    }

    // MARK: - Data loading/saving

    private func loadData() {
        guard let login = userLogin else {
            assertionFailure("PhotosViewController: userLogin не установлен")
            return
        }

        // Стандартные фото из ассетов
        allBasePhotos = imageNames.compactMap { name in
            guard let image = UIImage(named: name) else { return nil }
            return BasePhoto(id: name, image: image)
        }

        // Скрытые стандартные фото для пользователя
        hiddenBasePhotoIDs = PhotoStorage.shared.loadHiddenBasePhotoIDs(for: login)

        // Пользовательские фото
        userPhotos = PhotoStorage.shared.loadPhotos(for: login)

        collectionView.reloadData()
    }

    private func saveUserPhotos() {
        guard let login = userLogin else { return }
        PhotoStorage.shared.savePhotos(userPhotos, for: login)
    }

    private func saveHiddenBasePhotoIDs() {
        guard let login = userLogin else { return }
        PhotoStorage.shared.saveHiddenBasePhotoIDs(hiddenBasePhotoIDs, for: login)
    }

    // MARK: - Helpers: индекс -> тип фото

    private func isBasePhoto(at indexPath: IndexPath) -> Bool {
        indexPath.item < visibleBasePhotos.count
    }

    private func basePhotoIndex(for indexPath: IndexPath) -> Int? {
        let idx = indexPath.item
        return idx < visibleBasePhotos.count ? idx : nil
    }

    private func userPhotoIndex(for indexPath: IndexPath) -> Int? {
        let baseCount = visibleBasePhotos.count
        let idx = indexPath.item - baseCount
        return (idx >= 0 && idx < userPhotos.count) ? idx : nil
    }

    private func imageForItem(at indexPath: IndexPath) -> UIImage? {
        if let baseIndex = basePhotoIndex(for: indexPath) {
            return visibleBasePhotos[baseIndex].image
        } else if let userIndex = userPhotoIndex(for: indexPath) {
            let stored = userPhotos[userIndex]
            return UIImage(data: stored.imageData)
        } else {
            return nil
        }
    }

    // MARK: - Actions

    /// Добавление фото из галереи
    @objc private func addPhotoTapped() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        picker.delegate = self
        present(picker, animated: true)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return visibleBasePhotos.count + userPhotos.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotosCollectionViewCell.identifier,
            for: indexPath
        ) as! PhotosCollectionViewCell

        if let image = imageForItem(at: indexPath) {
            cell.configure(with: image)
        } else {
            cell.configure(with: UIImage(systemName: "photo"))
        }

        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let itemsPerRow: CGFloat = 3
        let padding: CGFloat = 12
        let spacing: CGFloat = 8

        let totalSpacing = (itemsPerRow - 1) * spacing + padding * 2
        let itemWidth = (collectionView.bounds.width - totalSpacing) / itemsPerRow

        return CGSize(width: floor(itemWidth), height: floor(itemWidth))
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        presentFullscreenPhoto(at: indexPath)
    }

    // MARK: - Fullscreen photo presentation

    private func setupFullscreenUIIfNeeded(in window: UIWindow) {
        if fullscreenOverlayView == nil {
            let overlay = UIView(frame: window.bounds)
            overlay.backgroundColor = UIColor.black.withAlphaComponent(0.9)
            overlay.alpha = 0
            fullscreenOverlayView = overlay
        }

        if fullscreenCloseButton == nil {
            let button = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)
            let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .white
            button.alpha = 0
            button.addTarget(self, action: #selector(closeFullscreenTapped), for: .touchUpInside)
            fullscreenCloseButton = button
        }

        if fullscreenDeleteButton == nil {
            let button = UIButton(type: .system)
            let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)
            let image = UIImage(systemName: "trash.circle.fill", withConfiguration: config)
            button.setImage(image, for: .normal)
            button.tintColor = .systemRed
            button.alpha = 0
            button.addTarget(self, action: #selector(deleteFullscreenTapped), for: .touchUpInside)
            fullscreenDeleteButton = button
        }

        if let overlay = fullscreenOverlayView, overlay.superview == nil {
            window.addSubview(overlay)
        }

        if let closeButton = fullscreenCloseButton, closeButton.superview == nil {
            window.addSubview(closeButton)
        }

        if let deleteButton = fullscreenDeleteButton, deleteButton.superview == nil {
            window.addSubview(deleteButton)
        }

        // Layout кнопок
        if let closeButton = fullscreenCloseButton,
           let deleteButton = fullscreenDeleteButton {

            closeButton.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.deactivate(closeButton.constraints)
            NSLayoutConstraint.deactivate(deleteButton.constraints)

            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 16),
                closeButton.leadingAnchor.constraint(equalTo: window.leadingAnchor, constant: 16),
                closeButton.widthAnchor.constraint(equalToConstant: 44),
                closeButton.heightAnchor.constraint(equalToConstant: 44),

                deleteButton.topAnchor.constraint(equalTo: window.safeAreaLayoutGuide.topAnchor, constant: 16),
                deleteButton.trailingAnchor.constraint(equalTo: window.trailingAnchor, constant: -16),
                deleteButton.widthAnchor.constraint(equalToConstant: 44),
                deleteButton.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
    }

    private func presentFullscreenPhoto(at indexPath: IndexPath) {
        guard
            let window = view.window,
            let cell = collectionView.cellForItem(at: indexPath),
            let image = imageForItem(at: indexPath)
        else { return }

        setupFullscreenUIIfNeeded(in: window)

        guard let overlay = fullscreenOverlayView else { return }

        let cellFrameInWindow = collectionView.convert(cell.frame, to: window)
        fullscreenOriginalFrame = cellFrameInWindow
        fullscreenIndexPath = indexPath
        fullscreenIsBasePhoto = isBasePhoto(at: indexPath)

        // Создаём imageView поверх всего
        let imageView = UIImageView(image: image)
        imageView.frame = cellFrameInWindow
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        fullscreenImageView = imageView

        window.addSubview(imageView)
        window.bringSubviewToFront(overlay)
        window.bringSubviewToFront(imageView)
        if let closeButton = fullscreenCloseButton {
            window.bringSubviewToFront(closeButton)
        }
        if let deleteButton = fullscreenDeleteButton {
            window.bringSubviewToFront(deleteButton)
        }

        // Целевой размер — по ширине экрана
        let targetWidth = window.bounds.width
        let imgSize = image.size
        let aspect = imgSize.width == 0 ? 1 : (targetWidth / imgSize.width)
        let targetHeight = imgSize.height * aspect
        let targetY = max((window.bounds.height - targetHeight) / 2, 40)

        overlay.alpha = 0
        fullscreenCloseButton?.alpha = 0
        fullscreenDeleteButton?.alpha = 0

        UIView.animate(withDuration: 0.4, animations: {
            overlay.alpha = 1
            imageView.frame = CGRect(x: 0,
                                     y: targetY,
                                     width: targetWidth,
                                     height: targetHeight)
        }, completion: { _ in
            UIView.animate(withDuration: 0.2) {
                self.fullscreenCloseButton?.alpha = 1
                self.fullscreenDeleteButton?.alpha = 1
            }
        })
    }

    // MARK: - Fullscreen close / delete actions

    @objc private func closeFullscreenTapped() {
        guard
            let window = view.window,
            let imageView = fullscreenImageView,
            let overlay = fullscreenOverlayView
        else { return }

        UIView.animate(withDuration: 0.2, animations: {
            self.fullscreenCloseButton?.alpha = 0
            self.fullscreenDeleteButton?.alpha = 0
        })

        UIView.animate(withDuration: 0.4, animations: {
            overlay.alpha = 0
            imageView.frame = self.fullscreenOriginalFrame
        }, completion: { _ in
            imageView.removeFromSuperview()
            self.fullscreenImageView = nil
            overlay.removeFromSuperview()
        })
    }

    @objc private func deleteFullscreenTapped() {
        guard let indexPath = fullscreenIndexPath else { return }

        let alert = UIAlertController(
            title: "Удалить фото?",
            message: "Это действие нельзя отменить.",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { [weak self] _ in
            self?.performDeletePhoto(at: indexPath)
        }))

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))

        present(alert, animated: true)
    }

    private func performDeletePhoto(at indexPath: IndexPath) {
        // Меняем данные
        if let baseIndex = basePhotoIndex(for: indexPath) {
            // Удаляем стандартную фотку для текущего пользователя
            let basePhoto = visibleBasePhotos[baseIndex]
            hiddenBasePhotoIDs.insert(basePhoto.id)
            saveHiddenBasePhotoIDs()
        } else if let userIndex = userPhotoIndex(for: indexPath) {
            // Удаляем пользовательскую фотку
            userPhotos.remove(at: userIndex)
            saveUserPhotos()
        }

        // Закрываем fullscreen с fade-анимацией
        guard
            let imageView = fullscreenImageView,
            let overlay = fullscreenOverlayView
        else {
            collectionView.reloadData()
            return
        }

        UIView.animate(withDuration: 0.2, animations: {
            self.fullscreenCloseButton?.alpha = 0
            self.fullscreenDeleteButton?.alpha = 0
        })

        UIView.animate(withDuration: 0.3, animations: {
            overlay.alpha = 0
            imageView.alpha = 0
        }, completion: { _ in
            imageView.removeFromSuperview()
            overlay.removeFromSuperview()
            self.fullscreenImageView = nil
            self.fullscreenIndexPath = nil
            self.collectionView.reloadData()
        })
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate

extension PhotosViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        defer { dismiss(animated: true) }

        guard let image = info[.originalImage] as? UIImage else { return }
        guard let data = image.jpegData(compressionQuality: 0.9) else { return }

        let stored = PhotoStorage.StoredPhoto(
            id: UUID().uuidString,
            imageData: data
        )

        userPhotos.append(stored)
        saveUserPhotos()

        let newIndex = IndexPath(item: visibleBasePhotos.count + userPhotos.count - 1, section: 0)
        collectionView.insertItems(at: [newIndex])
    }
}

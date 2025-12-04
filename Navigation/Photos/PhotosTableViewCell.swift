//
//  PhotosTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 09.06.2025.
//

import UIKit

final class PhotosTableViewCell: UITableViewCell {

    // MARK: - Public

    static let identifier = "PhotosTableViewCell"

    /// Колбэк по тапу на стрелку
    var onArrowTapped: (() -> Void)?

    // MARK: - UI

    private let arrowTapArea = UIView()

    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .secondaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Фотографии"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let maxPreviewCount = 4
    private var previewImageViews: [UIImageView] = []

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    // MARK: - Setup

    private func setupViews() {
        selectionStyle = .none

        setupTitleAndArrow()
        setupImageGrid()
    }

    private func setupTitleAndArrow() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowTapArea)
        arrowTapArea.addSubview(arrowImageView)

        arrowTapArea.translatesAutoresizingMaskIntoConstraints = false
        arrowTapArea.isUserInteractionEnabled = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(arrowTapped))
        arrowTapArea.addGestureRecognizer(tapGesture)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),

            arrowTapArea.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            arrowTapArea.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            arrowTapArea.widthAnchor.constraint(equalToConstant: 44),
            arrowTapArea.heightAnchor.constraint(equalToConstant: 44),

            arrowImageView.centerXAnchor.constraint(equalTo: arrowTapArea.centerXAnchor),
            arrowImageView.centerYAnchor.constraint(equalTo: arrowTapArea.centerYAnchor)
        ])
    }

    /// Создаём четыре квадратных превью
    private func setupImageGrid() {
        var previousImageView: UIImageView?

        for _ in 0..<maxPreviewCount {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 6
            imageView.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(imageView)
            previewImageViews.append(imageView)

            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
                imageView.widthAnchor.constraint(equalToConstant: 80),
                imageView.heightAnchor.constraint(equalToConstant: 80)
            ])

            if let previous = previousImageView {
                imageView.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: 8).isActive = true
            } else {
                imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
            }

            previousImageView = imageView
        }

        if let lastImageView = previousImageView {
            lastImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
        }
    }

    // MARK: - Configure

    /// Обновить превью для конкретного пользователя
    func configure(with login: String) {
        // Стандартные фотки
        let baseNames = (1...18).map { "photo\($0)" }
        let hidden = PhotoStorage.shared.loadHiddenBasePhotoIDs(for: login)

        let baseImages: [UIImage] = baseNames
            .filter { !hidden.contains($0) }
            .compactMap { UIImage(named: $0) }

        // Пользовательские фотки
        let storedPhotos = PhotoStorage.shared.loadPhotos(for: login)
        let userImages: [UIImage] = storedPhotos.compactMap { UIImage(data: $0.imageData) }

        // Объединяем: сначала стандартные, затем пользовательские
        let allImages = baseImages + userImages

        // Отображаем первые 4
        for (index, imageView) in previewImageViews.enumerated() {
            if index < allImages.count {
                imageView.isHidden = false
                imageView.image = allImages[index]
            } else {
                imageView.isHidden = true
                imageView.image = nil
            }
        }
    }

    // MARK: - Actions

    @objc private func arrowTapped() {
        onArrowTapped?()
    }
}

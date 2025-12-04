//
//  MusicEntryTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import UIKit

final class MusicEntryTableViewCell: UITableViewCell {

    // MARK: - Reuse

    static let reuseId = "MusicEntryTableViewCell"
    static let identifier = MusicEntryTableViewCell.reuseId

    /// Колбэк при нажатии на кнопку избранного
    var onToggleFavorite: (() -> Void)?

    // MARK: - UI

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.bodyBold()
        label.textColor = AppColors.textPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let favoriteButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = AppColors.accent
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .default
        accessoryType = .disclosureIndicator

        contentView.addSubview(titleLabel)
        contentView.addSubview(favoriteButton)
        contentView.addSubview(separator)

        favoriteButton.addTarget(self,
                                 action: #selector(favoriteButtonTapped),
                                 for: .touchUpInside)

        NSLayoutConstraint.activate([
            favoriteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            favoriteButton.widthAnchor.constraint(equalToConstant: 28),
            favoriteButton.heightAnchor.constraint(equalToConstant: 28),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: favoriteButton.leadingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(with track: MusicTrack, isFavorite: Bool) {
        titleLabel.text = track.title
        let imageName = isFavorite ? "star.fill" : "star"
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
    }

    // MARK: - Actions

    @objc private func favoriteButtonTapped() {
        onToggleFavorite?()
    }
}

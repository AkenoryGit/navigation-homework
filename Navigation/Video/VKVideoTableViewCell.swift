//
//  VKVideoTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import UIKit

/// Ячейка для отображения одного сохранённого VK-видео
final class VKVideoTableViewCell: UITableViewCell {

    // MARK: - Reuse ID

    static let reuseId = "VKVideoTableViewCell"

    // MARK: - UI

    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 8
        iv.backgroundColor = AppColors.secondaryBackground
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.bodyBold()
        label.textColor = AppColors.textPrimary
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let urlLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption()
        label.textColor = AppColors.textSecondary
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let stackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        accessoryType = .disclosureIndicator

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(stackView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(urlLabel)

        NSLayoutConstraint.activate([
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            thumbnailImageView.widthAnchor.constraint(equalToConstant: 100),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 64),

            stackView.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: thumbnailImageView.bottomAnchor, constant: 12),
            contentView.topAnchor.constraint(lessThanOrEqualTo: thumbnailImageView.topAnchor, constant: -12)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    func configure(with video: VKVideo) {
        titleLabel.text = video.title

        if let url = video.url {
            urlLabel.text = url.host ?? url.absoluteString
        } else {
            urlLabel.text = video.urlString
        }

        if let data = video.thumbnailData,
           let image = UIImage(data: data) {
            thumbnailImageView.image = image
        } else {
            thumbnailImageView.image = UIImage(systemName: "film")
        }
    }
}

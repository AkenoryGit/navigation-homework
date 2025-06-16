//
//  PhotosTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 09.06.2025.
//

import UIKit

final class PhotosTableViewCell: UITableViewCell {
    
    var onArrowTapped: (() -> Void)?
    
    private let arrowTapArea = UIView()
    
    private let arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.tintColor = .black
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    static let identifier = "PhotosTableViewCell"
    
    private let imageNames = ["photo1", "photo2", "photo3", "photo4"]

    private var imageViews: [UIImageView] = []
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Photos"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        setupTitleAndArrow()
        setupImageGrid()
    }
    
    private func setupTitleAndArrow() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowTapArea)
        arrowTapArea.addSubview(arrowImageView)

        arrowTapArea.translatesAutoresizingMaskIntoConstraints = false
        arrowTapArea.isUserInteractionEnabled = true

        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.isUserInteractionEnabled = false

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
    
    private func setupImageGrid() {
        var previousImageView: UIImageView?

        for name in imageNames {
            let imageView = UIImageView()
            imageView.image = UIImage(named: name) ?? UIImage(systemName: "photo")
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 6

            contentView.addSubview(imageView)
            imageViews.append(imageView)

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
    
    @objc private func arrowTapped() {
        onArrowTapped?()
    }
}

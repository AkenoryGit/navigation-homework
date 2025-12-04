//
//  PhotosCollectionViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 09.06.2025.
//

import UIKit

final class PhotosCollectionViewCell: UICollectionViewCell {

    // MARK: - Reuse

    static let identifier = "PhotosCollectionViewCell"

    // MARK: - UI

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill        // заполняем ячейку
        imageView.clipsToBounds = true                  // не выходим за границы
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.clipsToBounds = true
        contentView.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }

    // MARK: - Configure

    func configure(with image: UIImage?) {
        imageView.image = image
    }
}

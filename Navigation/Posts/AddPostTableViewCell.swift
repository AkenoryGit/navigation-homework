//
//  AddPostTableViewCell.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import UIKit

final class AddPostTableViewCell: UITableViewCell {

    static let identifier = "AddPostTableViewCell"

    /// Колбэк, вызываемый при нажатии на ячейку
    var onCreatePost: (() -> Void)?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Создать пост"
        label.font = AppFonts.bodyBold()
        label.textColor = AppColors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Добавьте фото, трек и описание"
        label.font = AppFonts.caption()
        label.textColor = AppColors.textSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let plusImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "plus.circle.fill")
        iv.tintColor = AppColors.accent
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
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

        contentView.addSubview(stackView)
        contentView.addSubview(plusImageView)

        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            plusImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plusImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            plusImageView.widthAnchor.constraint(equalToConstant: 24),
            plusImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Selection

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            onCreatePost?()
        }
    }
}

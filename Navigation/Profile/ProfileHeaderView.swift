//
//  ProfileHeaderView.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 08.05.2025.
//

import UIKit

final class ProfileHeaderView: UIView {
    
    // MARK: - Callbacks
    
    var onAvatarTap: (() -> Void)?
    var onLogoutTapped: (() -> Void)?
    
    // MARK: - Public avatar accessors (для анимации в ProfileViewController)
    
    var avatarImage: UIImage? {
        avatarImageView.image
    }

    var avatarFrame: CGRect {
        avatarImageView.frame
    }

    var avatarCornerRadius: CGFloat {
        avatarImageView.layer.cornerRadius
    }
    
    // MARK: - UI
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cat")
        imageView.layer.cornerRadius = 75
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = AppColors.background.cgColor
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hipster Cat"
        label.font = AppFonts.title3()
        label.textColor = AppColors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting for something..."
        label.textColor = AppColors.textSecondary
        label.font = AppFonts.caption()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        return label
    }()
    
    private let statusTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter new status..."
        textField.backgroundColor = AppColors.background
        textField.layer.borderWidth = 1
        textField.layer.borderColor = AppColors.separator.cgColor
        textField.layer.cornerRadius = 8
        textField.font = AppFonts.caption()
        textField.textColor = AppColors.textPrimary
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isHidden = false
        leftPadding(for: textField, width: 8)
        return textField
    }()
    
    private let setStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Status", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppFonts.bodyBold()
        button.backgroundColor = AppColors.buttonBlue
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 4
        
        return button
    }()
    
    private let logoutButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Выйти"
        config.baseBackgroundColor = AppColors.buttonBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 12, bottom: 6, trailing: 12)

        let button = UIButton(configuration: config)
        button.titleLabel?.font = AppFonts.captionBold()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupGesture()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupGesture()
        setupConstraints()
    }
    
    // MARK: - Setup
    
    private func setupGesture() {
        avatarImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupView() {
        backgroundColor = AppColors.secondaryBackground
        
        addSubview(avatarImageView)
        addSubview(fullNameLabel)
        addSubview(logoutButton)
        addSubview(statusLabel)
        addSubview(statusTextField)
        addSubview(setStatusButton)
        
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        setStatusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            avatarImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            avatarImageView.widthAnchor.constraint(equalToConstant: 150),
            avatarImageView.heightAnchor.constraint(equalToConstant: 150),
            
            fullNameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            fullNameLabel.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            fullNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            logoutButton.topAnchor.constraint(equalTo: fullNameLabel.bottomAnchor, constant: 8),
            logoutButton.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 16),
            logoutButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
            
            statusLabel.bottomAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: -30),
            statusLabel.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor),
            
            statusTextField.leadingAnchor.constraint(equalTo: fullNameLabel.leadingAnchor),
            statusTextField.trailingAnchor.constraint(equalTo: fullNameLabel.trailingAnchor),
            statusTextField.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 4),
            statusTextField.heightAnchor.constraint(equalToConstant: 36),

            setStatusButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            setStatusButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            setStatusButton.topAnchor.constraint(equalTo: statusTextField.bottomAnchor, constant: 8),
            setStatusButton.heightAnchor.constraint(equalToConstant: 44),
            setStatusButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func statusButtonTapped() {
        let text = statusTextField.text
        statusLabel.text = (text?.isEmpty == false) ? text : "Waiting for something..."
    }
    
    @objc private func avatarTapped() {
        onAvatarTap?()
    }

    @objc private func logoutTapped() {
        onLogoutTapped?()
    }
    
    // MARK: - Helpers
    
    private static func leftPadding(for textField: UITextField, width: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        textField.leftView = paddingView
        textField.leftViewMode = .always
    }
}

//
//  ProfileHeaderView.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 08.05.2025.
//

import UIKit
import SnapKit

class ProfileHeaderView: UIView {
    
    var onAvatarTap: (() -> Void)?
    var avatarImage: UIImage? {
        return avatarImageView.image
    }

    var avatarFrame: CGRect {
        return avatarImageView.frame
    }

    var avatarCornerRadius: CGFloat {
        return avatarImageView.layer.cornerRadius
    }
    
    private var statusTextFieldTopConstraint: NSLayoutConstraint!
    private var statusButtonTopConstraint: NSLayoutConstraint!
    
    private let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "cat")
        imageView.layer.cornerRadius = 75
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 3
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Hipster Cat"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting for something..."
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private let statusTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter new status..."
        textField.backgroundColor = .white
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = 8
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.isHidden = false
        return textField
    }()
    
    private let setStatusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Show Status", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        return button
    }()
    
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
    
    private func setupGesture() {
        avatarImageView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(avatarTapped))
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    
    private func setupView() {
        backgroundColor = .lightGray
        addSubview(avatarImageView)
        addSubview(fullNameLabel)
        addSubview(statusLabel)
        addSubview(statusTextField)
        addSubview(setStatusButton)
        
        setStatusButton.addTarget(self, action: #selector(statusButtonTapped), for: .touchUpInside)
        setStatusButton.layer.shadowColor = UIColor.black.cgColor
        setStatusButton.layer.shadowOpacity = 0.25
        setStatusButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        setStatusButton.layer.shadowRadius = 4
    }
    
    private func setupConstraints() {
        avatarImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.height.equalTo(150)
        }

        fullNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
            make.leading.equalTo(avatarImageView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().inset(16)
        }

        statusLabel.snp.makeConstraints { make in
            make.leading.trailing.equalTo(fullNameLabel)
            make.bottom.equalTo(avatarImageView.snp.bottom).offset(-30)
        }

        statusTextField.snp.makeConstraints { make in
            make.leading.trailing.equalTo(fullNameLabel)
            make.top.equalTo(statusLabel.snp.bottom).offset(4)
            make.height.equalTo(36)
        }

        setStatusButton.snp.makeConstraints { make in
            make.top.equalTo(statusTextField.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    @objc private func statusButtonTapped() {
            statusLabel.text = statusTextField.text?.isEmpty == false ? statusTextField.text : "Waiting for something..."
    }
    
    @objc private func avatarTapped() {
        print("Аватар нажат")
        onAvatarTap?()
    }
}

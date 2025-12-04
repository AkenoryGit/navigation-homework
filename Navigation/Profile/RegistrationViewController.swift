//
//  RegistrationViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 01.12.2025.
//

import UIKit

final class RegistrationViewController: UIViewController {
    
    // MARK: - Public
    
    /// Колбэк при успешной регистрации email, password, nickname
    var onRegistrationSuccess: ((String, String, String) -> Void)?
    
    // MARK: - Dependencies
    
    private let loginDelegate: LoginViewControllerDelegate
    
    // MARK: - UI
    
    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    private let contentView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Регистрация"
        label.font = AppFonts.title2()
        label.textAlignment = .center
        label.textColor = AppColors.textPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.font = AppFonts.body()
        tf.textColor = AppColors.textPrimary
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let nicknameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Никнейм"
        tf.font = AppFonts.body()
        tf.textColor = AppColors.textPrimary
        tf.autocapitalizationType = .none
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Пароль"
        tf.font = AppFonts.body()
        tf.textColor = AppColors.textPrimary
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Повторите пароль"
        tf.font = AppFonts.body()
        tf.textColor = AppColors.textPrimary
        tf.isSecureTextEntry = true
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    private let matchIconView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "checkmark.circle.fill")
        iv.tintColor = .systemGreen
        iv.isHidden = true
        return iv
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption()
        label.textColor = AppColors.error
        label.numberOfLines = 0
        label.textAlignment = .left
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let registerButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Создать аккаунт", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = AppFonts.bodyBold()
        btn.backgroundColor = AppColors.buttonBlue
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let registerActivityIndicator: UIActivityIndicatorView = {
        let ind = UIActivityIndicatorView(style: .medium)
        ind.hidesWhenStopped = true
        ind.color = .white
        ind.translatesAutoresizingMaskIntoConstraints = false
        return ind
    }()
    
    // MARK: - Init
    
    init(loginDelegate: LoginViewControllerDelegate) {
        self.loginDelegate = loginDelegate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColors.background
        
        setupNavigation()
        setupView()
        setupConstraints()
        setupActions()
    }
    
    // MARK: - Setup
    
    private func setupNavigation() {
        title = "Регистрация"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Отмена",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )
    }
    
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(emailTextField)
        contentView.addSubview(nicknameTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(confirmPasswordTextField)
        contentView.addSubview(matchIconView)
        contentView.addSubview(errorLabel)
        contentView.addSubview(registerButton)
        
        registerButton.addSubview(registerActivityIndicator)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // scrollView
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // contentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title
            titleLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Email
            emailTextField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            emailTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emailTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Nickname
            nicknameTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 12),
            nicknameTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            nicknameTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            nicknameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Password
            passwordTextField.topAnchor.constraint(equalTo: nicknameTextField.bottomAnchor, constant: 12),
            passwordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Confirm password
            confirmPasswordTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor, constant: -36),
            confirmPasswordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            matchIconView.centerYAnchor.constraint(equalTo: confirmPasswordTextField.centerYAnchor),
            matchIconView.leadingAnchor.constraint(equalTo: confirmPasswordTextField.trailingAnchor, constant: 8),
            matchIconView.widthAnchor.constraint(equalToConstant: 24),
            matchIconView.heightAnchor.constraint(equalToConstant: 24),
            
            // Error label
            errorLabel.topAnchor.constraint(equalTo: confirmPasswordTextField.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            // Register button
            registerButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            registerButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            registerButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            registerButton.heightAnchor.constraint(equalToConstant: 48),
            registerButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            registerActivityIndicator.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            registerActivityIndicator.centerYAnchor.constraint(equalTo: registerButton.centerYAnchor)
        ])
    }
    
    private func setupActions() {
        confirmPasswordTextField.addTarget(self, action: #selector(passwordsEditingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(passwordsEditingChanged), for: .editingChanged)
        registerButton.addTarget(self, action: #selector(registerTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true)
    }
    
    @objc private func passwordsEditingChanged() {
        let pass = passwordTextField.text ?? ""
        let confirm = confirmPasswordTextField.text ?? ""
        let nonEmpty = !pass.isEmpty && !confirm.isEmpty
        
        let matches = nonEmpty && (pass == confirm)
        matchIconView.isHidden = !matches
        
        if matches {
            errorLabel.isHidden = true
            errorLabel.text = nil
        }
    }
    
    @objc private func registerTapped() {
        errorLabel.isHidden = true
        errorLabel.text = nil
        
        let email = emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let nickname = nicknameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let password = passwordTextField.text ?? ""
        let confirm = confirmPasswordTextField.text ?? ""
        
        guard !email.isEmpty, !nickname.isEmpty, !password.isEmpty, !confirm.isEmpty else {
            showError("Заполните все поля")
            return
        }
        
        guard password == confirm else {
            showError("Пароли не совпадают")
            matchIconView.isHidden = true
            return
        }
        
        setRegisterLoading(true)
        
        loginDelegate.signUp(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success():
                    // Сохраняем никнейм локально (по email)
                    let key = "nickname_\(email)"
                    UserDefaults.standard.set(nickname, forKey: key)
                    
                    self.setRegisterLoading(false)
                    self.onRegistrationSuccess?(email, password, nickname)
                    self.dismiss(animated: true)
                    
                case .failure(let error):
                    self.setRegisterLoading(false)
                    self.showError(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func showError(_ text: String) {
        errorLabel.text = text
        errorLabel.isHidden = false
    }
    
    private func setRegisterLoading(_ isLoading: Bool) {
        if isLoading {
            registerButton.isEnabled = false
            registerButton.setTitle("", for: .normal)
            registerActivityIndicator.startAnimating()
        } else {
            registerActivityIndicator.stopAnimating()
            registerButton.isEnabled = true
            registerButton.setTitle("Создать аккаунт", for: .normal)
        }
    }
}

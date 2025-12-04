//
//  LogInViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 27.05.2025.
//

import UIKit
import FirebaseAuth
import RealmSwift

final class LogInViewController: UIViewController {
    
    // MARK: - Public
    
    var onLoginSuccess: ((User) -> Void)?
    
    // MARK: - Private state
    
    private var failedAttempts = 0
    private var lockoutTimer: Timer?
    private var lockoutSecondsRemaining = 0
    
    // MARK: - UI
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var textFieldStackView: UIStackView = {
        let separator = UIView()
        separator.backgroundColor = AppColors.separator
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, separator, passwordTextField])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = AppColors.separator.cgColor
        stackView.clipsToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = AppColors.secondaryBackground
        return stackView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email or phone"
        textField.font = AppFonts.body()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.textColor = AppColors.textPrimary
        textField.autocapitalizationType = .none
        textField.keyboardType = .emailAddress
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.font = AppFonts.body()
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.textColor = AppColors.textPrimary
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppFonts.bodyBold()
        button.backgroundColor = AppColors.buttonBlue
        button.setBackgroundImage(nil, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    /// Спиннер внутри кнопки логина
    private let loginActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        return indicator
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Зарегистрироваться", for: .normal)
        button.setTitleColor(AppColors.accent, for: .normal)
        button.titleLabel?.font = AppFonts.body()
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Dependencies

    private let userService: UserService
    private let loginDelegate: LoginViewControllerDelegate

    // MARK: - Init

    init(userService: UserService, loginDelegate: LoginViewControllerDelegate) {
        self.userService = userService
        self.loginDelegate = loginDelegate
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let savedLogin = UserDefaults.standard.string(forKey: "lastLogin")
        let savedPassword = UserDefaults.standard.string(forKey: "lastPassword")

        emailTextField.text = savedLogin
        passwordTextField.text = savedPassword
        
        view.backgroundColor = AppColors.background
        navigationController?.navigationBar.isHidden = true

        setupView()
        setupConstraints()
        setupLoginActivityIndicator()
        
        logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @objc private func logInButtonTapped() {
        print("Нажата кнопка логина")
        
        guard lockoutTimer == nil else {
            showAlert(message: "Слишком много попыток. Подождите \(lockoutSecondsRemaining) сек.")
            return
        }

        let email = emailTextField.text ?? ""
        let password = passwordTextField.text ?? ""
        
        guard !email.isEmpty, !password.isEmpty else {
            showAlert(message: "Введите email и пароль")
            return
        }
        
        setLoginLoading(true)

        loginDelegate.checkCredentials(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success():
                    self.failedAttempts = 0
                    
                    // Сохраняем последние введённые логин и пароль
                    UserDefaults.standard.set(email, forKey: "lastLogin")
                    UserDefaults.standard.set(password, forKey: "lastPassword")
                    
                    // Работа с Realm
                    var avatarImage: UIImage = UIImage(systemName: "person.crop.circle")!
                    var displayName: String = email
                    var statusText: String = "Online"
                    
                    do {
                        let realm = try Realm()
                        
                        if let existingUser = realm.objects(UserRealm.self)
                            .filter("login == %@", email)
                            .first {
                            
                            // Пользователь уже есть — обновляем только пароль
                            try realm.write {
                                existingUser.password = password
                            }
                            
                            if let data = existingUser.avatarData,
                               let image = UIImage(data: data) {
                                avatarImage = image
                            }
                            
                            if !existingUser.nickname.isEmpty {
                                displayName = existingUser.nickname
                            }
                            
                            if !existingUser.status.isEmpty {
                                statusText = existingUser.status
                            }
                            
                        } else {
                            let nicknameKey = "nickname_\(email)"
                            let nicknameFromDefaults = UserDefaults.standard.string(forKey: nicknameKey) ?? ""
                            
                            let newUser = UserRealm(
                                login: email,
                                password: password,
                                nickname: nicknameFromDefaults,
                                status: "Online",
                                avatarData: nil
                            )
                            
                            try realm.write {
                                realm.add(newUser)
                            }
                            
                            if !nicknameFromDefaults.isEmpty {
                                displayName = nicknameFromDefaults
                            }
                        }
                    } catch {
                        print("Ошибка при сохранении/чтении из Realm: \(error.localizedDescription)")
                    }
                    
                    print("Успешный вход!")
                    
                    let user = User(
                        login: email,
                        fullName: displayName,
                        avatar: avatarImage,
                        status: statusText
                    )
                    
                    self.onLoginSuccess?(user)
                    
                case .failure(let error):
                    self.failedAttempts += 1
                    
                    if self.failedAttempts >= 3 {
                        self.startLockout()
                    } else {
                        self.setLoginLoading(false)
                    }
                    
                    self.handleLoginError(error)
                }
            }
        }
    }
    
    @objc private func signUpButtonTapped() {
        let registrationVC = RegistrationViewController(loginDelegate: loginDelegate)
        
        registrationVC.onRegistrationSuccess = { [weak self] email, password, nickname in
            guard let self = self else { return }
            
            // Запоминаем никнейм
            let key = "nickname_\(email)"
            UserDefaults.standard.set(nickname, forKey: key)
            
            // Заполняем поля и автоматически логиним
            self.emailTextField.text = email
            self.passwordTextField.text = password
            self.logInButtonTapped()
        }
        
        let nav = UINavigationController(rootViewController: registrationVC)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true)
    }
    
    // MARK: - Lockout
    
    private func handleLoginError(_ error: Error) {
        let message = error.localizedDescription
        showAlert(message: message)
    }
    
    private func startLockout() {
        loginActivityIndicator.stopAnimating()
        
        lockoutSecondsRemaining = 15
        logInButton.isEnabled = false
        updateLockoutButtonTitle()
        
        lockoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            self.lockoutSecondsRemaining -= 1
            self.updateLockoutButtonTitle()

            if self.lockoutSecondsRemaining <= 0 {
                timer.invalidate()
                self.lockoutTimer = nil
                self.logInButton.setTitle("Log In", for: .normal)
                self.logInButton.isEnabled = true
                self.failedAttempts = 0
            }
        }
    }
    
    private func updateLockoutButtonTitle() {
        logInButton.setTitle("Подождите \(lockoutSecondsRemaining) сек", for: .normal)
    }
    
    private func setLoginLoading(_ isLoading: Bool) {
        if isLoading {
            logInButton.isEnabled = false
            logInButton.setTitle("", for: .normal)
            loginActivityIndicator.startAnimating()
        } else {
            loginActivityIndicator.stopAnimating()
            if lockoutTimer == nil {
                logInButton.isEnabled = true
                logInButton.setTitle("Log In", for: .normal)
            }
        }
    }
    
    // MARK: - Keyboard
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInset
        scrollView.verticalScrollIndicatorInsets = contentInset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.verticalScrollIndicatorInsets = contentInset
    }
    
    // MARK: - Alerts
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showAlert(message: String) {
        showAlert(title: "Ошибка", message: message)
    }
    
    // MARK: - Layout
    
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(textFieldStackView)
        contentView.addSubview(logInButton)
        contentView.addSubview(signUpButton)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            logoImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 120),
            logoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),

            textFieldStackView.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 120),
            textFieldStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldStackView.heightAnchor.constraint(equalToConstant: 101),

            emailTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),

            logInButton.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 16),
            logInButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            logInButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            
            signUpButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 16),
            signUpButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            signUpButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupLoginActivityIndicator() {
        logInButton.addSubview(loginActivityIndicator)
        NSLayoutConstraint.activate([
            loginActivityIndicator.centerXAnchor.constraint(equalTo: logInButton.centerXAnchor),
            loginActivityIndicator.centerYAnchor.constraint(equalTo: logInButton.centerYAnchor)
        ])
    }
}

//
//  LogInViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 27.05.2025.
//

import UIKit

class LogInViewController: UIViewController {
    
    var loginDelegate: LoginViewControllerDelegate?
    var onLoginSuccess: ((User) -> Void)?
    
    private var failedAttempts = 0
    private var lockoutTimer: Timer?
    private var lockoutSecondsRemaining = 0
    
    private let bruteForcer = PasswordBruteForcer()
    
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
        separator.backgroundColor = .lightGray
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        

        let stackView = UIStackView(arrangedSubviews: [emailTextField, separator, passwordTextField])
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.clipsToBounds = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.backgroundColor = .systemGray6
        return stackView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email or phone"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.textColor = .black
        textField.autocapitalizationType = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        textField.leftViewMode = .always
        textField.textColor = .black
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setBackgroundImage(UIImage(named: "blue_pixel"), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let bruteForceButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("Подобрать пароль", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.setBackgroundImage(UIImage(named: "blue_pixel"), for: .normal)
        btn.layer.cornerRadius = 10
        btn.layer.masksToBounds = true
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false 
        return indicator
    }()

    private let userService: UserService

    init(userService: UserService) {
        self.userService = userService
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
#if DEBUG
emailTextField.text = "test"
#else
emailTextField.text = "cat"
#endif
passwordTextField.text = "1234"

        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = true

        setupView()
        setupConstraints()
        logInButton.addTarget(self, action: #selector(logInButtonTapped), for: .touchUpInside)
        bruteForceButton.addTarget(self, action: #selector(bruteForceTapped), for: .touchUpInside)

        bruteForceButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: bruteForceButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: bruteForceButton.centerYAnchor)
        ])
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func logInButtonTapped() {
        guard lockoutTimer == nil else {
            showAlert(message: "Слишком много попыток. Подождите \(lockoutSecondsRemaining) сек.")
            return
        }

        guard let login = emailTextField.text, !login.isEmpty else {
            showAlert(message: "Введите логин")
            return
        }

        guard let password = passwordTextField.text else {
            showAlert(message: "Введите пароль")
            return
        }

        if loginDelegate?.check(login: login, password: password) == true,
           let user = userService.getUser(login: login) {
            failedAttempts = 0
            onLoginSuccess?(user)
        } else {
            failedAttempts += 1
            if failedAttempts >= 3 {
                startLockout()
            } else {
                showAlert(message: "Неверный логин или пароль")
            }
        }
    }
    
    private func startLockout() {
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
    
    @objc private func bruteForceTapped() {
        bruteForceButton.isEnabled = false
        bruteForceButton.setTitle("", for: .normal)
        activityIndicator.startAnimating()

        passwordTextField.text = ""
        passwordTextField.isSecureTextEntry = true

        let passwordToFind = bruteForcer.generateRandomPassword(length: 4)
        bruteForcer.bruteForce(passwordToUnlock: passwordToFind) { [weak self] result in
            guard let self = self else { return }

            self.passwordTextField.text = result
            self.passwordTextField.isSecureTextEntry = false

            self.activityIndicator.stopAnimating()
            self.bruteForceButton.setTitle("Подобрать пароль", for: .normal)
            self.bruteForceButton.isEnabled = true
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }

        let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
        scrollView.contentInset = contentInset
        scrollView.verticalScrollIndicatorInsets = contentInset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.verticalScrollIndicatorInsets = contentInset
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(logoImageView)
        contentView.addSubview(textFieldStackView)
        contentView.addSubview(logInButton)
        contentView.addSubview(bruteForceButton)
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

            bruteForceButton.topAnchor.constraint(equalTo: logInButton.bottomAnchor, constant: 16),
            bruteForceButton.leadingAnchor.constraint(equalTo: logInButton.leadingAnchor),
            bruteForceButton.trailingAnchor.constraint(equalTo: logInButton.trailingAnchor),
            bruteForceButton.heightAnchor.constraint(equalToConstant: 50),
            bruteForceButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


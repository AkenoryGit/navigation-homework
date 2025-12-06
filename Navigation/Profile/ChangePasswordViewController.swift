//
//  ChangePasswordViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 02.12.2025.
//

import UIKit
import RealmSwift
import FirebaseAuth

/// Экран смены пароля пользователя
final class ChangePasswordViewController: UIViewController {

    // MARK: - Public

    /// Текущий логин (email), для которого меняем пароль
    var currentLogin: String?

    // MARK: - Init

    init(login: String) {
        self.currentLogin = login
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        let l = UILabel()
        l.text = "Смена пароля"
        l.font = AppFonts.title1()
        l.textAlignment = .center
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()

    private let currentPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Текущий пароль"
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.font = AppFonts.body()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let newPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Новый пароль"
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.font = AppFonts.body()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let confirmPasswordField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Повторите новый пароль"
        tf.isSecureTextEntry = true
        tf.autocapitalizationType = .none
        tf.autocorrectionType = .no
        tf.borderStyle = .roundedRect
        tf.font = AppFonts.body()
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    private let changeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Сменить пароль", for: .normal)
        b.titleLabel?.font = AppFonts.bodyBold()
        b.setTitleColor(.white, for: .normal)
        b.backgroundColor = AppColors.buttonBlue
        b.layer.cornerRadius = 10
        b.layer.masksToBounds = true
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let a = UIActivityIndicatorView(style: .medium)
        a.hidesWhenStopped = true
        a.translatesAutoresizingMaskIntoConstraints = false
        return a
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Пароль"
        view.backgroundColor = AppColors.background

        setupLayout()
        setupKeyboardObservers()

        changeButton.addTarget(self,
                               action: #selector(changePasswordTapped),
                               for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(currentPasswordField)
        contentView.addSubview(newPasswordField)
        contentView.addSubview(confirmPasswordField)
        contentView.addSubview(changeButton)
        changeButton.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            currentPasswordField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            currentPasswordField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            currentPasswordField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            currentPasswordField.heightAnchor.constraint(equalToConstant: 44),

            newPasswordField.topAnchor.constraint(equalTo: currentPasswordField.bottomAnchor, constant: 16),
            newPasswordField.leadingAnchor.constraint(equalTo: currentPasswordField.leadingAnchor),
            newPasswordField.trailingAnchor.constraint(equalTo: currentPasswordField.trailingAnchor),
            newPasswordField.heightAnchor.constraint(equalToConstant: 44),

            confirmPasswordField.topAnchor.constraint(equalTo: newPasswordField.bottomAnchor, constant: 16),
            confirmPasswordField.leadingAnchor.constraint(equalTo: currentPasswordField.leadingAnchor),
            confirmPasswordField.trailingAnchor.constraint(equalTo: currentPasswordField.trailingAnchor),
            confirmPasswordField.heightAnchor.constraint(equalToConstant: 44),

            changeButton.topAnchor.constraint(equalTo: confirmPasswordField.bottomAnchor, constant: 24),
            changeButton.leadingAnchor.constraint(equalTo: currentPasswordField.leadingAnchor),
            changeButton.trailingAnchor.constraint(equalTo: currentPasswordField.trailingAnchor),
            changeButton.heightAnchor.constraint(equalToConstant: 50),
            changeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),

            activityIndicator.centerXAnchor.constraint(equalTo: changeButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: changeButton.centerYAnchor)
        ])
    }

    // MARK: - Keyboard

    private func setupKeyboardObservers() {
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
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
        else { return }

        let inset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height, right: 0)
        scrollView.contentInset = inset
        scrollView.verticalScrollIndicatorInsets = inset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.verticalScrollIndicatorInsets = .zero
    }

    // MARK: - Actions

    @objc private func changePasswordTapped() {
        view.endEditing(true)

        guard let login = currentLogin, !login.isEmpty else {
            showAlert(title: "Ошибка", message: "Неизвестен текущий пользователь.")
            return
        }

        let oldPassword = currentPasswordField.text ?? ""
        let newPassword = newPasswordField.text ?? ""
        let confirmPassword = confirmPasswordField.text ?? ""

        guard !oldPassword.isEmpty, !newPassword.isEmpty, !confirmPassword.isEmpty else {
            showAlert(title: "Ошибка", message: "Заполните все поля.")
            return
        }

        guard newPassword == confirmPassword else {
            showAlert(title: "Ошибка", message: "Новый пароль и подтверждение не совпадают.")
            return
        }

        guard newPassword.count >= 6 else {
            showAlert(title: "Ошибка", message: "Минимальная длина пароля — 6 символов.")
            return
        }

        setLoading(true)

        // Проверяем старый пароль через FirebaseAuth (ре-аутентификация)
        Auth.auth().signIn(withEmail: login, password: oldPassword) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showAlert(title: "Ошибка", message: "Текущий пароль неверен.\n\(error.localizedDescription)")
                }
                return
            }

            guard let user = result?.user ?? Auth.auth().currentUser else {
                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showAlert(title: "Ошибка", message: "Не удалось получить текущего пользователя.")
                }
                return
            }

            // Обновляем пароль в Firebase
            user.updatePassword(to: newPassword) { [weak self] error in
                guard let self = self else { return }

                if let error = error {
                    DispatchQueue.main.async {
                        self.setLoading(false)
                        self.showAlert(title: "Ошибка", message: "Не удалось обновить пароль.\n\(error.localizedDescription)")
                    }
                    return
                }

                // Обновляем пароль в Realm
                do {
                    let realm = try Realm()
                    if let userObject = realm.objects(UserRealm.self)
                        .filter("login == %@", login)
                        .first {
                        try realm.write {
                            userObject.password = newPassword
                        }
                    }
                } catch {
                    print("ChangePasswordVC: ошибка обновления пароля в Realm: \(error)")
                }

                // Обновляем последний пароль в UserDefaults
                UserDefaults.standard.set(newPassword, forKey: "lastPassword")

                DispatchQueue.main.async {
                    self.setLoading(false)
                    self.showAlert(title: "Готово", message: "Пароль успешно изменён.") { [weak self] in
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }

    private func setLoading(_ isLoading: Bool) {
        if isLoading {
            changeButton.isEnabled = false
            changeButton.setTitle("", for: .normal)
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            changeButton.isEnabled = true
            changeButton.setTitle("Сменить пароль", for: .normal)
        }
    }

    // MARK: - Alerts

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}

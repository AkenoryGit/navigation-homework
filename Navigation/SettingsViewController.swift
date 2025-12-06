//
//  SettingsViewController.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 02.12.2025.
//

import UIKit
import RealmSwift

// MARK: - ThemeManager

struct ThemeManager {

    enum Theme: String, CaseIterable {
        case system
        case light
        case dark

        var title: String {
            switch self {
            case .system: return "Системная"
            case .light:  return "Светлая"
            case .dark:   return "Тёмная"
            }
        }
    }

    private static let key = "app_theme"

    static func currentTheme() -> Theme {
        if let raw = UserDefaults.standard.string(forKey: key),
           let theme = Theme(rawValue: raw) {
            return theme
        }
        return .system
    }

    static func apply(_ theme: Theme) {
        UserDefaults.standard.set(theme.rawValue, forKey: key)

        let style: UIUserInterfaceStyle
        switch theme {
        case .system: style = .unspecified
        case .light:  style = .light
        case .dark:   style = .dark
        }

        // Применяем ко всем окнам приложения
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
}

// MARK: - SettingsViewController

final class SettingsViewController: UIViewController {

    // MARK: - Public

    /// Текущий логин
    var currentLogin: String?

    // MARK: - Private

    private enum Section: Int, CaseIterable {
        case appearance
        case profile
    }

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .singleLine
        tv.showsVerticalScrollIndicator = true
        return tv
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Настройки"
        view.backgroundColor = AppColors.background

        setupTableView()
        applyCurrentThemeToSelf()
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func applyCurrentThemeToSelf() {
        let theme = ThemeManager.currentTheme()
        let style: UIUserInterfaceStyle
        switch theme {
        case .system: style = .unspecified
        case .light:  style = .light
        case .dark:   style = .dark
        }
        overrideUserInterfaceStyle = style
    }

    // MARK: - Actions

    private func selectTheme(_ theme: ThemeManager.Theme) {
        ThemeManager.apply(theme)
        applyCurrentThemeToSelf()
        tableView.reloadSections(IndexSet(integer: Section.appearance.rawValue), with: .fade)
    }

    private func showChangeNicknameAlert() {
        guard let login = currentLogin else { return }

        var existingNickname: String = ""
        do {
            let realm = try Realm()
            if let user = realm.objects(UserRealm.self).filter("login == %@", login).first {
                existingNickname = user.nickname
            }
        } catch {
            print("Не удалось прочитать UserRealm для изменения никнейма: \(error)")
        }

        let alert = UIAlertController(
            title: "Изменить никнейм",
            message: "Новый никнейм будет отображаться в профиле и новых постах.",
            preferredStyle: .alert
        )

        alert.addTextField { textField in
            textField.placeholder = "Новый никнейм"
            textField.text = existingNickname.isEmpty ? nil : existingNickname
        }

        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [weak self, weak alert] _ in
            guard
                let self = self,
                let text = alert?.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                !text.isEmpty
            else { return }

            self.updateNickname(newNickname: text, for: login)
        }

        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    private func updateNickname(newNickname: String, for login: String) {
        // Realm
        do {
            let realm = try Realm()
            if let user = realm.objects(UserRealm.self).filter("login == %@", login).first {
                try realm.write {
                    user.nickname = newNickname
                }
            }
        } catch {
            print("Ошибка обновления никнейма в Realm: \(error)")
        }

        // UserDefaults
        let key = "nickname_\(login)"
        UserDefaults.standard.set(newNickname, forKey: key)

        // Обновляем секцию профиля в настройках
        tableView.reloadSections(IndexSet(integer: Section.profile.rawValue), with: .none)
    }

    private func openChangePassword() {
        guard let login = currentLogin else { return }

        let vc = ChangePasswordViewController(login: login)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {

        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .appearance:
            // System / Light / Dark
            return 3
        case .profile:
            // Change nickname / Change password
            return 2
        }
    }

    func tableView(_ tableView: UITableView,
                   titleForHeaderInSection section: Int) -> String? {
        guard let section = Section(rawValue: section) else { return nil }

        switch section {
        case .appearance:
            return "Тема оформления"
        case .profile:
            return "Профиль"
        }
    }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let section = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .none
        cell.selectionStyle = .default
        cell.textLabel?.font = AppFonts.body()
        cell.textLabel?.textColor = AppColors.textPrimary

        switch section {
        case .appearance:
            let theme = ThemeManager.currentTheme()
            let option: ThemeManager.Theme
            switch indexPath.row {
            case 0: option = .system
            case 1: option = .light
            case 2: option = .dark
            default: option = .system
            }
            cell.textLabel?.text = option.title
            cell.accessoryType = (option == theme) ? .checkmark : .none

        case .profile:
            if indexPath.row == 0 {
                cell.textLabel?.text = "Изменить никнейм"
                cell.accessoryType = .disclosureIndicator
            } else {
                cell.textLabel?.text = "Изменить пароль"
                cell.accessoryType = .disclosureIndicator
            }
        }

        return cell
    }
}

// MARK: - UITableViewDelegate

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {

        tableView.deselectRow(at: indexPath, animated: true)

        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .appearance:
            let option: ThemeManager.Theme
            switch indexPath.row {
            case 0: option = .system
            case 1: option = .light
            case 2: option = .dark
            default: option = .system
            }
            selectTheme(option)

        case .profile:
            if indexPath.row == 0 {
                showChangeNicknameAlert()
            } else {
                openChangePassword()
            }
        }
    }
}

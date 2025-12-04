//
//  AppColors.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 26.11.2025.
//

import UIKit

enum AppColors {

    // MARK: - Основная палитра

    static let background = UIColor.systemBackground     // фон экрана
    static let secondaryBackground = UIColor.secondarySystemBackground

    // Кнопочный фиксированный цвет
    static let buttonBlue = UIColor(
        red: 73/255,
        green: 134/255,
        blue: 204/255,
        alpha: 1
    )

    static let textPrimary = UIColor.label
    static let textSecondary = UIColor.secondaryLabel

    // MARK: - Акцент
    static let accent = UIColor.systemBlue

    // MARK: - Разделители
    static let separator = UIColor.separator

    // MARK: - Состояния
    static let success = UIColor.systemGreen
    static let error = UIColor.systemRed
}

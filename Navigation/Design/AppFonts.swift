//
//  AppFonts.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 26.11.2025.
//

import UIKit

enum AppFonts {

    // MARK: - Заголовки

    static func title1() -> UIFont {
        UIFont.systemFont(ofSize: 28, weight: .bold)
    }

    static func title2() -> UIFont {
        UIFont.systemFont(ofSize: 22, weight: .semibold)
    }

    static func title3() -> UIFont {
        UIFont.systemFont(ofSize: 18, weight: .semibold)
    }

    // MARK: - Основной текст

    static func body() -> UIFont {
        UIFont.systemFont(ofSize: 16, weight: .regular)
    }

    static func bodyMedium() -> UIFont {
        UIFont.systemFont(ofSize: 16, weight: .medium)
    }

    static func bodyBold() -> UIFont {
        UIFont.systemFont(ofSize: 16, weight: .semibold)
    }

    // MARK: - Вспомогательный текст

    static func caption() -> UIFont {
        UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    static func captionBold() -> UIFont {
        UIFont.systemFont(ofSize: 13, weight: .semibold)
    }
}

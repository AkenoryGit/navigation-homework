//
//  LoginViewControllerDelegate.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 07.07.2025.
//

import Foundation

protocol LoginViewControllerDelegate {
    func check(login: String, password: String) -> Bool
}

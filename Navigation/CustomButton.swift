//
//  CustomButton.swift
//  Navigation
//
//  Created by Дмитрий Дудник on 15.07.2025.
//

import UIKit

final class CustomButton: UIButton {
    
    private var onTap: (() -> Void)?
    
    init(title: String,
         titleColor: UIColor = .white,
         backgroundColor: UIColor = .systemBlue,
         onTap: (() -> Void)? = nil) {
        
        self.onTap = onTap
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
        layer.cornerRadius = 10
        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        translatesAutoresizingMaskIntoConstraints = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func buttonTapped() {
        onTap?()
    }
}

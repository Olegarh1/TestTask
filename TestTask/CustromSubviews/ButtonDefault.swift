//
// ButtonDefault.swift
// TestTask
//
// Created by Oleg Zakladnyi on 22.06.2025

import UIKit

class ButtonDefault: UIButton {
    
    init(title: String, target: Any?, action: Selector) {
        super.init(frame: .zero)
        setup(title: title, target: target, action: action)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup(title: String, target: Any?, action: Selector?) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        config.cornerStyle = .capsule
        config.baseForegroundColor = .black
        config.baseBackgroundColor = UIColor(hex: "#F4E041")
        
        self.configuration = config
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let target = target, let action = action {
            self.addTarget(target, action: action, for: .touchUpInside)
        }
    }
}

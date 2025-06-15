//
// RadioButton.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

class RadioButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "unselectedCircle")
        config.imagePadding = 16
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        config.baseForegroundColor = .black
        config.baseBackgroundColor = .white
        config.titleAlignment = .leading
        self.configuration = config
    }
    
    override var isSelected: Bool {
        didSet {
            self.setImage(UIImage(named: isSelected ? "selectedCircle" : "unselectedCircle"), for: .normal)
        }
    }
}


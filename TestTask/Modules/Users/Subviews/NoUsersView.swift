//
// NoUsersView.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

final class NoUsersView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "usersCircled")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "There are no users yet"
        label.font = .setFont(.nunitoRegular, size: 20)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var mainStack: UIStackView = {
        let vstack = UIStackView(arrangedSubviews: [imageView, label])
        vstack.axis = .vertical
        vstack.spacing = 24
        vstack.alignment = .center
        vstack.translatesAutoresizingMaskIntoConstraints = false
        return vstack
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

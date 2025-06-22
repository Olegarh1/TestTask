//
// RegistrationResultViewController.swift
// TestTask
//
// Created by Oleg Zakladnyi on 21.06.2025

import UIKit

class RegistrationResultViewController: UIViewController {
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .black.withAlphaComponent(0.48)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = success ? UIImage(named: "successImage") : UIImage(named: "FailedImage")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = message
        label.font = .setFont(.nunitoRegular, size: 24)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        return label
    }()
    
    private lazy var button: UIButton = ButtonDefault(title: success ? "Got it" : "Try again", target: self, action: #selector(dismissView))
    
    private lazy var mainStack: UIStackView = {
        let vstack = UIStackView(arrangedSubviews: [imageView, resultLabel, button])
        vstack.axis = .vertical
        vstack.alignment = .center
        vstack.spacing = 24
        vstack.translatesAutoresizingMaskIntoConstraints = false
        return vstack
    }()
    
    private let success: Bool
    private let message: String
    
    init(success: Bool, message: String) {
        self.success = success
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

private extension RegistrationResultViewController {
    func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(closeButton)
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),
            
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.9)
        ])
    }
    
    @objc
    func dismissView(_ sender: UIButton) {
        sender.showAnimation {
            self.dismiss(animated: true)
        }
    }
}

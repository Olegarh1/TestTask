//
// RegistrationResultViewController.swift
// TestTask
//
// Created by Oleg Zakladnyi on 21.06.2025

import UIKit

class RegistrationResultViewController: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = message
        label.font = .setFont(.nunitoRegular, size: 24)
        label.textColor = .black
        return label
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#F4E041")
        button.layer.cornerRadius = 24
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return button
    }()
    
    private lazy var mainStack: UIStackView = {
        let vstack = UIStackView(arrangedSubviews: [imageView, resultLabel, button])
        vstack.axis = .vertical
        vstack.alignment = .center
        vstack.spacing = 24
        return vstack
    }()
    
    private let success: Bool
    private let message: String
    
    init(success: Bool, message: String) {
        self.success = success
        self.message = message
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = success ? UIImage(named: "successImage") : UIImage(named: "FailedImage")
        setupUI()
    }
}

private extension RegistrationResultViewController {
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: 48)
        ])
    }
    
    @objc
    func buttonAction(_ sender: UIButton) {
        sender.showAnimation {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

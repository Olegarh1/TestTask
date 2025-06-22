//
// NetworkConnectionVC.swift
// TestTask
//
// Created by Oleg Zakladnyi on 22.06.2025

import UIKit

class NetworkConnectionVC: UIViewController {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "networkConnection")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.text = "There is no internet connection"
        label.font = .setFont(.nunitoRegular, size: 24)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textColor = .black
        return label
    }()
    
    private lazy var button: UIButton = ButtonDefault(title: "Try again", target: self, action: #selector(buttonAction))
    
    private lazy var mainStack: UIStackView = {
        let vstack = UIStackView(arrangedSubviews: [imageView, resultLabel, button])
        vstack.axis = .vertical
        vstack.alignment = .center
        vstack.spacing = 24
        vstack.translatesAutoresizingMaskIntoConstraints = false
        return vstack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

private extension NetworkConnectionVC {
    func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            mainStack.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, constant: 48),
            mainStack.heightAnchor.constraint(lessThanOrEqualTo: view.heightAnchor, multiplier: 0.9)
        ])
    }
    
    @objc
    func buttonAction(_ sender: UIButton) {
        sender.showAnimation {
            guard NetworkMonitor.shared.isConnected else { return }
            NetworkOverlayManager.shared.hideOverlay()
        }
    }
}

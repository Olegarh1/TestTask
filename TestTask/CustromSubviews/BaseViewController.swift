//
// BaseViewController.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

import UIKit

class BaseViewController: UIViewController {

    private lazy var customNavBar: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#F4E041")
        view.layer.zPosition = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomNavBar()
    }

    private func setupCustomNavBar() {
        view.addSubview(customNavBar)
        customNavBar.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            customNavBar.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 56),
            
            titleLabel.centerXAnchor.constraint(equalTo: customNavBar.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor)
        ])
    }

    func setNavTitle(_ title: String) {
        titleLabel.text = title
    }
}

//
// AlertView.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

final class AlertView {
    
    static func showError(_ message: String, on viewController: UIViewController) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        viewController.present(alert, animated: true)
    }
}

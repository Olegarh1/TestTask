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
    
    static func showAlertMessage(title: String,
                                 message: String,
                                 closeAction: String? = nil,
                                 action: String,
                                 actionStyle: UIAlertAction.Style = .default,
                                 completion: (() -> Void)? = nil,
                                 onCloseCompletion: (() -> Void)? = nil,
                                 on viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        if let closeTitle = closeAction {
            let close = UIAlertAction(title: closeTitle, style: .cancel) { _ in
                onCloseCompletion?()
            }
            alert.addAction(close)
        }
        
        let okay = UIAlertAction(title: action, style: actionStyle) { _ in
            completion?()
        }
        alert.addAction(okay)
        
        viewController.present(alert, animated: true)
    }
}

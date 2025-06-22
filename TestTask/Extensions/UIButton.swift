//
// UIButton.swift
// TestTask
//
// Created by Oleg Zakladnyi on 22.06.2025

import UIKit

private var loaderKey: UInt8 = 0
private var originalImageKey: UInt8 = 1
private var originalTitleKey: UInt8 = 2
private var originalAttributedTitleKey: UInt8 = 3

extension UIButton {
    private var loader: UIActivityIndicatorView? {
        get { return objc_getAssociatedObject(self, &loaderKey) as? UIActivityIndicatorView }
        set { objc_setAssociatedObject(self, &loaderKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    private var originalTitle: String? {
        get { return objc_getAssociatedObject(self, &originalTitleKey) as? String }
        set { objc_setAssociatedObject(self, &originalTitleKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func showLoaderInsteadOfcontent(color: UIColor = .black, style: UIActivityIndicatorView.Style = .medium) {
        guard loader == nil else { return }

        if let config = self.configuration {
            originalTitle = config.title
            var newConfig = config
            newConfig.title = nil
            self.configuration = newConfig
        }

        let activityIndicator = UIActivityIndicatorView(style: style)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = color
        activityIndicator.startAnimating()
        addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        loader = activityIndicator
        isUserInteractionEnabled = false
    }

    func hideLoaderAndRestoreContent() {
        DispatchQueue.main.async {
            self.loader?.removeFromSuperview()
            self.loader = nil
            self.isUserInteractionEnabled = true

            if var config = self.configuration, let title = self.originalTitle {
                config.title = title
                self.configuration = config
            }
        }
    }
}

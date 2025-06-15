//
// TabBarItem.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

final class TabBarItem: UITabBar {
    override func layoutSubviews() {
        super.layoutSubviews()

        for subview in subviews {
            guard let tabButton = subview as? UIControl else { continue }

            // Вимикаємо авто-розміщення системи
            tabButton.subviews.forEach { $0.translatesAutoresizingMaskIntoConstraints = true }

            var imageView: UIImageView?
            var label: UILabel?

            for innerView in tabButton.subviews {
                if let iv = innerView as? UIImageView {
                    imageView = iv
                } else if let lbl = innerView as? UILabel {
                    label = lbl
                }
            }

            guard let imageView = imageView, let label = label else { continue }

            imageView.contentMode = .scaleAspectFit
            label.sizeToFit()

            let spacing: CGFloat = 8
            let totalWidth = imageView.frame.width + spacing + label.frame.width

            let startX = (tabButton.bounds.width - totalWidth) / 2
            let centerY = tabButton.bounds.height / 2

            imageView.frame = CGRect(
                x: startX,
                y: centerY - imageView.frame.height / 2,
                width: imageView.frame.width,
                height: imageView.frame.height
            )

            label.frame = CGRect(
                x: imageView.frame.maxX + spacing,
                y: centerY - label.frame.height / 2,
                width: label.frame.width,
                height: label.frame.height
            )
        }
    }
}

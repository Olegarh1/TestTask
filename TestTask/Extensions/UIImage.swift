//
// UIImage.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

extension UIImage {
    func resized(to size: Double) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: CGSize(width: size, height: size)))
        }
    }
}

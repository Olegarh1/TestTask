//
// UIColor.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        guard hexSanitized.count == 6, let hexNumber = UInt64(hexSanitized, radix: 16) else {
            self.init(white: 0.0, alpha: 1.0)
            return
        }

        let r = (hexNumber & 0xFF0000) >> 16
        let g = (hexNumber & 0x00FF00) >> 8
        let b = hexNumber & 0x0000FF

        self.init(
            red: CGFloat(r) / 255.0,
            green: CGFloat(g) / 255.0,
            blue: CGFloat(b) / 255.0,
            alpha: 1.0
        )
    }
}

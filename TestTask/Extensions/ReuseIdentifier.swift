//
// ReuseIdentifiable.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit
 
protocol ReuseIdentifiable {
    static func identifier() -> String
}

extension ReuseIdentifiable {
    static func identifier() -> String {
        return "com.app.".appending(String(describing: Self.self)).appending(".reuseIdentifier")
    }
}

extension UICollectionViewCell: ReuseIdentifiable {
}

extension UITableViewCell: ReuseIdentifiable {
}

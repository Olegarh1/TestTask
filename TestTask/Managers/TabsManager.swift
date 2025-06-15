//
// TabsManager.swift
// InstaCatch
//
// Created by Oleg Zakladnyi on 29.01.2025

import Foundation

class TabsManager {
    
    var tabBarSelectedIndex: Int {
        set {
            UserDefaults.standard.set(newValue, forKey: key)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.integer(forKey: key)
        }
    }
    
    private let key = "tabBarIndex"
    
    fileprivate init() {}
    
    public static let `default`: TabsManager = .init()
}



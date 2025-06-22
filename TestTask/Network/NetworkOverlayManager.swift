//
// NetworkOverlayManager.swift
// TestTask
//
// Created by Oleg Zakladnyi on 22.06.2025

import UIKit

final class NetworkOverlayManager {
    
    static let shared = NetworkOverlayManager()
    
    var currentScene: UIWindowScene?
    
    private var overlayWindow: UIWindow?
    
    private init() {}
    
    func showOverlay() {
        guard overlayWindow == nil else { return }
        
        let overlayVC = NetworkConnectionVC()
        overlayVC.modalPresentationStyle = .fullScreen
        
        guard let windowScene = currentScene else {
            print("❗️No saved windowScene available")
            return
        }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = overlayVC
        window.windowLevel = UIWindow.Level.statusBar + 1
        window.makeKeyAndVisible()
        
        overlayWindow = window
    }
    
    func hideOverlay() {
        overlayWindow?.isHidden = true
        overlayWindow = nil
    }
}


//
// SceneDelegate.swift
// TestTask
//
// Created by Oleg Zakladnyi on 22.06.2025

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        NetworkOverlayManager.shared.currentScene = windowScene
        
        let mainVC = TabBarController()
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = mainVC
        window?.makeKeyAndVisible()
        
        NetworkMonitor.shared.startMonitoring()
    }
}


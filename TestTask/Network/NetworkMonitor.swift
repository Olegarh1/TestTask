//
// NetworkMonitor.swift
// TestTask
//
// Created by Oleg Zakladnyi on 22.06.2025

import Network

final class NetworkMonitor {
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private var onConnectActions: [() -> Void] = []

    private(set) var isConnected: Bool = false

    private init() {}

    func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self = self else { return }
            DispatchQueue.main.async {
                let wasConnected = self.isConnected
                self.isConnected = path.status == .satisfied
                
                if self.isConnected {
                    NetworkOverlayManager.shared.hideOverlay()
                    
                    if !wasConnected {
                        let actions = self.onConnectActions
                        self.onConnectActions.removeAll()
                        actions.forEach { $0() }
                    }
                } else {
                    NetworkOverlayManager.shared.showOverlay()
                }
            }
        }
        monitor.start(queue: queue)
    }

    /// Виконує дію одразу або зберігає до появи підключення
    func runWhenConnected(_ action: @escaping () -> Void) {
        if isConnected {
            action()
        } else {
            onConnectActions.append(action)
        }
    }
}

//
// PhotoSourceAlert.swift
// TestTask
//
// Created by Oleg Zakladnyi on 21.06.2025

import UIKit

final class PhotoSourceAlert {
    
    static func present(over viewController: UIViewController,
                        cameraHandler: @escaping () -> Void,
                        galleryHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: "Choose how you want to add a photo",
                                                message: nil,
                                                preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { _ in
            cameraHandler()
        })
        
        alertController.addAction(UIAlertAction(title: "Gallery", style: .default) { _ in
            galleryHandler()
        })
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        // Для iPad (actionSheet обов’язково має popover)
        if let popover = alertController.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        viewController.present(alertController, animated: true)
    }
}

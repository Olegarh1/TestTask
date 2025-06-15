//
// UIView.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

extension UIView {
    func showAnimation(_ completionBlock: @escaping () -> Void) {
      isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
                            self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        }) {  (done) in
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                                self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
                completionBlock()
            }
        }
    }
    
    func animateIn(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        self.alpha = 0
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: { _ in
            completion?()
        })
    }
    
    func animateOut(duration: TimeInterval = 0.3, completion: (() -> Void)? = nil) {
        self.alpha = 1
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }) { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.removeFromSuperview()
                completion?()
            }
        }
    }

}

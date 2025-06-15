//
// TabBarController.swift
// TestTask
//
// Created by Oleg Zakladnyi on 15.06.2025

import UIKit

class TabBarController: UITabBarController {
    
    public var duration = TimeInterval(0.3)
    
    private lazy var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration = duration * 2
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //TODO: Ima
//        let customTabBar = TabBarItem()
//        setValue(customTabBar, forKey: "tabBar")
        configureTabs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndex = TabsManager.default.tabBarSelectedIndex
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 1, let imageView = tabBar.subviews[idx + 1].subviews.first as? UIImageView else {
            return
        }
        imageView.layer.add(bounceAnimation, forKey: nil)
        TabsManager.default.tabBarSelectedIndex = idx
    }
}

private extension TabBarController {
    func configureTabs() {
        tabBar.backgroundColor = UIColor(hex: "#F8F8F8")
        tabBar.shadowImage = UIImage()
        tabBar.backgroundImage = UIImage()
        
        let v1 = UINavigationController(rootViewController: UsersViewController())
        
        let v2 = UINavigationController(rootViewController: SignUpViewController())
        
        v1.tabBarItem.title = "Users"
        v1.tabBarItem.image = UIImage(named: "Users")
        
        v2.tabBarItem.title = "Sign up"
        v2.tabBarItem.image = UIImage(named: "SignUp")
        
        tabBar.tintColor = UIColor(hex: "#00BDD3")
        tabBar.unselectedItemTintColor = UIColor.black.withAlphaComponent(0.6)
        
        self.setViewControllers([v1, v2], animated: true)
    }
}

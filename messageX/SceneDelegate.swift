//
//  SceneDelegate.swift
//  messageX
//
//  Created by М Й on 03.03.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        // Оборачиваем ProfileViewController в UINavigationController
        let profileVC = AuthViewController()
        let navController = UINavigationController(rootViewController: profileVC)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}

//
//  SceneDelegate.swift
//  MVVMWeatherApp
//
//  Created by khalifa on 2/13/21.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: HomeView.getConfiguredInstance())
            self.window = window
            window.makeKeyAndVisible()
        }
    }
}

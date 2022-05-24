//
//  AppDelegate.swift
//  EasyEnglish
//
//  Created on 3/4/19.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    private lazy var appCoordinator = AppCoordinator()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil)
        -> Bool {
            IQKeyboardManager.shared.enable = true
            
            appCoordinator.start()

            return true
    }
}

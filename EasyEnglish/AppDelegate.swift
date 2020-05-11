//
//  AppDelegate.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/4/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil)
        -> Bool {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.makeKeyAndVisible()
            let storyboard = UIStoryboard(name: "Dictionary", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "Dictionary")

            window?.rootViewController = controller

            IQKeyboardManager.shared.enable = true

            return true
    }
}

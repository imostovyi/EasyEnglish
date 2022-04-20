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

    private lazy var appCoordinator = AppCoordinator()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil)
        -> Bool {
            IQKeyboardManager.shared.enable = true
            
            appCoordinator.start()

            return true
    }
}

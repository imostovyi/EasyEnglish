//
//  AppCoordinator.swift
//  EasyEnglish
//
//  Created by Ігор Мостовий on 20.04.2022.
//  Copyright © 2022 Мостовий Ігор. All rights reserved.
//

import UIKit

final class AppCoordinator: Coordinator, ParentCoordinator {

    let navigationController = UINavigationController()
    var childCoordinators: [Coordinator] = []

    let window = UIWindow(frame: UIScreen.main.bounds)

    init() {
        self.window.makeKeyAndVisible()
    }

    func start() {
        window.rootViewController = navigationController
        startMainFlow()
    }

    private func startMainFlow() {
        let storyboard = UIStoryboard(name: "Dictionary", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "Dictionary")
        
        navigationController.viewControllers = [controller]
    }
    
    public func showDetectObjectScreen() {
        let storyboard = UIStoryboard(name: "ObjectDetectionVC", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ObjectDetectionVC")
        navigationController.pushViewController(controller, animated: true)
    }
    
    public func showWordDetailsScreen(_ word: Word?) {
        
    }
    
    public func showTestingScreen() {
        let storyboard = UIStoryboard(name: "TestWords", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: TestWordViewController.identifier)
        navigationController.pushViewController(controller, animated: true)
    }
    
    public func showSelfAddedWordsScreen() {
        let storyboard = UIStoryboard(name: "SelfAddedWords", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelfAddedWords")
        navigationController.pushViewController(controller, animated: true)
    }
}

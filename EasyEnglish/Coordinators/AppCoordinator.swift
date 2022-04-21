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
        guard let controller = storyboard
            .instantiateViewController(withIdentifier: "Dictionary")
                as? DictionaryViewController else {
            return
        }
        
        controller.appCoordinator = self
        navigationController.viewControllers = [controller]
    }
    
    public func showDetectObjectScreen() {
        let storyboard = UIStoryboard(name: "ObjectDetectionVC", bundle: nil)
        guard let controller = storyboard
                .instantiateViewController(withIdentifier: "ObjectDetectionVC")
                as? ObjectDetectionVC else {
                    return
                }
        controller.logicController = .init(coordinator: self)
        navigationController.present(controller, animated: true)
    }
    
    public func showWordDetailsScreen(_ word: Word?) {
        let storyboard = UIStoryboard(name: "ShowDetail", bundle: nil)
        guard let controller = storyboard
                .instantiateViewController(
                    withIdentifier: WordDetailsVC.identifier
                ) as? WordDetailsVC else {
                return
            }
        controller.context = word
        navigationController.pushViewController(controller, animated: true)
    }
    
    public func showTestingScreen() {
        let storyboard = UIStoryboard(name: "TestWords", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: TestWordViewController.identifier)
        navigationController.pushViewController(controller, animated: true)
    }
    
    public func showSelfAddedWordsScreen() {
        let storyboard = UIStoryboard(name: "SelfAddedWords", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "SelfAddedWords")
        navigationController.present(controller, animated: true)
    }
}

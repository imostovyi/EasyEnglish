//
//  Coordinator.swift
//  EasyEnglish
//
//  Created by Ігор Мостовий on 20.04.2022.
//  Copyright © 2022 Мостовий Ігор. All rights reserved.
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
}

protocol RootCoordinator: Coordinator {
    var navigationController: UINavigationController { get }
}

protocol ParentCoordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
}

extension ParentCoordinator {
    func addChildCoordinator(_ childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }

    func removeChildCoordinator(_ childCoordinator: Coordinator) {
        childCoordinators = childCoordinators.filter { $0 !== childCoordinator }
    }
}

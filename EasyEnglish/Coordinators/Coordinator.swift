//
//  Coordinator.swift
//  EasyEnglish
//
//  Created on 20.04.2022.
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

//
//  CoreDataStack.swift
//  EasyEnglish
//
//  Created on 3/4/19.
//

import CoreData

class CoreDataStack {

    static let shared = CoreDataStack()

    private init() {}

    private(set) lazy var persistantContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "EasyEnglish")
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error {
                debugPrint(error)
                return
            }
            //debugPrint(persistentStoreDescription)
            container.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        })
        return container
    }()
}

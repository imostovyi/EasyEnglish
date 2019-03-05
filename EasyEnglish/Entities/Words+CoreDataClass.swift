//
//  Words+CoreDataClass.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/4/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Words)
public class Words: NSManagedObject {

    class func fetchAll() -> [Words] {
        let context: NSManagedObjectContext = CoreDataStack.shared.persistantContainer.viewContext
        let request: NSFetchRequest = fetchRequest()
        var words: [Words] = []

        do {
            words = try context.fetch(request)
        } catch {
            debugPrint(error)
        }
        return words
    }
}

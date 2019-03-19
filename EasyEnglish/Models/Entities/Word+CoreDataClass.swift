//
//  Word+CoreDataClass.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/10/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Word)
public class Word: NSManagedObject {

    class func fetchAll() -> [Word] {
        let context: NSManagedObjectContext = CoreDataStack.shared.persistantContainer.viewContext
        let request: NSFetchRequest = fetchRequest()
        var words: [Word] = []

        do {
            words = try context.fetch(request)
        } catch {
            debugPrint(error)
        }
        return words
    }
}

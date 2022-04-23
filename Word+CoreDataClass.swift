//
//  Word+CoreDataClass.swift
//  EasyEnglish
//
//  Created by Ігор Мостовий on 23.04.2022.
//  Copyright © 2022 Мостовий Ігор. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Word)
public class Word: AbstractWord {

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

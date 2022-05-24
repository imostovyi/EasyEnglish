//
//  Word+CoreDataClass.swift
//  EasyEnglish
//
//  Created on 23.04.2022.
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

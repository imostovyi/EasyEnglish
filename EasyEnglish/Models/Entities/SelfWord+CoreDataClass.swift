//
//  SelfWord+CoreDataClass.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/10/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//
//

import Foundation
import CoreData

@objc(SelfWord)
public class SelfWord: NSManagedObject {

    class func fetchAll() -> [SelfWord] {
        let context = CoreDataStack.shared.persistantContainer.viewContext
        let request: NSFetchRequest = fetchRequest()
        var words: [SelfWord] = []

        do {
            try words = context.fetch(request)
        } catch {
            debugPrint(error)
        }
        return words
    }
}

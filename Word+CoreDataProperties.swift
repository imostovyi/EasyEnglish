//
//  Word+CoreDataProperties.swift
//  EasyEnglish
//
//  Created by Ігор Мостовий on 23.04.2022.
//  Copyright © 2022 Мостовий Ігор. All rights reserved.
//
//

import Foundation
import CoreData

extension Word {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Word> {
        return NSFetchRequest<Word>(entityName: "Word")
    }

    @NSManaged public var isApproved: Bool
    @NSManaged public var isKnown: Bool
}

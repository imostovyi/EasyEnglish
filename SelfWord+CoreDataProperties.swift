//
//  SelfWord+CoreDataProperties.swift
//  EasyEnglish
//
//  Created on 23.04.2022.
//

import Foundation
import CoreData

extension SelfWord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SelfWord> {
        return NSFetchRequest<SelfWord>(entityName: "SelfWord")
    }
}

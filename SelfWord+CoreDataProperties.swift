//
//  SelfWord+CoreDataProperties.swift
//  EasyEnglish
//
//  Created by Ігор Мостовий on 23.04.2022.
//  Copyright © 2022 Мостовий Ігор. All rights reserved.
//
//

import Foundation
import CoreData

extension SelfWord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SelfWord> {
        return NSFetchRequest<SelfWord>(entityName: "SelfWord")
    }
}

//
//  SelfWord+CoreDataProperties.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/10/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//
//

import Foundation
import CoreData

extension SelfWord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SelfWord> {
        return NSFetchRequest<SelfWord>(entityName: "SelfWord")
    }

    @NSManaged public var pictureURL: String?
    @NSManaged public var transcription: String?
    @NSManaged public var translationRU: String?
    @NSManaged public var translationUA: String?
    @NSManaged public var videoURL: String?
    @NSManaged public var word: String?
    @NSManaged public var wordDescription: String?

}

//
//  Words+CoreDataProperties.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/4/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//
//

import Foundation
import CoreData


extension Words {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Words> {
        return NSFetchRequest<Words>(entityName: "Words")
    }

    @NSManaged public var word: String?
    @NSManaged public var transcription: String?
    @NSManaged public var word_description: String?
    @NSManaged public var translationRu: String?
    @NSManaged public var translationUA: String?
    @NSManaged public var pictureURL: String?
    @NSManaged public var videoURL: String?
    @NSManaged public var isKnown: Bool

}

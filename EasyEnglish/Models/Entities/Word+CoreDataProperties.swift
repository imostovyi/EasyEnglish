//
//  Word+CoreDataProperties.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/30/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
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
    @NSManaged public var pictureURL: URL?
    @NSManaged public var transcription: String?
    @NSManaged public var translationRu: String?
    @NSManaged public var translationUA: String?
    @NSManaged public var videoURL: String?
    @NSManaged public var word: String?
    @NSManaged public var wordDescription: String?

}

//
//  AbstractWord+CoreDataProperties.swift
//  EasyEnglish
//
//  Created by Ігор Мостовий on 23.04.2022.
//  Copyright © 2022 Мостовий Ігор. All rights reserved.
//
//

import Foundation
import CoreData

extension AbstractWord: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AbstractWord> {
        return NSFetchRequest<AbstractWord>(entityName: "AbstractWord")
    }

    @NSManaged public var pictureURL: URL?
    @NSManaged public var transcription: String?
    @NSManaged public var translationUA: String?
    @NSManaged public var videoURL: String?
    @NSManaged public var word: String?
    @NSManaged public var wordDescription: String?

}
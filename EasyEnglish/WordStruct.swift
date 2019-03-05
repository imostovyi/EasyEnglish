//
//  WordStruct.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/5/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

struct WordStruct {

    let word: String?
    let transcription: String?
    let description: String?
    let translationUA: String?
    let translationRU: String?
    let imageURL: String?
    let videoURL: String?

    init(word: String?,
         transcription: String?,
         description: String?,
         translationUA: String?,
         translationRU: String?,
         imageURL: String?,
         videoURL: String?) {
        self.word = word
        self.transcription = transcription
        self.description = description
        self.translationUA = translationUA
        self.translationRU = translationRU
        self.imageURL = imageURL
        self.videoURL = videoURL
    }
}

//
//  WordStruct.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/5/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

struct WordStruct: Codable {

    let word: String?
    let transcription: String?
    let description: String?
    let translationUA: String?
    let translationRU: String?
    let imageURL: String?
    let videoURL: String?

    init(word: Word) {
        self.word = word.word
        self.transcription = word.transcription
        self.description = word.description
        self.translationUA = word.translationUA
        self.translationRU = word.translationRu
        self.imageURL = word.pictureURL
        self.videoURL = word.videoURL
    }
}

struct JsonObject: Codable {
    let words: [WordStruct]

    init(words: [WordStruct]) {
        self.words = words
    }
}

//
//  WordStruct.swift
//  EasyEnglish
//
//  Created on 3/5/19.
//

struct WordStruct: Codable {

    let word: String?
    let transcription: String?
    let description: String?
    let translationUA: String?
    let imageURL: String?
    let videoURL: String?

    init(word: Word) {
        self.word = word.word
        self.transcription = word.transcription ?? ""
        self.description = word.wordDescription ?? ""
        self.translationUA = word.translationUA ?? ""
        self.imageURL = word.pictureURL?.absoluteString ?? ""
        self.videoURL = word.videoURL ?? ""
    }
}

struct WordStructJsonWrapper: Codable {
    let id: Int
    let attributes: WordStruct
}

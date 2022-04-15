//
//  Api.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/31/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//
import Moya

enum Services {
    case validateWord(word: WordStruct)
    case updatebase
}

extension Services: TargetType {
    var baseURL: URL {
        return URL(string: "https://6882-2001-7d0-8417-9a80-f1d2-313d-29ac-cd9f.eu.ngrok.io/api/")!
    }

    var path: String {
        switch self {
        case .validateWord(word: _):
            return "/posts/add"
        case .updatebase:
            return "words"
        }
    }

    var method: Method {
        switch self {
        case .updatebase:
            return .get
        case .validateWord(word: _):
            return .post
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .updatebase:
            return .requestPlain
        case .validateWord(let word):
            return .requestJSONEncodable(word)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }

}

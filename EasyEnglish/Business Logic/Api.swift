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
        return URL(string: "https://api.front-end.icu/api")!
    }

    var path: String {
        switch self {
        case .validateWord(word: _):
            return "/posts/add"
        case .updatebase:
            return "/posts"
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


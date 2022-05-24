//
//  Api.swift
//  EasyEnglish
//
//  Created on 3/31/19.
//
import Moya

enum Services {
    case validateWord(word: [String: WordStruct])
    case updatebase
}

extension Services: TargetType {
    var baseURL: URL {
        return URL(string: "https://83e3-2001-7d0-8417-9a80-d569-8878-b258-caa1.eu.ngrok.io/api/")!
    }

    var path: String {
        switch self {
        case .validateWord:
            return "words"
        case .updatebase:
            return "words"
        }
    }

    var method: Method {
        switch self {
        case .updatebase:
            return .get
        case .validateWord:
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

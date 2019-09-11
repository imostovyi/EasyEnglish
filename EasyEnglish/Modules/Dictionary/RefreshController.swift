//
//  RefreshController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 4/1/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import Moya
import Foundation
import CoreData
import UIKit

class PullToRefresh {

    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        let controller = NSFetchedResultsController<Word>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)

        do {
            try controller.performFetch()
        } catch {
            debugPrint(error)
        }
        return controller
    }()
    private lazy var provider = MoyaProvider<Services>()

    static let shared = PullToRefresh()

    lazy var refreshController: UIRefreshControl = {
       let refreshController = UIRefreshControl()
        refreshController.addTarget(self, action: #selector(refresh), for: .valueChanged)

        return refreshController
    }()

    @objc private func refresh() {
        provider.request(.updatebase) { (result) in
            switch result {
            case let .success(moyaResponse):
                let data = moyaResponse.data
                do {
                    let wordsArray = try JSONDecoder().decode([WordStruct].self, from: data)
                    DispatchQueue.main.async {
                        for word in wordsArray {
                            self.saveChanges(word: word)
                        }
                    }
                } catch {
                    debugPrint(error)
                }
            case let .failure(error):
                debugPrint(error)
            }
        }

        refreshController.endRefreshing()
    }

    private func saveChanges(word: WordStruct) {
        var originalWord: Word?
        if containce(checkWord: word, originalWord: &originalWord) {
            guard let originalWord = originalWord else { return }
            originalWord.word =
                checkField(checkedField: word.word, originalField: originalWord.word)
            originalWord.transcription =
                checkField(checkedField: word.transcription, originalField: originalWord.transcription)
            originalWord.wordDescription =
                checkField(checkedField: word.description, originalField: originalWord.wordDescription)
            originalWord.translationUA =
                checkField(checkedField: word.translationUA, originalField: originalWord.translationUA)
            originalWord.translationRu =
                checkField(checkedField: word.translationRU, originalField: originalWord.translationRu)
            originalWord.pictureURL =
                URL(string: checkField(
                    checkedField: word.imageURL,
                    originalField: originalWord.pictureURL?.absoluteString) ?? "")
            originalWord.videoURL =
                checkField(checkedField: word.videoURL, originalField: originalWord.videoURL)
            originalWord.isKnown = false
            originalWord.isApproved = true

            do {
                try context.save()
            } catch {
                debugPrint(error)
            }

        } else {
            let object = Word(context: context)
            object.word = word.word
            object.transcription = word.transcription
            object.wordDescription = word.description
            object.translationUA = word.translationUA
            object.translationRu = word.translationRU
            object.pictureURL = URL(string: word.imageURL ?? "")
            object.videoURL = word.videoURL
            object.isKnown = false
            object.isApproved = true

            do {
                try context.save()
            } catch {
                debugPrint(error)
            }
        }
    }

    private func containce(checkWord: WordStruct, originalWord: inout Word?) -> Bool {
//        guard let wordsArray = fetchedResultsController.fetchedObjects else {
//            return false
//        }
        let wordsArray = Word.fetchAll()

        for word in wordsArray where word.word == checkWord.word {
            originalWord = word
            return true
        }

        return false
    }

    private func checkField(checkedField: String?, originalField: String?) -> String? {
        if checkedField == originalField {
            return originalField
        }
        return checkedField
    }
}

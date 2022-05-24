//
//  SelfAddedWordsLC.swift
//  EasyEnglish
//
//  Created on 22.04.2022.
//

import Foundation
import Moya
import CoreData

final class SelfAddedWordsLC: NSObject {
    
    var updatedProps: ((SelfAddedWordsVC.Props) -> Void)? {
        didSet {
            start()
        }
    }
    
    // MARK: - Private
    private let provider = MoyaProvider<Services>()
    private var words: [Word] = []
    
    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isApproved = 0")
        let controller = NSFetchedResultsController<Word>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        try? controller.performFetch()

        return controller
    }()
    
    // MARK: - Logic
    
    private func start() {
        words = fetchedResultsController.fetchedObjects ?? []
        updateProps()
    }
    
    private func updateProps() {
        updatedProps?(
            .init(words: wordModels(),
                  deleteWord: { [weak self] in self?.deleteWord($0) },
                  editWord: { [weak self] in self?.editWord($0) },
                  sendToServer: { [weak self] in self?.sendWordsToServer() }
                 )
        )
    }
    
    private func wordModels() -> [SelfAddedWordsVC.Props.WordModel] {
        words.map {
            .init(
                title: $0.word ?? "",
                description: $0.wordDescription ?? "",
                imageURL: $0.pictureURL
            )
        }
    }
    
    private func deleteWord(_ index: Int) {
        context.delete(words[index])
        try? context.save()
    }
    
    private func editWord(_ index: Int) -> Word? {
        words[index]
    }
    
    private func sendWordsToServer() {
        let encodedWords = words.map(WordStruct.init(word:))
        
        DispatchQueue.global(qos: .userInteractive).async { [weak provider] in
            encodedWords.forEach {
                provider?.request(.validateWord(word: ["data": $0])) { (result) in
                    if case let .failure(error) = result {
                        debugPrint(error)
                    }
                }
            }
        }
        words.forEach { $0.isApproved = true }
        try? context.save()
    }
}

// MARK: -- NSFetchedResultsControllerDelegate

extension SelfAddedWordsLC: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        words = fetchedResultsController.fetchedObjects ?? []
        updateProps()
    }
}

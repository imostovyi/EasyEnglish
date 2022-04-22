//
//  AddEditWordLC.swift
//  EasyEnglish
//
//  Created by Ігор Мостовий on 22.04.2022.
//  Copyright © 2022 Мостовий Ігор. All rights reserved.
//

import Foundation
import CoreData

final class AddEditWordLC: NSObject {
    
    // MARK: - Internal
    
    var updatedProps: ((AddEditWordVC.Props) -> Void)? {
        didSet {
            generateProps()
        }
    }
    
    // MARK: - Private
    
    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isApproved = 1")
        let controller = NSFetchedResultsController<Word>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        controller.delegate = self
        try? controller.performFetch()

        return controller
    }()
    
    private var wordIsValid = false
    private var descriptionIsValid = false
    private var wordIsAlreadyInDictionary = false
    private var isDoneButtonShouldBeShown: Bool {
        wordIsValid
        && descriptionIsValid
        && !wordIsAlreadyInDictionary
    }
    
    private func generateProps() {
        updatedProps?(
            .init(
                wordIsAlreadyInDictionary: wordIsAlreadyInDictionary,
                wordIsValid: wordIsValid,
                doneButtonShouldBeShown: isDoneButtonShouldBeShown,
                descriptionIsValid: descriptionIsValid,
                checkWord: { [weak self] in self?.validate($0) },
                saveWord: { [weak self] in self?.saveWord() }
            )
        )
    }
    
    private func checkIfWordPresentInDB(_ word: String?) -> Bool {
        guard let word = word,
              let dictionary = fetchedResultsController.fetchedObjects else {
            return false
        }

        return dictionary
            .map(\.word)
            .map { $0?.lowercased() }
            .contains(word.lowercased())
    }
    
    private func validate(_ word: Word) {
        wordIsValid = validate(word.word)
        descriptionIsValid = validate(word.wordDescription)
        wordIsAlreadyInDictionary = checkIfWordPresentInDB(word.word)
        generateProps()
    }
    
    private func saveWord() {
        try? context.save()
    }
    
    private func validate(_ string: String?) -> Bool {
        guard let string = string else {
            return false
        }

        let regex: NSRegularExpression
        do {
            try regex = NSRegularExpression(pattern: "[a-z]+", options: .caseInsensitive)
            let range = NSRange(location: 0, length: string.utf16.count)
            if regex.firstMatch(in: string, options: [], range: range) == nil {
                return false
            }
        } catch {
            debugPrint(error)
            return false
        }
        return true
    }
}

// MARK: -- NSFetchedResultsControllerDelegate
extension AddEditWordLC: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        generateProps()
    }
}

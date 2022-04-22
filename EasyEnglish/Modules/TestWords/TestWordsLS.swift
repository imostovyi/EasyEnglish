//
//  TestWordsLS.swift
//  EasyEnglish
//
//  Created by Ігор Мостовий on 22.04.2022.
//  Copyright © 2022 Мостовий Ігор. All rights reserved.
//

import CoreData
import Foundation

typealias Props = TestWordsVC.Props

final class TestWordsLS: NSObject {
    
    var updatedProps: ((Props) -> Void)? {
        didSet {
            start()
        }
    }
    
    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]

        let controller = NSFetchedResultsController<Word>(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        return controller
    }()

    private var wordsForTesting: Set<Word> = []
    private var shouldDisplayDoneButton: Bool {
        !wordsForTesting.isEmpty
    }
    private var wordModels: [(Props.WordModel, Word)] = []
    
    private func start() {
        try? fetchedResultsController.performFetch()
        wordModels = wordModels(for: fetchedResultsController.fetchedObjects ?? [])
        generateProps()
    }
    
    private func generateProps() {
        updatedProps?(
            .init(words: wordModels.map(\.0),
                  shouldDisplayDoneButton: shouldDisplayDoneButton,
                  doneButtonTouched: { [weak self] in
                      Array(self?.wordsForTesting ?? [])
                  },
                  didSelectWord: { [weak self] in self?.didSelectWord($0) })
        )
    }
    
    private func wordModels(for words: [Word]) -> [(Props.WordModel, Word)] {
        words.map {
            (
                .init(text: $0.wordDescription ?? "",
                      imageURL: $0.pictureURL,
                      isSelected: wordsForTesting.contains($0)
                     ),
                $0
            )
        }
    }
    
    private func doneButtonTouched() -> [Word] {
        Array(wordsForTesting)
    }
    
    private func didSelectWord(_ index: Int) {
        let word = wordModels[index].1
        
        if wordsForTesting.contains(word) {
            wordsForTesting.remove(word)
        } else {
            wordsForTesting.insert(word)
        }
        wordModels = wordModels(for: fetchedResultsController.fetchedObjects ?? [])
        generateProps()
    }
}

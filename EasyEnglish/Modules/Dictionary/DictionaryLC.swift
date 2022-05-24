//
//  DictionaryLC.swift
//  EasyEnglish
//
//  Created on 19.04.2022.
//

import UIKit
import CoreData

final class DictionaryLC: NSObject {
    
    var updatedProps: ((DictionaryViewController.Props) -> Void)? {
        didSet {
            start()
        }
    }
    
    private var words: [Word] = []
    private var filteredWords: [Word] = []
    private var searchQuery = ""
    
    private var isSearchMode: Bool {
        searchQuery.count >= 2
    }
    
    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedResultsController = makeWordsFetchResultsController()
    
    private func start() {
        try? fetchedResultsController.performFetch()
        words = fetchedResultsController.fetchedObjects ?? []
        updateProps()
    }
    
    private func updateProps() {
        let props = DictionaryViewController.Props(
            words: wordsModels(),
            updateSearchPattern: { [weak self] in self?.updateSearchQuery($0) },
            deleteWord: { [weak self] in self?.deleteWord(on: $0) },
            wordForIndex: { [weak self] in self?.ford(for: $0) }
        )
        updatedProps?(props)
    }
    
    private func wordsModels() -> [DictionaryViewController.Props.WordModel] {
        (isSearchMode ? filteredWords : words)
            .map(wordModel(for:))
    }
    
    private func wordModel(for word: Word) -> DictionaryViewController.Props.WordModel {
        let wordTitle = isSearchMode
        ? highlight(searchQuery, in: word.word ?? "")
        : NSAttributedString(string: word.word ?? "")
        
        return .init(
            word: wordTitle,
            descriptionText: word.wordDescription ?? "",
            imageURL: word.pictureURL
        )
    }
    
    private func updateSearchQuery(_ query: String) {
        defer {
            updateProps()
        }
        
        searchQuery = query.lowercased()
        if !isSearchMode { return }
        filteredWords = words.filter{
            $0.word?.lowercased().contains(searchQuery) ?? false
        }
    }
    
    private func deleteWord(on row: Int) {
        let word = (isSearchMode ? filteredWords : words)[row]
        context.delete(word)
        do {
            try self.context.save()
        } catch {
            debugPrint(error)
        }
        words = fetchedResultsController.fetchedObjects ?? []
        updateProps()
    }
    
    private func ford(for index: Int) -> Word {
        (isSearchMode ? filteredWords : words)[index]
    }
}

extension DictionaryLC {
    private func makeWordsFetchResultsController() -> NSFetchedResultsController<Word> {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isApproved = YES")
        let controller = NSFetchedResultsController<Word>(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        controller.delegate = self
        return controller
    }
    
    private func highlight(_ substring: String, in string: String, color: UIColor = UIColor.blue) -> NSAttributedString {
        let defaultAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0),
                                 NSAttributedString.Key.foregroundColor: UIColor.white]

        let text = NSMutableAttributedString(string: string, attributes: defaultAttributes)

        if let fillableRange = string.lowercased().range(of: (substring.lowercased())) {
            let substring = NSRange(fillableRange, in: string)
            text.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 22.0), range: substring)
            text.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.red, range: substring)
            text.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: substring)
        }
        return text
    }
}

// MARK: - FetchResultsControllerDelegate

extension DictionaryLC: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        words = fetchedResultsController.fetchedObjects ?? []
        updateProps()
    }
}

//
//  ComposeWordLC.swift
//  EasyEnglish
//
//  Created on 23.04.2022.
//

import Foundation

final class ComposeWordLC {
    
    typealias Props = ComposeWordViewController.Props
    
    init(words: [Word]) {
        self.words = words
    }
    
    // MARK: - Internal
    
    var updatedProps: ((Props) -> Void)? {
        didSet {
            start()
        }
    }
    
    // MARK: - Private
    
    private var words: [Word] = []
    private var observedIndex: Int = 0
    private var lettersData: [String] = []
    private var answerData: [String] = []
    
    private var checkStatus: Props.CheckStatus = .inProgress
    private var alertConfiguration: Props.AlertConfiguration?
    
    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    
    func start() {
        words.forEach { $0.isKnown = false }
        try? context.save()
        fillLettersArray()
    }
    
    func generateProps() {
        let buttonsEnability = checkButtonEnability()
        updatedProps?(
            .init(
                nextButtonIsEnabled: buttonsEnability.forwardIsEnabled,
                previousButtonIsEnabled: buttonsEnability.backIsEnabled,
                checkStatus: checkStatus,
                alertConfiguration: alertConfiguration,
                wordDescription: words[observedIndex].wordDescription ?? "",
                lettersDataSource: lettersData,
                answerDataSource: answerData,
                nextButtonTouched: { [weak self] in self?.nextButtonTouched() },
                previousButtonTouched: { [weak self] in self?.previousButtonTouched() },
                checkButtonTouched: { [weak self] in self?.checkButtonTouched() },
                didSelectLetter: { [weak self] in self?.didSelectLetter(in: $0, at: $1) },
                reorderLetter: { [weak self] in
                    self?.reorderLetter(in: $0, sourceIndex: $1, destinationIndex: $2)
                }
            )
        )
        alertConfiguration = nil
        checkStatus = .inProgress
    }
    
    private func checkButtonEnability() -> (forwardIsEnabled: Bool, backIsEnabled: Bool) {
        if words.count == 1 {
            return (false, false)
        }
        if observedIndex == 0 {
            return (true, false)
        }
        if observedIndex == (words.count - 1) {
            return (false, true)
        }
        return (true, true)
    }
    
    private func nextButtonTouched() {
        if observedIndex + 1 == words.count {
            return
        }
        observedIndex += 1
        fillLettersArray()
    }
    
    private func previousButtonTouched() {
        if observedIndex == 0 {
            return
        }
        observedIndex -= 1
        fillLettersArray()
    }
    
    private func fillLettersArray() {
        guard let word = words[observedIndex].word else {
            return
        }
        
        lettersData = word.map {
            String($0)
        }.shuffled()
        answerData = []
        
        generateProps()
    }
    
    private func checkButtonTouched() {
        defer {
            generateProps()
        }
        
        guard words[observedIndex].word == answerData.joined() else {
            checkStatus = .failed
            return
        }
        checkStatus = .success
        try? context.save()
        alertConfiguration = words.count - 1 == 0
        ? .allWordsCombined
        : .oneWordCombined(handler: { [weak self] in
            guard let self = self else {
                return
            }
            self.words.remove(at: self.observedIndex)
            self.fillLettersArray()
            self.generateProps()
        })
    }
    
    private func didSelectLetter(in collection: Props.Collection, at index: Int) {
        switch collection {
        case .source:
            didSelectLetterInSourceLetters(index)
        case .answer:
            didSelectLetterInAnswerLetters(index)
        }
        generateProps()
    }
    
    private func reorderLetter(
        in collection: Props.Collection,
        sourceIndex: Int,
        destinationIndex: Int) {
            switch collection {
            case .answer:
                let letter = answerData.remove(at: sourceIndex)
                answerData.insert(letter, at: destinationIndex)
            case .source:
                let letter = lettersData.remove(at: sourceIndex)
                lettersData.insert(letter, at: destinationIndex)
            }
            generateProps()
        }
}

extension ComposeWordLC {
    private func didSelectLetterInSourceLetters(_ index: Int) {
        swapLatter(
            in: &lettersData,
            at: index,
            destinationArray: &answerData,
            at: answerData.count
        )
    }
    
    private func didSelectLetterInAnswerLetters(_ index: Int) {
        swapLatter(
            in: &answerData,
            at: index,
            destinationArray: &lettersData,
            at: lettersData.count
        )
    }
    
    private func swapLatter(in sourceArray: inout [String],
                            at index: Int,
                            destinationArray: inout [String],
                            at destinationIndex: Int) {
        let letter = sourceArray.remove(at: index)
        destinationArray.insert(letter, at: destinationIndex)
    }
}

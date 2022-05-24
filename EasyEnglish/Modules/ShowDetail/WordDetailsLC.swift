//
//  WordDetailsLC.swift
//  EasyEnglish
//
//  Created on 20.04.2022.
//

import AVFoundation

final class WordDetailsLC: NSObject {
    
    // MARK: Public
    var updatedProps: ((WordDetailsVC.Props) -> Void)? {
        didSet {
            generateProps()
        }
    }
    
    // MARK: Private properties
    private var playButtonIsEnabled = true

    private lazy var speechSynthesizer: AVSpeechSynthesizer = {
        let speechSynthesizer = AVSpeechSynthesizer()
        speechSynthesizer.delegate = self
        return speechSynthesizer
    }()
    
    private func generateProps() {
        updatedProps?(
            .init(
                speechButtonIsEnabled: playButtonIsEnabled,
                pronounceWord: { [weak self] in self?.pronounce($0)}
            )
        )
    }
    
    private func pronounce(_ word: String) {
        let utterance = AVSpeechUtterance(string: word)
        if speechSynthesizer.isSpeaking {
            speechSynthesizer.stopSpeaking(at: .immediate)
        }
        speechSynthesizer.speak(utterance)
    }
}

// MARK: - Extension AVSpeechSynthesizerDelegate

extension WordDetailsLC: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        playButtonIsEnabled = false
        generateProps()
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playButtonIsEnabled = true
        generateProps()
    }
}

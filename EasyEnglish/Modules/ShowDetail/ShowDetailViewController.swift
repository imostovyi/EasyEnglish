//
//  ShowDetailViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/20/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import AVFoundation
import youtube_ios_player_helper

class ShowDetailViewController: UIViewController {

    // MARK: public properties

    static let identifier = "ShowDetailView"
    var context: Word?

    // MARK: Private properties

    private lazy var speechSentesizer = AVSpeechSynthesizer()
    private var speech: AVSpeechUtterance = AVSpeechUtterance()
    // MARK: Outlets

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var transcriptionLabel: UILabel!

    @IBOutlet weak var playButton: UIButton!

    @IBOutlet weak var videoView: YTPlayerView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var translationUA: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()
        checkAndFill()

        videoView.delegate = self
        videoView.isHidden = true
        speechSentesizer.delegate = self

        playButton.addTarget(self, action: #selector(playButtonWasTapped), for: .touchUpInside)
        playButton.layer.cornerRadius = 20
        playButton.layer.masksToBounds = true

    }

    // MARK: Go back function

    @objc private func goBack() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Seting up navigation bar

    private func setUpNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Go back", style: .done, target: self, action: #selector(goBack))
        navigationBar.items?.append(navigationItem)
    }

    // MARK: Checking passed object and filing context

    private func checkAndFill() {
        guard let word = context else {
            goBack()
            return
        }

        speech = AVSpeechUtterance(string: word.word!)

        title = word.word
        wordLabel.text = word.word
        transcriptionLabel.text = word.transcription
        descriptionTextView.text = word.wordDescription
        translationUA.text = word.translationUA

        let image = UIImage(named: "flag")
        let imageURL = word.pictureURL
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: imageURL,
                              placeholder: image,
                              options: nil,
                              progressBlock: nil)
        
        _ = word.videoURL.map(videoView.load(withVideoId:))
    }

    /// func that play speach
    @objc private func playButtonWasTapped() {
        if speechSentesizer.isSpeaking {
            speechSentesizer.stopSpeaking(at: .immediate)
        }
        speechSentesizer.speak(speech)
    }
}

extension ShowDetailViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.isHidden = false
    }
}

extension ShowDetailViewController: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        playButton.isEnabled = false
    }

    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        playButton.isEnabled = true
    }
}

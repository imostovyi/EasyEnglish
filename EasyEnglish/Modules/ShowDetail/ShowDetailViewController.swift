//
//  ShowDetailViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/20/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import WebKit
import AVFoundation
import youtube_ios_player_helper

class ShowDetailViewController: UIViewController {

    // MARK: public properties

    //nead for text to xpeech converting
    static let identifier = "ShowDetailView"
    var context: Word?

    // MARK: Private properties

    private let speechSentesizer = AVSpeechSynthesizer()
    private var speech: AVSpeechUtterance = AVSpeechUtterance()
    // MARK: Outlets

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var transcriptionLabel: UILabel!

    @IBOutlet weak var playButton: UIButton!

    @IBOutlet weak var videoView: YTPlayerView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var translationRU: UILabel!
    @IBOutlet weak var translationUA: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()
        checkAndFill()

        videoView.delegate = self

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

        title = word.word
        speech = AVSpeechUtterance(string: word.word!)

        wordLabel.text = word.word
        transcriptionLabel.text = word.transcription
        descriptionTextView.text = word.wordDescription
        translationUA.text = word.translationUA
        translationRU.text = word.translationRu

        let image = UIImage(named: "flag")
        if word.pictureURL == nil {
            imageView.image = image
        } else {
            let imageURL = URL(string: word.pictureURL!)
            imageView.kf.indicatorType = .activity
            imageView.kf.setImage(with: imageURL,
                                  placeholder: image,
                                  options: nil,
                                  progressBlock: nil) { (result) in
                                    if result.error != nil {
                                        //debugPrint(result.error?.localizedDescription)
                                        self.imageView.image = image
                                    }
            }
        }

        setUpPlayer(word: word)
    }

    /// func that play spech
    @objc private func playButtonWasTapped() {
        speechSentesizer.speak(speech)
    }

    ///Function that vreating and adding player to videoView

    private func setUpPlayer(word: Word) {
        guard let unwrapedStringURL = word.videoURL else {
            videoView.isHidden = true
            return
        }
        guard let videoURL = URL(string: unwrapedStringURL) else {
            videoView.isHidden = true
            return
        }

        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: videoURL) { (_, _, error) in
            if error == nil { return }

            DispatchQueue.main.async {
                self.videoView.isHidden = true
            }
        }
        task.resume()

//        videoView.frame = CGRect(x: videoView.frame.minX,
//                                 y: videoView.frame.minY,
//                                 width: wordLabel.frame.width,
//                                 height: wordLabel.frame.width * 9 / 16)
        videoView.backgroundColor = UIColor.clear
        //videoView.load(withVideoId: "dz5IIzIeBa0")
        videoView.loadVideo(byURL: "https://www.youtube.com/watch?v=dw7kytoA3KU?version=3", startSeconds: 0.0, suggestedQuality: .auto)
    }
}

extension ShowDetailViewController: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {

        print("OK")
    }
}


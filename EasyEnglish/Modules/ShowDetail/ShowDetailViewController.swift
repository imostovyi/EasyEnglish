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

    @IBOutlet weak var videoWebView: WKWebView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var translationRU: UILabel!
    @IBOutlet weak var translationUA: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()
        checkAndFill()

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

        guard let unwrapedStringURL = word.videoURL else {
            videoWebView.isHidden = true
            return
        }
        guard let videoURL = URL(string: unwrapedStringURL) else {
            videoWebView.isHidden = true
            return
        }

        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: videoURL) { (_, _, error) in
            if error == nil { return }

            DispatchQueue.main.async {
                self.videoWebView.isHidden = true
            }
        }
        task.resume()

        videoWebView.load(URLRequest(url: videoURL))
    }

    // MARK: func that play spech

    @objc private func playButtonWasTapped() {
        speechSentesizer.speak(speech)
    }

}


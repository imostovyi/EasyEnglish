//
//  WordDetailsVC.swift
//  EasyEnglish
//
//  Created on 3/20/19.
//

import UIKit
import youtube_ios_player_helper

class WordDetailsVC: UIViewController {

    // MARK: public properties

    static let identifier = "ShowDetailView"
    var context: Word?

    // MARK: Outlets

    @IBOutlet private weak var navigationBar: UINavigationBar!
    @IBOutlet private weak var wordLabel: UILabel!
    @IBOutlet private weak var transcriptionLabel: UILabel!

    @IBOutlet private weak var playButton: UIButton!

    @IBOutlet private weak var videoView: YTPlayerView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var translationUA: UILabel!
    @IBOutlet private weak var descriptionTextView: UITextView!
    
    private var props: Props?
    private let logicController = WordDetailsLC()

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavBar()
        checkAndFillLabels()

        videoView.delegate = self
        videoView.isHidden = true

        playButton.addTarget(self, action: #selector(playButtonTouched), for: .touchUpInside)
        playButton.layer.cornerRadius = 20
        playButton.layer.masksToBounds = true

        logicController.updatedProps = { [weak self] in
            self?.render($0)
        }
    }
    
    private func render(_ props: Props) {
        self.props = props
        playButton.isEnabled = props.speechButtonIsEnabled
    }
    
    @objc private func goBack() {
        dismiss(animated: true, completion: nil)
    }

    private func setUpNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Go back", style: .done, target: self, action: #selector(goBack))
        navigationBar.items?.append(navigationItem)
    }

    private func checkAndFillLabels() {
        guard let word = context else {
            goBack()
            return
        }

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

    @objc private func playButtonTouched() {
        guard let word = context?.word else {
            return
        }
        props?.pronounceWord(word)
    }
}

extension WordDetailsVC: YTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.isHidden = false
    }
}

extension WordDetailsVC {
    struct Props {
        let speechButtonIsEnabled: Bool
        
        let pronounceWord: (String) -> Void
    }
}

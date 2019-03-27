//
//  ComposeWordViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/26/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit

class ComposeWordViewController: UIViewController {

    // MARK: public properties

    public static let identifier = "ComposeWord"

    // MARK: outlets

    @IBOutlet private var navigationBar: UINavigationBar!
    @IBOutlet private var descriptionTextView: UITextView!
    @IBOutlet private var answerCollectionView: UICollectionView!
    @IBOutlet private var lettersCollectionView: UICollectionView!
    @IBOutlet private var backButton: UIButton!
    @IBOutlet private var checkButton: UIButton!
    @IBOutlet private var forwardButton: UIButton!
    @IBOutlet private var statusImageView: UIImageView!
    @IBOutlet var visualEffectView: UIVisualEffectView!
    // MARK: private properties

    private var wordsArray: [Word] = []
    private var observedIndex = 0
    private var lettersData: [String] = []
    private var answerData: [String] = []

    private lazy var checkedImage = UIImage(named: "checked")
    private lazy var canceledImage = UIImage(named: "cnacel")

    // MARK: Public functions

    public func fillWordsArray(words: [Word]) {
        wordsArray = words
    }

    // MARK: Private properties

    override func viewDidLoad() {
        super.viewDidLoad()

        observedIndex = 0

        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.white.cgColor

        configurateLayer(button: backButton)
        configurateLayer(button: checkButton)
        configurateLayer(button: forwardButton)

        backButton.addTarget(self, action: #selector(arrowButtonWasTapped(button:)), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(arrowButtonWasTapped(button:)), for: .touchUpInside)

        fillLettersAndDescription()
        configuratinCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIndex()
    }

    ///Filing letters array and description
    private func fillLettersAndDescription() {
        guard let word = wordsArray[observedIndex].word else { return }

        descriptionTextView.text = wordsArray[observedIndex].wordDescription

        lettersData = []
        let array = Array(word)
        for i in array {
            let charToString = String(i)
            lettersData.append(charToString)
        }

        lettersData = lettersData.shuffled()

        answerData = []

        statusImageView.image = canceledImage
    }

    ///Configurating layers for buttons
    private func configurateLayer(button: UIButton) {
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
    }

    ///FadeIn/FadeOut function with switching to the next word
    @objc private func arrowButtonWasTapped(button: UIButton) {
        let isForward = button == forwardButton ? true : false
        if isForward {self.observedIndex += 1} else {self.observedIndex -= 1}

        UIView.animate(withDuration: 1.5, delay: 0.5, options: .allowUserInteraction,
                       animations: {
                        self.visualEffectView.alpha = 0.3
        }, completion: nil)

        fillLettersAndDescription()
        checkIndex()

        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction,
                       animations: {
                        self.visualEffectView.alpha = 1.0
        }, completion: nil)
    }

    ///Chech if it's necessary to hide left or right button
    private func checkIndex() {

        defer {
            print(backButton.isEnabled)
            print(forwardButton.isEnabled)
        }

        if wordsArray.count == 1 {
            backButton.isEnabled = true
            forwardButton.isEnabled = true
            return
        }

        if observedIndex == 0 {
            backButton.isEnabled = false
            forwardButton.isEnabled = true
            return
        }

        if observedIndex == (wordsArray.count - 1) {
            forwardButton.isEnabled = false
            backButton.isEnabled = true
            return
        }

        forwardButton.isEnabled = true
        backButton.isEnabled = true
        return

    }

    ///Configurating collection view
    private func configuratinCollectionView() {
        lettersCollectionView.delegate = self
        lettersCollectionView.dragInteractionEnabled = true
        //lettersCollectionView.dragDelegate = self
        //lettersCollectionView.dropDelegate = self
        lettersCollectionView.dataSource = self

        lettersCollectionView.layer.borderWidth = 1
        lettersCollectionView.layer.cornerRadius = 8
        lettersCollectionView.layer.masksToBounds = true
        lettersCollectionView.layer.borderColor = UIColor.white.cgColor

        answerCollectionView.delegate = self
        answerCollectionView.dataSource = self
        answerCollectionView.dragInteractionEnabled = true
        //answerCollectionView.dragDelegate = self
        //answerCollectionView.dropDelegate = self

        answerCollectionView.layer.borderWidth = 1
        answerCollectionView.layer.cornerRadius = 8
        answerCollectionView.layer.masksToBounds = true
        answerCollectionView.layer.borderColor = UIColor.white.cgColor
    }
}

// MARK: - - Extension Collection view dataSource and Delegate

extension ComposeWordViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == lettersCollectionView {
            return lettersData.count
        }
        return answerData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == lettersCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LetterCell", for: indexPath) as! CollectionViewCell
            cell.initLabel(letter: lettersData[indexPath.row])
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AnswerLetterCell", for: indexPath) as! CollectionViewCell
        cell.initLabel(letter: answerData[indexPath.row])
        return cell
    }
}


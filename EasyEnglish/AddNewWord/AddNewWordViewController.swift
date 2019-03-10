//
//  AddNewWordViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/5/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import TextFieldEffects

class AddNewWordViewController: UIViewController {

    // MARK: IBoutlets

    @IBOutlet var wordInformation: [IsaoTextField]!
    @IBOutlet weak var descriptionTextView: UITextView!

    // MARK: Properties

    var savedWord: ((WordStruct) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTextView()
        setUpTextFields()
        setUpNavigationBar()

        title = "Add new word"
        view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(endEditing)))
    }

    // MARK: Fuction that implements closing keyboard

    @objc private func endEditing() {
        view.endEditing(true)
    }

    // MARK: Setting up textFields

    private func setUpTextFields() {
        for field in wordInformation {
            field.layer.cornerRadius = 7
            field.layer.borderWidth = 2
            field.layer.borderColor = UIColor.white.cgColor
            field.layer.masksToBounds = true
        }
    }

    // MARK: Setting up description text view

    private func setUpTextView() {
        descriptionTextView.layer.cornerRadius = 7
        descriptionTextView.layer.borderWidth = 2
        descriptionTextView.layer.borderColor = UIColor.white.cgColor
        descriptionTextView.layer.masksToBounds = true
        descriptionTextView.textColor = UIColor.blue
        descriptionTextView.text = "Word description"
    }

    // MARK: Adding navigation bar

    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveWord))
    }

    // MARK: Saving information About word

    @objc private func saveWord() {
        let word = WordStruct(word: wordInformation[0].text,
                              transcription: wordInformation[1].text,
                              description: descriptionTextView.text,
                              translationUA: wordInformation[2].text,
                              translationRU: wordInformation[3].text,
                              imageURL: wordInformation[4].text,
                              videoURL: wordInformation[5].text)

        savedWord?(word)
        let storyboard = UIStoryboard(name: "Dictionary", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Dictionary") as! DictionaryViewController
        navigationController?.present(vc, animated: true, completion: nil)
    }
}


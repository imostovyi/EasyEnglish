//
//  AddNewWordViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/5/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import TextFieldEffects
import CoreData

class AddNewWordViewController: UIViewController {

    // MARK: IBoutlets
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var wordInformation: [IsaoTextField]!
    @IBOutlet weak var descriptionTextView: UITextView!

    // MARK: public properties

    static public var passedObject: SelfWord?
    static public let reuseIdentifier = "AddNewWord"
    // MARK: Private poperties

    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedWords = SelfWord.fetchAll()
    private lazy var object = SelfWord(context: context)

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTextView()
        setUpTextFields()
        setUpNavigationBar()

        title = "Add new word"
        view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(endEditing)))

        //check if passedObject is nil it means that controller is not using as edit controller
        guard let tempObject = AddNewWordViewController.passedObject else { return }
        object = tempObject
        fillFields(object: object)
    }

    // MARK: Fuction that implements closing keyboard

    @objc private func endEditing() {
        view.endEditing(true)
    }

    // MARK: Setting up textFields

    private func setUpTextFields() {
        for field in wordInformation {
            field.layer.cornerRadius = 7
//            field.layer.borderWidth = 2
//            field.layer.borderColor = UIColor.white.cgColor
            field.layer.masksToBounds = true
        }
    }

    // MARK: Setting up description text view

    private func setUpTextView() {
//        descriptionTextView.layer.cornerRadius = 7
//        descriptionTextView.layer.borderWidth = 2
//        descriptionTextView.layer.borderColor = UIColor.white.cgColor
//        descriptionTextView.layer.masksToBounds = true
//        descriptionTextView.textColor = UIColor.blue
        descriptionTextView.text = "Word description"
        descriptionTextView.delegate = self
    }

    // MARK: Adding navigation bar

    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveWord))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(goBack))
        navigationBar.items?.append(navigationItem)
        title = "Add new word"
    }

    // MARK: Saving information About word

    @objc private func saveWord() {
        var errorAlertIsNeccesary = false

        //check if word textfield or description is nil or have wrong first character
        if wordInformation[0].text == nil || descriptionTextView.text == nil {
            errorAlertIsNeccesary = true
        } else {
            let regex: NSRegularExpression
            do {
                //check if word is nil
                try regex = NSRegularExpression(pattern: "[a-z]+", options: .caseInsensitive)
                var range = NSRange(location: 0, length: wordInformation[0].text!.utf16.count)
                if regex.firstMatch(in: wordInformation[0].text!, options: [], range: range) == nil {
                    errorAlertIsNeccesary = true
                }
                //check if description is correctly filled or if is description == placeholder
                range = NSRange(location: 0, length: descriptionTextView.text.utf16.count)
                if regex.firstMatch(in: descriptionTextView.text, options: [], range: range) == nil ||
                    descriptionTextView.text == "Word description" {
                    errorAlertIsNeccesary = true
                }
            } catch {
                debugPrint(error)
            }
        }

        if errorAlertIsNeccesary {
            let alert = UIAlertController(title: "Error", message: "Incorect text in word or description, please checke our insertion", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            view.endEditing(true)
            present(alert, animated: true, completion: nil)
            return
        }

        object.word = wordInformation[0].text
        object.transcription = wordInformation[1].text
        object.wordDescription = descriptionTextView.text
        object.translationUA = wordInformation[2].text
        object.translationRU = wordInformation[3].text
        object.pictureURL = wordInformation[4].text
        object.videoURL = wordInformation[5].text

        do {
            try context.save()
        } catch {
            debugPrint(error)
        }
        goBack()
    }

    // MARK: go back to sender viewcontroller

    @objc private func goBack() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: fill fields if this controller uses as edit controller

    private func fillFields(object: SelfWord) {
        wordInformation[0].text = object.word
        wordInformation[0].placeholderLabel.transform.ty = 0
        wordInformation[1].text = object.transcription
        wordInformation[1].placeholderLabel.transform.ty = 0
        descriptionTextView.text = object.wordDescription
        wordInformation[2].text = object.translationUA
        wordInformation[2].placeholderLabel.transform.ty = 0
        wordInformation[3].text = object.translationRU
        wordInformation[3].placeholderLabel.transform.ty = 0
        wordInformation[4].text = object.pictureURL
        wordInformation[4].placeholderLabel.transform.ty = 0
        wordInformation[5].text = object.videoURL
        wordInformation[5].placeholderLabel.transform.ty = 0
    }

}

// MARK: - - Extension textViewDelegate

extension AddNewWordViewController: UITextViewDelegate {

    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Word description" {
            textView.text = ""
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Word description"
        }
    }
}


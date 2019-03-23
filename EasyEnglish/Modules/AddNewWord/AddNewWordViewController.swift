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

    public var passedObject: SelfWord?
    static public let reuseIdentifier = "AddNewWord"

    // MARK: Private poperties

    private var isDoneButtonMustBeShown = [false, false]
    private var rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveWord))
    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedWords = Word.fetchAll()
    private lazy var object = SelfWord(context: context)

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTextView()
        setUpTextFields()
        setUpNavigationBar()

        //check if passedObject is nil it means that controller is not using as edit controller
        guard let tempObject = passedObject else { return }
        object = tempObject
        fillFields(object: object)
    }

    // MARK: Setting up textFields

    private func setUpTextFields() {
        for field in wordInformation {
            field.layer.cornerRadius = 7
            field.layer.masksToBounds = true
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.white.cgColor
        }
        wordInformation[0].delegate = self
        wordInformation[0].layer.borderColor = UIColor.red.cgColor
        wordInformation[0].addTarget(self, action: #selector(changingTheContext(textField:)), for: .editingChanged)
    }

    // MARK: Setting up description text view

    private func setUpTextView() {
        descriptionTextView.text = "Word description"
        descriptionTextView.delegate = self
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.red.cgColor
    }

    // MARK: Adding navigation bar

    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(goBack))
        navigationBar.items?.append(navigationItem)
        title = "Add new word"
    }

    // MARK: Saving information About word

    @objc private func saveWord() {

        object.word = wordInformation[0].text
        object.transcription = wordInformation[1].text
        object.wordDescription = descriptionTextView.text
        object.translationUA = wordInformation[2].text
        object.translationRU = wordInformation[3].text
        object.pictureURL = wordInformation[4].text
        object.videoURL = wordInformation[5].text
        
        if let index = wordInformation[5].text?.firstIndex(of: "=") {
            let id = wordInformation[5].text?[index...]
            object.videoURL = String(id ?? "") 
        }
        

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

    ///Function that handling changing the text
    @objc private func changingTheContext(textField: UITextField) {
        isDoneButtonMustBeShown[1] = checkIfWordIsNormal(textField: textField)
        checkNeccesaryForDoneButton()
    }

    ///Checking if word have set normally
    private func checkIfWordIsNormal(textField: UITextField) -> Bool {
        if textField.text == nil {
            textField.layer.borderColor = UIColor.red.cgColor
            return false
        }

        let regex: NSRegularExpression
        do {
            //check if word is nil
            try regex = NSRegularExpression(pattern: "[a-z]+", options: .caseInsensitive)
            let range = NSRange(location: 0, length: textField.text!.utf16.count)
            if regex.firstMatch(in: wordInformation[0].text!, options: [], range: range) == nil {
                textField.layer.borderColor = UIColor.red.cgColor
                return false
            }
        } catch {
            debugPrint(error)
        }

        textField.layer.borderColor = UIColor.white.cgColor
        return true
    }

    ///Checking if description set normally
    private func checkIfDescriptionIsNormal(textView: UITextView) -> Bool {
        if textView.text == nil {
            textView.layer.borderColor = UIColor.red.cgColor
            return false
        }

        let regex: NSRegularExpression

        do {
            try regex = NSRegularExpression(pattern: "[a-z]+", options: .caseInsensitive)
            let range = NSRange(location: 0, length: textView.text.utf16.count)
            if regex.firstMatch(in: textView.text, options: [], range: range) == nil {
                textView.layer.borderColor = UIColor.red.cgColor
                return false
            }
        } catch {
            debugPrint(error)
        }

        textView.layer.borderColor = UIColor.white.cgColor
        return true
    }

    ///Handling if doneButton must be shown
    private func checkNeccesaryForDoneButton() {
        if isDoneButtonMustBeShown[0] == true && isDoneButtonMustBeShown[1] == true {
            navigationItem.rightBarButtonItem = rightButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
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
            return
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        isDoneButtonMustBeShown[0] = checkIfDescriptionIsNormal(textView: textView)
        checkNeccesaryForDoneButton()
    }

}

// MARK: - - Extension textFieldDelegate

extension AddNewWordViewController: UITextFieldDelegate {

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == wordInformation[5] {
            if textField.text == "" {
                return
            }
            if !(textField.text!.contains("www.youtube.com/watch?v=")) {
                let alert = UIAlertController(title: "Error",
                                              message: "Incorect video URL. If you left it, you can't watch video", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                present(alert, animated: true, completion: nil)
                return
            }
            
            return
        }
        
        for word in fetchedWords where word.word == textField.text {

            textField.layer.borderColor = UIColor.red.cgColor

            let alert = UIAlertController(title: "Error", message: "You have this word already", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: {(_) in
                textField.becomeFirstResponder()
            }))

            present(alert, animated: true, completion: nil)
            return
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.white.cgColor
    }

}


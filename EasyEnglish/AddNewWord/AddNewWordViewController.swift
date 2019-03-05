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

        title = "Add new word"
        view.addGestureRecognizer(UIGestureRecognizer(target: self, action: #selector(endEditing)))

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: Func to creating toolbar

    private func createToolbar() -> (UIToolbar) {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(endEditing))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.items = [flexSpace, button]
        toolBar.sizeToFit()
        return toolBar
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
            field.inputAccessoryView = createToolbar()
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
        descriptionTextView.inputAccessoryView = createToolbar()
    }

    // MARK: Adding navigation bar

    private func setUpNavigationBar() {
        let button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveWord))
        navigationController?.navigationItem.rightBarButtonItem = button
    }

    @objc private func saveWord() {
        let word = WordStruct(word: wordInformation[0].text,
                              transcription: wordInformation[1].text,
                              description: descriptionTextView.text,
                              translationUA: wordInformation[2].text,
                              translationRU: wordInformation[3].text,
                              imageURL: wordInformation[4].text,
                              videoURL: wordInformation[5].text)

        savedWord?(word)
    }

    // MARK: Function for implementing moving for keyboard

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }}

extension AddNewWordViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print(textField)
        //TODO: Handle this textfield and switch it on willshow/hideKeyboard
    }
}

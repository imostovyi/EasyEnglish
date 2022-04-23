//
//  AddEditWordVC.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/5/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import TextFieldEffects
import CoreData

class AddEditWordVC: UIViewController {

    // MARK: - IBoutlets
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet var wordInformation: [IsaoTextField]!
    @IBOutlet weak var descriptionTextView: UITextView!

    // MARK: public state
    
    public var passedObject: Word?
    public var rootController: DictionaryViewController?
    public var newWord: String?
    static public let reuseIdentifier = "AddNewWord"
    public let logicController = AddEditWordLC()

    // MARK: - Private state
    
    private var rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTouched))
    private lazy var object = Word(context: CoreDataStack.shared.persistantContainer.viewContext)
    
    private var props: Props?

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTextView()
        setUpTextFields()
        setUpNavigationBar()

        logicController.updatedProps = { [weak self] in
            self?.render($0)
        }
        //check if passedObject is nil it means that controller is not using as edit controller
        guard let tempObject = passedObject else { return }
        object = tempObject
        fillFields(object: object)
        props?.checkWord(object)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard var text = newWord else { return }
        let capitalLetter = text.remove(at: String.Index(utf16Offset: 0, in: text)).uppercased()
        wordInformation[0].text = capitalLetter + text
        wordInformation[0].placeholderLabel.transform.ty = 0
    }
    
    private func render(_ props: Props) {
        self.props = props
        
        if props.doneButtonShouldBeShown {
            navigationItem.rightBarButtonItem = rightButton
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        var color = props.descriptionIsValid ? UIColor.white.cgColor : UIColor.red.cgColor
        descriptionTextView.layer.borderColor = color
        
        if props.wordIsAlreadyInDictionary {
            wordInformation[0].layer.borderColor = UIColor.red.cgColor
            let alert = UIAlertController(title: "Error", message: "You already have this word", preferredStyle: .alert)
            alert.addAction(
                UIAlertAction(title: "Ok", style: .cancel) { [weak self] _ in
                    self?.wordInformation[0].becomeFirstResponder()
                }
            )
            present(alert, animated: true, completion: nil)
            return
        }
        
        color = props.wordIsValid ? UIColor.white.cgColor : UIColor.red.cgColor
        wordInformation[0].layer.borderColor = color
    }

    // MARK: Setting up textFields
    
    private func setUpTextFields() {
        for field in wordInformation {
            field.layer.cornerRadius = 7
            field.layer.masksToBounds = true
            field.layer.borderWidth = 1
            field.layer.borderColor = UIColor.white.cgColor
        }
        wordInformation[0].layer.borderColor = UIColor.white.cgColor
        wordInformation[0].addTarget(self, action: #selector(changingTheContext(textField:)), for: .editingChanged)
    }

    // MARK: Setting up description text view
    
    private func setUpTextView() {
        descriptionTextView.text = "Word description"
        descriptionTextView.delegate = self
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.white.cgColor
    }

    // MARK: Adding navigation bar

    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(goBack))
        navigationBar.items?.append(navigationItem)
        title = "Add new word"
    }

    // MARK: Saving information About word
    @objc private func doneButtonTouched() {
        object.word = wordInformation[0].text
        object.transcription = wordInformation[1].text
        object.wordDescription = descriptionTextView.text
        object.translationUA = wordInformation[2].text
        object.pictureURL = URL(string: wordInformation[3].text ?? "")
        object.videoURL = wordInformation[4].text
        object.isKnown = false
        object.isApproved = false

        //cutting down videoURL
        if var index = wordInformation[4].text?.firstIndex(of: "=") {
            index = wordInformation[4].text?.index(after: index) ?? index
            let id = wordInformation[4].text?[index...]
            object.videoURL = String(id ?? "")
        }

        props?.saveWord()
        goToSelfAddedViewController()
    }

    /// Function that dismiss current view controller and presenting Controller with list of self added words
    @objc private func goToSelfAddedViewController() {
        guard let vc = rootController else {
            goBack()
            return
        }

        let storyboard = UIStoryboard(name: "SelfAddedWords", bundle: nil)
        let addedWordsVC = storyboard.instantiateViewController(withIdentifier: SelfAddedWordsVC.identifier) as! SelfAddedWordsVC
        addedWordsVC.root = rootController
        dismiss(animated: true, completion: nil)
        vc.present(addedWordsVC, animated: true, completion: nil)
    }

    @objc private func goBack() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: fill fields if this controller uses as edit controller
    private func fillFields(object: Word) {
        wordInformation[0].text = object.word
        wordInformation[0].placeholderLabel.transform.ty = 0
        wordInformation[1].text = object.transcription
        wordInformation[1].placeholderLabel.transform.ty = 0
        descriptionTextView.text = object.wordDescription
        wordInformation[2].text = object.translationUA
        wordInformation[2].placeholderLabel.transform.ty = 0
        wordInformation[3].text = object.pictureURL?.absoluteString
        wordInformation[3].placeholderLabel.transform.ty = 0
        wordInformation[4].text = object.videoURL
        wordInformation[4].placeholderLabel.transform.ty = 0
    }

    ///Function that handling changing the text
    @objc private func changingTheContext(textField: UITextField) {
        object.word = textField.text
        props?.checkWord(object)
    }
}

// MARK: -- Extension TextViewDelegate

extension AddEditWordVC: UITextViewDelegate {
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

    func textViewDidChange(_ textView: UITextView) {
        object.wordDescription = textView.text
        props?.checkWord(object)
    }
}

extension AddEditWordVC {
    struct Props {
        let wordIsAlreadyInDictionary: Bool
        let wordIsValid: Bool
        let doneButtonShouldBeShown: Bool
        let descriptionIsValid: Bool
        
        let checkWord: (Word) -> Void
        let saveWord: () -> Void
    }
}

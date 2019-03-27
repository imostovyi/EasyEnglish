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
    //using for callBack
    public var callBack: (([Word]) -> Void)?

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
    private var passedWords: [Word] = []
    private var wordsArray: [Word] = []
    private var observedIndex = 0
    private var lettersData: [String] = []
    private var answerData: [String] = []

    private lazy var checkedImage = UIImage(named: "checked")
    private lazy var canceledImage = UIImage(named: "cancel")

    private var sourceCollectionView: UICollectionView?
    private var sourceIndexPath: IndexPath?

    // MARK: Public functions

    public func fillWordsArray(words: [Word]) {
        wordsArray = words
    }

    // MARK: Private functions

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
        checkButton.addTarget(self, action: #selector(checkButtonWasTapped), for: .touchUpInside)

        fillLettersAndDescription()
        configuratinCollectionView()
        configuratingNavBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkIndex()
    }

    ///function for check button
    @objc private func checkButtonWasTapped() {
        var answer = ""

        for letter in answerData {
            answer += letter
        }

        if wordsArray[observedIndex].word != answer {
            statusImageView.image = canceledImage
            return
        }
        statusImageView.image = checkedImage

        for word in passedWords {
            if word == wordsArray[observedIndex] {
                return
            }
            passedWords.append(wordsArray[observedIndex])
        }

        if passedWords.count == wordsArray.count {
            let alert = UIAlertController(title: "Congratulation", message: "You passed all words", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Huray!)", style: .cancel, handler: { (_) in
                self.callBack?(self.passedWords)
                self.dismiss(animated: true, completion: nil)
            }))
            present(alert, animated: true, completion: nil)
        }
    }

    ///Configuaratind navigation bar
    private func configuratingNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Give up", style: .plain, target: self, action: #selector(giveUpWasTapped))
        navigationBar.items?.append(navigationItem)
        title = "Tets"
    }

    @objc private func giveUpWasTapped() {
        callBack?(passedWords)
        dismiss(animated: true, completion: nil)
    }

    ///Filing letters array and description
    private func fillLettersAndDescription() {
        if wordsArray.count == 0 { return }

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

        lettersCollectionView.reloadData()
        answerCollectionView.reloadData()
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
        lettersCollectionView.dragDelegate = self
        lettersCollectionView.dropDelegate = self
        lettersCollectionView.dataSource = self

        lettersCollectionView.layer.borderWidth = 1
        lettersCollectionView.layer.cornerRadius = 8
        lettersCollectionView.layer.masksToBounds = true
        lettersCollectionView.layer.borderColor = UIColor.white.cgColor

        answerCollectionView.delegate = self
        answerCollectionView.dataSource = self
        answerCollectionView.dragInteractionEnabled = true
        answerCollectionView.dragDelegate = self
        answerCollectionView.dropDelegate = self

        answerCollectionView.layer.borderWidth = 1
        answerCollectionView.layer.cornerRadius = 8
        answerCollectionView.layer.masksToBounds = true
        answerCollectionView.layer.borderColor = UIColor.white.cgColor
    }

    ///Reorder item
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        //sourceCollectionView? = collectionView
        let items = coordinator.items
        if items.count == 1, let item = items.first, let sourceIndexPath = item.sourceIndexPath {
            //Avoiding exeption index out of rage and cnaging let to var
            var dIndexPath = destinationIndexPath
            if destinationIndexPath.row >= collectionView.numberOfItems(inSection: 0) {
                dIndexPath.row = collectionView.numberOfItems(inSection: 0) - 1
            }

            collectionView.performBatchUpdates({
                if collectionView == lettersCollectionView {
                    lettersData.remove(at: sourceIndexPath.row)
                    lettersData.insert(item.dragItem.localObject as! String, at: dIndexPath.row)
                } else {
                    answerData.remove(at: sourceIndexPath.row)
                    answerData.insert(item.dragItem.localObject as! String, at: dIndexPath.row)
                }
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [dIndexPath])
            }, completion: nil)
            coordinator.drop(items.first!.dragItem, toItemAt: dIndexPath)
        }
    }

    //Moving items
    private func copyItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        if sourceCollectionView! == collectionView {
            sourceCollectionView = nil
            return
        }

        collectionView.performBatchUpdates({
            var indexPaths = [IndexPath]()

            defer {
                sourceCollectionView = nil
                sourceIndexPath = nil
            }

            guard let item = coordinator.items.first else {return}
            guard let source = sourceIndexPath else {return}
            let indexPath = IndexPath(row: destinationIndexPath.row, section: destinationIndexPath.section)
            if collectionView === lettersCollectionView {
                lettersData.insert(item.dragItem.localObject as! String, at: indexPath.row)
                let sourceIndex = source
                answerData.remove(at: sourceIndex.row)
            } else {
                answerData.insert(item.dragItem.localObject as! String, at: indexPath.row)
                let sourceIndex = source
                lettersData.remove(at: sourceIndex.row)
            }
            sourceCollectionView?.reloadData()
            indexPaths.append(indexPath)
            collectionView.insertItems(at: indexPaths)
        }, completion: nil)

        return
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

// MARK: - - Extension UiCollectionViewDragDelegate

extension ComposeWordViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        sourceCollectionView = collectionView
        sourceIndexPath = indexPath
        let item = collectionView == lettersCollectionView ? lettersData[indexPath.row] : answerData[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }

}

// MARK: - - Extension UICollectionViewDropDelegate

extension ComposeWordViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }

    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }

        switch coordinator.proposal.operation {
        case .move:
            reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        case .copy:
            copyItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        default:
            return
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
        }
    }

}

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

    public static let identifier = "Test"

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
    private var words: [Word] = []
    private var observedIndex = 0
    private var lettersData: [String] = []
    private var answerData: [String] = []

    private lazy var checkedImage = UIImage(named: "checked")
    private lazy var canceledImage = UIImage(named: "cancel")

    private var sourceCollectionView: UICollectionView?
    private var sourceIndexPath: IndexPath?

    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext

    // MARK: Public functions

    public func fillWordsArray(words: [Word]) {
        for word in words {
            word.isKnown = false
            self.words.append(word)
        }
    }

    // MARK: Private functions

    override func viewDidLoad() {
        super.viewDidLoad()

        observedIndex = 0

        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.white.cgColor

        backButton.addTarget(self, action: #selector(arrowButtonWasTapped(button:)), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(arrowButtonWasTapped(button:)), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(checkButtonWasTapped), for: .touchUpInside)

        fillLettersAndDescription()
        configurateCollectionView()
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

        if words[observedIndex].word != answer {
            statusImageView.image = canceledImage
            return
        }
        statusImageView.image = checkedImage
        words[observedIndex].isKnown = true
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }

        words.remove(at: observedIndex)

        createAlert()
    }

    ///Function that ctrate and present alert to congratulate user with passing one word or all words
    private func createAlert() {

        var messageInAlert = ""

        if words.count == 0 {
            messageInAlert = "Congratulation, you passed all the words"
        } else {
            messageInAlert = "Congratulation, you compose the word correctly"
        }

        let alert = UIAlertController(title: "Congratulation", message: messageInAlert, preferredStyle: .alert)

        if words.count == 0 {
            alert.addAction(UIAlertAction(title: "Go back", style: .default, handler: { (_) in
                self.dismiss(animated: true, completion: nil)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Next word", style: .default, handler: { (_) in
                self.observedIndex -= 1
                self.arrowButtonWasTapped(button: self.forwardButton)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    ///Configuaratind navigation bar
    private func configuratingNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Give up", style: .plain, target: self, action: #selector(giveUpWasTapped))
        navigationBar.items?.append(navigationItem)
        title = "Tets"
    }

    @objc private func giveUpWasTapped() {
        do {
            try context.save()
        } catch {
            debugPrint(error)
        }

        dismiss(animated: true, completion: nil)
    }

    ///Filing letters array and description
    private func fillLettersAndDescription() {
        if words.count == 0 { return }

        guard let word = words[observedIndex].word else { return }

        descriptionTextView.text = words[observedIndex].wordDescription

        lettersData = []
        answerData = []
        let array = Array(word)
        for i in array {
            let charToString = String(i)
            lettersData.append(charToString)
        }

        lettersData = lettersData.shuffled()

        statusImageView.image = canceledImage

        lettersCollectionView.reloadData()
        answerCollectionView.reloadData()
    }

    ///FadeIn/FadeOut function with switching to the next word. Also check and save changes in context
    @objc private func arrowButtonWasTapped(button: UIButton) {
        let isForward = button == forwardButton ? true : false

        if isForward {self.observedIndex += 1} else {self.observedIndex -= 1}
        checkIndex()

        UIView.animate(withDuration: 1.5, delay: 0.5, options: .allowUserInteraction,
                       animations: {
                        self.visualEffectView.alpha = 0.3
        }, completion: nil)

        fillLettersAndDescription()

        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction,
                       animations: {
                        self.visualEffectView.alpha = 1.0
        }, completion: nil)
    }

    ///Chech if it's necessary to hide left or right button
    private func checkIndex() {
        if words.count == 0 {
            createAlert()
        }

        if words.count == 1 {
            backButton.isEnabled = false
            forwardButton.isEnabled = false
            return
        }

        if observedIndex == 0 {
            backButton.isEnabled = false
            forwardButton.isEnabled = true
            return
        }

        if observedIndex == (words.count - 1) {
            forwardButton.isEnabled = false
            backButton.isEnabled = true
            return
        }

        forwardButton.isEnabled = true
        backButton.isEnabled = true
        return
    }

    ///Configurating collection view
    private func configurateCollectionView() {
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

    ///Reorder item in one section
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

    //Moving items between sections
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

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.performBatchUpdates({

            if collectionView == lettersCollectionView {
                let object = lettersData[indexPath.row]
                lettersData.remove(at: indexPath.row)

                //deciding where letter must be inseted
                var row: Int
                switch answerCollectionView.numberOfItems(inSection: 0) {
                case 0: row = 0
                case 1: row = 1
                default: row = answerCollectionView.numberOfItems(inSection: 0)
                }
                let dIndexPath = IndexPath(row: row, section: 0)
                answerData.insert(object, at: dIndexPath.row)

                collectionView.deleteItems(at: [indexPath])
                answerCollectionView.insertItems(at: [dIndexPath])
            } else {
                let object = answerData[indexPath.row]
                answerData.remove(at: indexPath.row)

                //deciding where letter must be inseted
                var row: Int
                switch lettersCollectionView.numberOfItems(inSection: 0) {
                case 0: row = 0
                case 1: row = 1
                default: row = lettersCollectionView.numberOfItems(inSection: 0)// - 1
                }
                let dIndexPath = IndexPath(row: row, section: 0)
                lettersData.insert(object, at: dIndexPath.row)

                collectionView.deleteItems(at: [indexPath])
                lettersCollectionView.insertItems(at: [dIndexPath])
            }
        }, completion: nil)
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

// Collection view flow layout delegate
extension ComposeWordViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 5
        let size = collectionView.frame.size.width - padding

        let height = size / CGFloat(words[observedIndex].word!.count + 1)
        let width = height

        return CGSize(width: width, height: height)
    }
}

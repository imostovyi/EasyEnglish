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
    public var logicController: ComposeWordLC!

    // MARK: outlets

    @IBOutlet private var navigationBar: UINavigationBar!
    @IBOutlet private var descriptionTextView: UITextView!
    @IBOutlet private var answerCollectionView: UICollectionView!
    @IBOutlet private var lettersCollectionView: UICollectionView!
    @IBOutlet private var previousWordButton: UIButton!
    @IBOutlet private var checkButton: UIButton!
    @IBOutlet private var nextWordButton: UIButton!
    @IBOutlet private var statusImageView: UIImageView!
    @IBOutlet var visualEffectView: UIVisualEffectView!

    // MARK: private properties
    private var props: Props!

    private lazy var checkedImage = UIImage(named: "checked")
    private lazy var canceledImage = UIImage(named: "cancel")

    private var sourceCollectionView: UICollectionView?
    private var sourceIndexPath: IndexPath?

    // MARK: Private functions

    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.layer.borderColor = UIColor.white.cgColor

        previousWordButton.addTarget(self, action: #selector(arrowButtonWasTapped(button:)), for: .touchUpInside)
        nextWordButton.addTarget(self, action: #selector(arrowButtonWasTapped(button:)), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(checkButtonWasTapped), for: .touchUpInside)
        
        configureNavBar()
        configureCollectionViews()
        
        logicController.updatedProps = { [weak self] in
            self?.render($0)
        }

    }
    
    private func render(_ props: Props) {
        self.props = props
        
        previousWordButton.isEnabled = props.previousButtonIsEnabled
        nextWordButton.isEnabled = props.nextButtonIsEnabled
        descriptionTextView.text = props.wordDescription
        render(props.checkStatus)
        
        lettersCollectionView.reloadData()
        answerCollectionView.reloadData()
        
        render(props.alertConfiguration)
    }
    
    private func render(_ checkStatus: Props.CheckStatus) {
        switch props.checkStatus {
        case .inProgress:
            statusImageView.image = nil
        case .failed:
            statusImageView.image = canceledImage
        case .success:
            statusImageView.image = checkedImage
        }
    }
    
    private func render(_ alertConfiguration: Props.AlertConfiguration?) {
        guard let alertConfiguration = alertConfiguration else {
            return
        }
        
        var messageInAlert: String
        var alertAction: UIAlertAction
        switch alertConfiguration {
        case .allWordsCombined:
            messageInAlert = "Congratulation, you passed all the words"
            alertAction = UIAlertAction(
                title: "Go back",
                style: .default,
                handler: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }
            )
        case let .oneWordCombined(handler: handler):
            messageInAlert = "Congratulation, you compose the word correctly"
            alertAction = UIAlertAction(
                title: "Next word",
                style: .default,
                handler: { _ in
                    handler()
                }
            )
        }
        
        let alert = UIAlertController(title: "Congratulation", message: messageInAlert, preferredStyle: .alert)
        alert.addAction(alertAction)
        alert.addAction(
            .init(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        present(alert, animated: true, completion: nil)
    }

    @objc private func checkButtonWasTapped() {
        props?.checkButtonTouched()
    }

    @objc private func giveUpWasTapped() {
        dismiss(animated: true, completion: nil)
    }

    ///FadeIn/FadeOut function with switching to the next word. Also check and save changes in context
    @objc private func arrowButtonWasTapped(button: UIButton) {
        let isForward = button == nextWordButton ? true : false
        UIView.animate(withDuration: 1.5, delay: 0.5, options: .allowUserInteraction,
                       animations: {
                        self.visualEffectView.alpha = 0.3
        }, completion: nil)
        
        isForward ? props?.nextButtonTouched() : props?.previousButtonTouched()
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .allowUserInteraction,
                       animations: {
                        self.visualEffectView.alpha = 1.0
        }, completion: nil)
    }
    
    
    private func configureNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Give up", style: .plain, target: self, action: #selector(giveUpWasTapped))
        navigationBar.items?.append(navigationItem)
        title = "Test"
    }

    private func configureCollectionViews() {
        let collectionViews = [lettersCollectionView, answerCollectionView]
        collectionViews.forEach {
            $0?.delegate = self
            $0?.dragInteractionEnabled = true
            $0?.dragDelegate = self
            $0?.dropDelegate = self
            $0?.dataSource = self

            $0?.layer.borderWidth = 1
            $0?.layer.cornerRadius = 8
            $0?.layer.masksToBounds = true
            $0?.layer.borderColor = UIColor.white.cgColor
        }
    }

    ///Reorder item in one section
    private func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        
        guard coordinator.items.count == 1,
              let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath else {
                  return
              }
        
        let collection: Props.Collection = collectionView == lettersCollectionView
        ? .source
        : .answer
        props.reorderLetter(collection, sourceIndexPath.row, destinationIndexPath.row)
        collectionView.performBatchUpdates {
            collectionView.deleteItems(at: [sourceIndexPath])
            collectionView.insertItems(at: [.init(row: destinationIndexPath.row, section: 0)])
        }
    }
}

// MARK: -- Extension CollectionViewDataSource & Delegate

extension ComposeWordViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView == lettersCollectionView
        ? props.lettersDataSource.count
        : props.answerDataSource.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let letter = collectionView == lettersCollectionView
        ? props.lettersDataSource[indexPath.row]
        : props.answerDataSource[indexPath.row]
        
        let reuseIdentifier = collectionView == lettersCollectionView
        ? "LetterCell"
        : "AnswerLetterCell"

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: reuseIdentifier,
            for: indexPath
        ) as! CollectionViewCell
        cell.initLabel(letter: letter)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let collection: Props.Collection = collectionView == lettersCollectionView
        ? .source
        : .answer
        props.didSelectLetter(collection, indexPath.row)
    }
}

// MARK: - Extension UiCollectionViewDragDelegate

extension ComposeWordViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        sourceCollectionView = collectionView
        sourceIndexPath = indexPath
        let item = collectionView == lettersCollectionView
        ? props.lettersDataSource[indexPath.row]
        : props.answerDataSource[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

// MARK: -- Extension UICollectionViewDropDelegate

extension ComposeWordViewController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        session.canLoadObjects(ofClass: NSString.self)
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
        default:
            return
        }
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ComposeWordViewController: UICollectionViewDelegateFlowLayout {

//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        let padding: CGFloat = 5
//        let size = collectionView.frame.size.width - padding
//
//        let height = size / CGFloat(words[observedIndex].word!.count + 1)
//        let width = height
//
//        return CGSize(width: width, height: height)
//    }
}

extension ComposeWordViewController {
    struct Props {
        let nextButtonIsEnabled: Bool
        let previousButtonIsEnabled: Bool
        let checkStatus: CheckStatus
        let alertConfiguration: AlertConfiguration?
        
        let wordDescription: String
        
        let lettersDataSource: [String]
        let answerDataSource: [String]
        
        let nextButtonTouched: () -> Void
        let previousButtonTouched: () -> Void
        let checkButtonTouched: () -> Void
        
        let didSelectLetter: (Collection, Int) -> Void
        let reorderLetter: (Collection, Int, Int) -> Void
        
        enum Collection {
            case source
            case answer
        }
        
        enum CheckStatus {
            case failed
            case success
            case inProgress
        }
        
        enum AlertConfiguration {
            case allWordsCombined
            case oneWordCombined(handler: () -> Void)
        }
    }
}

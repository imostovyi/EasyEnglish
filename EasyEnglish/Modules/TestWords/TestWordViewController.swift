//
//  TestWordViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/24/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import CoreData

class TestWordViewController: UIViewController {

    // MARK: Public properties

    public static let identifier = "TestWords"
    public var callBack: (([Word]) -> Void)?

    // MARK: private properties

    private var testWords: Set<Word> = []
    private var indexingArray: [Word] = []

    let nib = UINib(nibName: "SelfAddedWordsTableViewCell", bundle: nil)

    private lazy var editActions = [
        UITableViewRowAction(style: .normal, title: "Delete", handler: { [weak self](_, indexPath) in
        self?.deleteAction(indexPath: indexPath)
    })]

    private lazy var contex = CoreDataStack.shared.persistantContainer.viewContext
    // MARK: outlets

    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var tableView: UITableView!

    // MARK: Public functions

    ///Init for testWord array
    public func initArray(words: Set<Word>) {
        testWords = words
    }

    // MARK: Private functions

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nib, forCellReuseIdentifier: TestWordCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        customizationNavBar()
        indexingArray = Array(testWords)
    }

    ///Delete option for indexPath
    private func deleteAction(indexPath: IndexPath) {
        let object = indexingArray[indexPath.row]
        testWords.remove(object)
        indexingArray = Array(testWords)
        tableView.reloadData()
    }

    ///Customization navigation bar
    private func customizationNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "I'm ready!", style: .done, target: self, action: #selector(doneButtonWasTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Not this time", style: .plain, target: self, action: #selector(backButtonWasTapped))

        navigationBar.items?.append(navigationItem)
    }

    ///Done action
    @objc private func doneButtonWasTapped() {
        let storyBoard = UIStoryboard(name: "ComposeWord", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: ComposeWordViewController.identifier) as! ComposeWordViewController

        vc.fillWordsArray(words: indexingArray)
        present(vc, animated: true, completion: nil)

        vc.callBack = {(words) in
            for word in words {
                word.isKnown = true
                self.testWords.remove(word)
            }
            self.indexingArray = Array(self.testWords)

            do {
                try self.contex.save()
            } catch {
                debugPrint(error)
            }
            self.tableView.reloadData()
        }
    }

    ///Go back button
    @objc private func backButtonWasTapped() {
        dismiss(animated: true) {
            self.callBack?(self.indexingArray)
        }
    }

}

// MARK: - - Extension tableViewDataSource and tableViewDelegate
extension TestWordViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testWords.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelfAddedWordsTableViewCell.identfier) as! SelfAddedWordsTableViewCell

        cell.wordLabel.text = indexingArray[indexPath.row].word
        cell.descriptionLabel.text = indexingArray[indexPath.row].wordDescription

        guard let url = URL(string: indexingArray[indexPath.row].pictureURL!) else {
            return cell
        }
        let placeholderImage = UIImage(named: "flag")
        cell.captureImageView.kf.indicatorType = .activity
        cell.captureImageView.kf.setImage(with: url, placeholder: placeholderImage, options: nil, progressBlock: nil) { (result) in
            switch result {
            case .failure:
                cell.captureImageView.image = placeholderImage
            default: return
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return editActions
    }

}

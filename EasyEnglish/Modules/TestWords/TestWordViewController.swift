//
//  TestWordViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/24/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit

class TestWordViewController: UIViewController {

    // MARK: Public properties

    public let identifier = "TestWords"
    public var callBack: ((Set<Word>) -> Void)?

    // MARK: private properties

    private var testWords: Set<Word> = []
    private var indexingArray: [Word] = []

    let nib = UINib(nibName: "TestWordCell", bundle: nil)

    private lazy var editActions = [
        UITableViewRowAction(style: .normal, title: "Delete", handler: { [weak self](_, indexPath) in
        self?.deleteAction(indexPath: indexPath)
    })]
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

        indexingArray = Array(testWords)
    }

    ///Delete option for indexPath
    private func deleteAction(indexPath: IndexPath) {
        let object = indexingArray[indexPath.row]
        testWords.remove(object)

        indexingArray = Array(testWords)
    }

    ///Customization navigation bar
    private func customizationNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonWasTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonWasTapped))
    }

    ///Done action
    @objc private func doneButtonWasTapped() {

    }

    ///Go back button
    @objc private func backButtonWasTapped() {
        dismiss(animated: true) {
            self.callBack?(self.testWords)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TestWordCell.identifier) as! TestWordCell
        cell.initProperties(word: indexingArray[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return editActions
    }

}

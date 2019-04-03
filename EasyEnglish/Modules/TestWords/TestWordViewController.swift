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

    // MARK: private properties

    let nib = UINib(nibName: "SelfAddedWordsTableViewCell", bundle: nil)
    private let rightbutton = UIBarButtonItem(title: "I'm ready!", style: .done, target: self, action: #selector(doneButtonWasTapped))

    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let request: NSFetchRequest<Word> = Word.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]

        let controller = NSFetchedResultsController<Word>(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil)
        controller.delegate = self

        do {
            try controller.performFetch()
        } catch {
            debugPrint(error)
        }
        return controller
    }()

    private var wordsForTesting: Set<Word> = []

    // MARK: outlets

    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var tableView: UITableView!

    // MARK: Private functions

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nib, forCellReuseIdentifier: SelfAddedWordsTableViewCell.identfier)
        tableView.dataSource = self
        tableView.delegate = self
        customizationNavBar()

        checkCapacity()
    }

    ///Customization navigation bar, add two navigation items to the navigationbar
    private func customizationNavBar() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Not this time", style: .plain, target: self, action: #selector(backButtonWasTapped))

        navigationBar.items?.append(navigationItem)
    }

    ///Pass the Set called wordsForTest to ComposeViewController and present that controller
    @objc private func doneButtonWasTapped() {
        let storyBoard = UIStoryboard(name: "ComposeWord", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: ComposeWordViewController.identifier) as! ComposeWordViewController

        vc.fillWordsArray(words: Array(wordsForTesting))

        present(vc, animated: true, completion: nil)
        tableView.reloadData()
    }

    @objc private func backButtonWasTapped() {
        dismiss(animated: true)
    }

    ///Function that check capacity of wordsForTesting set and decide if it's necessary to show rightBarButtonItem
    private func checkCapacity() {
        if wordsForTesting.count != 0 {
            navigationItem.rightBarButtonItem = rightbutton
            return
        }
        navigationItem.rightBarButtonItem = nil
    }

}

// MARK: - - Extension tableViewDataSource and tableViewDelegate
extension TestWordViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelfAddedWordsTableViewCell.identfier) as! SelfAddedWordsTableViewCell
        let placeholderImage = UIImage(named: "flag")

        cell.wordLabel.isHidden = true
        cell.descriptionLabel.text = fetchedResultsController.fetchedObjects?[indexPath.row].wordDescription

        guard let url = fetchedResultsController.fetchedObjects?[indexPath.row].pictureURL else {
            cell.captureImageView.image = placeholderImage
            return cell
        }

        cell.captureImageView.kf.indicatorType = .activity
        cell.captureImageView.kf.setImage(with: url, placeholder: placeholderImage, options: nil, progressBlock: nil) { (result) in
            switch result {
            case .failure:
                cell.captureImageView.image = placeholderImage
            default: return
            }
        }

        cell.accessoryType = .none
        return cell
    }

    ///Add checkmark for selected word and push it to wordsForTesting and check it's count
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }

        guard let word = fetchedResultsController.fetchedObjects?[indexPath.row] else {
            return
        }
        if wordsForTesting.contains(word) { return }
        wordsForTesting.insert(word)

        checkCapacity()
    }

    ///Disabling checkmark for deselected word and removing it from wordForTesting
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
        }

        guard let word = fetchedResultsController.fetchedObjects?[indexPath.row] else {
            return
        }
        if !wordsForTesting.contains(word) { return }
        wordsForTesting.remove(word)

        checkCapacity()
    }

}

// MARK: - - Extension Fetched results controller delegate
extension TestWordViewController: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

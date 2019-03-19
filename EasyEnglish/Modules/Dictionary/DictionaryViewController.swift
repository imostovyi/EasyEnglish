//
//  ViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/5/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import Floaty
import CoreData
import Kingfisher

class DictionaryViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var floatyButton: Floaty!
    @IBOutlet weak var tableView: UITableView!

    // MARK: Private properties

    private var filtreedData = [Word]()
    private var resultSearchController = UISearchController()

    private let cell = UINib(nibName: "SelfAddedWordsTableViewCell", bundle: nil)

    private lazy var editActions = [
        UITableViewRowAction(style: .normal, title: "Delete", handler: { [weak self] (_, indexPath) in
            self?.deleteAction(indexPath: indexPath)
        })
    ]

    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        let controller = NSFetchedResultsController<Word>(
            fetchRequest: fetchRequest,
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

    // MARK: ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpFloatyButton()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell, forCellReuseIdentifier: SelfAddedWordsTableViewCell.identfier)

        resultSearchController = setUpSearchController()
    }

    // MARK: set up search controller and adding search bar to table view

    private func setUpSearchController() -> UISearchController {

        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.placeholder = "Tab to searching"
        controller.searchBar.layer.cornerRadius = 20
        let textColor = UIColor(named: "Text")
        let textFieldInside = controller.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInside?.textColor = textColor

//        let cancelButtonAttributes = [NSAttributedString.Key.foregroundColor: UIColor.red]
//        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes, for: .normal)

        tableView.tableHeaderView = controller.searchBar

        return controller
    }

    // MARK: seting up action button and adding it to view

    private func setUpFloatyButton() {
        floatyButton.sticky = true
        var icon = UIImage(named: "plus")
        floatyButton.addItem("Add word", icon: icon) { (_) in
            self.resultSearchController.dismiss(animated: false, completion: nil)
            let storyboard = UIStoryboard(name: "AddNewWord", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: AddNewWordViewController.reuseIdentifier) as! AddNewWordViewController
            self.present(vc, animated: true, completion: nil)

        }
        icon = UIImage(named: "layers")
        floatyButton.addItem("Self added words", icon: icon) { (_) in
            self.resultSearchController.dismiss(animated: false, completion: nil)
            let storyboard = UIStoryboard(name: "SelfAddedWords", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SelfAddedWords") as! SelfAddedWordsViewController
            self.present(vc, animated: true, completion: nil)

        }

        view.addSubview(floatyButton)
    }

    // MARK: delete option

    private func deleteAction(indexPath: IndexPath) {
        guard let object = fetchedResultsController.fetchedObjects?[indexPath.row] else { return }
        context.delete(object)
        do {
            try context.save()
        } catch { debugPrint(error) }
    }

}

// MARK: - - FetchedresultsControllerDelegate

extension DictionaryViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

// MARK: - - extension table view delegate and datasource

extension DictionaryViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultSearchController.isActive && resultSearchController.searchBar.text! != "" {
            return filtreedData.count
        } else {
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelfAddedWordsTableViewCell.identfier) as! SelfAddedWordsTableViewCell

        let data: [Word] = {
            var array: [Word]
            if resultSearchController.isActive &&
                resultSearchController.searchBar.text! != "" {
                array = filtreedData
            } else {
                array = fetchedResultsController.fetchedObjects ?? []
            }
            return array
        }()

        let object = data[indexPath.row]

        cell.wordLabel.text = object.word
        cell.descriptionLabel.text = object.wordDescription
        let placeholderImage = UIImage(named: "flag")
        guard let stringURL = object.pictureURL else {
            cell.captureImageView.image = placeholderImage
            return cell
        }

        let optionalUrl = URL(string: stringURL)
        guard let url = optionalUrl else {
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
        return cell
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return editActions
    }

}

// MARK: - - Extension U

extension DictionaryViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {

        filtreedData.removeAll(keepingCapacity: false) // clear data before any actions
        guard let searchText = resultSearchController.searchBar.text else {
            return
        } // text that uses for searching
        let regex = try? NSRegularExpression( // regular expression based on searchText
            pattern: searchText,
            options: .caseInsensitive)

        // filtring all data and pass only that walues which contaice regular expression
        let array = fetchedResultsController.fetchedObjects?.filter({ (word) -> Bool in
            guard let stringSearchIn = word.word else { return false }//text where searching compliting
            guard let regex = regex else { return false }
            let range = NSRange(location: 0, length: stringSearchIn.count)

            if regex.firstMatch(in: stringSearchIn, options: [], range: range) != nil {
                return true
            }

            return false
        })

        guard let data = array else {
            return
        }
        filtreedData = data // passing filtring data 

        tableView.reloadData()
    }

}

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

    private lazy var editActions: [UITableViewRowAction] = {
        let arrayOfActions: [UITableViewRowAction] = [
            UITableViewRowAction(style: .normal, title: "Delete", handler: { [weak self] (_, indexPath) in
            self?.deleteAction(indexPath: indexPath)
        })]
        arrayOfActions.first?.backgroundColor = UIColor.red
        return arrayOfActions
    }()

    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedResultsController: NSFetchedResultsController<Word> = {
        let fetchRequest: NSFetchRequest<Word> = Word.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        fetchRequest.predicate = NSPredicate(format: "isApproved = YES")
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
        tableView.addSubview(PullToRefresh.shared.refreshController)

        resultSearchController = setUpSearchController()
    }

    // MARK: set up search controller and adding search bar to table view

    private func setUpSearchController() -> UISearchController {

        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.dimsBackgroundDuringPresentation = false
        controller.searchBar.sizeToFit()
        controller.searchBar.placeholder = "At least two letters to start"
        controller.searchBar.layer.cornerRadius = 20

//        navigationItem.searchController = controller
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
            vc.rootController = self
            self.present(vc, animated: true, completion: nil)

        }

        icon = UIImage(named: "layers")
        floatyButton.addItem("Unchecked words", icon: icon) { (_) in
            self.resultSearchController.dismiss(animated: false, completion: nil)
            let storyboard = UIStoryboard(name: "SelfAddedWords", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SelfAddedWords") as! SelfAddedWordsViewController
            self.present(vc, animated: true, completion: nil)

        }

        floatyButton.addItem("Test", icon: nil) { (_) in
            self.resultSearchController.dismiss(animated: false, completion: nil)
            let storyboard = UIStoryboard(name: "TestWords", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: TestWordViewController.identifier) as! TestWordViewController
            self.present(controller, animated: true, completion: nil)
        }

        view.addSubview(floatyButton)
    }

    // MARK: delete option

    private func deleteAction(indexPath: IndexPath) {
        guard let object = fetchedResultsController.fetchedObjects?[indexPath.row] else { return }

        let alert = UIAlertController(title: "Are you shure?", message: "You are going to delete \(object.word ?? "")", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
            self.context.delete(object)
            do {
                try self.context.save()
            } catch {
                debugPrint(error)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    ///Function that checks if is nead to start searching
    private func isNecessaryToSearch() -> Bool {
        if resultSearchController.isActive && resultSearchController.searchBar.text! != "" &&
            resultSearchController.searchBar.text!.count >= 2 {
            return true
        }
        return false
    }

    private func highlight(_ substring: String, in string: String, color: UIColor = UIColor.blue) -> NSAttributedString {
        let defaultAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22.0),
                                 NSAttributedString.Key.foregroundColor: UIColor.white]

        let text = NSMutableAttributedString(string: string, attributes: defaultAttributes)

        if let fillableRange = string.lowercased().range(of: (substring.lowercased())) {
            let findedSubstring = NSRange(fillableRange, in: string)
            text.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 22.0), range: findedSubstring)
            text.addAttribute(NSAttributedString.Key.underlineColor, value: UIColor.red, range: findedSubstring)
            text.addAttribute(NSAttributedString.Key.underlineStyle, value: 1, range: findedSubstring)
        }

        return text
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
        if isNecessaryToSearch() {
            return filtreedData.count
        } else {
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        return resultSearchController.searchBar
//    }
//
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 40.0
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelfAddedWordsTableViewCell.identfier) as! SelfAddedWordsTableViewCell
        cell.selectionStyle = .none

        let data: [Word] = {
            var array: [Word]
            if isNecessaryToSearch() {
                array = filtreedData
            } else {
                array = fetchedResultsController.fetchedObjects ?? []
            }
            return array
        }()

        let object = data[indexPath.row]

        if isNecessaryToSearch() {
            cell.wordLabel.attributedText = highlight(
                resultSearchController.searchBar.text!, in: object.word!)
        } else {
            cell.wordLabel.attributedText = nil
            cell.wordLabel.text = object.word
        }

        cell.descriptionLabel.text = object.wordDescription

        let placeholderImage = UIImage(named: "flag")
        cell.captureImageView.kf.indicatorType = .activity
        cell.captureImageView.kf.setImage(with: object.pictureURL, placeholder: placeholderImage, options: nil, progressBlock: nil) { (result) in
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ShowDetail", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: ShowDetailViewController.identifier) as! ShowDetailViewController

        let data: [Word] = {
            var array: [Word]
            if isNecessaryToSearch() {
                array = filtreedData
            } else {
                array = fetchedResultsController.fetchedObjects ?? []
            }
            return array
        }()

        vc.context = data[indexPath.row]
        self.resultSearchController.dismiss(animated: true, completion: nil)
        present(vc, animated: true, completion: nil)
    }

}

// MARK: - - Extension UIsearchResultsUpdating

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


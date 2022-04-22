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

    @IBOutlet private weak var floatyButton: Floaty!
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: Public
    
    public var appCoordinator: AppCoordinator!

    // MARK: Private

    private var logicController: DictionaryLC!
    private var props: Props?
    private var resultSearchController = UISearchController()

    private let cell = UINib(nibName: "SelfAddedWordsTableViewCell", bundle: nil)

    private func render(_ props: Props) {
        self.props = props
        tableView.reloadData()
    }
    

    // MARK: ViewDidLoad

    override func viewDidLoad() {
        super.viewDidLoad()

        logicController = .init()
        logicController.updatedProps = { [weak self] in
            self?.render($0)
        }
        
        setUpFloatyButton()

        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cell, forCellReuseIdentifier: SelfAddedWordsTableViewCell.identifier)
        tableView.addSubview(PullToRefresh.shared.refreshController)

        resultSearchController = setUpSearchController()
    }

    // MARK: set up search controller and adding search bar to table view

    private func setUpSearchController() -> UISearchController {
        let controller = UISearchController(searchResultsController: nil)
        controller.searchResultsUpdater = self
        controller.searchBar.sizeToFit()
        controller.searchBar.placeholder = "At least two letters to start"
        controller.searchBar.layer.cornerRadius = 20

        tableView.tableHeaderView = controller.searchBar

        return controller
    }

    // MARK: delete option

    private func deleteAction(indexPath: IndexPath) {
        guard let object = props?.words[indexPath.row] else { return }

        let alert = UIAlertController(
            title: "Are you sure?",
            message: "You are going to delete \(object.word.string)",
            preferredStyle: .alert)
        alert.addAction(
            UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
                self?.props?.deleteWord(indexPath.row)
            })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

// MARK: - - extension table view delegate and datasource

extension DictionaryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        props?.words.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView
            .dequeueReusableCell(
                withIdentifier: SelfAddedWordsTableViewCell.identifier
            ) as! SelfAddedWordsTableViewCell
        cell.selectionStyle = .none
        
        guard let wordModel = props?.words[indexPath.row] else {
            return cell
        }

        cell.wordLabel.attributedText = wordModel.word
        cell.descriptionLabel.text = wordModel.descriptionText

        let placeholderImage = UIImage(named: "flag")
        cell.captureImageView.kf.indicatorType = .activity
        cell.captureImageView.kf.setImage(
            with: wordModel.imageURL,
            placeholder: placeholderImage,
            options: nil,
            progressBlock: nil) { (result) in
                switch result {
                case .failure:
                    cell.captureImageView.image = placeholderImage
                default: return
                }
            }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ShowDetail", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: WordDetailsVC.identifier) as! WordDetailsVC
        
        vc.context = props?.wordForIndex(indexPath.row)
        self.resultSearchController.dismiss(animated: true, completion: nil)
        present(vc, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { [weak self] _, _, completion in
            self?.props?.deleteWord(indexPath.row)
            completion(true)
        }
        return .init(actions: [deleteAction])
    }
}

// MARK: - - Extension UIsearchResultsUpdating

extension DictionaryViewController: UISearchResultsUpdating {

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = resultSearchController.searchBar.text else {
            return
        }
        props?.updateSearchPattern(searchText)
    }
}

// MARK: - Extension Floaty buttons
extension DictionaryViewController {
    private func setUpFloatyButton() {
        floatyButton.sticky = true
        var icon = UIImage(named: "plus")
        floatyButton.addItem("Add word", icon: icon) { (_) in
            self.resultSearchController.dismiss(animated: false, completion: nil)
            let storyboard = UIStoryboard(name: "AddNewWord", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: AddEditWordVC.reuseIdentifier) as! AddEditWordVC
            vc.rootController = self
            self.present(vc, animated: true, completion: nil)

        }

        icon = UIImage(named: "layers")
        floatyButton.addItem("Unchecked words", icon: icon) { [weak self] _ in
            self?.resultSearchController.dismiss(animated: false, completion: nil)
            self?.appCoordinator.showSelfAddedWordsScreen()
        }

        floatyButton.addItem("Test mode", icon: UIImage(named: "test")) { [weak self] _ in
            self?.resultSearchController.dismiss(animated: false, completion: nil)
            self?.appCoordinator.showTestingScreen()
        }

        floatyButton.addItem("Detect object", icon: UIImage(named: "objectDetection")) { [weak self] _ in
            self?.resultSearchController.dismiss(animated: false, completion: nil)
            self?.appCoordinator.showDetectObjectScreen()
        }

        view.addSubview(floatyButton)
    }
}

extension DictionaryViewController {
    struct Props {
        let words: [WordModel]
        
        let updateSearchPattern: (String) -> Void
        let deleteWord: (Int) -> Void
        let wordForIndex: (Int) -> Word?
        
        struct WordModel {
            let word: NSAttributedString
            let descriptionText: String
            let imageURL: URL?
        }
    }
}

//
//  SelfAddedWordsViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/11/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
import MessageUI

class SelfAddedWordsViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkButton: UIButton!

    // MARK: Private properties

    private let cell = UINib(nibName: "SelfAddedWordsTableViewCell", bundle: nil)

    private lazy var editActions = [
        UITableViewRowAction(style: .normal, title: "Delete", handler: { [weak self] (_, indexPath) in
            self?.deleteAction(indexPath: indexPath)
        }),
        UITableViewRowAction(style: .normal, title: "Edit", handler: { [weak self] (_, indexPath) in
            self?.editAction(indexPath: indexPath)
        })
    ]

    private lazy var context = CoreDataStack.shared.persistantContainer.viewContext
    private lazy var fetchedResultsController: NSFetchedResultsController<SelfWord> = {
        let fetchRequest: NSFetchRequest<SelfWord> = SelfWord.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "word", ascending: true)]
        let controller = NSFetchedResultsController<SelfWord>(
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

        setUpNavigationBar()
        setUpCheckButton()

        tableView.register(cell, forCellReuseIdentifier: SelfAddedWordsTableViewCell.identfier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWordButtonWasTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonWasTapped))
        navigationBar.items?.append(navigationItem)
        title = "List of self added words"
    }

    // MARK: Setting up check button

    private func setUpCheckButton() {
        checkButton.layer.cornerRadius = 7.0
        checkButton.setTitle("Chech word", for: .normal)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)

    }

    // MARK: Private objective C functions

    @objc private func checkButtonTapped() {
        while fetchedResultsController.fetchedObjects?.count != 0 {
            guard let object = fetchedResultsController.fetchedObjects?.first else { return }
            let newWord = Word(context: context)

            newWord.word = object.word
            newWord.transcription = object.transcription
            newWord.wordDescription = object.wordDescription
            newWord.translationUA = object.translationUA
            newWord.translationRu = object.translationRU
            newWord.pictureURL = object.pictureURL
            newWord.videoURL = object.videoURL

            do {
                context.delete(object)
                try context.save()
            } catch {
                debugPrint(error)
            }
        }
    }

    @objc private func doneButtonWasTapped() {
        let storyboard = UIStoryboard(name: "Dictionary", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Dictionary") as! DictionaryViewController
        self.present(vc, animated: true, completion: nil)
    }

    @objc private func addWordButtonWasTapped() {
        let storyboard = UIStoryboard(name: "AddNewWord", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddWordNavController")
        AddNewWordViewController.sender = .listOfSelfWords
        self.present(vc, animated: true, completion: nil)
    }

    // MARK: delete option

    private func deleteAction(indexPath: IndexPath) {
        guard let object = fetchedResultsController.fetchedObjects?[indexPath.row] else { return }
        context.delete(object)
        do {
            try context.save()
        } catch { debugPrint(error) }
    }

    // MARK: Edit option function

    private func editAction(indexPath: IndexPath) {
        guard let object = fetchedResultsController.fetchedObjects?[indexPath.row] else { return }
        let storyboard = UIStoryboard(name: "AddNewWord", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddWordNavController")
        AddNewWordViewController.sender = .listOfSelfWords
        AddNewWordViewController.passedObject = object
        self.present(vc, animated: true, completion: nil)

    }

}

// MARK: - - FetchedresultsControllerDelegate

extension SelfAddedWordsViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}

// MARK: - - extension table view delegate and datasource

extension SelfAddedWordsViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelfAddedWordsTableViewCell.identfier) as! SelfAddedWordsTableViewCell
        guard let object = fetchedResultsController.fetchedObjects?[indexPath.row] else {
            return cell
        }

        cell.wordLabel.text = object.word
        cell.descriptionLabel.text = object.wordDescription
        let placeholderImage = UIImage(named: "flag")
        guard let stringURL = object.pictureURL else {
            cell.captureImageView.image = placeholderImage
            return cell
        }
        let url = URL(string: stringURL)
        cell.captureImageView.kf.indicatorType = .activity
        cell.captureImageView.kf.setImage(with: url, placeholder: placeholderImage, options: nil, progressBlock: nil) { (result) in
            switch result {
            case .failure(let error):
                debugPrint(error)
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


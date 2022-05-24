//
//  SelfAddedWordsVC.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/11/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import CoreData
import Kingfisher
import Moya

class SelfAddedWordsVC: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkButton: UIButton!

    // MARK: Public properties

    static let identifier = "SelfAddedWords"

    // MARK: Private properties

    private var props: Props?
    private let logicController = SelfAddedWordsLC()
    
    private let cell = UINib(nibName: "SelfAddedWordsTableViewCell", bundle: nil)

    private lazy var editActions = [
        UITableViewRowAction(style: .normal, title: "Delete", handler: { [weak self] (_, indexPath) in
            self?.deleteAction(indexPath: indexPath)
        }),
        UITableViewRowAction(style: .normal, title: "Edit", handler: { [weak self] (_, indexPath) in
            self?.editAction(indexPath: indexPath)
        })
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpNavigationBar()
        setUpCheckButton()

        tableView.register(cell, forCellReuseIdentifier: SelfAddedWordsTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        logicController.updatedProps = { [weak self] in
            self?.render($0)
        }
    }
    
    private func render(_ props: Props) {
        self.props = props
        tableView.reloadData()
    }

    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWordButtonWasTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonWasTapped))
        navigationBar.items?.append(navigationItem)
        title = "List of self added words"
    }

    private func setUpCheckButton() {
        checkButton.layer.cornerRadius = 7.0
        checkButton.setTitle("Check words", for: .normal)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
    }

    @objc private func checkButtonTapped() {
        props?.sendToServer()
    }

    @objc private func doneButtonWasTapped() {
        if props?.words.count == 0 {
            dismiss(animated: true, completion: nil)
            return
        }

        let alert = UIAlertController(title: "Are you sure?", message: "You didn't send words for checking, so we cant check and approve it. This words will not appear in dictionary", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {(_) in
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alert, animated: true, completion: nil)
    }

    @objc private func addWordButtonWasTapped() {
        let storyboard = UIStoryboard(name: "AddNewWord", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddNewWord") as! AddEditWordVC
        self.present(vc, animated: true, completion: nil)
    }

    // MARK: delete option

    private func deleteAction(indexPath: IndexPath) {
        props?.deleteWord(indexPath.row)
    }

    // MARK: Edit option function

    private func editAction(indexPath: IndexPath) {
        guard let object = props?.editWord(indexPath.row) else { return }
        let storyboard = UIStoryboard(name: "AddNewWord", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AddNewWord") as! AddEditWordVC
        vc.passedObject = object
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - - extension table view delegate and datasource

extension SelfAddedWordsVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        props?.words.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelfAddedWordsTableViewCell.identifier) as! SelfAddedWordsTableViewCell
        guard let object = props?.words[indexPath.row] else {
            return cell
        }

        cell.wordLabel.text = object.title
        cell.descriptionLabel.text = object.description

        let placeholderImage = UIImage(named: "flag")
        cell.captureImageView.kf.indicatorType = .activity
        cell.captureImageView.kf.setImage(
            with: object.imageURL,
            placeholder: placeholderImage,
            options: nil,
            progressBlock: nil
        ) { (result) in
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

extension SelfAddedWordsVC {
    struct Props {
        let words: [WordModel]
        
        let deleteWord: (Int) -> Void
        let editWord: (Int) -> Word?
        let sendToServer: () -> Void
        
        struct WordModel {
            let title: String
            let description: String
            let imageURL: URL?
        }
    }
}

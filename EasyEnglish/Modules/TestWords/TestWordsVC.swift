//
//  TestWordsVC.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/24/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import CoreData

class TestWordsVC: UIViewController {

    // MARK: Public properties

    public static let identifier = "TestWords"

    // MARK: private properties

    private let nib = UINib(nibName: "SelfAddedWordsTableViewCell", bundle: nil)
    private let doneButton = UIBarButtonItem(title: "I'm ready!", style: .done, target: self, action: #selector(doneButtonWasTapped))
    
    private var props: Props?
    private let logicController = TestWordsLS()


    // MARK: outlets

    @IBOutlet var navigationBar: UINavigationBar!
    @IBOutlet var tableView: UITableView!

    // MARK: Private functions

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(nib, forCellReuseIdentifier: SelfAddedWordsTableViewCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        setUpNavigationBar()
        
        logicController.updatedProps = { [weak self] in
            self?.render($0)
        }
    }
    
    private func render(_ props: Props) {
        self.props = props
        tableView.reloadData()
        
        if props.shouldDisplayDoneButton {
            navigationItem.rightBarButtonItem = doneButton
            return
        }
        navigationItem.rightBarButtonItem = nil
    }

    ///Customization navigation bar, add two navigation items to the navigationbar
    private func setUpNavigationBar() {
        navigationItem.rightBarButtonItem = nil
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Not this time",
            style: .plain,
            target: self,
            action: #selector(backButtonWasTapped)
        )

        navigationBar.items?.append(navigationItem)
    }

    ///Pass the Set called wordsForTest to ComposeViewController and present that controller
    @objc private func doneButtonWasTapped() {
        let storyBoard = UIStoryboard(name: "ComposeWord", bundle: nil)
        guard let vc = storyBoard
                .instantiateViewController(
                    withIdentifier: ComposeWordViewController.identifier
                ) as? ComposeWordViewController,
              let words = props?.doneButtonTouched() else {
                  return
              }

        vc.fillWordsArray(words: words)
        present(vc, animated: true, completion: nil)
    }

    @objc private func backButtonWasTapped() {
        dismiss(animated: true)
    }
}

// MARK: - Extension tableViewDataSource and tableViewDelegate
extension TestWordsVC: UITableViewDataSource, UITableViewDelegate {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props?.words.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SelfAddedWordsTableViewCell.identifier) as! SelfAddedWordsTableViewCell
        
        cell.selectionStyle = .none
        
        guard let word = props?.words[indexPath.row] else {
            return cell
        }
        let placeholderImage = UIImage(named: "flag")

        cell.wordLabel.isHidden = true
        cell.descriptionLabel.text = word.text
        if word.isSelected {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        guard let url = word.imageURL else {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        props?.didSelectWord(indexPath.row)
    }
}

extension TestWordsVC {
    struct Props {
        let words: [WordModel]
        let shouldDisplayDoneButton: Bool
        
        let doneButtonTouched: () -> [Word]
        let didSelectWord: (Int) -> Void
        
        struct WordModel {
            let text: String
            let imageURL: URL?
            let isSelected: Bool
        }
    }
}

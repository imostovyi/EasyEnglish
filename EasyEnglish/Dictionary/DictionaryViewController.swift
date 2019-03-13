//
//  ViewController.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/5/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import Floaty

class DictionaryViewController: UIViewController {

    @IBOutlet weak var floatyButton: Floaty!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.addSubview(tableView)

        floatyButton.sticky = true
        var icon = UIImage(named: "plus")
        floatyButton.addItem("Add word", icon: icon) { (_) in
            let storyboard = UIStoryboard(name: "AddNewWord", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "AddWordNavController")
            AddNewWordViewController.sender = .dictionary
            self.present(vc, animated: true, completion: nil)
        }
        icon = UIImage(named: "layers")
        floatyButton.addItem("Self added words", icon: icon) { (_) in
            let storyboard = UIStoryboard(name: "SelfAddedWords", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "SelfAddedWords") as! SelfAddedWordsViewController
            self.present(vc, animated: true, completion: nil)
        }

        view.addSubview(floatyButton)
    }

}

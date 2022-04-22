//
//  SelfAddedWordsTableViewCell.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/11/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit

class SelfAddedWordsTableViewCell: UITableViewCell {

    @IBOutlet var captureImageView: UIImageView!
    @IBOutlet weak var wordLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    static let identifier = "SelfAddedWordCell"

    override func awakeFromNib() {
        super.awakeFromNib()

        self.layer.cornerRadius = 7
        self.layer.masksToBounds = true

        captureImageView.layer.cornerRadius = 20
        let image = UIImage(named: "flag")
        captureImageView.image = image
    }

}

//
//  TestWordCell.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/24/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit

class TestWordCell: UITableViewCell {

    // MARK: outlets

    @IBOutlet private weak var pictureView: UIImageView!
    @IBOutlet private weak var wordLabel: UILabel!

    // MARK: public properties

    public static let identifier = "TestWordCell"

    override func awakeFromNib() {
        super.awakeFromNib()
        pictureView.layer.cornerRadius = 10
        wordLabel.textColor = UIColor(named: "Text")
        self.layer.cornerRadius = 8
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Public function

    ///init for outlet's properties
    public func initProperties(word: Word) {
        wordLabel.text = word.word

        pictureView.kf.indicatorType = .activity
        pictureView.kf.setImage(with: word.pictureURL,
                                placeholder: UIImage(named: "flag"),
                                options: nil,
                                progressBlock: nil) { (result) in
                                    switch result {
                                    case .success: return
                                    default: self.pictureView.image = UIImage(named: "flag")
                                    }
        }

    }

}

//
//  CollectionViewCell.swift
//  EasyEnglish
//
//  Created on 3/26/19.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet private var letterLabel: UILabel!

    public func initLabel(letter: String) {
        letterLabel.text = letter

        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
    }
}

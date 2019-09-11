//
//  BounceButton.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/12/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import Foundation
import UIKit

class BounceButton: UIButton {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 6,
                       options: .allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform.identity
        },
                       completion: nil)
        super.touchesBegan(touches, with: event)
    }

    func performCustomLayer() {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1
    }
}

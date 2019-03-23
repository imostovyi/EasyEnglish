//
//  PlayerView.swift
//  EasyEnglish
//
//  Created by Мостовий Ігор on 3/23/19.
//  Copyright © 2019 Мостовий Ігор. All rights reserved.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    func setUp(url: URL) {
        let temp = URL(string: "https://www.youtube.com/watch?v=dz5IIzIeBa0")!
        let player = AVPlayer(url: temp)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.bounds
        self.layer.addSublayer(playerLayer)

        self.backgroundColor = UIColor.red

        player.play()
    }
}

//
//  TitleScene.swift
//  AvoidCollect
//
//  Created by Eric Internicola on 2/20/16.
//  Copyright © 2016 Eric Internicola. All rights reserved.
//

import UIKit
import SpriteKit

class TitleScene: SKScene {
    
    var btnPlay: UIButton?
    var gameTitle: SKLabelNode?
    
    let hudTextColor = UIColor.white
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.black
        
        setupText()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    // MARK: - Helper Methods
    
    func setupText() {
        gameTitle = SKLabelNode(fontNamed: "Courier")
        if let gameTitle = gameTitle {
            gameTitle.fontSize = 40
            gameTitle.fontColor = hudTextColor
            gameTitle.position = CGPoint(x: frame.midX, y: frame.midY)
            gameTitle.text = "Square Pop"
            
            addChild(gameTitle)
        }
        
        if let view = view {
            btnPlay = UIButton(frame: CGRect(x: 0, y: 100, width: view.frame.size.width, height: 100))
            if let btnPlay = btnPlay {
                btnPlay.center = CGPoint(x: view.frame.width/2, y: view.frame.height - 100)
                btnPlay.titleLabel?.font = UIFont(name: "Courier", size: 100)
                btnPlay.setTitle("Play", for: UIControlState())
                btnPlay.setTitleColor(hudTextColor, for: UIControlState())
                btnPlay.addTarget(self, action: #selector(TitleScene.playTheGame), for: .touchUpInside)
                view.addSubview(btnPlay)
            }
        }
    }
    
    func playTheGame() {
        if let view = view, let btnPlay = btnPlay, let gameScene = GameScene(fileNamed: "GameScene") {
            gameScene.scaleMode = .aspectFill
            btnPlay.removeFromSuperview()
            view.presentScene(gameScene, transition: SKTransition.fade(withDuration: 1))
            view.ignoresSiblingOrder = true
        }
    }
}

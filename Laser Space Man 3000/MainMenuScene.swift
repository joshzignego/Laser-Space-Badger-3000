//
//  MainMenuScene.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 8/1/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    var playButton = SKSpriteNode()
    let playButtonText = SKTexture(imageNamed: "PlayButton")
    
    override func didMove(to view: SKView) {
        
        playButton = SKSpriteNode(texture: playButtonText)
        playButton.position = CGPoint(x: frame.midX, y: frame.midY)
        let width: Double = Double(size.width) * 0.25
        let height: Double = Double(size.height) * 0.25
        playButton.scale(to: CGSize(width: width, height: height))
        self.addChild(playButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playButton {
                if let view = view {
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let scene:SKScene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
        }
    }
}

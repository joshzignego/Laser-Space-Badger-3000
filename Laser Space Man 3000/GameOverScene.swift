//
//  GameOverScene.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 8/1/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    var playAgainButton = SKSpriteNode()
    let playAgainButtonText = SKTexture(imageNamed: "PlayAgainButton")
    var mainMenuButton = SKSpriteNode()
    let mainMenuButtonText = SKTexture(imageNamed: "MainMenuButton")
    
    override init(size: CGSize) {
        
        super.init(size: size)
        
        // 1
        backgroundColor = SKColor.white
        
        // 2
        let message = "Game Over"
        
        // 3
        let label = SKLabelNode(fontNamed: "Helvetica-Bold")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPoint(x: size.width/2, y: size.height/2)
        addChild(label)
        
        /*
        run(SKAction.sequence([
            SKAction.wait(forDuration: 3.0),
            SKAction.run() {
                // 5
                let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
                let scene = GameScene(size: size)
                self.view?.presentScene(scene, transition:reveal)
            }
            ]))
        */
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        
        playAgainButton = SKSpriteNode(texture: playAgainButtonText)
        playAgainButton.position = CGPoint(x: size.width/2, y: size.height*0.75)
        let width: Double = Double(size.width) * 0.25
        let height: Double = Double(size.height) * 0.25
        playAgainButton.scale(to: CGSize(width: width, height: height))
        self.addChild(playAgainButton)
        
        mainMenuButton = SKSpriteNode(texture: mainMenuButtonText)
        mainMenuButton.position = CGPoint(x: size.width/2, y: size.height*0.25)
        mainMenuButton.scale(to: CGSize(width: width, height: height))
        self.addChild(mainMenuButton)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playAgainButton {
                if let view = view {
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let scene:SKScene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
            else if node == mainMenuButton {
                if let view = view {
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let scene:SKScene = MainMenuScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
            
            
        }
    }
    
}













    


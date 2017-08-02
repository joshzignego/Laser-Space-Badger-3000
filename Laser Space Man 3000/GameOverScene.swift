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
    
    var playAgainButton = SKShapeNode()
    var mainMenuButton = SKShapeNode()
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    // 6
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        
        let path = CGRect.init(x: Double(size.width/4), y: Double(size.height*33/100), width: Double(size.width/2), height: Double(size.height/4))
        playAgainButton = SKShapeNode.init(rect: path, cornerRadius: 10)
        playAgainButton.strokeColor = UIColor.black
        self.addChild(playAgainButton)

        let path2 = CGRect.init(x: Double(size.width/4), y: Double(size.height*5/100), width: Double(size.width/2), height: Double(size.height/4))
        mainMenuButton = SKShapeNode.init(rect: path2, cornerRadius: 10)
        mainMenuButton.strokeColor = UIColor.black
        self.addChild(mainMenuButton)
        
        let message = "Game Over"
        let label = SKLabelNode(fontNamed: "Fipps-Regular")
        label.text = message
        label.fontSize = 60
        label.fontColor = SKColor.red
        label.position = CGPoint(x: size.width/2, y: size.height*66/100)
        self.addChild(label)
        
        let message2 = "Play Again"
        let label2 = SKLabelNode(fontNamed: "Fipps-Regular")
        label2.text = message2
        label2.fontSize = 40
        label2.fontColor = SKColor.blue
        label2.position = CGPoint(x: size.width/2, y: size.height*41/100)
        self.addChild(label2)
        
        let message3 = "Main Menu"
        let label3 = SKLabelNode(fontNamed: "Fipps-Regular")
        label3.text = message3
        label3.fontSize = 40
        label3.fontColor = SKColor.blue
        label3.position = CGPoint(x: size.width/2, y: size.height*12/100)
        self.addChild(label3)
        
        
        
      /*  playAgainButton = SKSpriteNode(texture: playAgainButtonText)
        playAgainButton.position = CGPoint(x: size.width/2, y: size.height*0.75)
        let width: Double = Double(size.width) * 0.25
        let height: Double = Double(size.height) * 0.25
        playAgainButton.scale(to: CGSize(width: width, height: height))
        self.addChild(playAgainButton)
        
        mainMenuButton = SKSpriteNode(texture: mainMenuButtonText)
        mainMenuButton.position = CGPoint(x: size.width/2, y: size.height*0.25)
        mainMenuButton.scale(to: CGSize(width: width, height: height))
        self.addChild(mainMenuButton)*/
        
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

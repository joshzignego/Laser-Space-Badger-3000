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
    
    //var playButton = SKSpriteNode()
    var playButtonDoneAsAShape = SKShapeNode()
    //let playButtonText = SKTexture(imageNamed: "PlayButton")
    
    override func didMove(to view: SKView) {
        
        //playButton = SKSpriteNode(texture: playButtonText)
        backgroundColor = SKColor.white
        
        // Try as a shape
        let path = CGRect.init(x: Double(size.width/4), y: Double(size.height*1/4), width: Double(size.width/2), height: Double(size.height/4))
        playButtonDoneAsAShape = SKShapeNode.init(rect: path, cornerRadius: 10)
        playButtonDoneAsAShape.strokeColor = UIColor.black
        self.addChild(playButtonDoneAsAShape)
        
        let message = "Play"
        let label = SKLabelNode(fontNamed: "Fipps-Regular")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blue
        label.position = CGPoint(x: size.width/2, y: size.height*32/100)
        self.addChild(label)
        
        let titleMessage = "Laser Space Man 3000"
        let title = SKLabelNode(fontNamed: "Fipps-Regular")
        title.text = titleMessage
        title.fontSize = 40
        title.fontColor = SKColor.blue
        title.position = CGPoint(x: size.width/2, y: size.height*66/100)
        self.addChild(title)
        
        
        //playButtonDoneAsAShape.position = CGPoint(x: frame.midX, y: frame.midY)
        //let width: Double = Double(size.width) * 0.25
        //let height: Double = Double(size.height) * 0.25
        //playButtonDoneAsAShape.scale(to: CGSize(width: width, height: height))
        //self.addChild(playButtonDoneAsAShape)
        
        /*playButton.position = CGPoint(x: frame.midX, y: frame.midY)
        let width: Double = Double(size.width) * 0.25
        let height: Double = Double(size.height) * 0.25
        playButton.scale(to: CGSize(width: width, height: height))
        self.addChild(playButton)*/
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playButtonDoneAsAShape {
                if let view = view {
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let scene:SKScene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
        }
    }
}

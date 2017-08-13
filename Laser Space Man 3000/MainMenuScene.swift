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
    
    var hsButton = SKShapeNode()
    var playButtonDoneAsAShape = SKShapeNode()
    //let playButtonText = SKTexture(imageNamed: "PlayButton")
    
    override func didMove(to view: SKView) {
        
        //playButton = SKSpriteNode(texture: playButtonText)
        backgroundColor = SKColor.white
        
        let message = "Play"
        let label = SKLabelNode(fontNamed: "Fipps-Regular")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blue
        addChild(label)
        
        let message2 = "High Scores"
        let label2 = SKLabelNode(fontNamed: "Fipps-Regular")
        label2.text = message2
        label2.fontSize = 40
        label2.fontColor = SKColor.blue
        addChild(label2)
        
        // Try as a shape
        let path = CGRect.init(x: Double(size.width/4), y: Double(size.height*1/4), width: Double(size.width/2), height: Double(size.height/4))
        playButtonDoneAsAShape = SKShapeNode.init(rect: path, cornerRadius: 10)
        playButtonDoneAsAShape.strokeColor = UIColor.black
        addChild(playButtonDoneAsAShape)
        
        let path2 = CGRect.init(x: Double(size.width/4), y: Double(1), width: Double(size.width/2), height: Double(size.height/4))
        hsButton = SKShapeNode.init(rect: path2, cornerRadius: 10)
        hsButton.strokeColor = UIColor.black
        addChild(hsButton)
        
        let titleMessage = "Laser Space Man 3000"
        let title = SKLabelNode(fontNamed: "Fipps-Regular")
        title.text = titleMessage
        title.fontSize = 40
        title.fontColor = SKColor.blue
        addChild(title)
        
        
        adjustLabelFontSizeToFitRect(labelNode: label, rect: path)
        adjustLabelFontSizeToFitRect(labelNode: label2, rect: path2)
        adjustLabelFontSizeToFitRect(labelNode: title, rect: CGRect.init(x: Double(size.width/10), y: Double(size.height*2/3), width: Double(size.width*8/10), height: Double(size.height/4)))
    }
    
    func adjustLabelFontSizeToFitRect(labelNode: SKLabelNode, rect:CGRect) {
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / labelNode.frame.width, rect.height / labelNode.frame.height)
        
        // Change the fontSize.
        labelNode.fontSize *= scalingFactor
        
        // Optionally move the SKLabelNode to the center of the rectangle.
        labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
            if node == playButtonDoneAsAShape {
                if view != nil {
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let scene:SKScene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
            else if node == hsButton {
                if view != nil {
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let scene:SKScene = HighScores(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
        }
    }
}

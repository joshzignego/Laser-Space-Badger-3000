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
        //backgroundColor = SKColor.purple
        
        
        let sky = SKSpriteNode(imageNamed: "Sky")
        sky.position = CGPoint(x: size.width/2, y: size.height/2)
        sky.scale(to: CGSize(width: size.width, height: size.height))
        sky.zPosition = -2
        addChild(sky)
        
        let texture = SKTexture(imageNamed: "Macarena 1")
        let badger = SKSpriteNode(texture: texture)
        badger.position = CGPoint(x: size.width * 0.15, y: size.height*0.30)
        badger.scale(to: CGSize(width: size.width*0.25, height: size.height*0.35))
        badger.zPosition = 0
        addChild(badger)
        let textureAtlas = SKTextureAtlas(named: "Badger")
        let frames = ["Macarena 1", "Macarena 2", "Macarena 3", "Macarena 4", "Macarena 5", "Macarena 6", "Macarena 7", "Macarena 8", "Macarena 9", "Macarena 10", "Macarena 11", "Macarena 12", "Macarena 13", "Macarena 14", "Macarena 15", "Macarena 16"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.4)
        badger.run(SKAction.repeatForever(SKAction.sequence([animate, SKAction.run({badger.texture = texture}), SKAction.wait(forDuration: 4)])))
        
        
        
        
        
        
        
        
        let message = "Play"
        let label = SKLabelNode(fontNamed: "Fipps-Regular")
        label.text = message
        label.fontSize = 40
        label.zPosition = 1
        label.fontColor = SKColor.blue
        addChild(label)
        
        let message2 = "High Scores"
        let label2 = SKLabelNode(fontNamed: "Fipps-Regular")
        label2.text = message2
        label2.fontSize = 40
        label2.zPosition = 1
        label2.fontColor = SKColor.blue
        addChild(label2)
        
        // Try as a shape
        let path = CGRect.init(x: Double(size.width/4), y: Double(size.height*1/4), width: Double(size.width/2), height: Double(size.height/4))
        playButtonDoneAsAShape = SKShapeNode.init(rect: path, cornerRadius: 10)
        playButtonDoneAsAShape.strokeColor = UIColor.clear
        playButtonDoneAsAShape.zPosition = 2
        addChild(playButtonDoneAsAShape)
        
        let path2 = CGRect.init(x: Double(size.width/4), y: Double(1), width: Double(size.width/2), height: Double(size.height/4))
        hsButton = SKShapeNode.init(rect: path2, cornerRadius: 10)
        hsButton.strokeColor = UIColor.clear
        hsButton.zPosition = 2
        addChild(hsButton)
        
        let titleMessage = "Laser Space Badger 3000"
        let title = SKLabelNode(fontNamed: "Avenir-Black")
        title.text = titleMessage
        title.fontSize = 80
        title.zPosition = 1
        title.fontColor = SKColor.blue
        addChild(title)
        
        
        adjustLabelFontSizeToFitRect(labelNode: label, rect: path)
        adjustLabelFontSizeToFitRect(labelNode: label2, rect: path2)
        adjustLabelFontSizeToFitRect(labelNode: title, rect: CGRect.init(x: Double(size.width/10), y: Double(size.height*2/3), width: Double(size.width*8/10), height: Double(size.height/4)))
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addStar), SKAction.wait(forDuration: 1)  ])))
    }
    
    func addStar() {
        let starY : CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * size.height
        let starX : CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * size.width
        let rectangle = CGRect.init(x: 0, y: 0, width: size.width*0.05, height: size.height*0.02)
        let star = SKShapeNode.init(rect: rectangle)
        star.position = CGPoint(x: starX, y: starY)
        star.strokeColor = SKColor.black
        star.fillColor = SKColor.yellow
        star.zPosition = -1
        addChild(star)
        let move = SKAction.moveTo(x: starX + size.width*0.33, duration: TimeInterval(2))
        let moveDone = SKAction.removeFromParent()
            
        star.run(SKAction.sequence([move, moveDone]))
        
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

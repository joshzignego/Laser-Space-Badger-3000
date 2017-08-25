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
        
        //Add background
        let sky = SKSpriteNode(imageNamed: "Sky")
        sky.position = CGPoint(x: size.width/2, y: size.height/2)
        sky.scale(to: CGSize(width: size.width, height: size.height))
        sky.zPosition = -2
        addChild(sky)
        
        //Add dancing Badger
        let texture = SKTexture(imageNamed: "Macarena 1")
        let badger = SKSpriteNode(texture: texture)
        badger.position = CGPoint(x: size.width * 0.18, y: size.height*0.40)
        badger.scale(to: CGSize(width: size.width*0.25, height: size.height*0.35))
        badger.zPosition = 0
        addChild(badger)
        let textureAtlas = SKTextureAtlas(named: "Badger")
        let frames = ["Macarena 1", "Macarena 2", "Macarena 3", "Macarena 4", "Macarena 5", "Macarena 6", "Macarena 7", "Macarena 8", "Macarena 9", "Macarena 10", "Macarena 11", "Macarena 12", "Macarena 13", "Macarena 14", "Macarena 15", "Macarena 16"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.4)
        badger.run(SKAction.repeatForever(SKAction.sequence([animate, SKAction.run({badger.texture = texture}), SKAction.wait(forDuration: 4)])))
        
        //Add buttons
        let path = CGRect.init(x: size.width*0.25, y: size.height*0.27, width: size.width*0.60, height: size.height*0.48)
        playButtonDoneAsAShape = SKShapeNode.init(rect: path)
        playButtonDoneAsAShape.position.x += size.width * 0.10
        playButtonDoneAsAShape.strokeColor = UIColor.clear
        playButtonDoneAsAShape.zPosition = 2
        addChild(playButtonDoneAsAShape)
        
        let path2 = CGRect.init(x: size.width/4, y: 1, width: size.width*0.60, height: size.height/4)
        hsButton = SKShapeNode.init(rect: path2)
        hsButton.strokeColor = UIColor.clear
        hsButton.position.x += size.width * 0.10
        hsButton.zPosition = 2
        addChild(hsButton)
        
        let label = createMessage(point: CGPoint(x: size.width/2, y: size.height*5/100), message: "Play", size: 40, color: SKColor.blue)
        let label2 = createMessage(point: CGPoint(x: size.width/2, y: size.height*5/100), message: "High Scores", size: 40, color: SKColor.blue)
        let title = createMessage(point: CGPoint(x: size.width/2, y: size.height*5/100), message: "Laser Space Badger", size: 80, color: SKColor.blue)
        let title3000 = createMessage(point: CGPoint(x: size.width/2, y: size.height*5/100), message: "3000", size: 200, color: SKColor.red)
        title3000.fontName = "Alisandra-Demo"


        //Adjust labels
        adjustLabelFontSizeToFitRect(labelNode: label, rect: path)
        label.position.y += size.height*0.08
        label.position.x += size.width * 0.10
        adjustLabelFontSizeToFitRect(labelNode: label2, rect: path2)
        label2.position.y += size.height*0.02
        label2.position.x += size.width * 0.12
        adjustLabelFontSizeToFitRect(labelNode: title, rect: CGRect.init(x: size.width*0.03, y: size.height*2/3, width: size.width*0.68, height: size.height*0.35))
        adjustLabelFontSizeToFitRect(labelNode: title3000, rect: CGRect.init(x: size.width*0.70, y: size.height*0.70, width: size.width*0.28, height: size.height*0.30))
        
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addStar), SKAction.wait(forDuration: 1)  ])))
    }
    
    func createMessage(point: CGPoint, message: String, size: CGFloat, color: SKColor)->SKLabelNode {
        let label = SKLabelNode(fontNamed: "Fipps-Regular")
        label.text = message
        label.fontSize = size
        label.fontColor = color
        label.position = point
        label.zPosition = 1
        self.addChild(label)
        
        return label
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

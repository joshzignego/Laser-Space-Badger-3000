//
//  HighScores.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 8/3/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import Foundation
import SpriteKit

class HighScores: SKScene {
    
    var mainMenuButton = SKShapeNode()
    
    override func didMove(to view: SKView) {
        //Add background
        let sky = SKSpriteNode(imageNamed: "Sky")
        sky.position = CGPoint(x: size.width/2, y: size.height/2)
        sky.scale(to: CGSize(width: size.width, height: size.height))
        sky.zPosition = -2
        addChild(sky)
        
        //Add dancing Badger
        let texture = SKTexture(imageNamed: "Maraca 1")
        let badger = SKSpriteNode(texture: texture)
        badger.position = CGPoint(x: size.width * 0.15, y: size.height*0.50)
        badger.scale(to: CGSize(width: size.width*0.25, height: size.height*0.35))
        badger.zPosition = 0
        addChild(badger)
        let textureAtlas = SKTextureAtlas(named: "Badger")
        let frames = ["Maraca 1", "Maraca 2", "Maraca 3", "Maraca 4", "Maraca 5", "Maraca 6", "Maraca 7", "Maraca 8", "Maraca 9", "Maraca 10", "Maraca 11", "Maraca 12", "Maraca 13"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.3)
        badger.run(SKAction.repeatForever(SKAction.sequence([animate, SKAction.run({badger.texture = texture}), SKAction.wait(forDuration: 3)])))
        
        
        //Print high scores
        let userDefaults = UserDefaults.standard
        let array = userDefaults.array(forKey: "highscores")  as? [Int] ?? [Int]()
        var height : CGFloat = size.height*72/100
        for item in array {
            createMessage(point: CGPoint(x: size.width/2, y: height), message: String(item), size: 13, color: SKColor.yellow)
            height -= size.height * 0.052
        }
        
        //Print total score
        let totalScore : Int = userDefaults.integer(forKey: "totalscore")
        createMessage(point: CGPoint(x: size.width*0.75, y: size.height*0.40), message: String(totalScore), size: 23, color: SKColor.yellow)

        createMessage(point: CGPoint(x: size.width/2, y: size.height*80/100), message: "High Scores", size: 50, color: SKColor.blue)
        createMessage(point: CGPoint(x: size.width/2, y: size.height*5/100), message: "Main Menu", size: 40, color: SKColor.blue)
        createMessage(point: CGPoint(x: size.width*0.75, y: size.height*50/100), message: "Total Score", size: 23, color: SKColor.yellow)
        
        let path = CGRect.init(x: size.width*0.20, y: 0, width: size.width*0.60, height: size.height*0.25)
        mainMenuButton = SKShapeNode.init(rect: path)
        mainMenuButton.strokeColor = UIColor.clear
        mainMenuButton.zPosition = 1
        self.addChild(mainMenuButton)
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addStar), SKAction.wait(forDuration: 1)  ])))
    }
    
    func createMessage(point: CGPoint, message: String, size: CGFloat, color: SKColor) {
        let label = SKLabelNode(fontNamed: "Fipps-Regular")
        label.text = message
        label.fontSize = size
        label.fontColor = color
        label.position = point
        label.zPosition = 0
        self.addChild(label)
    }
    
    func addStar() {
        let starY : CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * size.height
        let starX : CGFloat = CGFloat(Float(arc4random()) / Float(UINT32_MAX)) * size.width
        
        // Create star at random position
        let rectangle = CGRect.init(x: 0, y: 0, width: size.width*0.05, height: size.height*0.02)
        let star = SKShapeNode.init(rect: rectangle)
        star.position = CGPoint(x: starX, y: starY)
        star.strokeColor = SKColor.black
        star.fillColor = SKColor.yellow
        star.zPosition = -1
        
        addChild(star)
        
        // Create action sequence
        let move = SKAction.moveTo(x: starX + size.width*0.33, duration: TimeInterval(2))
        let moveDone = SKAction.removeFromParent()
        star.run(SKAction.sequence([move, moveDone]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let pos = touch.location(in: self)
            let node = self.atPoint(pos)
            
         if node == mainMenuButton {
                if view != nil {
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let scene:SKScene = MainMenuScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
        }
    }
}

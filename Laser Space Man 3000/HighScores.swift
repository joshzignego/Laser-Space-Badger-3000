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
    
    //var playAgainButton = SKShapeNode()
    var mainMenuButton = SKShapeNode()
 //   var score = Score(score: 0)
    //var highScores : Int = []
    
    override func didMove(to view: SKView) {
        let sky = SKSpriteNode(imageNamed: "Sky")
        sky.position = CGPoint(x: size.width/2, y: size.height/2)
        sky.scale(to: CGSize(width: size.width, height: size.height))
        sky.zPosition = -2
        addChild(sky)
        
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
        
        let message = "High Scores"
        let hsLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        hsLabel.text = message
        hsLabel.fontSize = 50
        hsLabel.fontColor = SKColor.blue
        hsLabel.position = CGPoint(x: size.width/2, y: size.height*80/100)
        self.addChild(hsLabel)
        
        let userDefaults = UserDefaults.standard
        let array = userDefaults.array(forKey: "highscores")  as? [Int] ?? [Int]()
        var height : CGFloat = size.height*72/100
        for item in array {
            //print("printing label")
            let message2 = String(item)
            let label = SKLabelNode(fontNamed: "Fipps-Regular")
            label.text = message2
            label.fontSize = 13
            label.fontColor = SKColor.yellow
            label.position = CGPoint(x: size.width/2, y: height)
            self.addChild(label)
            height -= size.height * 0.052
        }
     
        let messageTotal = String("Total Score")
        let label = SKLabelNode(fontNamed: "Fipps-Regular")
        label.text = messageTotal
        label.fontSize = 23
        label.fontColor = SKColor.yellow
        label.position = CGPoint(x: size.width*0.75, y: size.height*0.50)
        self.addChild(label)
        
        let totalScore : Int = userDefaults.integer(forKey: "totalscore")
        let messageTotalScore = String(totalScore)
        let label2 = SKLabelNode(fontNamed: "Fipps-Regular")
        label2.text = messageTotalScore
        label2.fontSize = 23
        label2.fontColor = SKColor.yellow
        label2.position = CGPoint(x: size.width*0.75, y: size.height*0.40)
        self.addChild(label2)
        
   
        
        let message3 = "Main Menu"
        let label3 = SKLabelNode(fontNamed: "Fipps-Regular")
        label3.text = message3
        label3.fontSize = 40
        label3.zPosition = 0
        label3.fontColor = SKColor.blue
        label3.position = CGPoint(x: size.width/2, y: size.height*5/100)
        self.addChild(label3)
        
        
        let path = CGRect.init(x: size.width*0.20, y: 0, width: size.width*0.60, height: size.height*0.25)
        mainMenuButton = SKShapeNode.init(rect: path)
        mainMenuButton.strokeColor = UIColor.clear
        mainMenuButton.zPosition = 1
        self.addChild(mainMenuButton)
        
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

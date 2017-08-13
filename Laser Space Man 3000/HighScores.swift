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
        backgroundColor = SKColor.white
        
        let message = "High Scores"
        let hsLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        hsLabel.text = message
        hsLabel.fontSize = 50
        hsLabel.fontColor = SKColor.blue
        hsLabel.position = CGPoint(x: size.width/2, y: size.height*80/100)
        self.addChild(hsLabel)
        
        let userDefaults = UserDefaults.standard
        let array = userDefaults.array(forKey: "highscores")  as? [Int] ?? [Int]()
        var height : CGFloat = size.height*75/100
        for item in array {
            //print("printing label")
            let message2 = String(item)
            let label = SKLabelNode(fontNamed: "Fipps-Regular")
            label.text = message2
            label.fontSize = 10
            label.fontColor = SKColor.red
            label.position = CGPoint(x: size.width/2, y: height)
            self.addChild(label)
            height -= size.height * 0.05
        }
     
        var messageTotal = String("Total Score: ")
        let totalScore : Int = userDefaults.integer(forKey: "totalscore")
        messageTotal = messageTotal! + String(totalScore) 
        let label = SKLabelNode(fontNamed: "Fipps-Regular")
        label.text = messageTotal
        label.fontSize = 10
        label.fontColor = SKColor.red
        label.position = CGPoint(x: size.width/3, y: size.height*75/100)
        self.addChild(label)
        
   
        
        let message3 = "Main Menu"
        let label3 = SKLabelNode(fontNamed: "Fipps-Regular")
        label3.text = message3
        label3.fontSize = 40
        label3.fontColor = SKColor.blue
        label3.position = CGPoint(x: size.width/2, y: size.height*12/100)
        self.addChild(label3)
        
        
        let path = CGRect.init(x: Double(size.width/4), y: Double(size.height*5/100), width: Double(size.width/2), height: Double(size.height/4))
        mainMenuButton = SKShapeNode.init(rect: path, cornerRadius: 10)
        mainMenuButton.strokeColor = UIColor.black
        self.addChild(mainMenuButton)
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

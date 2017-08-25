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
    var score : Int = 0
    
    init(size: CGSize, score: Int) {
        super.init(size: size)
        self.score = score
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        //Add background
        let sky = SKSpriteNode(imageNamed: "Sky")
        sky.position = CGPoint(x: size.width/2, y: size.height/2)
        sky.scale(to: CGSize(width: size.width, height: size.height))
        sky.zPosition = -2
        addChild(sky)
        
        //Add coffin Badger
        let texture = SKTexture(imageNamed: "Coffin-1")
        let badger = SKSpriteNode(texture: texture)
        badger.position = CGPoint(x: size.width * 0.11, y: size.height*0.35)
        badger.scale(to: CGSize(width: size.width*0.22, height: size.height*0.22))
        badger.zPosition = 0
        addChild(badger)
        let textureAtlas = SKTextureAtlas(named: "Badger")
        let frames = ["Coffin-1", "Coffin-2", "Coffin-3", "Coffin-4", "Coffin-5", "Coffin-6", "Coffin-7", "Coffin-8", "Coffin-9", "Coffin-10", "Coffin-11", "Coffin-12", "Coffin-13", "Coffin-14", "Coffin-15", "Coffin-16", "Coffin-17", "Coffin-18", "Coffin-19"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.4)
        badger.run(SKAction.repeatForever(SKAction.sequence([animate, SKAction.run({badger.texture = texture}), SKAction.wait(forDuration: 4)])))
        
        //Spider motion
        let texture2 = SKTexture(imageNamed: "Spider RESIZE-1")
        let spider = SKSpriteNode(texture: texture2)
        spider.position = CGPoint(x: size.width+size.width*0.075, y: size.height*0.35)
        spider.scale(to: CGSize(width: size.width*0.15, height: size.height*0.22))
        spider.zPosition = 0
        addChild(spider)
        let moveOut = SKAction.moveTo(x: size.width*0.90, duration: TimeInterval(2))
        let moveBack = SKAction.moveTo(x: size.width+size.width*0.075, duration: TimeInterval(2))
        spider.run(SKAction.repeatForever(SKAction.sequence([moveOut, SKAction.wait(forDuration: 3.6), moveBack, SKAction.wait(forDuration: 4)])))

        let defaults = UserDefaults.standard
        var array = defaults.object(forKey: "highscores") as? [Int] ?? [Int]()
        var flag : Bool = true
        var added : Bool = false
        let arraySize = array.count
        var index : Int = 0
        
        //Update total score
        var totalScore = defaults.integer(forKey: "totalscore")
        totalScore += score
        defaults.set(totalScore, forKey: "totalscore")
        
        //Add first score
        if arraySize == 0 {
            array.insert(score, at: 0)
        }
        //Add to highscores if applicable
        else {
            while flag {
                if index >= arraySize {
                    flag = false
                }
                else {
                    if score > array[index] {
                        array.insert(score, at: index)
                        //print("TOP score of ", score, " added at index ", index)

                    
                        //Don't let array get bigger than 10 elements
                        if (arraySize >= 10) {
                            array.remove(at: 10)
                        }
                        added = true
                        flag = false
                    }
                }
                index += 1
            }
            index-=1
            if index < 10  && !added{
                array.insert(score, at: (index))
                //print("BOTTOM score of ", score, " added at index ", index)
            }
        }
        defaults.set(array, forKey: "highscores")
        
        var scoreMessage = "Score: "
        scoreMessage.append(String(score))
        createMessage(point: CGPoint(x: size.width*0.50, y: size.height*58/100), message: scoreMessage, size: 40, color: SKColor.yellow)
        createMessage(point: CGPoint(x: size.width*0.50, y: size.height*75/100), message: "Game Over", size: 60, color: SKColor.red)
        createMessage(point: CGPoint(x: size.width*0.50, y: size.height*10/100), message: "Main Menu", size: 40, color: SKColor.blue)
        createMessage(point: CGPoint(x: size.width*0.50, y: size.height*38/100), message: "Play Again", size: 40, color: SKColor.blue)
        
        let path = CGRect.init(x: size.width*0.22, y: size.height*31/100, width: size.width*0.56, height: size.height/4)
        playAgainButton = SKShapeNode.init(rect: path)
        playAgainButton.zPosition = 5
        playAgainButton.strokeColor = UIColor.clear
        self.addChild(playAgainButton)

        let path2 = CGRect.init(x: size.width*0.322, y: size.height*3/100, width: size.width*0.56, height: size.height/4)
        mainMenuButton = SKShapeNode.init(rect: path2)
        mainMenuButton.zPosition = 5
        mainMenuButton.strokeColor = UIColor.clear
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
            
            if node == playAgainButton {
                if view != nil {
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let scene:SKScene = GameScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
            else if node == mainMenuButton {
                if view != nil {
                    let transition:SKTransition = SKTransition.fade(withDuration: 1)
                    let scene:SKScene = MainMenuScene(size: self.size)
                    self.view?.presentScene(scene, transition: transition)
                }
            }
        }
    }
}

//
//  ButtonManager.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 8/13/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import Foundation
import SpriteKit

class ButtonManager {
    
    func makePauseButton(gameScene: GameScene)->Button {
        let path = CGRect.init(x: gameScene.size.width*1/100, y: gameScene.size.height*35/1000, width: gameScene.size.width*14/100, height: gameScene.size.height*7/100)
        let pauseButton = Button.init(rect: path, cornerRadius: 5)
        pauseButton.strokeColor = UIColor.black
        pauseButton.fillColor = UIColor.white
        pauseButton.zPosition = 100
        pauseButton.createLabel(message: "Pause", fontSize: 10, color: SKColor.blue, position: CGPoint(x: gameScene.size.width*8/100, y: gameScene.size.height*5/100), zPosition: 150)
        adjustLabelFontSizeToFitRect(labelNode: pauseButton.label, rect: path)
        pauseButton.label.position.y += gameScene.size.height*5/1000
        gameScene.addChild(pauseButton)
        
        return pauseButton
    }
    
    func makeEnemiesCanStillTakeHitsFromLabel(gameScene: GameScene)->SKLabelNode {
        let enemiesCanStillTakeHitsFromLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        enemiesCanStillTakeHitsFromLabel.text = String(gameScene.enemiesPassedToDie)
        enemiesCanStillTakeHitsFromLabel.fontSize = 25
        enemiesCanStillTakeHitsFromLabel.fontColor = SKColor.red
        enemiesCanStillTakeHitsFromLabel.position = CGPoint(x: gameScene.size.width*16/100, y: gameScene.size.height*88/100)
        enemiesCanStillTakeHitsFromLabel.zPosition = 100
        gameScene.addChild(enemiesCanStillTakeHitsFromLabel)
        
        return enemiesCanStillTakeHitsFromLabel
    }
    
    func makeEnemiesIcon(gameScene: GameScene)->SKSpriteNode {
        let icon = SKSpriteNode(imageNamed: "Spider RESIZE-1")
        icon.anchorPoint = CGPoint(x: 0, y: 0)
        icon.position = CGPoint(x: gameScene.size.width * 0.05, y: gameScene.size.height * 0.88)
        icon.zPosition = 50
        let width: CGFloat = gameScene.xScaler
        let height: CGFloat = gameScene.yScaler
        icon.scale(to: CGSize(width: width, height: height))
        gameScene.addChild(icon)
        
        return icon
    }
 
    func makeMainMenuButton(gameScene: GameScene)->Button {
        let path = CGRect.init(x: gameScene.size.width*83/100, y: gameScene.size.height*35/1000, width: gameScene.size.width*14/100, height: gameScene.size.height*7/100)
        let mainMenuButton = Button.init(rect: path, cornerRadius: 5)
        mainMenuButton.strokeColor = UIColor.black
        mainMenuButton.fillColor = UIColor.white
        mainMenuButton.zPosition = 100
        mainMenuButton.createLabel(message: "Menu", fontSize: 10, color: SKColor.blue, position: CGPoint(x: gameScene.size.width*90/100, y: gameScene.size.height*5/100), zPosition: 150)
        adjustLabelFontSizeToFitRect(labelNode: mainMenuButton.label, rect: path)
        mainMenuButton.label.position.y += gameScene.size.height*5/1000
        gameScene.addChild(mainMenuButton)
        
        return mainMenuButton
    }
    
    func makeAreYouSureLabel(gameScene: GameScene)->SKLabelNode {
        gameScene.areYouSureDisplayed = true
        
        let areYouSureLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        areYouSureLabel.text = "Are you sure?"
        areYouSureLabel.fontSize = 20
        areYouSureLabel.fontColor = SKColor.blue
        areYouSureLabel.position = CGPoint(x: gameScene.size.width/2, y: gameScene.size.height*0.66)
        areYouSureLabel.zPosition = 150
        gameScene.addChild(areYouSureLabel)
        
        return areYouSureLabel
    }
    
    func makeAreYouSureYes(gameScene: GameScene)->Button {
        let path = CGRect.init(x: gameScene.size.width*34/100, y: gameScene.size.height*44/100, width: gameScene.size.width*14/100, height: gameScene.size.height*7/100)
        let areYouSure_Yes = Button.init(rect: path, cornerRadius: 5)
        areYouSure_Yes.strokeColor = UIColor.black
        areYouSure_Yes.fillColor = UIColor.white
        areYouSure_Yes.zPosition = 100
        areYouSure_Yes.createLabel(message: "Yes", fontSize: 10, color: SKColor.black, position: CGPoint(x: gameScene.size.width*0.41, y: gameScene.size.height * 0.455), zPosition: 150)
        gameScene.addChild(areYouSure_Yes)
        
        return areYouSure_Yes
    }
    
    func makeAreYouSureNo(gameScene: GameScene)->Button {
        let path2 = CGRect.init(x: gameScene.size.width*0.50, y: gameScene.size.height*44/100, width: gameScene.size.width*14/100, height: gameScene.size.height*7/100)
        let areYouSure_No = Button.init(rect: path2, cornerRadius: 5)
        areYouSure_No.strokeColor = UIColor.black
        areYouSure_No.fillColor = UIColor.white
        areYouSure_No.zPosition = 100
        areYouSure_No.createLabel(message: "No", fontSize: 10, color: SKColor.black, position: CGPoint(x: gameScene.size.width*0.57, y: gameScene.size.height * 0.455), zPosition: 150)
        gameScene.addChild(areYouSure_No)
        
        return areYouSure_No
    }
    
    func makeBarrier(gameScene: GameScene)->SKShapeNode {
        let rectangle = CGRect.init(x: 0, y: 0, width: gameScene.size.width, height: gameScene.size.height*88/100)
        let barrier = SKShapeNode.init(rect: rectangle)
        barrier.physicsBody = SKPhysicsBody(edgeLoopFrom: rectangle)
        barrier.strokeColor = SKColor.clear
        barrier.physicsBody?.isDynamic = false
        barrier.physicsBody?.restitution = 0
        barrier.physicsBody?.categoryBitMask = PhysicsCategory.Barrier
        barrier.physicsBody?.contactTestBitMask = PhysicsCategory.None
        barrier.physicsBody?.collisionBitMask = PhysicsCategory.Player
        gameScene.addChild(barrier)
        
        return barrier
    }
    
    func makeEnemyCounterWall(gameScene: GameScene)->SKShapeNode {
        let rectangle = CGRect.init(x: 0, y: 0, width: 2, height: Double(gameScene.size.height))
        let enemyCounterWall = SKShapeNode.init(rect: rectangle)
        enemyCounterWall.position = CGPoint(x: -gameScene.xScaler-1, y: gameScene.size.height/2)
        enemyCounterWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: gameScene.size.height))
        enemyCounterWall.physicsBody?.isDynamic = false
        enemyCounterWall.physicsBody?.categoryBitMask = PhysicsCategory.EnemyCounterWall
        enemyCounterWall.physicsBody?.contactTestBitMask = PhysicsCategory.ShootEnemy | PhysicsCategory.RamEnemy
        enemyCounterWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        gameScene.addChild(enemyCounterWall)
        
        return enemyCounterWall
    }
    
    func makeBulletRemoverWall(gameScene: GameScene)->SKShapeNode {
        let rectangle = CGRect.init(x: 0, y: 0, width: 2, height: Double(gameScene.size.height))
        let bulletRemoverWall = SKShapeNode.init(rect: rectangle)
        bulletRemoverWall.position = CGPoint(x: gameScene.size.width + 1, y: gameScene.size.height/2)
        bulletRemoverWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: gameScene.size.height))
        bulletRemoverWall.physicsBody?.isDynamic = false
        bulletRemoverWall.physicsBody?.categoryBitMask = PhysicsCategory.BulletRemoverWall
        bulletRemoverWall.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        bulletRemoverWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        gameScene.addChild(bulletRemoverWall)
        
        return bulletRemoverWall
    }
    
    func makeScoreLabel(gameScene: GameScene)->SKLabelNode {
        let scoreLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        scoreLabel.text = String(0)
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.yellow
        scoreLabel.position = CGPoint(x: gameScene.size.width*93/100, y: gameScene.size.height*88/100)
        scoreLabel.zPosition += 100
        gameScene.addChild(scoreLabel)
        
        return scoreLabel
    }
    
    func adjustLabelFontSizeToFitRect(labelNode: SKLabelNode, rect:CGRect) {
        // Determine the font scaling factor that should let the label text fit in the given rectangle.
        let scalingFactor = min(rect.width / labelNode.frame.width, rect.height / labelNode.frame.height)
        
        // Change the fontSize.
        labelNode.fontSize *= scalingFactor
        
        // Optionally move the SKLabelNode to the center of the rectangle.
        labelNode.position = CGPoint(x: rect.midX, y: rect.midY - labelNode.frame.height / 2.0)
    }
}

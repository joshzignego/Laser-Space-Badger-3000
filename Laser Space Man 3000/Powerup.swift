//
//  MySKSpriteNode.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 8/3/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import Foundation
import SpriteKit

class Powerup: SKSpriteNode {
    var speedBullets = false
    var invincibility = false
    var bonusLives = false
    
    func addPowerup(platform: SKShapeNode, point: CGPoint, type: String, gameScene: GameScene) {
        self.setType(type: type)
        self.position = point
        addPowerupInfo(gameScene: gameScene)
        
        platform.addChild(self)
    }
    
    func addGroundPowerup(point: CGPoint, type: String, gameScene: GameScene) {
        self.setType(type: type)
        self.position = point
        addPowerupInfo(gameScene: gameScene)
        
        gameScene.addChild(self)
    }
    
    func addPowerupInfo(gameScene: GameScene) {
        self.anchorPoint = CGPoint(x: 0, y: 0)
        self.scale(to: CGSize(width: gameScene.xScaler, height: gameScene.yScaler))
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: gameScene.xScaler/2, y: gameScene.yScaler/2))
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Powerup
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    func setType(type: String) {
        if type == "speedBullets" {
            speedBullets = true
        }
        if type == "invincible" {
            invincibility = true
        }
        if type == "bonusLives" {
             bonusLives = true
        }
    }
    
    func getType()->String {
        if speedBullets {
            return "speedBullets"
        }
        else if invincibility {
            return "invincible"
        }
        else {
            return "bonusLives"
        }
    }
}

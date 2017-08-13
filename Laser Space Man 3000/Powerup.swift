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
    var speedBullet = false
    var invincibility = false
    var bonusLives = false
    
    func addPowerup(platform: SKShapeNode, point: CGPoint, type: String, gameScene: GameScene) {
        self.setType(type: type)
        self.position = point
        self.anchorPoint = CGPoint(x: 0, y: 0)
        let width: Double = Double(gameScene.size.width) * gameScene.xScaler
        let height: Double = Double(gameScene.size.height) * gameScene.yScaler
        self.scale(to: CGSize(width: width, height: height))
        platform.addChild(self)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: width/2, y: height/2))
        self.physicsBody?.isDynamic = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Powerup
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.linearDamping = 0
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.friction = 0
        self.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        self.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    func addGroundPowerup(point: CGPoint, type: String, gameScene: GameScene) {
        self.setType(type: type)
        self.position = point
        self.anchorPoint = CGPoint(x: 0, y: 0)
        let width: Double = Double(gameScene.size.width) * gameScene.xScaler
        let height: Double = Double(gameScene.size.height) * gameScene.yScaler
        self.scale(to: CGSize(width: width, height: height))
        gameScene.addChild(self)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size, center: CGPoint(x: width/2, y: height/2))
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
        if type == "speedBullet" {
            speedBullet = true
        }
        if type == "invincible" {
            invincibility = true
        }
        if type == "bonusLives" {
            speedBullet = bonusLives
        }
    }
    
    func getType()->String {
        if speedBullet {
            return "speedBullet"
        }
        else if invincibility {
            return "invincible"
        }
        else {
            return "bonusLives"
        }
    }
}

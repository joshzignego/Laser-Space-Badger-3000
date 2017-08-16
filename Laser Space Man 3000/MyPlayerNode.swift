//
//  MySKSpriteNode.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 8/3/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import Foundation
import SpriteKit

class MyPlayerNode: SKSpriteNode {
    var movingUp : Bool = false
    var movingDown : Bool = false
    var movingRight : Bool = false
    var movingLeft : Bool = false
    var doRunAnimation : Bool = false
    var doKickingAnimation : Bool = false
    var doJumpAnimation : Bool = false
    var doPowerupAnimation : Bool = false
    var doPuttingOnAnimation : Bool = false
    var shirtless : Bool = false
    
    init() {
        let texture = SKTexture(imageNamed: "Running FLANNEL-1")
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
    }
    
    func initializePlayer(gameScene: GameScene) {
        self.position = CGPoint(x: gameScene.size.width * 0.1, y: gameScene.size.height * 1 / 7 + CGFloat(gameScene.yScaler)*gameScene.size.height/2)
        self.zPosition = 0
        let width: Double = Double(gameScene.size.width) * gameScene.xScaler
        let height: Double = Double(gameScene.size.height) * gameScene.yScaler
        self.scale(to: CGSize(width: width, height: height))
        gameScene.addChild(self)
        
        self.physicsBody = SKPhysicsBody(rectangleOf: self.size)
        self.physicsBody?.isDynamic = true
        //self.physicsBody?.linearDamping = 1
        self.physicsBody?.allowsRotation = false
        self.physicsBody?.restitution = 0
        //self.physicsBody?.friction = 1
        self.physicsBody?.usesPreciseCollisionDetection = true
        self.physicsBody?.categoryBitMask = PhysicsCategory.Player
        self.physicsBody?.contactTestBitMask = PhysicsCategory.ShootEnemy | PhysicsCategory.RamEnemy
        self.physicsBody?.collisionBitMask = PhysicsCategory.Platform | PhysicsCategory.Barrier
    }
    
    func beginRunAnimation() {
        if doPowerupAnimation {
            return
        }
        if doPuttingOnAnimation {
            return
        }
        if doKickingAnimation {
            stopKickingAnimation()
        }
        if doJumpAnimation {
            doJumpAnimation = false
        }
        if doRunAnimation {
            return
        }
        doRunAnimation = true
        let textureAtlas = SKTextureAtlas(named: "Badger")
        var frames : [SKTexture]
        if shirtless {
            frames = ["Shirtless Run 1", "Shirtless Run 2", "Shirtless Run 3", "Shirtless Run 4"].map { textureAtlas.textureNamed($0) }
        }
        else {
            frames = ["Running FLANNEL-1", "Running FLANNEL-2", "Running FLANNEL-3", "Running FLANNEL-4"].map { textureAtlas.textureNamed($0) }
        }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        let forever = SKAction.repeatForever(animate)
        self.run(forever, withKey: "runningAnimation")
    }
    
    func stopRunAnimation() {
        if doRunAnimation {
            self.removeAction(forKey: "runningAnimation")
        }
        doRunAnimation = false
    }
    
    func beginKickAnimation() {
        if doPowerupAnimation {
            return
        }
        if doPuttingOnAnimation {
            return
        }
        if doRunAnimation {
            stopRunAnimation()
        }
        if doJumpAnimation {
            doJumpAnimation = false
        }
        //print("Kick Animation")
        let textureAtlas = SKTextureAtlas(named: "Badger")
        var frames : [SKTexture]
        if shirtless {
            frames = ["Shirtless Kicking 1", "Shirtless Kicking 3", "Shirtless Kicking 3"].map { textureAtlas.textureNamed($0) }
        } else {
            frames = ["Kicking FLANNEL-1", "Kicking FLANNEL-3", "Kicking FLANNEL-3"].map { textureAtlas.textureNamed($0) }
        }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        self.run(animate)
        if shirtless {
            self.texture = SKTexture(imageNamed: "Shirtless Kicking 3")
        }
        else {
            self.texture = SKTexture(imageNamed: "Kicking FLANNEL-3")
        }
    }
    
    func stopKickingAnimation() {
        doKickingAnimation = false
    }
    
    func beginReverseKickAnimation() {
        if doPowerupAnimation {
            return
        }
        if doPuttingOnAnimation {
            return
        }
        if doRunAnimation {
            stopRunAnimation()
        }
        if doJumpAnimation {
            doJumpAnimation = false
        }
        //print("Kick Animation")
        doKickingAnimation = true
        let textureAtlas = SKTextureAtlas(named: "Badger")
        var frames : [SKTexture]
        if shirtless {
            frames = ["Shirtless Reverse Kicking 1", "Shirtless Reverse Kicking 3", "Shirtless Reverse Kicking 3"].map { textureAtlas.textureNamed($0) }
        } else {
            frames = ["Reverse Kicking FLANNEL-1", "Reverse Kicking FLANNEL-3", "Reverse Kicking FLANNEL-3"].map { textureAtlas.textureNamed($0) }
        }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        self.run(animate)
        if shirtless {
            self.texture = SKTexture(imageNamed: "Shirtless Reverse Kicking 3")
        }
        else {
            self.texture = SKTexture(imageNamed: "Reverse Kicking FLANNEL-3")
        }
    }
    
    func beginJumpAnimation() {
        if doPowerupAnimation {
            return
        }
        if doPuttingOnAnimation {
            return
        }
        if doKickingAnimation {
            stopKickingAnimation()
        }
        if doRunAnimation {
            stopRunAnimation()
        }
        doJumpAnimation = true
        if shirtless {
            self.texture = SKTexture(imageNamed: "Shirtless Jumping")
        }
        else {
            self.texture = SKTexture(imageNamed: "Jumping FLANNEL-1")
        }
    }
    
    func stopJumpAnimation() {
        doJumpAnimation = false
    }
    
    func beginPowerupAnimation(type: String) {
        if shirtless {
            return
        }
        doPowerupAnimation = true
        
        if doKickingAnimation {
            stopKickingAnimation()
        }
        if doRunAnimation {
            stopRunAnimation()
        }
        if doJumpAnimation {
            stopJumpAnimation()
        }
        
        if type == "tear" {
            doPuttingOnAnimation = false
            shirtless = true
            let textureAtlas = SKTextureAtlas(named: "Badger")
            let frames = ["Tear 1", "Tear 2", "Tear 3", "Tear 4", "Tear 5", "Tear 6", "Tear 7", "Tear 8", "Tear 9", "Tear 10", "Tear 11", "Tear 12"].map { textureAtlas.textureNamed($0) }
            let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        
            self.run(SKAction.sequence([animate, SKAction.run(stopPowerupAnimation)]))
        } else if type == "flip" {
            let textureAtlas = SKTextureAtlas(named: "Badger")
            let frames = ["Flip 1", "Flip 2", "Flip 3", "Flip 4"].map { textureAtlas.textureNamed($0) }
            let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
            
            self.run(SKAction.sequence([animate, SKAction.run(stopPowerupAnimation)]))
        } else if type == "lightning" {
            
            let textureAtlas = SKTextureAtlas(named: "Badger")
            let frames = ["Lightning 1", "Lightning 2", "Lightning 3", "Lightning 4"].map { textureAtlas.textureNamed($0) }
            let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
            
            self.run(SKAction.sequence([animate, SKAction.run(stopPowerupAnimation)]))
        }
    }
    
    func stopPowerupAnimation() {
        doPowerupAnimation = false
    }
    
    
    func putShirtOn() {
        stopRunAnimation()
        stopJumpAnimation()
        stopKickingAnimation()
        if shirtless {
            shirtless = false
            doPuttingOnAnimation = true
            let textureAtlas = SKTextureAtlas(named: "Badger")
            let frames = ["Tear 12", "Tear 11", "Tear 10", "Tear 9", "Tear 8", "Tear 7"].map { textureAtlas.textureNamed($0) }
            let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        
            self.run(SKAction.sequence([animate, SKAction.run(stopPuttingOn)]))
        }
    }
    
    func stopPuttingOn() {
        doPuttingOnAnimation = false
    }
 
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setMoving(direction: String, value: Bool) {
        if direction == "up" {
            movingUp = value
        }
        else if direction == "down" {
            movingDown = value
        }
        else if direction == "right" {
            movingRight = value
        }
        else if direction == "left" {
            movingLeft = value
        }
    }
    
    func isMoving(direction: String) -> Bool {
        if direction == "up" {
            return movingUp
        }
        else if direction == "down" {
            return movingDown
        }
        else if direction == "right" {
            return movingRight
        }
        else if direction == "left" {
            return movingLeft
        }
        return false
    }
}

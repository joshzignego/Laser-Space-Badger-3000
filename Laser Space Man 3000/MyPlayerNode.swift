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
    
    init() {
        let texture = SKTexture(imageNamed: "Gun nakey badger RESIZE-1")
        super.init(texture: texture, color: SKColor.clear, size: texture.size())
    }
    
    func beginRunAnimation() {
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
        let frames = ["Gun nakey badger RESIZE-1", "Gun nakey badger RESIZE-2", "Gun nakey badger RESIZE-3", "Gun nakey badger RESIZE-4"].map { textureAtlas.textureNamed($0) }
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
        if doRunAnimation {
            stopRunAnimation()
        }
        if doJumpAnimation {
            doJumpAnimation = false
        }
        //print("Kick Animation")
        let textureAtlas = SKTextureAtlas(named: "Badger")
        let frames = ["Kicking RESIZE-1", "Kicking RESIZE-2", "Kicking RESIZE-3", "Kicking RESIZE-4"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        self.run(animate)
        self.texture = SKTexture(imageNamed: "Kicking RESIZE-3")
    }
    
    func stopKickingAnimation() {
        doKickingAnimation = false
    }
    
    func beginJumpAnimation() {
        if doKickingAnimation {
            stopKickingAnimation()
        }
        if doRunAnimation {
            stopRunAnimation()
        }
        self.texture = SKTexture(imageNamed: "Jumping RESIZE-1")
        doJumpAnimation = true
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

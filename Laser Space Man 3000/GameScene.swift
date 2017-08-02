//
//  GameScene.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 7/31/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None     : UInt32 = 0
    static let All      : UInt32 = UInt32.max
    static let Enemy    : UInt32 = 0b1
    static let Bullet   : UInt32 = 0b10
    static let Plauer   : UInt32 = 0b100
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}



class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //let space = SKSpriteNode(imageNamed: "Space")
    let player = SKSpriteNode(imageNamed: "player")
    let xScaler: Double = 0.05
    let yScaler: Double = 0.08
    
    override func didMove(to view: SKView) {
        
        //space.position = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        backgroundColor = SKColor.white
        
        player.anchorPoint = CGPoint(x: 0, y: 0)
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 3 / 7)
        
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        player.scale(to: CGSize(width: width, height: height))
        self.addChild(player)
        addPlatform()
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        
        //let random = Double(arc4random_uniform(4)) + 1
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addPlatform),
                SKAction.run(addEnemy),
                SKAction.wait(forDuration: 1)
                ])
        ))
        
        /*
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        */
    }
    
    func addPlatform() {
        
        
        let platformNumber: Double = Double(arc4random_uniform(5)) + 1
        let height: Double = platformNumber / 7 * Double(size.height)
        let randomLength: Double = Double(arc4random_uniform(10)) + 1
        let width: Double = randomLength * Double(size.width) / 10
        let startPoint: CGPoint = CGPoint(x: Double(size.width), y: height)
        let endPoint: CGPoint = CGPoint(x: Double(size.width) + width, y: height)
        let path: CGMutablePath = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        
        let platform = SKShapeNode()
        platform.path = path
        platform.strokeColor = UIColor.black
        platform.lineWidth = 2
        self.addChild(platform)

        let move = SKAction.moveTo(x: platform.position.x - size.width - CGFloat(width), duration: TimeInterval(5))
        let moveDone = SKAction.removeFromParent()
        platform.run(SKAction.sequence([move, moveDone]))
    }
 
    func addEnemy() {
        
        // Create enemy
        let enemy = SKSpriteNode(imageNamed: "enemy")
        
        // Determine what line to spawn enemy on (random # 1-5 out of 7)
        let random: Double = Double(arc4random_uniform(5)) + 1
        let y: Double = (random/7)
        
        
        
        
        
        // Position the enemy slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        enemy.position = CGPoint(x: size.width*1.1, y: CGFloat(y)*size.height)
        enemy.anchorPoint = CGPoint(x: 0, y: 0)
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        enemy.scale(to: CGSize(width: width, height: height))
        
        self.addChild(enemy)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size) // 1
        enemy.physicsBody?.isDynamic = true // 2
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy // 3
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet // 4
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        let move = SKAction.move(to: CGPoint(x: CGFloat(-width), y: CGFloat(y)*size.height), duration: TimeInterval(5))
        let moveDone = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([move, moveDone]))
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        // 2 - Set up initial location of projectile
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position.x = player.position.x + (size.width * CGFloat(xScaler))
        bullet.position.y = player.position.y + (size.height * CGFloat(yScaler))/2
        
        // Make bullet appropiate size
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler / 4
        bullet.scale(to: CGSize(width: width, height: height))
        
        // 3 - Determine offset of location to projectile
        let offset = touchLocation - bullet.position
        
        
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        // 6 - Get the direction of where to shoot
        let direction = offset.normalized()
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * size.width
        
        // 8 - Add the shoot amount to the current position
        let destination = shootAmount + bullet.position
        
        // Rotate bullet so it's faces the proper direction
        //let degrees = tan(Double(direction.y)/Double(direction.x))
        //let rotation = SKAction.rotate(byAngle: CGFloat(degrees), duration: 0)
        //bullet.run(rotation)
        //bullet.zRotation += CGFloat(degrees * Double.pi / 180)
        let angle = atan2(direction.y, direction.x)
        bullet.zRotation += angle
        //bullet.zRotation = angle - CGFloat(Double.pi/2)
        
        addChild(bullet)
        
        // 9 - Create the actions
        let actionMove = SKAction.move(to: destination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }

/*
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
 */
    func projectileDidCollideWithMonster(projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Sort by category bitmask
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Check if enemy & bullet collide
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Bullet != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let
                projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
        
    }
}

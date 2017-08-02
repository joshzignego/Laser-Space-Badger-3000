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
    static let Player   : UInt32 = 0b100
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
    
    let player = SKSpriteNode(imageNamed: "player")
    var pauseButton = SKShapeNode()
    var pauseLabel = SKLabelNode()
    let xScaler: Double = 0.05
    let yScaler: Double = 0.08
    let platformAndEnemySpeed = 200
    let teleportSpeed = 400
    var enemiesKilled : Int = 0
    var spriteView = SKView()
    struct PlatformStruct {
        let platform : SKShapeNode
        let length : Double
        let height : Double
    }
    var platforms: [PlatformStruct] = []
    
    override func didMove(to view: SKView) {
        
        backgroundColor = SKColor.white
        self.scaleMode = SKSceneScaleMode.resizeFill
        spriteView = self.view!
        player.anchorPoint = CGPoint(x: 0, y: 0)
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 3 / 7)
        
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        player.scale(to: CGSize(width: width, height: height))
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size, center: CGPoint(x: width/2, y: height/2)) // 1
        player.physicsBody?.isDynamic = true // 2
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player // 3
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy // 4
        player.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        makePauseButton()
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.run(jumpUp), SKAction.wait(forDuration: 2)])))
        
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
        let randomLength: Double = Double(arc4random_uniform(9)) + 2
        let width: Double = randomLength * Double(size.width) / 10
        //let path: CGMutablePath = CGMutablePath()
        
        
        let startPoint: CGPoint = CGPoint(x: Double(size.width), y: height)
        let endPoint: CGPoint = CGPoint(x: Double(size.width) + width, y: height)
        let path: CGMutablePath = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
 
        
        let platform = SKShapeNode()
        self.addChild(platform)
        print("Platform added. origin is ", platform.frame.origin, " position is ", platform.position, " parent is ", platform.parent!, "\n")
        platform.path = path
        platform.strokeColor = UIColor.black
        platform.lineWidth = 2
        //platform.frame
        //addChild(platform)
        platforms.append(PlatformStruct(platform: platform, length: width, height: height))
        
        let enemyRate = 2;
        for i in 2...Int(randomLength) {
            let randomEnemyNumber = Double(arc4random_uniform(UInt32(enemyRate)))
            //For each segment of platform, "1 in enemyRate" chance enemy spawned there
            if (randomEnemyNumber == 0) {
                let point: CGPoint = CGPoint(x: (Double(i)*Double(size.width)/10 + Double(size.width)) - (Double(size.width) * xScaler), y: height)
                addEnemy(platform: platform, point: point)
            }
            
        }
        
        
        
        
        /*let time = (Double(point.x) + width) / Double(platformAndEnemySpeed)
        let move = SKAction.move(to: CGPoint(x: CGFloat(-width), y: point.y), duration: TimeInterval(time))
        let moveDone = SKAction.removeFromParent()
        let loseAction = SKAction.run() {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let gameOverScene = GameOverScene(size: self.size)
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        enemy.run(SKAction.sequence([move, loseAction, moveDone]))
        */
        
        let time = (Double(startPoint.x) + width) / Double(platformAndEnemySpeed)
        let move = SKAction.moveTo(x: platform.position.x - size.width - CGFloat(width), duration: TimeInterval(time))
        
        let moveDone = SKAction.removeFromParent()
        platform.run(SKAction.sequence([move, SKAction.run(
            {
                //let length = self.platforms.count - 1
                var flag : Bool = true
                var index : Int = 0
                while flag {
                    if self.platforms[index].platform.hashValue == platform.hashValue {
                        print("found it")
                        flag = false
                        self.platforms.remove(at: index)
                    }
                    index += 1
                }
            }
            ), moveDone]))
        
        
        
        
        
        
        
        // let index = platforms.index(of: platform)
        //platforms.remove(at: index!)
    }
 
    /*  Enemy will be child of the platform that calls it.
        Enemy will be spawned at given CGPoint. */
    func addEnemy(platform: SKShapeNode, point : CGPoint) {
    
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.position = point
        enemy.anchorPoint = CGPoint(x: 0, y: 0)
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        enemy.scale(to: CGSize(width: width, height: height))
        
        platform.addChild(enemy)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size, center: CGPoint(x: width/2, y: height/2))
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // 1 - Choose one of the touches to work with
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: self)
        
        
        
        let node = self.atPoint(touchLocation)
        if node == pauseButton {
            pauseButtonHit()
            return
        }
        if self.speed == 0 {
            return
        }
    
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
        
        /*for item in platforms {
            print("platform hash value: ", item.platform.hashValue, "platform position: ", item.platform.position, " platform length: ", item.length, " player's position: ", player.position)
        }*/
        
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
    func bulletDidCollideWithMonster(bullet: SKSpriteNode, enemy: SKSpriteNode) {
        print("Hit")
        enemiesKilled += 1
        bullet.removeFromParent()
        enemy.removeFromParent()
    }
    
    func gameOver() {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func makePauseButton() {
        pauseLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        pauseLabel.text = "Pause"
        pauseLabel.fontSize = 10
        pauseLabel.fontColor = SKColor.blue
        pauseLabel.position = CGPoint(x: size.width*7/100, y: size.height*5/100)
        addChild(pauseLabel)
        
        
        // Try as a shape
        let path = CGRect.init(x: Double(size.width*2/100), y: Double(size.height*35/1000), width: Double(size.width*10/100), height: Double(size.height*7/100))
        pauseButton = SKShapeNode.init(rect: path, cornerRadius: 5)
        pauseButton.strokeColor = UIColor.black
        addChild(pauseButton)
    }
    
    func pauseButtonHit() {
        if self.speed == 1 {
            self.speed = 0
            pauseLabel.text = "Resume"
            return
        }
        pauseLabel.text = "Pause"
        self.speed = 1
        return
        
        /*let message = "Pause"
        let label = SKLabelNode(fontNamed: "Fipps-Regular")
        label.text = message
        label.fontSize = 10
        label.fontColor = SKColor.blue
        label.position = CGPoint(x: size.width*7/100, y: size.height*5/100)
        addChild(label)*/
    }
    /*
    func teleportRight() {
        
    }
    
    func teleportLeft() {
        
    }
    */
    func jumpUp() {
        //If no platforms possibly above, do nothing & return
        if Double(player.position.y) >= 5 / 7 * Double(size.height) {
            return
        }
        
        var lowestYAbove : CGFloat = size.height
        
        for platformStruct in platforms {
            //If platform above player
            if (CGFloat(platformStruct.height) > player.position.y) {
                
                
                //let convertedPosition = platformStruct.platform.scene?.convert(platformStruct.platform.position,
                                                                               //from: platformStruct.platform.parent!)
                
                //print("platform hash value: ", platformStruct.platform.hashValue, "platform position: ", platformStruct.platform.position, " platform length: ", platformStruct.length, " platform height: ", platformStruct.height)
                
                
                
                //If player is within the platforms x span
                if ((size.width + platformStruct.platform.position.x) < (player.position.x + size.width * CGFloat(xScaler))) &&
                    ((size.width + platformStruct.platform.position.x + platformStruct.platform.lineLength) > (player.position.x)) {
                    
                    //If platform is the next lowest platform above, update lowestYAbove
                    if CGFloat(platformStruct.height) < lowestYAbove {
                            lowestYAbove = CGFloat(platformStruct.height)
                    }
                }
            }
        }
 
        if lowestYAbove < size.height {
            let time = (Double(lowestYAbove - player.position.y)) / Double(teleportSpeed)
            player.run(SKAction.moveTo(y: lowestYAbove, duration: time))
        }
        
    }
 
    /*
    func teleportDown() {
        
    }
    */
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
            if let enemy = firstBody.node as? SKSpriteNode, let
                bullet = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithMonster(bullet: bullet, enemy: enemy)
            }
        }
        // Player is 2nd body
        // Check if enemy & player collide
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
                gameOver()
        }
        
    }
}

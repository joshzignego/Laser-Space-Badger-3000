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
    static let Invisiwall   : UInt32 = 0b1000
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
    let enemiesCanStillTakeHitsFromIcon = SKSpriteNode(imageNamed: "enemy")
    var invisiwall = SKShapeNode()
    var pauseButton = SKShapeNode()
    var pauseLabel = SKLabelNode()
    var scoreLabel = SKLabelNode()
    var enemiesCanStillTakeHitsFromLabel = SKLabelNode()
    let xScaler: Double = 0.05
    let yScaler: Double = 0.08
    var score: Int = 0
    let platformAndEnemySpeed = 200
    let teleportSpeed = 400
    let enemiesPassedToDie = 30
    var enemiesCanStillTakeHitsFrom: Int = 0
    var enemiesKilled : Int = 0
    var enemiesPassed : Int = 0
    var spriteView = SKView()
    struct PlatformStruct {
        let platform : SKShapeNode
        let length : Double
        let height : Double
    }
    var platforms: [PlatformStruct] = []
    var teleportDistance : Double = 0.0
    
    
    //Swipes
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    
    override func didMove(to view: SKView) {
        
        self.name = "GameScene"
        enemiesCanStillTakeHitsFrom = enemiesPassedToDie
        teleportDistance = Double(size.width) * 0.10
        backgroundColor = SKColor.white
        self.scaleMode = SKSceneScaleMode.resizeFill
        spriteView = self.view!
        
        enemiesCanStillTakeHitsFromIcon.anchorPoint = CGPoint(x: 0, y: 0)
        enemiesCanStillTakeHitsFromIcon.position = CGPoint(x: size.width * 0.05, y: size.height * 0.88)
        player.anchorPoint = CGPoint(x: 0, y: 0)
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 3 / 7)
        
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        enemiesCanStillTakeHitsFromIcon.scale(to: CGSize(width: width, height: height))
        player.scale(to: CGSize(width: width, height: height))
        addChild(player)
        addChild(enemiesCanStillTakeHitsFromIcon)
        //print("Player added. origin is ", player.frame.origin, " position is ", player.position, " parent is ", player.parent!, "\n")
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size, center: CGPoint(x: width/2, y: height/2))
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let rectangle = CGRect.init(x: 0, y: 0, width: 2, height: Double(size.height))
        invisiwall = SKShapeNode.init(rect: rectangle)
        invisiwall.position = CGPoint(x: -xScaler*Double(size.width), y: Double(size.height)/2)
        invisiwall.strokeColor = UIColor.black
        invisiwall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: size.height))
        invisiwall.physicsBody?.isDynamic = true
        invisiwall.physicsBody?.categoryBitMask = PhysicsCategory.Invisiwall
        invisiwall.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        invisiwall.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        addChild(invisiwall)
        
        
        swipeRightRec.addTarget(self, action: #selector(swipedRight) )
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        swipeLeftRec.addTarget(self, action: #selector(swipedLeft) )
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)
        
        
        swipeUpRec.addTarget(self, action: #selector(swipedUp) )
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(swipedDown) )
        swipeDownRec.direction = .down
        self.view!.addGestureRecognizer(swipeDownRec)
        
        
        physicsWorld.gravity = CGVector.zero
        physicsWorld.contactDelegate = self
        
        makePauseButton()
        makeScoreLabel()
        makeEnemiesCanStillTakeHitsFromLabel()
        
        /* Teleport/Jump tester
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.run(jumpUp), SKAction.wait(forDuration: 1), SKAction.run(teleportRight), SKAction.wait(forDuration: 1), SKAction.run(teleportLeft), SKAction.wait(forDuration: 1), SKAction.run(jumpDown), SKAction.wait(forDuration: 1)])))
        */
        
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.wait(forDuration: 1)])))
    }
    
    
    func addPlatform() {
        
        let platformNumber: Double = Double(arc4random_uniform(5)) + 1
        let height: Double = platformNumber / 7 * Double(size.height)
        let randomLength: Double = Double(arc4random_uniform(9)) + 2
        let width: Double = randomLength * Double(size.width) / 10
        //let path: CGMutablePath = CGMutablePath()
        
        
        let startPoint: CGPoint = CGPoint(x: 0, y: 0)
        let endPoint: CGPoint = CGPoint(x: width, y: 0)
        let path: CGMutablePath = CGMutablePath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
 
        
        let platform = SKShapeNode()
        platform.position = CGPoint(x: size.width, y: CGFloat(height))
        platform.path = path
        platform.strokeColor = UIColor.black
        platform.lineWidth = 2
        addChild(platform)
        //print("Platform added. origin is ", platform.frame.origin, " position is ", platform.position, " parent is ", platform.parent!, "\n")
        platforms.append(PlatformStruct(platform: platform, length: width, height: height))
        
        let enemyRate = 2;
        for i in 2...Int(randomLength) {
            let randomEnemyNumber = Double(arc4random_uniform(UInt32(enemyRate)))
            //For each segment of platform, "1 in enemyRate" chance enemy spawned there
            if (randomEnemyNumber == 0) {
                let point: CGPoint = CGPoint(x: Double(i)*Double(size.width)/10 - (Double(size.width) * xScaler), y: 0)
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
        
        let time = (Double(size.width) + width) / Double(platformAndEnemySpeed)
        let move = SKAction.moveTo(x: -CGFloat(width), duration: TimeInterval(time))
        let moveDone = SKAction.removeFromParent()
        
        platform.run(SKAction.sequence([move, SKAction.run(
            {
                //let length = self.platforms.count - 1
                var flag : Bool = true
                var index : Int = 0
                while flag {
                    if self.platforms[index].platform.hashValue == platform.hashValue {
                        //print("found it")
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

    func swipedRight() {
        //print("Right")
        teleportRight()
    }
    
    func swipedLeft() {
        //print("Left")
        teleportLeft()
    }
    
    func swipedUp() {
        //print("Up")
        jumpUp()
    }
    
    func swipedDown() {
        //print("Down")
        jumpDown()
    }

    func bulletDidCollideWithEnemy(bullet: SKSpriteNode, enemy: SKSpriteNode) {
        //print("Hit")
        enemiesKilled += 1
        score += 1
        updateScore()
        bullet.removeFromParent()
        enemy.removeFromParent()
    }
    
    func enemyCollideWithInvisiwall() {
        enemiesCanStillTakeHitsFrom -= 1
        updateEnemiesCanStillTakeHitsFromLabel()
        if enemiesCanStillTakeHitsFrom <= 0 {
            gameOver()
        }
    }
    
    func gameOver() {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func makeEnemiesCanStillTakeHitsFromLabel() {
        enemiesCanStillTakeHitsFromLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        enemiesCanStillTakeHitsFromLabel.text = String(enemiesCanStillTakeHitsFrom)
        enemiesCanStillTakeHitsFromLabel.fontSize = 25
        enemiesCanStillTakeHitsFromLabel.fontColor = SKColor.red
        enemiesCanStillTakeHitsFromLabel.position = CGPoint(x: size.width*15/100, y: size.height*88/100)
        addChild(enemiesCanStillTakeHitsFromLabel)
    }
    
    func makeScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        scoreLabel.text = String(score)
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.yellow
        scoreLabel.position = CGPoint(x: size.width*93/100, y: size.height*88/100)
        addChild(scoreLabel)
    }
    
    func updateEnemiesCanStillTakeHitsFromLabel() {
        enemiesCanStillTakeHitsFromLabel.text = String(enemiesCanStillTakeHitsFrom)
    }
    
    func updateScore() {
        scoreLabel.text = String(score)
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
    }
    
    func teleportRight() {
        //If no more screen in front, do nothing & return
        if Double(player.position.x) + teleportDistance + xScaler * Double(size.width) >= Double(size.width)  {
            return
        }
        
        var flag : Bool = false
        for platformStruct in platforms {
            //If platform has same height as player
            if ((CGFloat(platformStruct.height) * 0.999 < player.position.y)
                && (CGFloat(platformStruct.height) * 1.001 > player.position.y)) {
            
                //If teleporting puts you on platform still
                if (platformStruct.platform.position.x + CGFloat(platformStruct.length) > player.position.x + CGFloat(teleportDistance) + CGFloat(xScaler) * size.width)
                    && (player.position.x + CGFloat(teleportDistance) >= platformStruct.platform.position.x) {
                    flag = true
                }
            }
        }
        
        if flag {
            player.position.x += CGFloat(teleportDistance)
        }
    }
    
    func teleportLeft() {
        //If no more screen behind, do nothing & return
        if Double(player.position.x) - teleportDistance < 0  {
            return
        }
        
        var flag : Bool = false
        for platformStruct in platforms {
            //If platform has same height as player
            if ((CGFloat(platformStruct.height) * 0.999 < player.position.y)
                && (CGFloat(platformStruct.height) * 1.001 > player.position.y)) {
                
                //If teleporting puts you on platform still
                if (platformStruct.platform.position.x + CGFloat(platformStruct.length) > player.position.x - CGFloat(teleportDistance))
                    && (player.position.x - CGFloat(teleportDistance) >= platformStruct.platform.position.x) {
                    flag = true
                }
            }
        }
        
        if flag {
            player.position.x -= CGFloat(teleportDistance)
        }
    }
 
    func jumpUp() {
        //If no platforms possibly above, do nothing & return
        if Double(player.position.y) >= 5 / 7 * Double(size.height) {
            return
        }
        
        var lowestYAbove : CGFloat = size.height
        
        for platformStruct in platforms {
            //If platform above player
            if (CGFloat(platformStruct.platform.position.y) > player.position.y) {
                
                
                //let convertedPosition = platformStruct.platform.scene?.convert(platformStruct.platform.position,
                                                                               //from: platformStruct.platform.parent!)
                
                //print("platform hash value: ", platformStruct.platform.hashValue, "platform position: ", platformStruct.platform.position, " platform length: ", platformStruct.length, " platform height: ", platformStruct.height)
                
                
                
                //If player is within the platforms x span
                if ((platformStruct.platform.position.x) < (player.position.x + size.width * CGFloat(xScaler))) &&
                    ((Double(platformStruct.platform.position.x) + platformStruct.length) > Double(player.position.x)) {
                    
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
 
    
    func jumpDown() {
        //If no platforms possibly below, do nothing & return
        if Double(player.position.y) <= 1 / 7 * Double(size.height) {
            return
        }
        
        var highestYBelow : CGFloat = 0
        
        for platformStruct in platforms {
            //If platform below player
            if (CGFloat(platformStruct.platform.position.y) < player.position.y) {
                
                //If player is within the platforms x span
                if ((platformStruct.platform.position.x) < (player.position.x + size.width * CGFloat(xScaler))) &&
                    ((Double(platformStruct.platform.position.x) + platformStruct.length) > Double(player.position.x)) {
                    
                    //If platform is the next lowest platform above, update lowestYAbove
                    if CGFloat(platformStruct.height) > highestYBelow {
                        highestYBelow = CGFloat(platformStruct.height)
                    }
                }
            }
        }
        
        if highestYBelow > 0 {
            let time = (Double(player.position.y) - Double(highestYBelow)) / Double(teleportSpeed)
            player.run(SKAction.moveTo(y: highestYBelow, duration: time))
        }

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
            if let enemy = firstBody.node as? SKSpriteNode, let
                bullet = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithEnemy(bullet: bullet, enemy: enemy)
            }
        }
        // Player is 2nd body
        // Check if enemy & player collide
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Player != 0)) {
                gameOver()
        }
        // Check if enemy & invisiwall collide
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Invisiwall != 0)) {
                enemyCollideWithInvisiwall()
        }
    }
}

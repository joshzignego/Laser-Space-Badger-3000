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
    static let None                 : UInt32         = 0
    static let Enemy                : UInt32         = 0b1
    static let Bullet               : UInt32         = 0b10
    static let Player               : UInt32         = 0b100
    static let EnemyCounterWall     : UInt32         = 0b1000
    static let Platform             : UInt32         = 0b10000
    static let BulletRemoverWall    : UInt32         = 0b100000
    static let All                  : UInt32         = UInt32.max
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
    
    let player = MyPlayerNode(imageNamed: "player")
    var ground = SKShapeNode()
    let enemiesCanStillTakeHitsFromIcon = SKSpriteNode(imageNamed: "enemy")
    var enemyCounterWall = SKShapeNode()
    var bulletRemoverWall = SKShapeNode()
    var pauseButton = Button()
    var mainMenuButton = Button()
    var areYouSureLabel = SKLabelNode(fontNamed: "Fipps-Regular")
    var areYouSure_Yes = Button()
    var areYouSure_No = Button()
    var scoreLabel = SKLabelNode()
    var enemiesCanStillTakeHitsFromLabel = SKLabelNode()
    let xScaler: Double = 0.05
    let yScaler: Double = 0.08
    var score: Int = 0
    let maxPlatformLength = 10
    let platformAndEnemySpeed = 300
    let teleportSpeed = 400
    let enemiesPassedToDie = 30
    var enemiesCanStillTakeHitsFrom: Int = 0
    var enemiesKilled : Int = 0
    var enemiesPassed : Int = 0
    let enemyRate = 4   //0 means max enemies, higher numer means less enemies
    var spriteView = SKView()
    struct PlatformStruct {
        let platform : SKShapeNode
        let length : Double
        let height : Double
    }
    var platforms: [PlatformStruct] = []
    var teleportDistance : Double = 0.0
    var lastGroundSpawnTimeInterval : TimeInterval = 0
    var lastUpdateTimeInterval : TimeInterval = 0
    var ptu : Double = 0
    
    
    //Swipes
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    //Tap
    let tapRec = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        enemiesCanStillTakeHitsFrom = enemiesPassedToDie
        teleportDistance = Double(size.width) * 0.10
        backgroundColor = SKColor.white
        self.scaleMode = SKSceneScaleMode.resizeFill
        spriteView = self.view!
        player.setMoving(value: false)
        physicsWorld.contactDelegate = self
        //physicsWorld.gravity = CGVector.init(dx: 0, dy: -5)
        ptu = Double(1.0 / sqrt(SKPhysicsBody.init(rectangleOf: CGSize(width:1, height:1)).mass))
        
        
        initializePlayer()
        makeEnemiesIcon()
        invisiwallsMaker()
        setUpSwipes()
        makePauseButton()
        makeScoreLabel()
        makeGround()
        makeEnemiesCanStillTakeHitsFromLabel()
    
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.run(addGroundMonster), SKAction.wait(forDuration: 1)  ])))
    }
    
    override func update(_ currentTime: TimeInterval){
        //Can't jump above frame
        if self.player.position.y + CGFloat(xScaler)*size.height/2 >= 6/7*size.height {
            self.player.physicsBody?.velocity.dy = 0
        }
        //So don't get pushed off screen to the left
        if self.player.position.x < 0 {
            self.player.position.x = 0
            self.player.position.y -= CGFloat(xScaler)*size.height
            self.player.physicsBody?.velocity.dy = 0
        }
        
        //Let player move through platfroms if jumping, but not if stationary or falling
        if let body = player.physicsBody {
            let dy = body.velocity.dy
            if dy > 0 && !self.player.isMoving() {
                print("Caught the fucker!!!")
            }
            else if dy > 0 {
                // Prevent collisions if the hero is jumping
                for plat in platforms {
                    plat.platform.physicsBody?.collisionBitMask = PhysicsCategory.None
                }
                
                body.collisionBitMask &= ~PhysicsCategory.Platform
            }
            else {
                // Allow collisions if the hero is falling
                self.player.setMoving(value: false)
                body.collisionBitMask |= PhysicsCategory.Platform
                for plat in platforms {
                    plat.platform.physicsBody?.collisionBitMask = PhysicsCategory.Player
                }
            }
        }
    }
    
    func makeGround() {
        let rectangle = CGRect.init(x: 0, y: 0, width: size.width, height: 2)
        ground = SKShapeNode.init(rect: rectangle)
        ground.position = CGPoint(x: 0, y: size.height*1/7)
        ground.zPosition += 1
        ground.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: size.width, height: 2 + size.height/7*2), center: CGPoint(x: size.width/2, y: -size.height/7 + 1))
        
        ground.strokeColor = UIColor.black
        
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.linearDamping = 0
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.usesPreciseCollisionDetection = true
        ground.physicsBody?.friction = 0
        ground.physicsBody?.restitution = 0
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.None
        ground.physicsBody?.collisionBitMask = PhysicsCategory.Player
    
        addChild(ground)
        platforms.append(PlatformStruct(platform: ground, length: Double(size.width), height: Double(1/7*size.height)))
    }
    
    func addGroundMonster() {
        let randomEnemyNumber = Double(arc4random_uniform(UInt32(enemyRate)))
        if (randomEnemyNumber == 0) {
            let point: CGPoint = CGPoint(x: Double(size.width)*1.1, y: 2)
            let enemy = addEnemy(platform: ground, point: point)
        
        
        
            let time = (Double(size.width)*1.1 + xScaler*Double(size.width)) / Double(platformAndEnemySpeed)
            let move = SKAction.moveTo(x: -CGFloat(xScaler)*size.width, duration: TimeInterval(time))
            let moveDone = SKAction.removeFromParent()
            enemy.run(SKAction.sequence([move, moveDone]))
        }
    }
    
    func addPlatform() {
        let platformNumber: Double = Double(arc4random_uniform(4)) + 2
        let platHeight: Double = platformNumber / 7 * Double(size.height)
        let randomLength: Double = Double(arc4random_uniform(UInt32(maxPlatformLength-1))) + 1
        let platLength: Double = randomLength * Double(size.width) / Double(maxPlatformLength)
        
        var platform = SKShapeNode()
        let rectangle = CGRect.init(x: 0, y: 0, width: platLength, height: 2)
        platform = SKShapeNode.init(rect: rectangle)
        platform.position = CGPoint(x: size.width, y: CGFloat(platHeight))
        platform.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: platLength, height: 2), center: CGPoint(x: CGFloat(platLength/2), y: 2))
        
        platform.strokeColor = UIColor.black
        addChild(platform)
        platforms.append(PlatformStruct(platform: platform, length: platLength, height: platHeight))
        
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.linearDamping = 0
        platform.physicsBody?.usesPreciseCollisionDetection = true
        platform.physicsBody?.friction = 0
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.restitution = 0
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        platform.physicsBody?.contactTestBitMask = PhysicsCategory.None
        platform.physicsBody?.collisionBitMask = PhysicsCategory.Player

        
        for i in 1...Int(randomLength) {
            let randomEnemyNumber = Double(arc4random_uniform(UInt32(enemyRate)))
            //For each segment of platform, "1 in enemyRate" chance enemy spawned there
            if (randomEnemyNumber == 0) {
                let point: CGPoint = CGPoint(x: Double(i)*Double(size.width)/10 - (Double(size.width) * xScaler), y: 2)
                addEnemy(platform: platform, point: point)
            }
            
        }
        
        let time = (Double(size.width) + platLength) / Double(platformAndEnemySpeed)
        let move = SKAction.moveTo(x: -CGFloat(platLength), duration: TimeInterval(time))
        let moveDone = SKAction.removeFromParent()
        
        platform.run(SKAction.sequence([move, SKAction.run(
            {
                var flag : Bool = true
                var index : Int = 0
                while flag {
                    if self.platforms[index].platform.hashValue == platform.hashValue {
                        flag = false
                        self.platforms.remove(at: index)
                    }
                    index += 1
                }                   }), moveDone]))
    }
 
    /*  Enemy will be child of the platform that calls it.
        Enemy will be spawned at given CGPoint. */
    func addEnemy(platform: SKShapeNode, point : CGPoint)-> SKSpriteNode {
    
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
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.linearDamping = 0
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.friction = 0
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        return enemy
    }
    
    
    // what gets called when there's a single tap...
    //notice the sender is a parameter. This is why we added (_:) that part to the selector earlier
    
    func tappedView(_ sender:UITapGestureRecognizer) {
        var point:CGPoint = sender.location(in: self.view)
        point.y = size.height - point.y
        
        let node = self.atPoint(point)
        if node == pauseButton || node == pauseButton.label {
            pauseButtonHit()
            return
        }
        if node == areYouSure_Yes || node == areYouSure_Yes.label {
            areYouSure(value: true)
            return
        }
        if node == areYouSure_No || node == areYouSure_No.label  {
            areYouSure(value: false)
            return
        }
        if node == mainMenuButton || node == mainMenuButton.label {
            mainMenuButtonHit()
            return
        }
        
        if self.speed == 0 {
            return
        }
        
        // Set up initial location of projectile
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.position.x = player.position.x + (size.width * CGFloat(xScaler))/2
        bullet.position.y = player.position.y
        
        // Make bullet appropiate size
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler / 4
        bullet.scale(to: CGSize(width: width, height: height))
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy & PhysicsCategory.BulletRemoverWall
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        // Determine offset of location to projectile
        let offset = point - bullet.position
        
        // Get the direction of where to shoot
        let direction = offset.normalized()
        
        // Make it shoot far enough to be guaranteed off screen
        let shootAmount = direction * size.width
        
        // Add the shoot amount to the current position
        let destination = shootAmount + bullet.position
        
        // Rotate bullet so it's faces the proper direction
        let angle = atan2(direction.y, direction.x)
        bullet.zRotation += angle
        addChild(bullet)
        
        // Create the actions
        let actionMove = SKAction.move(to: destination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func swipedRight() {
        teleportRight()
    }
    
    func swipedLeft() {
        teleportLeft()
    }
    
    func swipedUp() {
        jumpUp()
    }
    
    func swipedDown() {
        jumpDown()
    }

    func bulletDidCollideWithEnemy(bullet: SKSpriteNode, enemy: SKSpriteNode) {
        enemiesKilled += 1
        score += 1
        updateScore()
        bullet.removeFromParent()
        enemy.removeFromParent()
    }
    
    func enemyCollideWithEnemyCounterWall() {
        enemiesCanStillTakeHitsFrom -= 1
        updateEnemiesCanStillTakeHitsFromLabel()
        if enemiesCanStillTakeHitsFrom <= 0 {
            gameOver()
        }
    }
    
    func bulletCollideWithBulletRemoverWall(node: SKNode) {
            node.physicsBody?.categoryBitMask = PhysicsCategory.None
            node.physicsBody?.contactTestBitMask = PhysicsCategory.None
    }
    
    func gameOver() {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, score: score)
        self.view?.presentScene(gameOverScene, transition: reveal)
    }
    
    func makeEnemiesCanStillTakeHitsFromLabel() {
        enemiesCanStillTakeHitsFromLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        enemiesCanStillTakeHitsFromLabel.text = String(enemiesCanStillTakeHitsFrom)
        enemiesCanStillTakeHitsFromLabel.fontSize = 25
        enemiesCanStillTakeHitsFromLabel.fontColor = SKColor.red
        enemiesCanStillTakeHitsFromLabel.position = CGPoint(x: size.width*15/100, y: size.height*88/100)
        enemiesCanStillTakeHitsFromLabel.zPosition += 100
        addChild(enemiesCanStillTakeHitsFromLabel)
    }
    
    func makeScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        scoreLabel.text = String(score)
        scoreLabel.fontSize = 25
        scoreLabel.fontColor = SKColor.yellow
        scoreLabel.position = CGPoint(x: size.width*93/100, y: size.height*88/100)
        scoreLabel.zPosition += 100
        addChild(scoreLabel)
    }
    
    func setUpSwipes() {
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
        
        tapRec.addTarget(self, action:#selector(self.tappedView(_:) ))
        tapRec.numberOfTouchesRequired = 1
        tapRec.numberOfTapsRequired = 1
        self.view!.addGestureRecognizer(tapRec)
    }
    
    func updateEnemiesCanStillTakeHitsFromLabel() {
        enemiesCanStillTakeHitsFromLabel.text = String(enemiesCanStillTakeHitsFrom)
    }
    
    func updateScore() {
        scoreLabel.text = String(score)
    }
    
    func makePauseButton() {
        let path = CGRect.init(x: size.width*1/100, y: size.height*35/1000, width: size.width*14/100, height: size.height*7/100)
        pauseButton = Button.init(rect: path, cornerRadius: 5)
        pauseButton.strokeColor = UIColor.black
        pauseButton.fillColor = UIColor.white
        pauseButton.zPosition = 100
        pauseButton.createLabel(message: "Pause", fontSize: 10, color: SKColor.blue, position: CGPoint(x: size.width*8/100, y: size.height*5/100), zPosition: 150)
        addChild(pauseButton)
    }
    
    func makeEnemiesIcon() {
        enemiesCanStillTakeHitsFromIcon.anchorPoint = CGPoint(x: 0, y: 0)
        enemiesCanStillTakeHitsFromIcon.position = CGPoint(x: size.width * 0.05, y: size.height * 0.88)
        enemiesCanStillTakeHitsFromIcon.zPosition += 50
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        enemiesCanStillTakeHitsFromIcon.scale(to: CGSize(width: width, height: height))
        addChild(enemiesCanStillTakeHitsFromIcon)
    }
    
    func makeMainMenuButton() {
        let path = CGRect.init(x: size.width*83/100, y: size.height*35/1000, width: size.width*14/100, height: size.height*7/100)
        mainMenuButton = Button.init(rect: path, cornerRadius: 5)
        mainMenuButton.strokeColor = UIColor.black
        mainMenuButton.fillColor = UIColor.white
        mainMenuButton.zPosition = 100
        mainMenuButton.createLabel(message: "Menu", fontSize: 10, color: SKColor.blue, position: CGPoint(x: size.width*90/100, y: size.height*5/100), zPosition: 150)
        addChild(mainMenuButton)
    }
    
    func mainMenuButtonHit() {
        makeAreYouSureButtons(type: "menu")
    }
    
    func areYouSure(value: Bool) {
        if areYouSure_Yes.getButtonType() == "menu" && value {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let mainMenuScene = MainMenuScene(size: self.size)
            self.view?.presentScene(mainMenuScene, transition: reveal)
        }
        if areYouSure_Yes.getButtonType() == "play again" && value {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let newGameScene = GameScene(size: self.size)
            self.view?.presentScene(newGameScene, transition: reveal)
        }
        
        areYouSureLabel.removeFromParent()
        areYouSure_Yes.removeFromParent()
        areYouSure_No.removeFromParent()
    }
    
    func pauseButtonHit() {
        if self.speed == 1 {
            self.speed = 0
            physicsWorld.speed = 0
            pauseButton.setLabelText(message: "Resume")
            makeMainMenuButton()
            return
        }
        pauseButton.setLabelText(message: "Pause")
        mainMenuButton.removeFromParent()
        self.speed = 1
        physicsWorld.speed = 1
        return
    }
    
    func makeAreYouSureButtons(type: String) {
        areYouSureLabel.text = "Are you sure?"
        areYouSureLabel.fontSize = 20
        areYouSureLabel.fontColor = SKColor.blue
        areYouSureLabel.position = CGPoint(x: size.width/2, y: size.height*0.66)
        areYouSureLabel.zPosition = 150
        addChild(areYouSureLabel)
        
        
        let path = CGRect.init(x: size.width*34/100, y: size.height*44/100, width: size.width*14/100, height: size.height*7/100)
        areYouSure_Yes = Button.init(rect: path, cornerRadius: 5)
        areYouSure_Yes.setButtonType(type: type)
        areYouSure_Yes.strokeColor = UIColor.black
        areYouSure_Yes.fillColor = UIColor.white
        areYouSure_Yes.zPosition = 100
        areYouSure_Yes.createLabel(message: "Yes", fontSize: 10, color: SKColor.black, position: CGPoint(x: size.width*0.42, y: size.height * 0.45), zPosition: 150)
        addChild(areYouSure_Yes)
        
        let path2 = CGRect.init(x: size.width*0.50, y: size.height*44/100, width: size.width*14/100, height: size.height*7/100)
        areYouSure_No = Button.init(rect: path2, cornerRadius: 5)
        areYouSure_No.setButtonType(type: type)
        areYouSure_No.strokeColor = UIColor.black
        areYouSure_No.fillColor = UIColor.white
        areYouSure_No.zPosition = 100
        areYouSure_No.createLabel(message: "No", fontSize: 10, color: SKColor.black, position: CGPoint(x: size.width*0.57, y: size.height * 0.45), zPosition: 150)
        addChild(areYouSure_No)
        
    }
    
    func teleportRight() {
        //If no more screen in front, do nothing & return
        if Double(player.position.x) + teleportDistance + xScaler * Double(size.width) / 2 >= Double(size.width)  {
            player.position.x = size.width - CGFloat(xScaler) * size.width
            return
        }
        player.position.x += CGFloat(teleportDistance)
    }
    
    func teleportLeft() {
        //If no more screen behind, do nothing & return
        if player.position.x - CGFloat(teleportDistance) + size.width * CGFloat(xScaler)/2 < 0  {
            player.position.x = 0
            return
        }
        player.position.x -= CGFloat(teleportDistance)
    }
 
    func jumpUp() {
        //If no platforms possibly above, do nothing & return
        if self.player.position.y + CGFloat(xScaler)*size.height >= 6/7*size.height {
            return
        }
        
        let dy = player.physicBody?.mass * sqrt(2 * -self.physicsWorld.gravity.dy * (size.height*2/7 * ptu))
        player.setMoving(value: true)
        let vector = CGVector.init(dx: 0, dy: dy)
        player.physicsBody?.applyImpulse(vector)
        
    }
 
    
    func jumpDown() {
        player.setMoving(value: false)
        
        //If no platforms possibly below, do nothing & return
        if Double(player.position.y) <= (1 / 7 * Double(size.height)) {
            return
        }
        let vector = CGVector.init(dx: 0, dy: -Double(size.height)*0.08)
        player.physicsBody?.applyImpulse(vector)
        
    }
    
    func invisiwallsMaker() {
        //enemyCounterWall
        let rectangle = CGRect.init(x: 0, y: 0, width: 2, height: Double(size.height))
        enemyCounterWall = SKShapeNode.init(rect: rectangle)
        enemyCounterWall.position = CGPoint(x: -xScaler*Double(size.width)-1, y: Double(size.height)/2)
        enemyCounterWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: size.height))
        enemyCounterWall.physicsBody?.isDynamic = false
        enemyCounterWall.physicsBody?.categoryBitMask = PhysicsCategory.EnemyCounterWall
        enemyCounterWall.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        enemyCounterWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        addChild(enemyCounterWall)
        
        //bulletRemoverWall
        //let rectangle2 = CGRect.init(x: 0, y: 0, width: 2, height: Double(size.height))
        bulletRemoverWall = SKShapeNode.init(rect: rectangle)
        bulletRemoverWall.position = CGPoint(x: size.width + 1, y: size.height/2)
        bulletRemoverWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: size.height))
        bulletRemoverWall.physicsBody?.isDynamic = false
        bulletRemoverWall.physicsBody?.categoryBitMask = PhysicsCategory.BulletRemoverWall
        bulletRemoverWall.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        bulletRemoverWall.physicsBody?.collisionBitMask = PhysicsCategory.None
        addChild(bulletRemoverWall)
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
        // Check if enemy & enemyCounterWall collide
        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.EnemyCounterWall != 0)) {
                enemyCollideWithEnemyCounterWall()
        }
        
        // Check if bullet & bulletRemoverWall collide
        if ((firstBody.categoryBitMask & PhysicsCategory.Bullet != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.BulletRemoverWall != 0)) {
            if firstBody.node != nil {
                bulletCollideWithBulletRemoverWall(node: firstBody.node!)
            }
        }
    }
 
    func initializePlayer() {
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 1 / 7 + CGFloat(yScaler)*size.height)
        player.zPosition = 0
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        player.scale(to: CGSize(width: width, height: height))
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.linearDamping = 0
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        player.physicsBody?.friction = 0
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.Platform
    }
}

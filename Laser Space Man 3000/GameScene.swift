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
    static let Player               : UInt32         = 0b1
    static let Bullet               : UInt32         = 0b10
    static let Platform             : UInt32         = 0b100
    static let Barrier              : UInt32         = 0b1000
    static let EnemyCounterWall     : UInt32         = 0b10000
    static let BulletRemoverWall    : UInt32         = 0b100000
    static let ShootEnemy           : UInt32         = 0b1000000
    static let RamEnemy             : UInt32         = 0b10000000
    static let Powerup              : UInt32         = 0b100000000
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
    
    //var spriteView = SKView()
    let buttonManager = ButtonManager()
    var player = MyPlayerNode()
    var ground = SKShapeNode()
    let enemiesCanStillTakeHitsFromIcon = SKSpriteNode(imageNamed: "Spider RESIZE-1")
    var enemyCounterWall = SKShapeNode()
    var bulletRemoverWall = SKShapeNode()
    var barrier = SKShapeNode()
    var pauseButton = Button()
    var mainMenuButton = Button()
    var areYouSureLabel = SKLabelNode(fontNamed: "Fipps-Regular")
    var areYouSure_Yes = Button()
    var areYouSure_No = Button()
    var scoreLabel = SKLabelNode()
    var enemiesCanStillTakeHitsFromLabel = SKLabelNode()
    let xScaler: Double = 0.06
    let yScaler: Double = 0.12
    var score: Int = 0
    let maxPlatformLength = 15
    let platformAndEnemySpeed = 100
    let enemiesPassedToDie = 30
    let segmentLength = 10 //# of platform segments/ size.width
    var enemiesCanStillTakeHitsFrom: Int = 0
    var enemiesPassed : Int = 0
    let shootEmemyRate = 3   //0 means max enemies, higher numer means less enemies
    let ramEnemyRate = 10
    let powerupRate = 3
    struct PlatformStruct {
        let platform : SKShapeNode
        let length : Double
        let height : Double
        var swipeDownThrough : Bool
    }
    var platforms: [PlatformStruct] = []
    var doublePlatformPreventerArray: [Int] = [0,0,0,0]
    var lastGroundSpawnTimeInterval : TimeInterval = 0
    var lastUpdateTimeInterval : TimeInterval = 0
    var runningFrames : [SKTexture]!
    var ptu : CGFloat = 0
    var jumpVector : CGFloat = 0
    var areYouSureDisplayed : Bool = false
    var invincible : Int = 0
    var speedBullets : Int = 0
    
    
    //Swipes
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    //Tap
    let tapRec = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        enemiesCanStillTakeHitsFrom = enemiesPassedToDie
        backgroundColor = SKColor.gray
        self.scaleMode = SKSceneScaleMode.resizeFill
        //spriteView = self.view!
        physicsWorld.contactDelegate = self
        player.initializePlayer(gameScene: self)
    
        let body = SKPhysicsBody.init(rectangleOf: CGSize(width: 1, height: 1))
        ptu = 1.0 / sqrt(body.mass)
        let mass: CGFloat = (player.physicsBody?.mass)!
        jumpVector = mass * sqrt(2 * -self.physicsWorld.gravity.dy * ((size.height*2/7 + 5) * ptu))
        
        player.beginRunAnimation()
        makeButtons()
        invisiwallsMaker()
        setUpSwipes()
        makeScoreLabel()
        makeGround()
        makeEnemiesCanStillTakeHitsFromLabel()
    
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.run(addGroundMonster), SKAction.wait(forDuration: 1)  ])))
        //run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addGroundMonster), SKAction.wait(forDuration: 1)  ])))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if self.invincible == 1 {
            player.scale(to: CGSize(width: size.width*CGFloat(xScaler), height: size.height*CGFloat(yScaler)))
            player.putShirtOn()
        }
        
        //Let player move through platfroms if jumping, but not if stationary or falling
        if let body = player.physicsBody {
            let dy = body.velocity.dy
            let dx = body.velocity.dx
            
            if !(self.player.isMoving(direction: "up") || self.player.isMoving(direction: "down") || self.player.isMoving(direction: "right") || self.player.isMoving(direction: "left")) {
                self.player.beginRunAnimation()
            }
            
            
            
            if dx == 0 {
                self.player.setMoving(direction: "left", value: false)
                self.player.setMoving(direction: "right", value: false)
            }
            
            if dy > 0 && !self.player.isMoving(direction: "up") {
                
            }
            else if dy > 0 {
                self.player.setMoving(direction: "down", value: false)
                
                // Prevent collisions if the hero is jumping
                for var plat in platforms {
                    plat.platform.physicsBody?.categoryBitMask = PhysicsCategory.Platform
                    plat.platform.physicsBody?.collisionBitMask = PhysicsCategory.None
                    plat.swipeDownThrough = false
                }
                body.collisionBitMask &= ~PhysicsCategory.Platform
            }
            else if dy == 0 {
                self.player.setMoving(direction: "down", value: false)
            }
            else {
                // Allow collisions if the hero is falling
                self.player.setMoving(direction: "up", value: false)
                self.player.setMoving(direction: "down", value: true)
                body.collisionBitMask |= PhysicsCategory.Platform
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
        ground.fillColor = UIColor.black
        
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.affectedByGravity = false
        ground.physicsBody?.linearDamping = 0
        ground.physicsBody?.allowsRotation = false
        ground.physicsBody?.usesPreciseCollisionDetection = true
        ground.physicsBody?.friction = 1
        ground.physicsBody?.restitution = 0
        ground.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.None
        ground.physicsBody?.collisionBitMask = PhysicsCategory.Player
    
        addChild(ground)
        platforms.append(PlatformStruct(platform: ground, length: Double(size.width), height: Double(1/7*size.height), swipeDownThrough: false))
    }
    
    func addGroundMonster() {
        let randomShootNumber = Double(arc4random_uniform(UInt32(shootEmemyRate)))
        let randomRamNumber = Double(arc4random_uniform(UInt32(ramEnemyRate)))
        let randomPowerupNumber = Double(arc4random_uniform(UInt32(powerupRate)))
        let point: CGPoint = CGPoint(x: Double(size.width)*1.1, y: 2)
        let time = (Double(size.width)*1.1 + xScaler*Double(size.width)) / Double(platformAndEnemySpeed)
        let move = SKAction.moveTo(x: -CGFloat(xScaler)*size.width, duration: TimeInterval(time))
        let moveDone = SKAction.removeFromParent()
        
        
        if (randomShootNumber == 0) {
            let shootEnemy = addShootEnemy(platform: ground, point: point)
            shootEnemy.run(SKAction.sequence([move, moveDone]))
        } else if randomRamNumber == 0 {
            let ramEnemy = addRamEnemy(platform: ground, point: point)
            ramEnemy.run(SKAction.sequence([move, moveDone]))
        }
        else if randomPowerupNumber == 0 {
            let powerup = addSpeedBullet(platform: ground, point: point)
            powerup.run(SKAction.sequence([move, moveDone]))
        }
        else if randomPowerupNumber == 1 {
            let powerup = addBonusLives(platform: ground, point: point)
            powerup.run(SKAction.sequence([move, moveDone]))
        }
        else if randomPowerupNumber == 2 {
            let powerup = addInvincible(platform: ground, point: point)
            powerup.run(SKAction.sequence([move, moveDone]))
        }
    }
    
    func addPlatform() {
        let platformNumber : Int = Int(arc4random_uniform(4)) + 2
        if doublePlatformPreventerArray[platformNumber - 2] > 0  {
            return
        }
        let platHeight: Double = Double(platformNumber) / 7 * Double(size.height)
        let randomLength: Int = Int(arc4random_uniform(UInt32(maxPlatformLength-1))) + 4
        let platLength: Double = Double(randomLength) * Double(size.width) / Double(segmentLength)
        
        var platform = SKShapeNode()
        let rectangle = CGRect.init(x: 0, y: 0, width: platLength, height: 2)
        platform = SKShapeNode.init(rect: rectangle)
        platform.position = CGPoint(x: size.width, y: CGFloat(platHeight))
        platform.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: platLength, height: 2), center: CGPoint(x: CGFloat(platLength/2), y: 2))
        
        platform.strokeColor = UIColor.black
        platform.fillColor = UIColor.black
        addChild(platform)
        platforms.append(PlatformStruct(platform: platform, length: platLength, height: platHeight, swipeDownThrough: false))
        
        platform.physicsBody?.isDynamic = false
        platform.physicsBody?.affectedByGravity = false
        platform.physicsBody?.linearDamping = 0
        platform.physicsBody?.usesPreciseCollisionDetection = true
        platform.physicsBody?.friction = 1
        platform.physicsBody?.allowsRotation = false
        platform.physicsBody?.restitution = 0
        platform.physicsBody?.categoryBitMask = PhysicsCategory.Platform
        platform.physicsBody?.contactTestBitMask = PhysicsCategory.None
        platform.physicsBody?.collisionBitMask = PhysicsCategory.Player

        
        for i in 1...randomLength {
            let randomShootNumber = Double(arc4random_uniform(UInt32(shootEmemyRate)))
            let randomRamNumber = Double(arc4random_uniform(UInt32(ramEnemyRate)))
            let randomPowerupNumber = Double(arc4random_uniform(UInt32(powerupRate)))
            let point: CGPoint = CGPoint(x: Double(i)*Double(size.width)/Double(segmentLength) - (Double(size.width) * xScaler), y: 2)
            
            //For each segment of platform, "1 in shootEmemyRate" chance enemy spawned there
            if randomShootNumber == 0 {
                addShootEnemy(platform: platform, point: point)
            }
            else if randomRamNumber == 0 {
                addRamEnemy(platform: platform, point: point)
            }
            else if randomPowerupNumber == 0 {
                addSpeedBullet(platform: platform, point: point)
            }
            else if randomPowerupNumber == 1 {
                addBonusLives(platform: platform, point: point)
            }
            else if randomPowerupNumber == 2 {
                addInvincible(platform: platform, point: point)
            }
        }
        //Gap between platforms
        doublePlatformPreventerArray[platformNumber - 2] += 1
        let timeForGap = (3 * Double(size.width) / Double(maxPlatformLength)) / Double(platformAndEnemySpeed)
        let timeForLastSegmentToEnterScreen = platLength / Double(platformAndEnemySpeed)
        
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: timeForGap + timeForLastSegmentToEnterScreen),
            SKAction.run({              self.doublePlatformPreventerArray[platformNumber - 2] -= 1               })]))
        
        
        
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
    func addShootEnemy(platform: SKShapeNode, point : CGPoint)-> SKSpriteNode {
        let texture = SKTexture(imageNamed: "Spider RESIZE-1")
        let shootEnemy = SKSpriteNode.init(texture: texture, color: SKColor.clear, size: texture.size())
        shootEnemy.position = point
        shootEnemy.anchorPoint = CGPoint(x: 0, y: 0)
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        shootEnemy.scale(to: CGSize(width: width, height: height))
        
        platform.addChild(shootEnemy)
        
        shootEnemy.physicsBody = SKPhysicsBody(rectangleOf: shootEnemy.size, center: CGPoint(x: width/2, y: height/2))
        shootEnemy.physicsBody?.isDynamic = true
        shootEnemy.physicsBody?.categoryBitMask = PhysicsCategory.ShootEnemy
        shootEnemy.physicsBody?.affectedByGravity = false
        shootEnemy.physicsBody?.linearDamping = 0
        shootEnemy.physicsBody?.allowsRotation = false
        shootEnemy.physicsBody?.friction = 0
        shootEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet | PhysicsCategory.Player | PhysicsCategory.EnemyCounterWall
        shootEnemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        
        
        let textureAtlas = SKTextureAtlas(named: "ShootEnemy")
        let frames = ["Spider RESIZE-1", "Spider RESIZE-2"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        let forever = SKAction.repeatForever(animate)
        shootEnemy.run(forever)
        
        return shootEnemy
    }
    
    func addRamEnemy(platform: SKShapeNode, point : CGPoint)-> SKSpriteNode {
        let texture = SKTexture(imageNamed: "Dragon RESIZE-1")
        let ramEnemy = SKSpriteNode.init(texture: texture, color: SKColor.clear, size: texture.size())
        ramEnemy.position = point
        ramEnemy.anchorPoint = CGPoint(x: 0, y: 0)
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        ramEnemy.scale(to: CGSize(width: width, height: height))
        
        platform.addChild(ramEnemy)
        
        ramEnemy.physicsBody = SKPhysicsBody(rectangleOf: ramEnemy.size, center: CGPoint(x: width/2, y: height/2))
        ramEnemy.physicsBody?.isDynamic = true
        ramEnemy.physicsBody?.categoryBitMask = PhysicsCategory.RamEnemy
        ramEnemy.physicsBody?.affectedByGravity = false
        ramEnemy.physicsBody?.linearDamping = 0
        ramEnemy.physicsBody?.allowsRotation = false
        ramEnemy.physicsBody?.friction = 0
        ramEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet | PhysicsCategory.Player | PhysicsCategory.EnemyCounterWall
        ramEnemy.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        let textureAtlas = SKTextureAtlas(named: "RamEnemy")
        let frames = ["Dragon RESIZE-1", "Dragon RESIZE-2"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        let forever = SKAction.repeatForever(animate)
        ramEnemy.run(forever)
        
        return ramEnemy
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
        
        // Make bullet appropiate size
        let width: Double = Double(size.width) * xScaler / 3 * 2
        let height: Double = Double(size.height) * yScaler / 8
        
        
        
        
        /*
        platform.position = CGPoint(x: size.width, y: CGFloat(platHeight))
        platform.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: platLength, height: 2), center: CGPoint(x: CGFloat(platLength/2), y: 2))
        */
        // Set up initial location of projectile
        var bullet = SKShapeNode()
        let rectangle = CGRect.init(x: 0, y: 0, width: width, height: height)
        bullet = SKShapeNode.init(rect: rectangle)
        bullet.position = CGPoint(x: player.position.x, y: player.position.y)
    
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height), center: CGPoint(x: width/2, y: height/2))
        
        bullet.strokeColor = SKColor.black
        bullet.fillColor = SKColor.orange
        
        
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.ShootEnemy | PhysicsCategory.BulletRemoverWall
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
        bullet.zPosition += 20
        addChild(bullet)
        
        // Create the actions
        
        var actionMove = SKAction.move(to: destination, duration: 2.0)
        if speedBullets > 0 {
            bullet.fillColor = UIColor.blue
            bullet.strokeColor = UIColor.blue
            actionMove = SKAction.move(to: destination, duration: 1.0)
        }
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func addSpeedBullet(platform: SKShapeNode, point: CGPoint)->Powerup {
        let texture = SKTexture(imageNamed: "Lightning")
        let speedBullet = Powerup.init(texture: texture, color: SKColor.clear, size: texture.size())
        speedBullet.setType(type: "speedBullet")
        speedBullet.position = point
        speedBullet.anchorPoint = CGPoint(x: 0, y: 0)
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        speedBullet.scale(to: CGSize(width: width, height: height))
        platform.addChild(speedBullet)
        
        speedBullet.physicsBody = SKPhysicsBody(rectangleOf: speedBullet.size, center: CGPoint(x: width/2, y: height/2))
        speedBullet.physicsBody?.isDynamic = true
        speedBullet.physicsBody?.categoryBitMask = PhysicsCategory.Powerup
        speedBullet.physicsBody?.affectedByGravity = false
        speedBullet.physicsBody?.linearDamping = 0
        speedBullet.physicsBody?.allowsRotation = false
        speedBullet.physicsBody?.friction = 0
        speedBullet.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        speedBullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        return speedBullet
    }
    
    func addInvincible(platform: SKShapeNode, point: CGPoint)->Powerup {
        let texture = SKTexture(imageNamed: "Spinach")
        let invincible = Powerup.init(texture: texture, color: SKColor.clear, size: texture.size())
        invincible.setType(type: "invincible")
        invincible.position = point
        invincible.anchorPoint = CGPoint(x: 0, y: 0)
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        invincible.scale(to: CGSize(width: width, height: height))
        platform.addChild(invincible)
        
        invincible.physicsBody = SKPhysicsBody(rectangleOf: invincible.size, center: CGPoint(x: width/2, y: height/2))
        invincible.physicsBody?.isDynamic = true
        invincible.physicsBody?.categoryBitMask = PhysicsCategory.Powerup
        invincible.physicsBody?.affectedByGravity = false
        invincible.physicsBody?.linearDamping = 0
        invincible.physicsBody?.allowsRotation = false
        invincible.physicsBody?.friction = 0
        invincible.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        invincible.physicsBody?.collisionBitMask = PhysicsCategory.None
        
        return invincible
    }
    
    func addBonusLives(platform: SKShapeNode, point: CGPoint)->Powerup {
        let texture = SKTexture(imageNamed: "Heart")
        let bonusLives = Powerup.init(texture: texture, color: SKColor.clear, size: texture.size())
        bonusLives.setType(type: "bonusLives")
        bonusLives.position = point
        bonusLives.anchorPoint = CGPoint(x: 0, y: 0)
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        bonusLives.scale(to: CGSize(width: width, height: height))
        platform.addChild(bonusLives)
        
        bonusLives.physicsBody = SKPhysicsBody(rectangleOf: bonusLives.size, center: CGPoint(x: width/2, y: height/2))
        bonusLives.physicsBody?.isDynamic = true
        bonusLives.physicsBody?.categoryBitMask = PhysicsCategory.Powerup
        bonusLives.physicsBody?.affectedByGravity = false
        bonusLives.physicsBody?.linearDamping = 0
        bonusLives.physicsBody?.allowsRotation = false
        bonusLives.physicsBody?.friction = 0
        bonusLives.physicsBody?.contactTestBitMask = PhysicsCategory.Player
        bonusLives.physicsBody?.collisionBitMask = PhysicsCategory.None
        return bonusLives
    }
    
    func playerDidCollideWithRamEnemy(ramEnemy: SKSpriteNode) {
        if invincible > 0 {
            score += 1
            updateScore()
            ramEnemy.removeFromParent()
            return
        }
        if player.isMoving(direction: "up") || player.isMoving(direction: "down") ||
            player.isMoving(direction: "right") || player.isMoving(direction: "left") {
            score += 1
            updateScore()
            ramEnemy.removeFromParent()
        }
        else {
            gameOver()
        }
    }

    func bulletDidCollideWithEnemy(bullet: SKShapeNode, enemy: SKSpriteNode, type: String) {
        if type == "shoot" {
            score += 1
            updateScore()
            enemy.removeFromParent()
        }
        bullet.removeFromParent()
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
    
    func playerDidCollideWithPowerup(powerup: Powerup) {
        if powerup.getType() == "speedBullet" {
            self.speedBullets += 1
            self.run(SKAction.sequence([SKAction.wait(forDuration: 10),
                SKAction.run({  self.speedBullets -= 1 })]))
        }
        else if powerup.getType() == "invincible" {
            if self.invincible == 0 || self.invincible == 1 {
                self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run(scale1), SKAction.wait(forDuration: 0.5), SKAction.run(scale2), SKAction.wait(forDuration: 0.5), SKAction.run(scale3)]))
            }
            self.invincible += 10
            self.run(SKAction.sequence([SKAction.wait(forDuration: 9), SKAction.run({  self.invincible -= 9 }), SKAction.wait(forDuration: 1), SKAction.run({  self.invincible -= 1 })]))
        } else {
            enemiesCanStillTakeHitsFrom += 10
            updateEnemiesCanStillTakeHitsFromLabel()
        }
        player.beginTearingAnimation()
        powerup.removeFromParent()
    }
    func scale1() {self.player.scale(to: CGSize(width: size.width*CGFloat(xScaler)*1.05, height: size.height*CGFloat(yScaler)*1.06))}
    func scale2() {self.player.scale(to: CGSize(width: size.width*CGFloat(xScaler)*1.11, height: size.height*CGFloat(yScaler)*1.12))}
    func scale3() {self.player.scale(to: CGSize(width: size.width*CGFloat(xScaler)*1.16, height: size.height*CGFloat(yScaler)*1.16))}
    
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
        swipeRightRec.addTarget(self, action: #selector(moveRight) )
        swipeRightRec.direction = .right
        self.view!.addGestureRecognizer(swipeRightRec)
        
        swipeLeftRec.addTarget(self, action: #selector(moveLeft) )
        swipeLeftRec.direction = .left
        self.view!.addGestureRecognizer(swipeLeftRec)
        
        swipeUpRec.addTarget(self, action: #selector(jumpUp) )
        swipeUpRec.direction = .up
        self.view!.addGestureRecognizer(swipeUpRec)
        
        swipeDownRec.addTarget(self, action: #selector(jumpDown) )
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
    
    func makeButtons() {
        pauseButton = buttonManager.makePauseButton(gameScene: self)
        buttonManager.makeEnemiesIcon(icon: enemiesCanStillTakeHitsFromIcon, gameScene: self)
    }
    
    func mainMenuButtonHit() {
        if areYouSureDisplayed {
            return
        }
        makeAreYouSureButtons()
    }
    
    func areYouSure(value: Bool) {
        if value {
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            let mainMenuScene = MainMenuScene(size: self.size)
            self.view?.presentScene(mainMenuScene, transition: reveal)
        }
        
        
        areYouSureDisplayed = false
        areYouSureLabel.removeFromParent()
        areYouSure_Yes.removeFromParent()
        areYouSure_No.removeFromParent()
    }
    
    func pauseButtonHit() {
        if areYouSureDisplayed {
            return
        }
        if self.speed == 1 {
            self.speed = 0
            physicsWorld.speed = 0
            pauseButton.setLabelText(message: "Resume")
            mainMenuButton = buttonManager.makeMainMenuButton(gameScene: self)  //make mainMenuButton
            return
        }
        pauseButton.setLabelText(message: "Pause")
        mainMenuButton.removeFromParent()
        areYouSure(value: false)
        self.speed = 1
        physicsWorld.speed = 1
        return
    }
    
    func makeAreYouSureButtons() {
        areYouSureLabel = buttonManager.makeAreYouSureLabel(gameScene: self)
        areYouSure_Yes = buttonManager.makeAreYouSureYes(gameScene: self)
        areYouSure_No = buttonManager.makeAreYouSureNo(gameScene: self)
    }
        
    func moveRight() {
        if self.speed == 0 {
            return
        }
        //if !player.isMoving(direction: "up") && !player.isMoving(direction: "down") {
            player.beginKickAnimation()
            player.setMoving(direction: "right", value: true)
            let vector = CGVector.init(dx: size.width*0.05, dy: 0)
            player.physicsBody?.applyImpulse(vector)
        //}
    }
    
    func moveLeft() {
        if self.speed == 0 {
            return
        }
        //if !player.isMoving(direction: "up") && !player.isMoving(direction: "down") {
            player.beginReverseKickAnimation()
            player.setMoving(direction: "left", value: true)
            let vector = CGVector.init(dx: -size.width*0.05, dy: 0)
            player.physicsBody?.applyImpulse(vector)
        //}
    }
 
    func jumpUp() {
        if self.speed == 0 {
            return
        }
        player.setMoving(direction: "up", value: true)
        player.beginJumpAnimation()
        let vector = CGVector.init(dx: 0, dy: jumpVector)
        player.physicsBody?.applyImpulse(vector)
    }
    
    func jumpDown() {
        if self.speed == 0 {
            return
        }
        player.setMoving(direction: "up", value: false)
        player.setMoving(direction: "down", value: true)
        player.beginJumpAnimation()
        for var plat in platforms {
            if invincible == 0 {
                if (CGFloat(plat.height)*1.03 > (player.position.y - CGFloat(yScaler)*size.height/2) && CGFloat(plat.height)*0.97 < player.position.y - CGFloat(yScaler)*size.height/2) &&
                       (plat.platform.position.x - CGFloat(xScaler)*size.width/2*3 <= player.position.x && plat.platform.position.x + CGFloat(plat.length) >= player.position.x - 3/2*size.width*CGFloat(xScaler)) {
                    if !(plat.platform.position.y*1.03 > ground.position.y && plat.platform.position.y*0.97 < ground.position.y) {
                        plat.platform.physicsBody?.categoryBitMask = PhysicsCategory.None
                        plat.platform.physicsBody?.collisionBitMask = PhysicsCategory.None
                        plat.swipeDownThrough =  true
                    }
                }
            }
            else {
                if (CGFloat(plat.height)*1.03 > (player.position.y - CGFloat(yScaler)*size.height/2*1.16) && CGFloat(plat.height)*0.97 < player.position.y - CGFloat(yScaler)*size.height/2*1.16) &&
                    (plat.platform.position.x - CGFloat(xScaler)*size.width/2*3 <= player.position.x && plat.platform.position.x + CGFloat(plat.length) >= player.position.x - 3/2*size.width*CGFloat(xScaler)) {
                    if !(plat.platform.position.y*1.03 > ground.position.y && plat.platform.position.y*0.97 < ground.position.y) {
                        plat.platform.physicsBody?.categoryBitMask = PhysicsCategory.None
                        plat.platform.physicsBody?.collisionBitMask = PhysicsCategory.None
                        plat.swipeDownThrough =  true
                    }
                }
            }
        }
        
        let vector = CGVector.init(dx: 0, dy: -jumpVector)
        player.physicsBody?.applyImpulse(vector)
        
    }
    
    func invisiwallsMaker() {
        //barrier
        let rectangle3 = CGRect.init(x: 0, y: 0, width: size.width, height: size.height*6/7)
        barrier = SKShapeNode.init(rect: rectangle3)
        barrier.physicsBody = SKPhysicsBody(edgeLoopFrom: rectangle3)
        barrier.strokeColor = SKColor.clear
        barrier.physicsBody?.isDynamic = false
        barrier.physicsBody?.restitution = 0
        barrier.physicsBody?.categoryBitMask = PhysicsCategory.Barrier
        barrier.physicsBody?.contactTestBitMask = PhysicsCategory.None
        barrier.physicsBody?.collisionBitMask = PhysicsCategory.Player
        addChild(barrier)
        
        //enemyCounterWall
        let rectangle = CGRect.init(x: 0, y: 0, width: 2, height: Double(size.height))
        enemyCounterWall = SKShapeNode.init(rect: rectangle)
        enemyCounterWall.position = CGPoint(x: -xScaler*Double(size.width)-1, y: Double(size.height)/2)
        enemyCounterWall.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 2, height: size.height))
        enemyCounterWall.physicsBody?.isDynamic = false
        enemyCounterWall.physicsBody?.categoryBitMask = PhysicsCategory.EnemyCounterWall
        enemyCounterWall.physicsBody?.contactTestBitMask = PhysicsCategory.ShootEnemy | PhysicsCategory.RamEnemy
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
    
    func playerDidCollideWithShootEnemy(shootEnemy: SKSpriteNode) {
        if invincible > 0 {
            shootEnemy.removeFromParent()
            score += 1
            updateScore()
            return
        }
        gameOver()
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
        
        
        // Check if player & powerup collide
        if (firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Powerup != 0) {
            
            if secondBody.node != nil {
                playerDidCollideWithPowerup(powerup: secondBody.node! as! Powerup)
            }

        }
        
        // Check if player & shootEnemy collide
        if (firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ShootEnemy != 0) {
            if let shootEnemy = secondBody.node as? SKSpriteNode {
                playerDidCollideWithShootEnemy(shootEnemy: shootEnemy)
            }
        }
        
        // Check if player & ramEnemy collide
        if (firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.RamEnemy != 0) {
            if let ramEnemy = secondBody.node as? SKSpriteNode {
                playerDidCollideWithRamEnemy(ramEnemy: ramEnemy)
            }
        }
        
        // Check if shootEnemy & bullet collide
        if (firstBody.categoryBitMask & PhysicsCategory.Bullet != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ShootEnemy != 0) {
            if let bullet = firstBody.node as? SKShapeNode, let
                shootEnemy = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithEnemy(bullet: bullet, enemy: shootEnemy, type: "shoot")
            }
        }
        
        // Check if ramEnemy & bullet collide
        if (firstBody.categoryBitMask & PhysicsCategory.Bullet != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.RamEnemy != 0) {
            if let bullet = firstBody.node as? SKShapeNode, let
                ramEnemy = secondBody.node as? SKSpriteNode {
                bulletDidCollideWithEnemy(bullet: bullet, enemy: ramEnemy, type: "ram")
            }
        }
        
        // Check if enemyCounterWall & shootEnemy or ramEnemy collide
        if (firstBody.categoryBitMask & PhysicsCategory.EnemyCounterWall != 0) &&
            ((secondBody.categoryBitMask & PhysicsCategory.ShootEnemy != 0) ||
            (secondBody.categoryBitMask & PhysicsCategory.RamEnemy != 0)) {
                enemyCollideWithEnemyCounterWall()
        }
        
        // Check if bullet & bulletRemoverWall collide
        if (firstBody.categoryBitMask & PhysicsCategory.Bullet != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.BulletRemoverWall != 0) {
            if firstBody.node != nil {
                bulletCollideWithBulletRemoverWall(node: firstBody.node!)
            }
        }
    }
 
    //Should go in playernode eventually
    func initializePlayer() {
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 1 / 7 + CGFloat(yScaler)*size.height/2)
        player.zPosition = 0
        let width: Double = Double(size.width) * xScaler
        let height: Double = Double(size.height) * yScaler
        player.scale(to: CGSize(width: width, height: height))
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        //player.physicsBody?.linearDamping = 1
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.restitution = 0
        //player.physicsBody?.friction = 1
        player.physicsBody?.usesPreciseCollisionDetection = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.Player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ShootEnemy | PhysicsCategory.RamEnemy | PhysicsCategory.Powerup
        player.physicsBody?.collisionBitMask = PhysicsCategory.Platform | PhysicsCategory.Barrier
    }
}

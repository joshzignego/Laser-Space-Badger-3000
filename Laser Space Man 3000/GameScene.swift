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
    
    var spriteView = SKView()
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
    var ammo = 0
    let enemiesPassedToDie = 30
    let segmentLength = 10 //# of platform segments/ size.width
    var enemiesCanStillTakeHitsFrom: Int = 0
    var enemiesKilled : Int = 0
    var enemiesPassed : Int = 0
    let shootEmemyRate = 3   //0 means max enemies, higher numer means less enemies
    let ramEnemyRate = 3
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
        spriteView = self.view!
        physicsWorld.contactDelegate = self
        initializePlayer()
    
        let body = SKPhysicsBody.init(rectangleOf: CGSize(width: 1, height: 1))
        ptu = 1.0 / sqrt(body.mass)
        let mass: CGFloat = (player.physicsBody?.mass)!
        jumpVector = mass * sqrt(2 * -self.physicsWorld.gravity.dy * ((size.height*2/7 + 5) * ptu))
        
        player.beginRunAnimation()
        makeEnemiesIcon()
        invisiwallsMaker()
        setUpSwipes()
        makePauseButton()
        makeScoreLabel()
        makeGround()
        makeEnemiesCanStillTakeHitsFromLabel()
    
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.run(addGroundMonster), SKAction.wait(forDuration: 1)  ])))
        //run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addGroundMonster), SKAction.wait(forDuration: 1)  ])))
    }
    
    override func update(_ currentTime: TimeInterval){
        
        //Let player move through platfroms if jumping, but not if stationary or falling
        if let body = player.physicsBody {
            let dy = body.velocity.dy
            let dx = body.velocity.dx
            
            if !(self.player.isMoving(direction: "up") || self.player.isMoving(direction: "down") || self.player.isMoving(direction: "right") || self.player.isMoving(direction: "left")) {
                self.player.beginRunAnimation()
            }
            
            
            
            
            if dx >= 0 {
                self.player.setMoving(direction: "left", value: false)
            }
            if dx <= 0 {
                self.player.setMoving(direction: "right", value: false)
            }
            
            if dy > 0 && !self.player.isMoving(direction: "up") {
                
            }
            else if dy > 0 {
                self.player.setMoving(direction: "right", value: false)
                self.player.setMoving(direction: "left", value: false)
                self.player.setMoving(direction: "down", value: false)
                self.player.physicsBody?.velocity.dx = 0
                
                // Prevent collisions if the hero is jumping
                //for plat in platforms {
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
                self.player.setMoving(direction: "right", value: false)
                self.player.setMoving(direction: "left", value: false)
                self.player.physicsBody?.velocity.dx = 0
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
        if (randomShootNumber == 0) {
            let point: CGPoint = CGPoint(x: Double(size.width)*1.1, y: 2)
            let shootEnemy = addShootEnemy(platform: ground, point: point)
        
        
        
            let time = (Double(size.width)*1.1 + xScaler*Double(size.width)) / Double(platformAndEnemySpeed)
            let move = SKAction.moveTo(x: -CGFloat(xScaler)*size.width, duration: TimeInterval(time))
            let moveDone = SKAction.removeFromParent()
            shootEnemy.run(SKAction.sequence([move, moveDone]))
        }
        else
        if randomRamNumber == 0 {
            let point: CGPoint = CGPoint(x: Double(size.width)*1.1, y: 2)
            let ramEnemy = addRamEnemy(platform: ground, point: point)
            
            let time = (Double(size.width)*1.1 + xScaler*Double(size.width)) / Double(platformAndEnemySpeed)
            let move = SKAction.moveTo(x: -CGFloat(xScaler)*size.width, duration: TimeInterval(time))
            let moveDone = SKAction.removeFromParent()
            ramEnemy.run(SKAction.sequence([move, moveDone]))
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
            let point: CGPoint = CGPoint(x: Double(i)*Double(size.width)/Double(segmentLength) - (Double(size.width) * xScaler), y: 2)
            
            //For each segment of platform, "1 in shootEmemyRate" chance enemy spawned there
            if randomShootNumber == 0 {
                addShootEnemy(platform: platform, point: point)
            }
            else
                if randomRamNumber == 0 {
                addRamEnemy(platform: platform, point: point)
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
        let actionMove = SKAction.move(to: destination, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func swipedRight() {
        moveRight()
    }
    
    func swipedLeft() {
        moveLeft()
    }
    
    func swipedUp() {
        jumpUp()
    }
    
    func swipedDown() {
        jumpDown()
    }
    
    func playerDidCollideWithRamEnemy(ramEnemy: SKSpriteNode) {
        if player.isMoving(direction: "up") || player.isMoving(direction: "down") ||
            player.isMoving(direction: "right") || player.isMoving(direction: "left") {
            enemiesKilled += 1
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
            enemiesKilled += 1
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
            makeMainMenuButton()
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
        areYouSureDisplayed = true
        
        areYouSureLabel.text = "Are you sure?"
        areYouSureLabel.fontSize = 20
        areYouSureLabel.fontColor = SKColor.blue
        areYouSureLabel.position = CGPoint(x: size.width/2, y: size.height*0.66)
        areYouSureLabel.zPosition = 150
        addChild(areYouSureLabel)
        
        
        let path = CGRect.init(x: size.width*34/100, y: size.height*44/100, width: size.width*14/100, height: size.height*7/100)
        areYouSure_Yes = Button.init(rect: path, cornerRadius: 5)
        areYouSure_Yes.strokeColor = UIColor.black
        areYouSure_Yes.fillColor = UIColor.white
        areYouSure_Yes.zPosition = 100
        areYouSure_Yes.createLabel(message: "Yes", fontSize: 10, color: SKColor.black, position: CGPoint(x: size.width*0.42, y: size.height * 0.45), zPosition: 150)
        addChild(areYouSure_Yes)
        
        let path2 = CGRect.init(x: size.width*0.50, y: size.height*44/100, width: size.width*14/100, height: size.height*7/100)
        areYouSure_No = Button.init(rect: path2, cornerRadius: 5)
        areYouSure_No.strokeColor = UIColor.black
        areYouSure_No.fillColor = UIColor.white
        areYouSure_No.zPosition = 100
        areYouSure_No.createLabel(message: "No", fontSize: 10, color: SKColor.black, position: CGPoint(x: size.width*0.57, y: size.height * 0.45), zPosition: 150)
        addChild(areYouSure_No)
        
    }
    
    func moveRight() {
        if self.speed == 0 {
            return
        }
        if !player.isMoving(direction: "up") && !player.isMoving(direction: "down") {
            player.beginKickAnimation()
            player.setMoving(direction: "right", value: true)
            let vector = CGVector.init(dx: size.width*0.05, dy: 0)
            player.physicsBody?.applyImpulse(vector)
        }
    }
    
    func moveLeft() {
        if self.speed == 0 {
            return
        }
        if !player.isMoving(direction: "up") && !player.isMoving(direction: "down") {
            player.beginReverseKickAnimation()
            player.setMoving(direction: "left", value: true)
            let vector = CGVector.init(dx: -size.width*0.05, dy: 0)
            player.physicsBody?.applyImpulse(vector)
        }
    }
 
    func jumpUp() {
        player.setMoving(direction: "up", value: true)
        player.beginJumpAnimation()
        let vector = CGVector.init(dx: 0, dy: jumpVector)
        player.physicsBody?.applyImpulse(vector)
    }
    
    func jumpDown() {
        print("Player position: ", player.position)
        player.setMoving(direction: "up", value: false)
        player.setMoving(direction: "down", value: true)
        player.beginJumpAnimation()
        for var plat in platforms {
            print("Plat height: ", plat.height)
            if (CGFloat(plat.height)*1.03 > (player.position.y - CGFloat(yScaler)*size.height/2) && CGFloat(plat.height)*0.97 < player.position.y - CGFloat(yScaler)*size.height/2) &&
                (plat.platform.position.x - CGFloat(xScaler)*size.width/2*3 <= player.position.x && plat.platform.position.x + CGFloat(plat.length) >= player.position.x - 3/2*size.width*CGFloat(xScaler)) {
                if !(plat.platform.position.y*1.03 > ground.position.y && plat.platform.position.y*0.97 < ground.position.y) {
                    print("found swipe down platform")
                    plat.platform.physicsBody?.categoryBitMask = PhysicsCategory.None
                    plat.platform.physicsBody?.collisionBitMask = PhysicsCategory.None
                    plat.swipeDownThrough =  true
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
        
        
        // Check if player & shootEnemy collide
        if (firstBody.categoryBitMask & PhysicsCategory.Player != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.ShootEnemy != 0) {
            gameOver()
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
        player.physicsBody?.contactTestBitMask = PhysicsCategory.ShootEnemy | PhysicsCategory.RamEnemy
        player.physicsBody?.collisionBitMask = PhysicsCategory.Platform | PhysicsCategory.Barrier
    }
}

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

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    struct PlatformStruct {
        let platform : SKShapeNode
        let length : Double
        let height : Double
        var swipeDownThrough : Bool
    }
    var platforms: [PlatformStruct] = []
    var doublePlatformPreventerArray: [Int] = [0,0,0,0]
    
    //Helper to setup buttons
    let buttonManager = ButtonManager()
    var areYouSureDisplayed : Bool = false
    
    //Physics bodies
    var player = MyPlayerNode()
    var ground = SKShapeNode()
    var barrier = SKShapeNode()
    var enemiesCanStillTakeHitsFromIcon = SKSpriteNode()
    var enemyCounterWall = SKShapeNode()
    var bulletRemoverWall = SKShapeNode()
    
    //Buttons
    var pauseButton = Button()
    var mainMenuButton = Button()
    var areYouSure_Yes = Button()
    var areYouSure_No = Button()
    
    //Labels
    var scoreLabel = SKLabelNode()
    var areYouSureLabel = SKLabelNode()
    var enemiesCanStillTakeHitsFromLabel = SKLabelNode()
    
    //Scalers for player and enemy size
    var xScaler: CGFloat = 0
    var yScaler: CGFloat = 0
    
    //Constants
    let MAX_PLATFORM_LENGTH = 15
    let PLATFORM_AND_ENEMY_SPEED = 100
    let ENEMIES_PASSED_TO_DIE = 30
    let SEGMENT_LENGTH = 10 //# of platform segments/ size.width
    let SHOOT_ENEMY_RATE = 5   //0 means max enemies, higher numer means less enemies
    let RAM_ENEMY_RATE = 5
    let POWERUP_RATE = 100
    var JUMP_VECTOR : CGFloat = 0
    var SLIDE_VECTOR : CGFloat = 0
    
    //Counters
    var score: Int = 0
    var enemiesCanStillTakeHitsFrom: Int = 0
    var enemiesPassed : Int = 0
    var invincible : Int = 0
    var speedBullets : Int = 0
    
    // Gesture Recognizers
    let swipeRightRec = UISwipeGestureRecognizer()
    let swipeLeftRec = UISwipeGestureRecognizer()
    let swipeUpRec = UISwipeGestureRecognizer()
    let swipeDownRec = UISwipeGestureRecognizer()
    let tapRec = UITapGestureRecognizer()
    
    override func didMove(to view: SKView) {
        //Setup scene members
        self.scaleMode = SKSceneScaleMode.resizeFill
        physicsWorld.contactDelegate = self
        
        //Initialize globals to proper values
        enemiesCanStillTakeHitsFrom = ENEMIES_PASSED_TO_DIE
        xScaler = 0.06 * size.width
        yScaler = 0.12 * size.height
        player.initializePlayer(gameScene: self)
        let body = SKPhysicsBody.init(rectangleOf: CGSize(width: 1, height: 1))
        let ptu = 1.0 / sqrt(body.mass)
        let mass : CGFloat = (player.physicsBody?.mass)!
        JUMP_VECTOR = mass * sqrt(2 * -self.physicsWorld.gravity.dy * ((size.height*2/7 + 5) * ptu))
        SLIDE_VECTOR =  mass * sqrt(2 * -self.physicsWorld.gravity.dy * ((size.width*0.11) * ptu))
        
        //Create player running animation, buttons, swipe recognizers, ground, background
        player.beginRunAnimation()
        makeButtons()
        setUpSwipes()
        makeGround()
        addBackground()
        
        //Continuously add platforms & monsters
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addPlatform), SKAction.run(addGroundMonster), SKAction.wait(forDuration: 1)  ])))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if self.invincible == 1 {
            player.scale(to: CGSize(width: xScaler, height: yScaler))
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
                //Player will randomly move up small amount even tho no jump due to physics engine
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
    
    // Single tap
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
        if self.speed == 0 || invincible > 0 {
            return
        }
        
        // Make bullet appropiate size
        let width: CGFloat = xScaler / 3 * 2
        let height: CGFloat = yScaler / 8
        
        // Set up initial location of projectile
        var bullet = SKShapeNode()
        let rectangle = CGRect.init(x: 0, y: 0, width: width, height: height)
        bullet = SKShapeNode.init(rect: rectangle)
        bullet.position = CGPoint(x: player.position.x, y: player.position.y)
        
        bullet.strokeColor = SKColor.black
        bullet.fillColor = SKColor.orange
        
        bullet.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: width, height: height), center: CGPoint(x: width/2, y: height/2))
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
        bullet.physicsBody?.contactTestBitMask = PhysicsCategory.ShootEnemy | PhysicsCategory.BulletRemoverWall
        bullet.physicsBody?.collisionBitMask = PhysicsCategory.None
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        // Determine offset of location to projectile
        let offsetX = point.x - bullet.position.x
        let offsetY = point.y - bullet.position.y
        
        // Get the direction of where to shoot
        let scalar = sqrt(offsetX*offsetX + offsetY*offsetY)
        let direction = CGPoint(x: offsetX/scalar, y: offsetY/scalar)
        
        // Make it shoot far enough to be guaranteed off screen
        let shootAmount = CGPoint(x: direction.x * size.width, y: direction.y * size.width)
        
        // Add the shoot amount to the current position
        let destination = CGPoint(x: shootAmount.x + bullet.position.x, y: shootAmount.y + bullet.position.y)
        
        // Rotate bullet so it's faces the proper direction
        let angle = atan2(direction.y, direction.x)
        bullet.zRotation += angle
        bullet.zPosition = 20
        addChild(bullet)
        
        // Create the action sequence
        var actionMove = SKAction.move(to: destination, duration: 2.0)
        if speedBullets > 0 {
            bullet.fillColor = UIColor.blue
            bullet.strokeColor = UIColor.blue
            actionMove = SKAction.move(to: destination, duration: 1.0)
        }
        let actionMoveDone = SKAction.removeFromParent()
        bullet.run(SKAction.sequence([actionMove, actionMoveDone]))
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
    
///////////////////////////////////////Add Platforms & Enemies////////////////////////////////////////////////////////////////////////////
    
    func makeGround() {
        let rectangle = CGRect.init(x: 0, y: 0, width: size.width, height: 2)
        ground = SKShapeNode.init(rect: rectangle)
        ground.position = CGPoint(x: 0, y: size.height*1/7)
        ground.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: size.width, height: 2 + size.height/7*2), center: CGPoint(x: size.width/2, y: -size.height/7 + 1))
        
        addPlatform(platform: ground)
        platforms.append(PlatformStruct(platform: ground, length: Double(size.width), height: Double(1/7*size.height), swipeDownThrough: false))
    }
    
    func addGroundMonster() {
        let randomShootNumber = Double(arc4random_uniform(UInt32(SHOOT_ENEMY_RATE)))
        let randomRamNumber = Double(arc4random_uniform(UInt32(RAM_ENEMY_RATE)))
        let randomPowerupNumber = Double(arc4random_uniform(UInt32(POWERUP_RATE)))
        let point: CGPoint = CGPoint(x: Double(size.width)*1.1, y: 2)
        let time = Double(size.width*1.1 + xScaler) / Double(PLATFORM_AND_ENEMY_SPEED)
        let move = SKAction.moveTo(x: -xScaler, duration: TimeInterval(time))
        let moveDone = SKAction.removeFromParent()
        
        
        if (randomShootNumber == 0) {
            let shootEnemy = addShootEnemy(platform: ground, point: point)
            shootEnemy.run(SKAction.sequence([move, moveDone]))
        } else if randomRamNumber == 0 {
            let ramEnemy = addRamEnemy(platform: ground, point: point)
            ramEnemy.run(SKAction.sequence([move, moveDone]))
        }
        else if randomPowerupNumber == 0 {
            let texture = SKTexture(imageNamed: "Lightning")
            let powerup = Powerup.init(texture: texture, color: UIColor.clear, size: texture.size())
            powerup.addPowerup(platform: ground, point: point, type: "speedBullets", gameScene: self)
            powerup.run(SKAction.sequence([move, moveDone]))
        }
        else if randomPowerupNumber == 1 {
            let texture = SKTexture(imageNamed: "Heart")
            let powerup = Powerup.init(texture: texture, color: UIColor.clear, size: texture.size())
            powerup.addPowerup(platform: ground, point: point, type: "bonusLives", gameScene: self)
            powerup.run(SKAction.sequence([move, moveDone]))
        }
        else if randomPowerupNumber == 2 {
            let texture = SKTexture(imageNamed: "Kale")
            let powerup = Powerup.init(texture: texture, color: UIColor.clear, size: texture.size())
            powerup.addPowerup(platform: ground, point: point, type: "invincible", gameScene: self)
            powerup.run(SKAction.sequence([move, moveDone]))
        }
    }
    
    func addPlatform() {
        let platformNumber : Int = Int(arc4random_uniform(4)) + 2
        if doublePlatformPreventerArray[platformNumber - 2] > 0  {
            return
        }
        let platHeight: Double = Double(platformNumber) / 7 * Double(size.height)
        let randomLength: Int = Int(arc4random_uniform(UInt32(MAX_PLATFORM_LENGTH-1))) + 4
        let platLength: Double = Double(randomLength) * Double(size.width) / Double(SEGMENT_LENGTH)
        
        var platform = SKShapeNode()
        let rectangle = CGRect.init(x: 0, y: 0, width: platLength, height: 2)
        platform = SKShapeNode.init(rect: rectangle)
        platform.position = CGPoint(x: size.width, y: CGFloat(platHeight))
        platform.physicsBody = SKPhysicsBody.init(rectangleOf: CGSize(width: platLength, height: 2), center: CGPoint(x: CGFloat(platLength/2), y: 2))
        
        platforms.append(PlatformStruct(platform: platform, length: platLength, height: platHeight, swipeDownThrough: false))
        addPlatform(platform: platform)
        
        for i in 1...randomLength {
            let randomShootNumber = Double(arc4random_uniform(UInt32(SHOOT_ENEMY_RATE)))
            let randomRamNumber = Double(arc4random_uniform(UInt32(RAM_ENEMY_RATE)))
            let randomPowerupNumber = Double(arc4random_uniform(UInt32(POWERUP_RATE)))
            let point: CGPoint = CGPoint(x: Double(i)*Double(size.width)/Double(SEGMENT_LENGTH) - Double(xScaler), y: 2)
            
            //For each segment of platform, "1 in SHOOT_ENEMY_RATE" chance enemy spawned there
            if randomShootNumber == 0 {
                addShootEnemy(platform: platform, point: point)
            }
            else if randomRamNumber == 0 {
                addRamEnemy(platform: platform, point: point)
            }
            else if randomPowerupNumber == 0 {
                let texture = SKTexture(imageNamed: "Lightning")
                let powerup = Powerup.init(texture: texture, color: UIColor.clear, size: texture.size())
                powerup.addPowerup(platform: platform, point: point, type: "speedBullets", gameScene: self)
            }
            else if randomPowerupNumber == 1 {
                let texture = SKTexture(imageNamed: "Heart")
                let powerup = Powerup.init(texture: texture, color: UIColor.clear, size: texture.size())
                powerup.addPowerup(platform: platform, point: point, type: "bonusLives", gameScene: self)
            }
            else if randomPowerupNumber == 2 {
                let texture = SKTexture(imageNamed: "Kale")
                let powerup = Powerup.init(texture: texture, color: UIColor.clear, size: texture.size())
                powerup.addPowerup(platform: platform, point: point, type: "invincible", gameScene: self)
            }
        }
        //Gap between platforms
        doublePlatformPreventerArray[platformNumber - 2] += 1
        let timeForGap = (3 * Double(size.width) / Double(MAX_PLATFORM_LENGTH)) / Double(PLATFORM_AND_ENEMY_SPEED)
        let timeForLastSegmentToEnterScreen = platLength / Double(PLATFORM_AND_ENEMY_SPEED)
        
        
        self.run(SKAction.sequence([SKAction.wait(forDuration: timeForGap + timeForLastSegmentToEnterScreen),
            SKAction.run({              self.doublePlatformPreventerArray[platformNumber - 2] -= 1               })]))
        
        
        
        let time = (Double(size.width) + platLength) / Double(PLATFORM_AND_ENEMY_SPEED)
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
 
    func addPlatform(platform: SKShapeNode) {
        platform.zPosition = 2
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
        
        platform.strokeColor = UIColor.black
        platform.fillColor = UIColor.black
        
        addChild(platform)
    }
    
    // Enemy will be child of the platform that calls it. Enemy will be spawned at given CGPoint.
    func addShootEnemy(platform: SKShapeNode, point : CGPoint)-> SKSpriteNode {
        let texture = SKTexture(imageNamed: "Spider RESIZE-1")
        let shootEnemy = SKSpriteNode.init(texture: texture, color: SKColor.clear, size: texture.size())
        shootEnemy.position = point
        addNewEnemyInfo(platform: platform, enemy: shootEnemy)
        shootEnemy.physicsBody?.categoryBitMask = PhysicsCategory.ShootEnemy
        shootEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet | PhysicsCategory.Player | PhysicsCategory.EnemyCounterWall
        
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
        addNewEnemyInfo(platform: platform, enemy: ramEnemy)
        
        ramEnemy.physicsBody?.categoryBitMask = PhysicsCategory.RamEnemy
        ramEnemy.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet | PhysicsCategory.Player | PhysicsCategory.EnemyCounterWall
        
        let textureAtlas = SKTextureAtlas(named: "RamEnemy")
        let frames = ["Dragon RESIZE-1", "Dragon RESIZE-2"].map { textureAtlas.textureNamed($0) }
        let animate = SKAction.animate(with: frames, timePerFrame: 0.2)
        let forever = SKAction.repeatForever(animate)
        ramEnemy.run(forever)
        
        return ramEnemy
    }
    
    func addNewEnemyInfo(platform: SKShapeNode, enemy: SKSpriteNode) {
        enemy.anchorPoint = CGPoint(x: 0, y: 0)
        enemy.scale(to: CGSize(width: xScaler, height: yScaler))
        platform.addChild(enemy)
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size, center: CGPoint(x: xScaler/2, y: yScaler/2 + 1))
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.affectedByGravity = false
        enemy.physicsBody?.linearDamping = 0
        enemy.physicsBody?.allowsRotation = false
        enemy.physicsBody?.friction = 0
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None
    }
/////////////////////////////////////////////////Button Handlers//////////////////////////////////////////////////////////////////////////
    func updateEnemiesCanStillTakeHitsFromLabel() {
        enemiesCanStillTakeHitsFromLabel.text = String(enemiesCanStillTakeHitsFrom)
    }
    
    func updateScore() {
        scoreLabel.text = String(score)
    }
    
    func makeButtons() {
        pauseButton = buttonManager.makePauseButton(gameScene: self)
        enemiesCanStillTakeHitsFromIcon = buttonManager.makeEnemiesIcon(gameScene: self)
        bulletRemoverWall = buttonManager.makeBulletRemoverWall(gameScene: self)
        enemyCounterWall = buttonManager.makeEnemyCounterWall(gameScene: self)
        barrier = buttonManager.makeBarrier(gameScene: self)
        scoreLabel = buttonManager.makeScoreLabel(gameScene: self)
        enemiesCanStillTakeHitsFromLabel = buttonManager.makeEnemiesCanStillTakeHitsFromLabel(gameScene: self)
    }
    
    func addBackground() {
        let sky = SKSpriteNode(imageNamed: "Sky")
        sky.position = CGPoint(x: size.width/2, y: size.height/2)
        sky.scale(to: CGSize(width: size.width, height: size.height))
        sky.zPosition = -1
        addChild(sky)
    }
    
    func mainMenuButtonHit() {
        if areYouSureDisplayed {
            return
        }
        areYouSureLabel = buttonManager.makeAreYouSureLabel(gameScene: self)
        areYouSure_Yes = buttonManager.makeAreYouSureYes(gameScene: self)
        areYouSure_No = buttonManager.makeAreYouSureNo(gameScene: self)
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
            let path = CGRect.init(x: size.width*1/100, y: size.height*35/1000, width: size.width*14/100, height: size.height*7/100)
            buttonManager.adjustLabelFontSizeToFitRect(labelNode: pauseButton.label, rect: path)
            pauseButton.label.position.y += size.height*5/1000
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
    
/////////////////////////////////////////////////////Swipe Responses//////////////////////////////////////////////////////////////////////
        
    func moveRight() {
        if self.speed == 0 {
            return
        }
        player.beginKickAnimation()
        let vector = CGVector.init(dx: SLIDE_VECTOR, dy: 0)
        player.setMoving(direction: "right", value: true)
        player.physicsBody?.applyImpulse(vector)
    }
    
    func moveLeft() {
        if self.speed == 0 {
            return
        }
        player.beginReverseKickAnimation()
        player.setMoving(direction: "left", value: true)
        let vector = CGVector.init(dx: -SLIDE_VECTOR, dy: 0)
        player.physicsBody?.applyImpulse(vector)
    }
 
    func jumpUp() {
        if self.speed == 0 {
            return
        }
        player.setMoving(direction: "up", value: true)
        player.beginJumpAnimation()
        let vector = CGVector.init(dx: 0, dy: JUMP_VECTOR)
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
            //If not invincible
            if invincible == 0 {
                if (CGFloat(plat.height)*1.03 > player.position.y - yScaler/2 && CGFloat(plat.height)*0.97 < player.position.y - yScaler/2) &&
                       (plat.platform.position.x - xScaler/2*3 <= player.position.x && plat.platform.position.x + CGFloat(plat.length) >= player.position.x - 3/2*xScaler) {
                    if !(plat.platform.position.y*1.03 > ground.position.y && plat.platform.position.y*0.97 < ground.position.y) {
                        plat.platform.physicsBody?.categoryBitMask = PhysicsCategory.None
                        plat.platform.physicsBody?.collisionBitMask = PhysicsCategory.None
                        plat.swipeDownThrough =  true
                    }
                }
            }
            //If invincible, different height of player
            else {
                if (CGFloat(plat.height)*1.03 > player.position.y - yScaler/2*1.16 && CGFloat(plat.height)*0.97 < player.position.y - yScaler/2*1.16) &&
                    (plat.platform.position.x - xScaler/2*3 <= player.position.x && plat.platform.position.x + CGFloat(plat.length) >= player.position.x - 3/2*xScaler) {
                    if !(plat.platform.position.y*1.03 > ground.position.y && plat.platform.position.y*0.97 < ground.position.y) {
                        plat.platform.physicsBody?.categoryBitMask = PhysicsCategory.None
                        plat.platform.physicsBody?.collisionBitMask = PhysicsCategory.None
                        plat.swipeDownThrough =  true
                    }
                }
            }
        }
        
        let vector = CGVector.init(dx: 0, dy: -JUMP_VECTOR)
        player.physicsBody?.applyImpulse(vector)
        
    }
    
////////////////////////////////////////////////Collision Handlers////////////////////////////////////////////////////////////////////////
    
    func playerDidCollideWithShootEnemy(shootEnemy: SKSpriteNode) {
        if invincible > 0 {
            shootEnemy.removeFromParent()
            score += 1
            updateScore()
            return
        }
        gameOver()
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
        
        if powerup.getType() == "speedBullets" {
            player.beginPowerupAnimation(type: "lightning")
            self.speedBullets += 1
            self.run(SKAction.sequence([SKAction.wait(forDuration: 10),
                                        SKAction.run({  self.speedBullets -= 1 })]))
        }
        else if powerup.getType() == "invincible" {
            if self.invincible == 0 || self.invincible == 1 {
                player.beginPowerupAnimation(type: "tear")
                self.run(SKAction.sequence([SKAction.wait(forDuration: 0.5), SKAction.run(scale1), SKAction.wait(forDuration: 0.5), SKAction.run(scale2), SKAction.wait(forDuration: 0.5), SKAction.run(scale3)]))
            }
            self.invincible += 10
            self.run(SKAction.sequence([SKAction.wait(forDuration: 9), SKAction.run({  self.invincible -= 9 }), SKAction.wait(forDuration: 1), SKAction.run({  self.invincible -= 1 })]))
        } else {
            player.beginPowerupAnimation(type: "flip")
            enemiesCanStillTakeHitsFrom += 10
            updateEnemiesCanStillTakeHitsFromLabel()
        }
        
        powerup.removeFromParent()
    }
    
    func scale1() {self.player.scale(to: CGSize(width: xScaler*1.05, height: yScaler*1.06))}
    func scale2() {self.player.scale(to: CGSize(width: xScaler*1.11, height: yScaler*1.12))}
    func scale3() {self.player.scale(to: CGSize(width: xScaler*1.16, height: yScaler*1.16))}
    
    func gameOver() {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let gameOverScene = GameOverScene(size: self.size, score: score)
        self.view?.presentScene(gameOverScene, transition: reveal)
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
}

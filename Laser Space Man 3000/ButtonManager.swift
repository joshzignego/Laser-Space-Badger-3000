//
//  ButtonManager.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 8/13/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import Foundation
import SpriteKit

class ButtonManager : SKShapeNode {
    
    func makePauseButton(gameScene: GameScene)->Button {
        let path = CGRect.init(x: gameScene.size.width*1/100, y: gameScene.size.height*35/1000, width: gameScene.size.width*14/100, height: gameScene.size.height*7/100)
        let pauseButton = Button.init(rect: path, cornerRadius: 5)
        pauseButton.strokeColor = UIColor.black
        pauseButton.fillColor = UIColor.white
        pauseButton.zPosition = 100
        pauseButton.createLabel(message: "Pause", fontSize: 10, color: SKColor.blue, position: CGPoint(x: gameScene.size.width*8/100, y: gameScene.size.height*5/100), zPosition: 150)
        gameScene.addChild(pauseButton)
        
        return pauseButton
    }
    
    func makeEnemiesIcon(icon: SKSpriteNode, gameScene: GameScene) {
        icon.anchorPoint = CGPoint(x: 0, y: 0)
        icon.position = CGPoint(x: gameScene.size.width * 0.05, y: gameScene.size.height * 0.88)
        icon.zPosition += 50
        let width: Double = Double(gameScene.size.width) * gameScene.xScaler
        let height: Double = Double(gameScene.size.height) * gameScene.yScaler
        icon.scale(to: CGSize(width: width, height: height))
        gameScene.addChild(icon)
    }
 
    func makeMainMenuButton(gameScene: GameScene)->Button {
        let path = CGRect.init(x: gameScene.size.width*83/100, y: gameScene.size.height*35/1000, width: gameScene.size.width*14/100, height: gameScene.size.height*7/100)
        let mainMenuButton = Button.init(rect: path, cornerRadius: 5)
        mainMenuButton.strokeColor = UIColor.black
        mainMenuButton.fillColor = UIColor.white
        mainMenuButton.zPosition = 100
        mainMenuButton.createLabel(message: "Menu", fontSize: 10, color: SKColor.blue, position: CGPoint(x: gameScene.size.width*90/100, y: gameScene.size.height*5/100), zPosition: 150)
        gameScene.addChild(mainMenuButton)
        
        return mainMenuButton
    }
    
    func makeAreYouSureLabel(gameScene: GameScene)->SKLabelNode {
        gameScene.areYouSureDisplayed = true
        
        let areYouSureLabel = SKLabelNode(fontNamed: "Fipps-Regular")
        areYouSureLabel.text = "Are you sure?"
        areYouSureLabel.fontSize = 20
        areYouSureLabel.fontColor = SKColor.blue
        areYouSureLabel.position = CGPoint(x: gameScene.size.width/2, y: gameScene.size.height*0.66)
        areYouSureLabel.zPosition = 150
        gameScene.addChild(areYouSureLabel)
        
        return areYouSureLabel
    }
    
    func makeAreYouSureYes(gameScene: GameScene)->Button {
        let path = CGRect.init(x: gameScene.size.width*34/100, y: gameScene.size.height*44/100, width: gameScene.size.width*14/100, height: gameScene.size.height*7/100)
        let areYouSure_Yes = Button.init(rect: path, cornerRadius: 5)
        areYouSure_Yes.strokeColor = UIColor.black
        areYouSure_Yes.fillColor = UIColor.white
        areYouSure_Yes.zPosition = 100
        areYouSure_Yes.createLabel(message: "Yes", fontSize: 10, color: SKColor.black, position: CGPoint(x: gameScene.size.width*0.42, y: gameScene.size.height * 0.45), zPosition: 150)
        gameScene.addChild(areYouSure_Yes)
        
        return areYouSure_Yes
    }
    
    func makeAreYouSureNo(gameScene: GameScene)->Button {
        let path2 = CGRect.init(x: gameScene.size.width*0.50, y: gameScene.size.height*44/100, width: gameScene.size.width*14/100, height: gameScene.size.height*7/100)
        let areYouSure_No = Button.init(rect: path2, cornerRadius: 5)
        areYouSure_No.strokeColor = UIColor.black
        areYouSure_No.fillColor = UIColor.white
        areYouSure_No.zPosition = 100
        areYouSure_No.createLabel(message: "No", fontSize: 10, color: SKColor.black, position: CGPoint(x: gameScene.size.width*0.57, y: gameScene.size.height * 0.45), zPosition: 150)
        gameScene.addChild(areYouSure_No)
        
        return areYouSure_No
    }

}

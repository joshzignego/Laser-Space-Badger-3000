//
//  Button.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 8/5/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import Foundation
import SpriteKit

class Button : SKShapeNode {
    var label = SKLabelNode(fontNamed: "Fipps-Regular")
    var buttonType : String = ""
    
    func createLabel(message: String, fontSize: CGFloat, color: SKColor, position: CGPoint, zPosition: CGFloat) {
        label.text = message
        label.fontSize = fontSize
        label.fontColor = color
        label.position = position
        label.zPosition = zPosition
        addChild(label)
        
    }
    
    func setButtonType(type: String) {
        buttonType = type
    }
    
    func getButtonType() -> String {
        return buttonType
    }
    
    func setLabelText(message: String) {
        label.text = message
    }

}

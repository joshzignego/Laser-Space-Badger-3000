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
    var moving : Bool = false
    
    func setMoving(value: Bool) {
        moving = value
    }
    
    func isMoving() -> Bool {
        return moving
    }
}

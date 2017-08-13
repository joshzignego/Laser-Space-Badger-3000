//
//  MySKSpriteNode.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 8/3/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import Foundation
import SpriteKit

class Powerup: SKSpriteNode {
    var speedBullet = false
    var invincibility = false
    var bonusLives = false
    
    func setType(type: String) {
        if type == "speedBullet" {
            speedBullet = true
        }
        if type == "invincible" {
            invincibility = true
        }
        if type == "bonusLives" {
            speedBullet = bonusLives
        }
    }
    
    func getType()->String {
        if speedBullet {
            return "speedBullet"
        }
        else if invincibility {
            return "invincible"
        }
        else {
            return "bonusLives"
        }
    }
}

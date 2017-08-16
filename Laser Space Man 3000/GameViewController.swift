//
//  GameViewController.swift
//  Laser Space Man 3000
//
//  Created by Josh Zignego on 7/31/17.
//  Copyright © 2017 Josh Zignego. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = MainMenuScene(size: self.view.bounds.size)
        let view = self.view as! SKView
        view.showsFPS = true
        //view.showsPhysics = true
        view.showsNodeCount = true
        view.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

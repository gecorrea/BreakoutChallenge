//
//  GameOver.swift
//  BreakoutChallenge
//
//  Created by Maxwell Schneider on 7/6/17.
//  Copyright © 2017 George Correa. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameOver: GKState {
    unowned let scene: GameScene
    
    init(scene: SKScene) {
        self.scene = scene as! GameScene
        super.init()
    }
    
    override func didEnter(from previousState: GKState?) {
        if previousState is Playing {
            let ball = scene.childNode(withName: "ball") as! SKSpriteNode
            ball.physicsBody!.linearDamping = 1.0
            ball.physicsBody?.affectedByGravity = true
            scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        }
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is TapToPlay.Type
    }

}

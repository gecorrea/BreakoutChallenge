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

final class GameOver: GKState {
    unowned let scene: GameScene

    init(scene: SKScene) {
        guard let scene = scene as? GameScene else {
            fatalError("Error setting scene as GameScene in GameOver.")
        }
        self.scene = scene
        super.init()
    }

    internal override func didEnter(from previousState: GKState?) {
        if previousState is Playing {
            guard let ball = scene.childNode(withName: "ball") as? SKSpriteNode else {
                fatalError("Error locating ball in GameScene for GameOver.")
            }
            ball.physicsBody!.linearDamping = 1.0
            ball.physicsBody?.affectedByGravity = true
            ball.physicsBody?.restitution = 0
            scene.physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        }
    }

    internal override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is TapToPlay.Type
    }
}

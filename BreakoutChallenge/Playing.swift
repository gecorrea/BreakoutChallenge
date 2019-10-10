//
//  Playing.swift
//  BreakoutChallenge
//
//  Created by Maxwell Schneider on 7/6/17.
//  Copyright © 2017 George Correa. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

final class Playing: GKState {
    unowned let scene: GameScene

    init(scene: SKScene) {
        guard let scene = scene as? GameScene else {
            fatalError("Error setting scene as GameScene in Playing.")
        }
        self.scene = scene
        super.init()
    }

    internal override func didEnter(from previousState: GKState?) {
        if previousState is TapToPlay {
            guard let ball = scene.childNode(withName: "ball") as? SKSpriteNode else {
                fatalError("Error locating ball in GameScene for Playing.")
            }
            ball.physicsBody?.applyImpulse(CGVector(dx: randomDirection(), dy: randomDirection()))
        }
    }

    internal override func update(deltaTime seconds: TimeInterval) {
        guard let ball = scene.childNode(withName: "ball") as? SKSpriteNode else {
            fatalError("Error locating ball in GameScene for Playing.")
        }

        let maxSpeed: CGFloat = 400.0

        let xSpeed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx)
        let ySpeed = sqrt(ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)

        let speed = sqrt(ball.physicsBody!.velocity.dx * ball.physicsBody!.velocity.dx + ball.physicsBody!.velocity.dy * ball.physicsBody!.velocity.dy)

        if xSpeed <= 10.0 {
            ball.physicsBody!.applyImpulse(CGVector(dx: randomDirection(), dy: 0.0))
        }

        if ySpeed <= 10.0 {
            ball.physicsBody!.applyImpulse(CGVector(dx: 0.0, dy: randomDirection()))
        }

        if speed > maxSpeed {
            ball.physicsBody!.linearDamping = 0.4
        } else {
            ball.physicsBody!.linearDamping = 0.0
        }
    }

    internal override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is GameOver.Type
    }

    private func randomDirection() -> CGFloat {
        let speedFactor: CGFloat = 40.0
        if randomFloat(from: 0.0, to: 100.0) >= 50 {
            return -speedFactor
        } else {
            return speedFactor
        }
    }

    private func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
        let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
}

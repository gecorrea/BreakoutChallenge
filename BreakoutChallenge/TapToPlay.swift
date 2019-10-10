//
//  TapToPlay.swift
//  BreakoutChallenge
//
//  Created by Maxwell Schneider on 7/6/17.
//  Copyright © 2017 George Correa. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit
import GameKit

final class TapToPlay: GKState {
    unowned let scene: GameScene

    init(scene: SKScene) {
        guard let scene = scene as? GameScene else {
            fatalError("Error setting scene as GameScene in TapToPlay.")
        }
        self.scene = scene
        super.init()
    }

    internal override func didEnter(from previousState: GKState?) {
        let scale = SKAction.scale(to: 1.0, duration: 0.25)
        scene.childNode(withName: "gameMessage")!.run(scale)
    }

    internal override func willExit(to nextState: GKState) {
        if nextState is Playing {
            let scale = SKAction.scale(to: 0, duration: 0.4)
            scene.childNode(withName: "gameMessage")!.run(scale)
        }
    }

    internal override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass is Playing.Type
    }
}

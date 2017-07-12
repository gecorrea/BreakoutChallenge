//
//  Block.swift
//  BreakoutChallenge
//
//  Created by Maxwell Schneider on 7/12/17.
//  Copyright © 2017 George Correa. All rights reserved.
//

import UIKit
import SpriteKit

class Block: SKSpriteNode {

    var xIndex: Int
    var yIndex: Int
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(x: Int, y: Int, size: CGSize, texture: SKTexture) {
        
        
        // public init(texture: SKTexture?, color: UIColor, size: CGSize)
        self.xIndex = x
        self.yIndex = y
        super.init(texture: texture, color: .clear, size: size)
        
        
    }
    
}

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BallCategory   : UInt32 = 0x1 << 0
    let BottomCategory : UInt32 = 0x1 << 1
    let BlockCategory  : UInt32 = 0x1 << 2
    let PaddleCategory : UInt32 = 0x1 << 3
    let BorderCategory : UInt32 = 0x1 << 4
    
    var ball = SKSpriteNode()
    var paddle = SKSpriteNode()
    let backgroundImage = SKSpriteNode(imageNamed: "background")
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        backgroundImage.position = CGPoint(x: self.frame.width/5, y: self.frame.height/5)
        self.insertChild(backgroundImage, at: 0)
        
        
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        
        paddle = self.childNode(withName: "paddle") as! SKSpriteNode
        paddle.position = CGPoint(x: 0, y: -(view.frame.size.height)*2/5)
        paddle.zPosition = 1
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 20))
        ball.zPosition = 1
        
        let bottomRect = CGRect(x: frame.origin.x, y: frame.origin.y, width: frame.size.width, height: 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFrom: bottomRect)
        addChild(bottom)
        
//        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
//        border.friction = 0
//        border.restitution = 1
//        self.physicsBody = border
        
        ball.physicsBody!.categoryBitMask = BallCategory
        paddle.physicsBody!.categoryBitMask = PaddleCategory
        borderBody.categoryBitMask = BorderCategory
        bottom.physicsBody?.categoryBitMask = BottomCategory
        
        makeBricks()
        

    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        // 2
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        // 3
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
            print("Hit brick")
        }
    }

    
    func makeBricks(){
        // 1
        let numberOfBlocks = 8
        let blockWidth = SKSpriteNode(imageNamed: "brick1").size.width
        //        let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
        // 2
        
        //        let xOffset = (frame.width - totalBlocksWidth) / 2
        // 3
        for i in 0..<numberOfBlocks {
            let block = SKSpriteNode(imageNamed: "brick1")
            //            block.position = CGPoint(x: frame.width + CGFloat(CGFloat(i)) * blockWidth,
            //                                     y: frame.height * 0.8)
            //            block.position = CGPoint(x: frame.width, y: frame.height)
            
            block.position = CGPoint(x: CGFloat(i) * (blockWidth / 2) - (frame.width / 4), y: 0)
            
            block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
            block.physicsBody!.allowsRotation = false
            block.physicsBody!.friction = 0.0
            block.physicsBody!.affectedByGravity = false
            block.physicsBody!.isDynamic = false
            block.name = "brick"
            block.physicsBody!.categoryBitMask = BlockCategory
            block.physicsBody?.collisionBitMask = 1
            block.physicsBody?.contactTestBitMask = 1
            block.zPosition = 1
            addChild(block)
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

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
    var bottom = SKSpriteNode()
    var rows = [CGFloat]()
    let backgroundImage = SKSpriteNode(imageNamed: "background")
//    var isFingerOnPaddle = false
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        backgroundImage.position = CGPoint(x: self.frame.width/5, y: self.frame.height/5)
        self.insertChild(backgroundImage, at: 0)
        
        
//        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
//        borderBody.friction = 0
//        borderBody.restitution = 1
//        borderBody.contactTestBitMask = 2
//        borderBody.collisionBitMask = 2
//        borderBody.categoryBitMask = 1
//        borderBody.isDynamic = false
//        self.physicsBody = borderBody
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        paddle = self.childNode(withName: "paddle") as! SKSpriteNode
        paddle.position = CGPoint(x: 0, y: -(view.frame.size.height)*2/5)
        paddle.zPosition = 1
//        print(paddle.frame)
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 40))
        ball.physicsBody?.collisionBitMask = 1
        ball.physicsBody?.contactTestBitMask = 1
        ball.physicsBody?.categoryBitMask = 2
        ball.zPosition = 1
        
        bottom = self.childNode(withName: "bottom") as! SKSpriteNode
        bottom.zPosition = 1
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        ball.physicsBody!.categoryBitMask = BallCategory
//        paddle.physicsBody!.categoryBitMask = PaddleCategory
//        border.categoryBitMask = BorderCategory
//        bottom.physicsBody?.categoryBitMask = BottomCategory
        
        rows = [309.5, 364.5, 419.5, 474.5, 529.5, 584.5, 639.5]
        
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
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == 3 {
//            print("Hit brick")
            breakBlock(node: secondBody.node!)
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody == bottom.physicsBody {
            print("Rock bottom")
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody == self.physicsBody {
            print("To the wallz")
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody == paddle.physicsBody {
            print("Paddle")
        }
    }
    
    
    func breakBlock(node: SKNode) {
//        let particles = SKEmitterNode(fileNamed: "BrokenPlatform")!
//        particles.position = node.position
//        particles.zPosition = 3
//        addChild(particles)
//        particles.run(SKAction.sequence([SKAction.wait(forDuration: 1.0),
//                                         SKAction.removeFromParent()]))
        node.removeFromParent()
    }

    
    func makeBricks(){
        
        for row in rows {
            let blockWidth = SKSpriteNode(imageNamed: "brick1").size.width

            for i in 0...6 {
                let block = SKSpriteNode(imageNamed: "brick1")
                block.size.width = blockWidth * 1.071
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                if rand == 1 {
                    block.position = CGPoint(x: frame.origin.x + (block.size.width/2) + (blockCount*block.size.width), y: row)
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                    block.physicsBody!.allowsRotation = false
                    block.physicsBody!.friction = 0.0
                    block.physicsBody!.affectedByGravity = false
                    block.physicsBody!.isDynamic = false
                    block.name = "brick"
                            block.physicsBody!.categoryBitMask = 3
                    block.physicsBody?.collisionBitMask = 2
                    block.physicsBody?.contactTestBitMask = 2
                    block.zPosition = 1
                    addChild(block)
                
            
                }
                else{
                    continue
                }
            }
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
        }
//        let touch = touches.first
//        let touchLocation = touch!.location(in: self)
//        
//        if let body = physicsWorld.body(at: touchLocation) {
//            if body.node!.name == "paddle" {
//                print("Began touch on paddle")
//                isFingerOnPaddle = true
//            }
//        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            paddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
        }
//        if isFingerOnPaddle {
//            // 2
//            let touch = touches.first
//            let touchLocation = touch!.location(in: self)
//            let previousLocation = touch!.previousLocation(in: self)
//            // 3
//            let paddle = childNode(withName: "paddle") as! SKSpriteNode
//            // 4
//            var paddleX = paddle.position.x + (touchLocation.x - previousLocation.x)
//            // 5
//            paddleX = max(paddleX, paddle.size.width/2)
//            paddleX = min(paddleX, size.width - paddle.size.width/2)
//            // 6
//            paddle.position = CGPoint(x: paddleX, y: paddle.position.y)
//        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isFingerOnPaddle = false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

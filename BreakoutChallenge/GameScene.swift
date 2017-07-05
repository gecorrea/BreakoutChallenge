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
    var brick = SKSpriteNode()
    var brick1 = SKSpriteNode()
    var brick2 = SKSpriteNode()
    var brick3 = SKSpriteNode()
    var brick4 = SKSpriteNode()
    var brick5 = SKSpriteNode()
    var brick6 = SKSpriteNode()
    var brick7 = SKSpriteNode()
    var brick8 = SKSpriteNode()
    var brick9 = SKSpriteNode()
    var brick10 = SKSpriteNode()
    var brick11 = SKSpriteNode()
    var brick12 = SKSpriteNode()
    var brick13 = SKSpriteNode()
    var brick14 = SKSpriteNode()
    var brick15 = SKSpriteNode()
    var brick16 = SKSpriteNode()
    var brick17 = SKSpriteNode()
    var brick18 = SKSpriteNode()
    var brick19 = SKSpriteNode()
    var brick20 = SKSpriteNode()
    var brick21 = SKSpriteNode()
    var brick22 = SKSpriteNode()
    var brick23 = SKSpriteNode()
    var brick24 = SKSpriteNode()
    var brick25 = SKSpriteNode()
    var brick26 = SKSpriteNode()
    var brick27 = SKSpriteNode()
    var brick28 = SKSpriteNode()
    let backgroundImage = SKSpriteNode(imageNamed: "background")
    var isFingerOnPaddle = false
    
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
        
//        brick1 = self.childNode(withName: "brick1") as! SKSpriteNode
//        brick2 = self.childNode(withName: "brick2") as! SKSpriteNode
//        brick3 = self.childNode(withName: "brick3") as! SKSpriteNode
//        brick4 = self.childNode(withName: "brick4") as! SKSpriteNode
//        brick5 = self.childNode(withName: "brick5") as! SKSpriteNode
//        brick6 = self.childNode(withName: "brick6") as! SKSpriteNode
//        brick7 = self.childNode(withName: "brick7") as! SKSpriteNode
//        brick8 = self.childNode(withName: "brick8") as! SKSpriteNode
//        brick9 = self.childNode(withName: "brick9") as! SKSpriteNode
//        brick10 = self.childNode(withName: "brick10") as! SKSpriteNode
//        brick11 = self.childNode(withName: "brick11") as! SKSpriteNode
//        brick12 = self.childNode(withName: "brick12") as! SKSpriteNode
//        brick13 = self.childNode(withName: "brick13") as! SKSpriteNode
//        brick14 = self.childNode(withName: "brick14") as! SKSpriteNode
//        brick15 = self.childNode(withName: "brick15") as! SKSpriteNode
//        brick16 = self.childNode(withName: "brick16") as! SKSpriteNode
//        brick17 = self.childNode(withName: "brick17") as! SKSpriteNode
//        brick18 = self.childNode(withName: "brick18") as! SKSpriteNode
//        brick19 = self.childNode(withName: "brick19") as! SKSpriteNode
//        brick20 = self.childNode(withName: "brick20") as! SKSpriteNode
//        brick21 = self.childNode(withName: "brick21") as! SKSpriteNode
//        brick22 = self.childNode(withName: "brick22") as! SKSpriteNode
//        brick23 = self.childNode(withName: "brick23") as! SKSpriteNode
//        brick24 = self.childNode(withName: "brick24") as! SKSpriteNode
//        brick25 = self.childNode(withName: "brick25") as! SKSpriteNode
//        brick26 = self.childNode(withName: "brick26") as! SKSpriteNode
//        brick27 = self.childNode(withName: "brick27") as! SKSpriteNode
//        brick28 = self.childNode(withName: "brick28") as! SKSpriteNode
        
//        brick = self.childNode(withName: "brick1") as! SKSpriteNode
//        brick.zPosition = 1
        
//        let bottom = SKNode()
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
//            brick.removeFromParent()
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

    
    func makeBricks(){
        let blockWidth = SKSpriteNode(imageNamed: "brick1").size.width

        for i in 0...7 {
            let block = SKSpriteNode(imageNamed: "brick1")
            let rand = Int(arc4random_uniform(2))
             let blockCount = CGFloat (i)
            if rand == 1 {
            block.position = CGPoint(x: frame.origin.x + (blockCount*blockWidth), y: 309.5)
                block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                block.physicsBody!.allowsRotation = false
                block.physicsBody!.friction = 0.0
                block.physicsBody!.affectedByGravity = false
                block.physicsBody!.isDynamic = false
                block.name = "brick"
                //            block.physicsBody!.categoryBitMask = BlockCategory
                block.physicsBody?.collisionBitMask = 1
                block.physicsBody?.contactTestBitMask = 1
                block.zPosition = 1
                addChild(block)
                
            
            }
                //y values
                //364.5
                //419.5
                //474.5
                //529.5
                //584.5
                //639.5
            else{
                continue
            }
            
            for i in 0...7 {
                let block = SKSpriteNode(imageNamed: "brick1")
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                if rand == 1 {
                    block.position = CGPoint(x: frame.origin.x + (blockCount*blockWidth), y: 364.5)
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                    block.physicsBody!.allowsRotation = false
                    block.physicsBody!.friction = 0.0
                    block.physicsBody!.affectedByGravity = false
                    block.physicsBody!.isDynamic = false
                    block.name = "brick"
                    //            block.physicsBody!.categoryBitMask = BlockCategory
                    block.physicsBody?.collisionBitMask = 1
                    block.physicsBody?.contactTestBitMask = 1
                    block.zPosition = 1
                    addChild(block)
                    
                    
                }
                else{
                    continue
                }

            }
            
            for i in 0...7 {
                let block = SKSpriteNode(imageNamed: "brick1")
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                if rand == 1 {
                    block.position = CGPoint(x: frame.origin.x + (blockCount*blockWidth), y: 419.5)
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                    block.physicsBody!.allowsRotation = false
                    block.physicsBody!.friction = 0.0
                    block.physicsBody!.affectedByGravity = false
                    block.physicsBody!.isDynamic = false
                    block.name = "brick"
                    //            block.physicsBody!.categoryBitMask = BlockCategory
                    block.physicsBody?.collisionBitMask = 1
                    block.physicsBody?.contactTestBitMask = 1
                    block.zPosition = 1
                    addChild(block)
                    
                    
                }
                else{
                    continue
                }
                
            }

            for i in 0...7 {
                let block = SKSpriteNode(imageNamed: "brick1")
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                if rand == 1 {
                    block.position = CGPoint(x: frame.origin.x + (blockCount*blockWidth), y: 474.5)
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                    block.physicsBody!.allowsRotation = false
                    block.physicsBody!.friction = 0.0
                    block.physicsBody!.affectedByGravity = false
                    block.physicsBody!.isDynamic = false
                    block.name = "brick"
                    //            block.physicsBody!.categoryBitMask = BlockCategory
                    block.physicsBody?.collisionBitMask = 1
                    block.physicsBody?.contactTestBitMask = 1
                    block.zPosition = 1
                    addChild(block)
                    
                    
                }
                else{
                    continue
                }
                
            }

            
            for i in 0...7 {
                let block = SKSpriteNode(imageNamed: "brick1")
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                if rand == 1 {
                    block.position = CGPoint(x: frame.origin.x + (blockCount*blockWidth), y: 529.5)
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                    block.physicsBody!.allowsRotation = false
                    block.physicsBody!.friction = 0.0
                    block.physicsBody!.affectedByGravity = false
                    block.physicsBody!.isDynamic = false
                    block.name = "brick"
                    //            block.physicsBody!.categoryBitMask = BlockCategory
                    block.physicsBody?.collisionBitMask = 1
                    block.physicsBody?.contactTestBitMask = 1
                    block.zPosition = 1
                    addChild(block)
                    
                    
                }
                else{
                    continue
                }
                
            }

            for i in 0...7 {
                let block = SKSpriteNode(imageNamed: "brick1")
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                if rand == 1 {
                    block.position = CGPoint(x: frame.origin.x + (blockCount*blockWidth), y: 584.5)
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                    block.physicsBody!.allowsRotation = false
                    block.physicsBody!.friction = 0.0
                    block.physicsBody!.affectedByGravity = false
                    block.physicsBody!.isDynamic = false
                    block.name = "brick"
                    //            block.physicsBody!.categoryBitMask = BlockCategory
                    block.physicsBody?.collisionBitMask = 1
                    block.physicsBody?.contactTestBitMask = 1
                    block.zPosition = 1
                    addChild(block)
                    
                    
                }
                else{
                    continue
                }
                
            }

            for i in 0...7 {
                let block = SKSpriteNode(imageNamed: "brick1")
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                if rand == 1 {
                    block.position = CGPoint(x: frame.origin.x + (blockCount*blockWidth), y: 639.5)
                    block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                    block.physicsBody!.allowsRotation = false
                    block.physicsBody!.friction = 0.0
                    block.physicsBody!.affectedByGravity = false
                    block.physicsBody!.isDynamic = false
                    block.name = "brick"
                    //            block.physicsBody!.categoryBitMask = BlockCategory
                    block.physicsBody?.collisionBitMask = 1
                    block.physicsBody?.contactTestBitMask = 1
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
        isFingerOnPaddle = false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

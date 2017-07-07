import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BallCategory   : UInt32 = 0x1 << 0
    let BottomCategory : UInt32 = 0x1 << 1
    let BlockCategory  : UInt32 = 0x1 << 2
    let PaddleCategory : UInt32 = 0x1 << 3
    let BorderCategory : UInt32 = 0x1 << 4
    
    let GameMessageName = "gameMessage"
    
//    var gameWon = false
    var ball = SKSpriteNode()
    var paddle = SKSpriteNode()
    var bottom = SKSpriteNode()
    var block = SKSpriteNode()
    var brickCount = Int()
    var rows = [CGFloat]()
    let backgroundImage = SKSpriteNode(imageNamed: "PrisonCell")
    
    
    lazy var gameState: GKStateMachine = GKStateMachine(states: [
        TapToPlay(scene: self),
        Playing(scene: self),
        GameOver(scene: self)])
    
    var gameWon : Bool = false {
        didSet {
            let gameOver = childNode(withName: GameMessageName) as! SKSpriteNode
            let textureName = gameWon ? "YouWon" : "GameOver"
            let texture = SKTexture(imageNamed: textureName)
            let actionSequence = SKAction.sequence([SKAction.setTexture(texture),
                                                    SKAction.scale(to: 1.0, duration: 0.25)])
            
            gameOver.run(actionSequence)
            //            run(gameWon ? gameWonSound : gameOverSound)
        }
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundImage.inputView?.layer.contents = UIImage(named: "PrisonCell")?.cgImage
        backgroundImage.size = CGSize(width: view.frame.size.width*1.85, height: view.frame.size.height*1.85)
        self.insertChild(backgroundImage, at: 0)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        paddle.texture = nil
        paddle.color = UIColor.orange
        paddle.colorBlendFactor = 1
        paddle.size = CGSize(width: 200, height: 30)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 30))
        paddle.physicsBody?.allowsRotation = false
        paddle.physicsBody?.friction = 0.0
        paddle.physicsBody?.affectedByGravity = false
        paddle.physicsBody?.isDynamic = false
        paddle.name = "paddle"
        paddle.physicsBody?.categoryBitMask = 1
        paddle.physicsBody?.collisionBitMask = 2
        paddle.physicsBody?.contactTestBitMask = 2
        paddle.position = CGPoint(x: 0, y: -(view.frame.size.height)*2/5)
        paddle.zPosition = 1
        self.insertChild(paddle, at: 1)
        let range = SKRange(lowerLimit: backgroundImage.frame.minX+100, upperLimit: backgroundImage.frame.maxX-100)
        let constraint = SKConstraint.positionX(range)
        paddle.constraints = [constraint]
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        
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
        
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        gameMessage.zPosition = 4
        gameMessage.setScale(0.0)
        addChild(gameMessage)
        
        gameState.enter(TapToPlay.self)
        

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
            print("Hit brick")
            breakBlock(node: secondBody.node!)
            if isGameWon() {
                gameState.enter(GameOver.self)
                gameWon = true
            }
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody == bottom.physicsBody {
//            print("Rock bottom")
            
            gameState.enter(GameOver.self)
            gameWon = false

        }
        
//        if firstBody.categoryBitMask == BallCategory && secondBody == self.physicsBody {
//            print("To the wallz")
//        }
//        
//        if firstBody.categoryBitMask == BallCategory && secondBody == paddle.physicsBody {
//            print("Paddle")
//        }
//        if firstBody == paddle.physicsBody && secondBody == bottom.physicsBody {
//            print("Da fuq")
//        }
            if (ball.physicsBody?.velocity.dx == 0 || ball.physicsBody?.velocity.dy == 0) && secondBody != bottom.physicsBody {
            ball.physicsBody?.isResting = true
            ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 40))
        }
    }
    
    func makeBricks(){
        
        for row in rows {
            let blockWidth = SKSpriteNode(imageNamed: "brick1").size.width
            for i in 0...6 {
                block = SKSpriteNode(imageNamed: "brick1")
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
    
    
    func breakBlock(node: SKNode) {
                let particles = SKEmitterNode(fileNamed: "BreakBlock")!
                particles.position = node.position
                particles.zPosition = 3
                addChild(particles)
                particles.run(SKAction.sequence([SKAction.wait(forDuration: 0.25),
                                                 SKAction.removeFromParent()]))
        node.removeFromParent()
    }
    
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        
        switch gameState.currentState {
        case is TapToPlay:
            gameState.enter(Playing.self)
           
            
        case is Playing:
            for touch in touches {
                let location = touch.location(in: self)
                paddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
            }
            
            
        case is GameOver:
            let newScene = GameScene(fileNamed:"GameScene")
            newScene!.scaleMode = .aspectFit
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene!, transition: reveal)
            
        default:
            break
        }


        
        

    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        
        for touch in touches {
            let location = touch.location(in: self)
            paddle.run(SKAction.moveTo(x: location.x, duration: 0.2))
            
        }
    }
    
    func isGameWon() -> Bool {
        brickCount = 0
        self.enumerateChildNodes(withName: "brick") {
            node, stop in
            self.brickCount = self.brickCount + 1
        }
        return brickCount == 0
    }
    
    func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
        let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }

    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        isFingerOnPaddle = false
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

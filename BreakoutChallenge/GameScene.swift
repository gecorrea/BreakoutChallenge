import SpriteKit
import GameplayKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BallCategory   : UInt32 = 0x1 << 0
    let BottomCategory : UInt32 = 0x1 << 1
    let BlockCategory  : UInt32 = 0x1 << 2
    let PaddleCategory : UInt32 = 0x1 << 3
    let BorderCategory : UInt32 = 0x1 << 4
    
    let GameMessageName = "gameMessage"
    
    var ball = SKSpriteNode()
    var paddle = SKSpriteNode()
    var bottom = SKSpriteNode()
    var block = SKSpriteNode()
    var brickCount = Int()
    var rows = [CGFloat]()
    let backgroundImage = SKSpriteNode(imageNamed: "PrisonCell")
    var bars = UIImageView()
    var bgMusic = NSURL(fileURLWithPath:Bundle.main.path(forResource:"mouse_trap", ofType: "mp3")!)
    var explosion = SKAction.playSoundFileNamed("explosion", waitForCompletion: false)
    var audioPlayer = AVAudioPlayer()

    
    
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
            
            if textureName == "GameOver" {
                bars.image = UIImage(named: "cellBars")
                bars.frame.size = CGSize(width: (view?.frame.size.width)!, height: (view?.frame.size.height)!)
                bars.contentMode = .scaleToFill
                moveImageView(imgView: bars)
                let jailCell = SKAction.playSoundFileNamed("jail_cell_door", waitForCompletion: false)
                run(jailCell)
            }
            gameOver.run(actionSequence)
            //            run(gameWon ? gameWonSound : gameOverSound)
        }
    }
    
    func moveImageView(imgView: UIImageView){
        let transition = CATransition()
        transition.duration = 1.0
        transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.type = kCATransitionMoveIn
        transition.subtype = kCATransitionFromBottom
        imgView.layer.add(transition, forKey: nil)
        view?.addSubview(imgView)
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        backgroundImage.inputView?.layer.contents = UIImage(named: "PrisonCell")?.cgImage
        backgroundImage.size = CGSize(width: view.frame.size.width*1.85, height: view.frame.size.height*1.85)
        self.insertChild(backgroundImage, at: 0)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        
        paddle.texture = nil
        paddle.color = UIColor.orange
        paddle.size = CGSize(width: 200, height: 30)
        paddle.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 200, height: 30))
        paddle.physicsBody?.allowsRotation = false
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
        
        audioPlayer = try! AVAudioPlayer(contentsOf: bgMusic as URL)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        audioPlayer.numberOfLoops = -1
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
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == 5 {
            
            //  PUT EXPLODECODE HERE
//            explodeBlock(node: secondBody.node!)
            secondBody.contactTestBitMask = BallCategory
//            blastRadius(secondBody: secondBody, onCompletion: {
            breakBlock(node: secondBody.node!)
            run(explosion)
            
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
    
    func blastRadius(secondBody: SKPhysicsBody, onCompletion: @escaping () -> Void) {
//        for brick in contactBricks {
//            print(brick.node!)
//        }
    }
    
    func makeBricks(){
        
        for row in rows {
            for i in 0...6 {
                let blockWidth = SKSpriteNode(imageNamed: "brick1").size.width
                block.size.width = blockWidth * 1.071
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                
                if rand == 0{
                    let rand2 = Int(arc4random_uniform(99))
                    if rand2 < 15 {
                        block = SKSpriteNode(imageNamed: "brickSplode")
                        block.position = CGPoint(x: frame.origin.x + (block.size.width/2) + (blockCount*block.size.width) * 1.071, y: row)
                        block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                        block.physicsBody!.allowsRotation = false
                        block.physicsBody!.friction = 0.0
                        block.physicsBody!.affectedByGravity = false
                        block.physicsBody!.isDynamic = false
                        block.name = "tnt"
                        block.physicsBody!.categoryBitMask = 5
                        block.physicsBody?.collisionBitMask = 2
                        block.physicsBody?.contactTestBitMask = 2
                        block.zPosition = 1
                        addChild(block)

                    }
                    else {
                        continue
                    }
                    
                }
                
                if rand == 1 {
                    block = SKSpriteNode(imageNamed: "brick1")
                    block.position = CGPoint(x: frame.origin.x + (block.size.width/2) + (blockCount*block.size.width) * 1.071, y: row)
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
        if node.name == "tnt" {
            let particles = SKEmitterNode(fileNamed: "BreakTNT")!
            particles.position = node.position
            particles.zPosition = 3
            addChild(particles)
            particles.run(SKAction.sequence([SKAction.wait(forDuration: 2),
                                             SKAction.removeFromParent()]))
        }
        else {
            let particles = SKEmitterNode(fileNamed: "BreakBrick")!
            particles.position = node.position
            particles.zPosition = 3
            addChild(particles)
            particles.run(SKAction.sequence([SKAction.wait(forDuration: 2),
                                                 SKAction.removeFromParent()]))
        }
        node.removeFromParent()
    }
    
    func explodeBlock(node:SKNode){
        let brickHeight = node.frame.height
        let brickWidth = node.frame.width
        
        
        //Collision on the right
        let invisiBrickRight = SKSpriteNode(color: .purple, size: block.size)
        invisiBrickRight.position = CGPoint(x: node.position.x + brickWidth, y: node.position.y)
        invisiBrickRight.physicsBody?.categoryBitMask = BallCategory
//        invisiBrickRight.physicsBody?.categoryBitMask = 2
        invisiBrickRight.physicsBody?.collisionBitMask = 3
        invisiBrickRight.physicsBody?.contactTestBitMask = 3
        invisiBrickRight.zPosition = 1
        
        //Collision to the left
        let invisiBrickLeft = SKSpriteNode(color: .purple, size: block.size)
        invisiBrickLeft.position = CGPoint(x: node.position.x - brickWidth, y: node.position.y)
        invisiBrickLeft.physicsBody?.categoryBitMask = BallCategory
//        invisiBrickLeft.physicsBody?.categoryBitMask = 2
        invisiBrickLeft.physicsBody?.collisionBitMask = 3
        invisiBrickLeft.physicsBody?.contactTestBitMask = 3
        invisiBrickLeft.zPosition = 1
        
        //Collision TopLeft
        let invisiBrickTopLeft = SKSpriteNode(color: .purple, size: block.size)
        invisiBrickTopLeft.position = CGPoint(x: node.position.x - brickWidth, y: node.position.y + brickHeight)
        invisiBrickTopLeft.physicsBody?.categoryBitMask = BallCategory
//        invisiBrickTopLeft.physicsBody?.categoryBitMask = 2
        invisiBrickTopLeft.physicsBody?.collisionBitMask = 3
        invisiBrickTopLeft.physicsBody?.contactTestBitMask = 3
        invisiBrickTopLeft.zPosition = 1
        
        //Collision TopRight
        let invisiBrickTopRight = SKSpriteNode(color: .purple, size: block.size)
        invisiBrickTopRight.position = CGPoint(x: node.position.x + brickWidth, y: node.position.y + brickHeight)
        invisiBrickTopRight.physicsBody?.categoryBitMask = BallCategory
//        invisiBrickTopRight.physicsBody?.categoryBitMask = 2
        invisiBrickTopRight.physicsBody?.collisionBitMask = 3
        invisiBrickTopRight.physicsBody?.contactTestBitMask = 3
        invisiBrickTopRight.zPosition = 1
        
        //Collision on bottomLeft
        let invisiBrickBottomLeft = SKSpriteNode(color: .purple, size: block.size)
        invisiBrickBottomLeft.position = CGPoint(x: node.position.x - brickWidth, y: node.position.y - brickHeight)
        invisiBrickBottomLeft.physicsBody?.categoryBitMask = BallCategory
//        invisiBrickBottomLeft.physicsBody?.categoryBitMask = 2
        invisiBrickBottomLeft.physicsBody?.collisionBitMask = 1
        invisiBrickBottomLeft.physicsBody?.contactTestBitMask = 1
        invisiBrickBottomLeft.zPosition = 1
        
        //Collision on bottomRight
        let invisiBrickBottomRight = SKSpriteNode(color: .purple, size: block.size)
        invisiBrickBottomRight.position = CGPoint(x: node.position.x + brickWidth, y: node.position.y - brickHeight)
        invisiBrickBottomRight.physicsBody?.categoryBitMask = BallCategory
//        invisiBrickBottomRight.physicsBody?.categoryBitMask = 2
        invisiBrickBottomRight.physicsBody?.collisionBitMask = 3
        invisiBrickBottomRight.physicsBody?.contactTestBitMask = 3
        invisiBrickBottomRight.zPosition = 1
        
        //Collision up top
        let invisiBrickTop = SKSpriteNode(color: .purple, size: block.size)
        invisiBrickTop.position = CGPoint(x: node.position.x, y: node.position.y + brickHeight)
        invisiBrickTop.physicsBody?.categoryBitMask = BallCategory
//        invisiBrickTop.physicsBody?.categoryBitMask = 2
        invisiBrickTop.physicsBody?.collisionBitMask = 3
        invisiBrickTop.physicsBody?.contactTestBitMask = 3
        invisiBrickTop.zPosition = 1
        
        //Collision on bottom
        let invisiBrickBottom = SKSpriteNode(color: .purple, size: block.size)
        invisiBrickBottom.position = CGPoint(x: node.position.x, y: node.position.y - brickHeight)
        invisiBrickBottom.physicsBody?.categoryBitMask = BallCategory
//        invisiBrickBottom.physicsBody?.categoryBitMask = 2
        invisiBrickBottom.physicsBody?.collisionBitMask = 3
        invisiBrickBottom.physicsBody?.contactTestBitMask = 3
        invisiBrickBottom.zPosition = 1
        
        
        let invisabricks = [invisiBrickRight, invisiBrickLeft, invisiBrickTopLeft, invisiBrickTopRight, invisiBrickBottomLeft, invisiBrickBottomRight, invisiBrickTop, invisiBrickBottom]
        
        for brick in invisabricks {
//            brick.physicsBody!.allowsRotation = false
//            brick.physicsBody!.friction = 0.0
//            brick.physicsBody?.affectedByGravity = false
            brick.physicsBody?.isDynamic = true
            brick.physicsBody?.restitution = 1
            brick.physicsBody = SKPhysicsBody(rectangleOf: brick.frame.size)
            brick.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 20))
            addChild(brick)
        }
//        addChild(invisiBrickRight)
//        addChild(invisiBrickLeft)
//        addChild(invisiBrickTopLeft)
//        addChild(invisiBrickTopRight)
//        addChild(invisiBrickBottomLeft)
//        addChild(invisiBrickBottomRight)
//        addChild(invisiBrickTop)
//        addChild(invisiBrickBottom)
        
        
        
//        invisiBrickBottomRight.removeFromParent()
//        invisiBrickLeft.removeFromParent()
//        invisiBrickTopLeft.removeFromParent()
//        invisiBrickTopRight.removeFromParent()
//        invisiBrickBottomLeft.removeFromParent()
//        invisiBrickBottomRight.removeFromParent()
//        invisiBrickTop.removeFromParent()
//        invisiBrickBottom.removeFromParent()
//        invisiBrickRight.removeFromParent()
        
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
            bars.removeFromSuperview()
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
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

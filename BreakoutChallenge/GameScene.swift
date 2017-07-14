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
    var blocks = Array<Block>()
//    lazy var block = Block(x: 0, y: 0, size: CGSize(), texture: SKTexture())
    var brickCount = Int()
    var rows = [CGFloat]()
    let backgroundImage = SKSpriteNode(imageNamed: "PrisonCell")
    let winBackground = SKSpriteNode(imageNamed: "freedom")
    var bars = UIImageView()
    let bgMusic = NSURL(fileURLWithPath:Bundle.main.path(forResource:"mouse_trap", ofType: "mp3")!)
    let explosion = SKAction.playSoundFileNamed("explosion", waitForCompletion: false)
    let jailCell = SKAction.playSoundFileNamed("jail_cell_door", waitForCompletion: false)
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
                run(jailCell)
            }
            else{
                winBackground.inputView?.layer.contents = UIImage(named: "freedom")?.cgImage
                 winBackground.size = CGSize(width: (view?.frame.size.width)!*1.85, height: (view?.frame.size.height)!*1.85)
                self.insertChild(winBackground, at: 2)
            
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
            guard let node = secondBody.node else {return}
            breakBlock(node: node as! Block)
            if isGameWon() {
                gameState.enter(GameOver.self)
                gameWon = true
            }
        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody == bottom.physicsBody {
            gameState.enter(GameOver.self)
            gameWon = false

        }
        
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == 5 {
            
            //  PUT EXPLODECODE HERE
//            explodeBlock(node: secondBody.node!)
            
            guard let node = secondBody.node else {return}
            blastRadius(node: node as! Block)
//            breakBlock(node: node as! Block)
            run(explosion)
            
            if isGameWon() {
                gameState.enter(GameOver.self)
                gameWon = true
            }

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
            for i in 0...6 {
                
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                if rand == 0{
                    let rand2 = Int(arc4random_uniform(99))
                    if rand2 < 99 {
                        let index = 7 * rows.index(of: row)! + i
                        let blockWidth = SKSpriteNode(imageNamed: "brickSplode").size.width
                        let blockHeight = SKSpriteNode(imageNamed: "brickSplode").size.height
                        let blockSize = CGSize(width: blockWidth * 1.071, height: blockHeight)
                        let block = Block(index: index, size: blockSize, texture: SKTexture(imageNamed: "brickSplode"))
//                        block.size.width = blockWidth * 1.071
//                        block.xIndex = i
//                        block.yIndex = Int(row)
//                        block.texture = SKTexture(imageNamed: "brickSplode")
                        block.position = CGPoint(x: frame.origin.x + (block.size.width/2) + (blockCount*block.size.width), y: row)
                        block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
                        block.physicsBody!.allowsRotation = false
                        block.physicsBody!.friction = 0.0
                        block.physicsBody!.affectedByGravity = false
                        block.physicsBody!.isDynamic = false
                        block.name = "brick"
                        block.physicsBody!.categoryBitMask = 5
                        block.physicsBody?.collisionBitMask = 2
                        block.physicsBody?.contactTestBitMask = 2
                        block.zPosition = 1
                        addChild(block)
                        blocks.append(block)
                    }
                    else {
                        continue
                    }
                    
                }
                
                if rand == 1 {
                    let index = 7 * rows.index(of: row)! + i
                    let blockWidth = SKSpriteNode(imageNamed: "brick1").size.width
                    let blockHeight = SKSpriteNode(imageNamed: "brick1").size.height
                    let blockSize = CGSize(width: blockWidth * 1.071, height: blockHeight)
                    let block = Block(index: index, size: blockSize, texture: SKTexture(imageNamed: "brick1"))
//                    block.xIndex = i
//                    block.yIndex = Int(row)
//                    block.texture = SKTexture(imageNamed: "brick1")
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
                    blocks.append(block)
                }
                else{
                    continue
                }
            }
        }
        
    }
    
    func blastRadius(node: Block) {
        let center = node.index
        
        for i in blocks{
            switch true {
            case i.index == center-1:
                if i.index % 7 != 6 {
                    breakBlock(node: i)
                }
                continue
                
            case i.index == center+1:
                if i.index % 7 != 0 {
                breakBlock(node: i)
                }
                continue
                
            case i.index == center+6:
                if i.index % 7 != 6 {
                    breakBlock(node: i)
                }
                continue
                
            
            case i.index == center+7:
                breakBlock(node: i)
                continue
                
            case i.index == center+8:
                if i.index % 7 != 0 {
                    breakBlock(node: i)
                }
                continue
                
            case i.index == center-6:
                if i.index % 7 != 0 {
                    breakBlock(node: i)
                }
                continue
                
            case i.index == center-7:
                breakBlock(node: i)
                continue
                
            case i.index == center-8:
                if i.index % 7 != 6 {
                    breakBlock(node: i)
                }
                continue
                
            case i.index == center:
                breakBlock(node: i)
                continue
                
            default:
                continue
            }
        }
        
        
    }
    
    
    func breakBlock(node: Block) {
        let nodeIndex = blocks.index(of: node)
        if node.physicsBody?.categoryBitMask == 5 {
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
        blocks.remove(at: nodeIndex!)
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
       return blocks.count == 0
    }
    
    
    
    func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
        let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

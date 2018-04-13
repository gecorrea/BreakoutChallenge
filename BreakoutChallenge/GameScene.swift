import SpriteKit
import GameplayKit
import AVFoundation

protocol RefreshLabelsDelegate {
    func beginGame()
    func updateScore()
    func gameIsOver()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BallCategory   : UInt32 = 0x1 << 0
    
    let GameMessageName = "gameMessage"
    var labelDelegate: RefreshLabelsDelegate?
    var ball = SKSpriteNode()
    var paddle = SKSpriteNode()
    var bottom = SKSpriteNode()
    var blocks = Array<Block>()
    var brickCount = Int()
    var rows = [CGFloat]()
    var winRows = [CGFloat]()
    let upperBound = 640
    let lowerBound = -640
    let backgroundImage = SKSpriteNode(imageNamed: "PrisonCell")
    let winBackground = SKSpriteNode(imageNamed: "freedom")
    var bars = UIImageView()
    let notification = UINotificationFeedbackGenerator()
    let impact = UIImpactFeedbackGenerator(style: .heavy)
    let bgMusic = NSURL(fileURLWithPath:Bundle.main.path(forResource:"mouse_trap", ofType: "mp3")!)
    let explosion = SKAction.playSoundFileNamed("explosion", waitForCompletion: false)
    let jailCell = SKAction.playSoundFileNamed("jail_cell_door", waitForCompletion: false)
    var audioPlayer = AVAudioPlayer()
    var barActionDone = Bool()
    static var difficulty = 36
    static var stageScore = 0
    static var currentScore = Int()
    
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
                if barActionDone == false {
                    if GameScene.difficulty < 99 {
                        GameScene.difficulty += 9
                    }
                    bars.image = UIImage(named: "cellBars")
                    guard let viewWidth = view?.frame.size.width,
                        let viewHeight = view?.frame.size.height else { return }
                    bars.frame.size = CGSize(width: viewWidth, height: viewHeight)
                    bars.contentMode = .scaleToFill
                    moveImageView(imgView: bars)
                    run(jailCell)
                    barActionDone = true
                    notification.notificationOccurred(.warning)

                    labelDelegate?.gameIsOver()
                    GameScene.stageScore = 0
                    GameScene.currentScore = 0
                }
            }
            else{
                if GameScene.difficulty > 0{
                    GameScene.difficulty -= 9
                }
                for row in winRows {
                    for i in 0...6 {
                        let blockCount = CGFloat (i)
                        let index = 7 * winRows.index(of: row)! + i
                        let particles = SKEmitterNode(fileNamed: "BreakBrick")!
                        let blockWidth = SKSpriteNode(imageNamed: "brick1").size.width
                        let blockHeight = SKSpriteNode(imageNamed: "brick1").size.height
                        let blockSize = CGSize(width: blockWidth * 1.071, height: blockHeight)
                        let block = Block(index: index, size: blockSize, texture: SKTexture(imageNamed: "brick1"))
                        particles.position = CGPoint(x: frame.origin.x + (block.size.width/2) + (blockCount*block.size.width), y: row)
                        particles.zPosition = 3
                        addChild(particles)
                        particles.run(SKAction.sequence([SKAction.wait(forDuration: 2),
                                                         SKAction.removeFromParent()]))
                    }
                }
                backgroundImage.removeFromParent()
                winBackground.inputView?.layer.contents = UIImage(named: "freedom")?.cgImage
                guard let viewWidth = view?.frame.size.width,
                    let viewHeight = view?.frame.size.height else { return }
                winBackground.size = CGSize(width: viewWidth, height: viewHeight)
                winBackground.size = frame.size
                self.insertChild(winBackground, at: 0)
                notification.notificationOccurred(.success)
                GameScene.stageScore = 0
            }
            gameOver.run(actionSequence)
        }
    }

    func moveImageView(imgView: UIImageView) {
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
        backgroundImage.size = CGSize(width: view.frame.size.width, height: view.frame.size.height)
        backgroundImage.size = frame.size
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
        paddle.position = CGPoint(x: 0, y: -(view.frame.size.height) * 2/5)
        paddle.zPosition = 1
        self.insertChild(paddle, at: 1)
        let range = SKRange(lowerLimit: backgroundImage.frame.minX + 100, upperLimit: backgroundImage.frame.maxX - 100)
        let constraint = SKConstraint.positionX(range)
        paddle.constraints = [constraint]
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.physicsBody?.collisionBitMask = 1
        ball.physicsBody?.contactTestBitMask = 1
        ball.physicsBody?.categoryBitMask = 2
        ball.position = CGPoint(x: 0, y: -(view.frame.size.height)*3/10)
        ball.zPosition = 1
        ball.physicsBody!.categoryBitMask = BallCategory
        
        bottom = self.childNode(withName: "bottom") as! SKSpriteNode
        bottom.zPosition = 1
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        // setup rows array
        var i = upperBound
        repeat {
            let newFloat = CGFloat(i) - 0.5
            rows.append(newFloat)
            i -= 55
        } while i >= ((upperBound/2) - 10)
        
        makeBricks()
        
        // setup winRows array
        i = upperBound
        repeat {
            let newFloat = CGFloat(i) - 0.5
            winRows.append(newFloat)
            i -= 55
        } while i >= lowerBound
        
        let gameMessage = SKSpriteNode(imageNamed: "TapToPlay")
        gameMessage.name = GameMessageName
        gameMessage.position = CGPoint(x: frame.midX, y: frame.midY)
        gameMessage.zPosition = 5
        gameMessage.setScale(0.0)
        addChild(gameMessage)
        gameState.enter(TapToPlay.self)
        labelDelegate?.beginGame()
        
        barActionDone = false
        
        audioPlayer = try! AVAudioPlayer(contentsOf: bgMusic as URL)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
        audioPlayer.numberOfLoops = -1
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        switch true {
        case firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == 3:
            guard let node = secondBody.node else {return}
            breakBlock(node: node as! Block)
            if isGameWon() {
                gameState.enter(GameOver.self)
                gameWon = true
            }
            break
            
        case firstBody.categoryBitMask == BallCategory && secondBody == bottom.physicsBody:
            gameState.enter(GameOver.self)
            if blocks.count > 0 {
                gameWon = false
            }
            break
            
        case firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == 5:
            guard let node = secondBody.node else {return}
            breakBlock(node: node as! Block)
            run(explosion)
            if isGameWon() {
                gameState.enter(GameOver.self)
                gameWon = true
            }
            break
            
        case (ball.physicsBody?.velocity.dx == 0 || ball.physicsBody?.velocity.dy == 0) && secondBody != bottom.physicsBody:
            ball.physicsBody?.isResting = true
            gameState.update(deltaTime: 0)
            break
            
        default:
            break
        }
    }
    
    func makeBricks(){
        for row in rows {
            for i in 0...6 {
                let rand = Int(arc4random_uniform(2))
                let blockCount = CGFloat (i)
                if rand == 0 {
                    let rand2 = Int(arc4random_uniform(99))
                    if rand2 < GameScene.difficulty {
                        let index = 7 * rows.index(of: row)! + i
                        let blockWidth = SKSpriteNode(imageNamed: "brickSplode").size.width
                        let blockHeight = SKSpriteNode(imageNamed: "brickSplode").size.height
                        let blockSize = CGSize(width: blockWidth * 1.071, height: blockHeight)
                        let block = Block(index: index, size: blockSize, texture: SKTexture(imageNamed: "brickSplode"))
                        block.position = CGPoint(x: frame.origin.x + (block.size.width/2) + (blockCount*block.size.width), y: row)
                        standardBlockProperties(block: block)
                        block.physicsBody?.categoryBitMask = 5
                    }
                }
                
                if rand == 1 {
                    let rand1 = Int(arc4random_uniform(4))
                    if (rand1 == 1 || rand1 == 2 || rand1 == 3) {
                        let index = 7 * rows.index(of: row)! + i
                        let blockWidth = SKSpriteNode(imageNamed: "brick1").size.width
                        let blockHeight = SKSpriteNode(imageNamed: "brick1").size.height
                        let blockSize = CGSize(width: blockWidth * 1.071, height: blockHeight)
                        let block = Block(index: index, size: blockSize, texture: SKTexture(imageNamed: "brick1"))
                        block.position = CGPoint(x: frame.origin.x + (block.size.width/2) + (blockCount*block.size.width), y: row)
                        standardBlockProperties(block: block)
                        block.physicsBody?.categoryBitMask = 3
                    }
                }
            }
        }
    }
    
    func standardBlockProperties(block: Block) {
        block.physicsBody = SKPhysicsBody(rectangleOf: block.frame.size)
        block.physicsBody?.allowsRotation = false
        block.physicsBody?.friction = 0.0
        block.physicsBody?.affectedByGravity = false
        block.physicsBody?.isDynamic = false
        block.name = "brick"
        block.physicsBody?.collisionBitMask = 2
        block.physicsBody?.contactTestBitMask = 2
        block.zPosition = 1
        addChild(block)
        blocks.append(block)
    }
    
    func blastRadius(node: Block) {
        let center = node.index
        for block in blocks{
            switch true {
            case block.index == center - 1 || block.index == center + 6 || block.index == center - 8 && block.index % 7 != 6:
                breakBlock(node: block)
                continue
            case block.index == center + 1 || block.index == center - 6 || block.index == center + 8 && block.index % 7 != 0:
                breakBlock(node: block)
                continue
            case block.index == center - 7 || block.index == center + 7:
                breakBlock(node: block)
                continue
            default:
                break
            }
        }
    }
    
    func breakBlock(node: Block) {
        guard let nodeIndex = blocks.index(of: node) else { return }
        blocks.remove(at: nodeIndex)
        if node.physicsBody?.categoryBitMask == 5 {
            GameScene.stageScore += 10
            GameScene.currentScore += 10
            let particles = SKEmitterNode(fileNamed: "BreakTNT")!
            particles.position = node.position
            particles.zPosition = 3
            addChild(particles)
            particles.run(SKAction.sequence([SKAction.wait(forDuration: 2),
                                             SKAction.removeFromParent()]))
            shakeCamera(layer: backgroundImage, duration: 1)
            for Block in blocks {
                shakeCamera(layer: Block, duration: 1)
            }
            blastRadius(node: node)
        }
        else {
            GameScene.stageScore += 50
            GameScene.currentScore += 50
            let particles = SKEmitterNode(fileNamed: "BreakBrick")!
            particles.position = node.position
            particles.zPosition = 3
            addChild(particles)
            particles.run(SKAction.sequence([SKAction.wait(forDuration: 2),
                                             SKAction.removeFromParent()]))
        }
        node.removeFromParent()
        labelDelegate?.updateScore()
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
            guard let newScene = GameScene(fileNamed:"GameScene"),
                let viewWindow = view?.window else { return }
            let vc = viewWindow.rootViewController as! GameViewController
            newScene.labelDelegate = vc
            newScene.scaleMode = .aspectFit
            bars.removeFromSuperview()
            winBackground.removeFromParent()
            let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
            self.view?.presentScene(newScene, transition: reveal)
            
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
    
    func shakeCamera(layer:SKSpriteNode, duration:Float) {
        let amplitudeX:Float = 10;
        let amplitudeY:Float = 6;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }
        let actionSeq = SKAction.sequence(actionsArray);
        layer.run(actionSeq);
        impact.impactOccurred()
    }
    
    func randomFloat(from:CGFloat, to:CGFloat) -> CGFloat {
        let rand:CGFloat = CGFloat(Float(arc4random()) / 0xFFFFFFFF)
        return (rand) * (to - from) + from
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

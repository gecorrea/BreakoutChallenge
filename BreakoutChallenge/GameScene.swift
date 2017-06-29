import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var ball = SKSpriteNode()
    var paddle = SKSpriteNode()
    let backgroundImage = SKSpriteNode(imageNamed: "background")
    
    override func didMove(to view: SKView) {
        backgroundImage.position = CGPoint(x: self.frame.width/5, y: self.frame.height/5)
        self.insertChild(backgroundImage, at: 0)
        
        
        paddle = self.childNode(withName: "paddle") as! SKSpriteNode
        paddle.position = CGPoint(x: 0, y: -(view.frame.size.height)*2/5)
        paddle.zPosition = 1
        
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        ball.physicsBody?.applyImpulse(CGVector(dx: 20, dy: 20))
        ball.zPosition = 1
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        border.friction = 0
        border.restitution = 1
        
        self.physicsBody = border
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

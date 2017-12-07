import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var stageScoreLabel: UILabel!
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var finalScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                scene.labelDelegate = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}

extension GameViewController: RefreshLabelsDelegate {
    func beginGame() {
        stageScoreLabel.text = "Stage Score: \(GameScene.stageScore)"
        currentScoreLabel.text = "Current Score: \(GameScene.currentScore)"
        finalScoreLabel.isHidden = true
    }
    
    func updateScore() {
        stageScoreLabel.text = "Stage Score: \(GameScene.stageScore)"
        currentScoreLabel.text = "Current Score: \(GameScene.currentScore)"
    }
    
    func gameIsOver() {
        finalScoreLabel.text = "Final Score: \(GameScene.currentScore)"
        view.bringSubview(toFront: finalScoreLabel)
        finalScoreLabel.isHidden = false
    }
}

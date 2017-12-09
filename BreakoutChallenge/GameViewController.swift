import UIKit
import SpriteKit
import GameplayKit
import GameKit

class GameViewController: UIViewController {
    
    @IBOutlet weak var stageScoreLabel: UILabel!
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var checkLeaderboardButton: UIButton!
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    
//    var score = 0
    
    // IMPORTANT: replace the red string below with your own Leaderboard ID (the one you've set in iTunes Connect)
    let LEADERBOARD_ID = "com.score.BreakoutChallenge"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = GameScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit
                scene.labelDelegate = self
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
        }
        authenticateLocalPlayer()
    }
    
    // MARK: - AUTHENTICATE LOCAL PLAYER
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = {(ViewController, error) -> Void in
            if((ViewController) != nil) {
                // 1. Show login if player is not logged in
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                // 2. Player is already authenticated & logged in, load game center
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error as Any)
                    } else { self.gcDefaultLeaderBoard = (leaderboardIdentifer)! }
                })
                
            } else {
                // 3. Game center is not enabled on the users device
                self.gcEnabled = false
                print("Local player could not be authenticated!")
                print(error as Any)
            }
        }
    }
    
    // Action that allows you to check Top Scores Leaderboard in Game Center
    @IBAction func checkLeaderboard(_ sender: UIButton) {
        let gcVC = GKGameCenterViewController()
        gcVC.gameCenterDelegate = self
        gcVC.viewState = .leaderboards
        gcVC.leaderboardIdentifier = LEADERBOARD_ID
        present(gcVC, animated: true, completion: nil)
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

extension GameViewController: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}

extension GameViewController: RefreshLabelsDelegate {
    func beginGame() {
        stageScoreLabel.text = "Stage Score: \(GameScene.stageScore)"
        currentScoreLabel.text = "Current Score: \(GameScene.currentScore)"
        finalScoreLabel.isHidden = true
        checkLeaderboardButton.isHidden = true
    }
    
    func updateScore() {
        stageScoreLabel.text = "Stage Score: \(GameScene.stageScore)"
        currentScoreLabel.text = "Current Score: \(GameScene.currentScore)"
    }
    
    func gameIsOver() {
        let labels = [stageScoreLabel, currentScoreLabel, finalScoreLabel]
        for label in labels {
            if let subview = label {
               view.bringSubview(toFront: subview)
            }
        }
        finalScoreLabel.text = "Final Score: \(GameScene.currentScore)"
//        view.bringSubview(toFront: finalScoreLabel)
        finalScoreLabel.isHidden = false
        view.bringSubview(toFront: checkLeaderboardButton)
        checkLeaderboardButton.isHidden = false
        
        // Submit score to Game Center
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(GameScene.currentScore)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
}

import UIKit
import SpriteKit
import GameplayKit
import GameKit

final class GameViewController: UIViewController {
    
    @IBOutlet weak var stageScoreLabel: UILabel!
    @IBOutlet weak var currentScoreLabel: UILabel!
    @IBOutlet weak var finalScoreLabel: UILabel!
    @IBOutlet weak var checkLeaderboardButton: UIButton!
    @IBOutlet weak var jailBreakoutLabel: UILabel!
    @IBOutlet weak var challengeLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var playButton: UIButton!
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID

    let LEADERBOARD_ID = "com.score.BreakoutChallenge"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        [stageScoreLabel, currentScoreLabel, finalScoreLabel].forEach { $0?.isHidden = true }
        checkLeaderboardButton.isHidden = true
        authenticateLocalPlayer()
    }
    
    @IBAction func playButtonTouched(_ sender: UIButton) {
        [jailBreakoutLabel, challengeLabel, backgroundView].forEach { $0?.isHidden = true }
        playButton.isHidden = true
        guard let view = self.view as? SKView,
            let  scene = GameScene(fileNamed: "GameScene") else { return }
        scene.scaleMode = .aspectFit
        scene.view?.bounds = view.bounds
        scene.labelDelegate = self
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
    }
    
    
    // MARK: - AUTHENTICATE LOCAL PLAYER
    func authenticateLocalPlayer() {
        let localPlayer: GKLocalPlayer = GKLocalPlayer.localPlayer()
        
        localPlayer.authenticateHandler = { (ViewController, error) -> Void in
            if((ViewController) != nil) {
                self.present(ViewController!, animated: true, completion: nil)
            } else if (localPlayer.isAuthenticated) {
                self.gcEnabled = true
                
                // Get the default leaderboard ID
                localPlayer.loadDefaultLeaderboardIdentifier(completionHandler: { (leaderboardIdentifer, error) in
                    if error != nil { print(error as Any)
                    } else {
                        if let leadIdentifer = leaderboardIdentifer {
                            self.gcDefaultLeaderBoard = leadIdentifer
                        }
                    }
                })
                
            } else {
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
        [stageScoreLabel, currentScoreLabel].forEach { $0?.isHidden = false }
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
        [stageScoreLabel, currentScoreLabel, finalScoreLabel].forEach { label in
            if let subview = label {
                view.bringSubview(toFront: subview)
            }
        }
        finalScoreLabel.text = "Final Score: \(GameScene.currentScore)"
        finalScoreLabel.isHidden = false
        view.bringSubview(toFront: checkLeaderboardButton)
        checkLeaderboardButton.isHidden = false
        
        // Submit score to Game Center
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(GameScene.currentScore)
        GKScore.report([bestScoreInt]) { error in
            if error != nil {
                guard let error = error else {
                    fatalError("Fatal error in GameViewController while getting error message.")
                }
                print(error.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
    }
}

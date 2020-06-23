//
//  GameScene.swift
//  crab
//
//  Created by Vincent Qi on 2020-06-20.
//  Copyright © 2020 Vincent Qi. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Menu
    var title: SKLabelNode?
    var logo: SKSpriteNode?
    var highScore: SKLabelNode?
    var playButton: SKSpriteNode?
    
    // Others
    
    var inGame: Bool = false

    var gameManager: GameManager!
    
    var isMoving: Bool = false
    var nm: String?
    var pos: Int = 1
    var bestScore: Int = 0
    
    var allowMovement: Bool = false

    override func didMove(to view: SKView) {
        gameManager = GameManager(self)
        gameManager.gmInit()
        initMenu()
    }
    
    override func update(_ currentTime: TimeInterval) {
        movePlayer(name: nm)
        gameManager.update(currentTime)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //guard let touch = touches.first else {
        //    return
        //}
        for touch in touches {
            let location = touch.location(in: self)
            let tNodes = nodes(at: location)
            for node in tNodes {
                if node.name == "play" {
                    playGame()
                } else if node.name == "ok" && gameManager.showingResults {
                    gameManager.endResults()
                }
                if !inGame || !allowMovement { return }
                for cNode in (gameManager.control?.children)! {
                    if node == cNode {
                        nm = node.name!
                        isMoving = true
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMoving = false
        gameManager.zooming = false
    }
    
    private func playGame() {
        if inGame { return }
        allowMovement = true
        gameManager.startTimer()
        gameManager.updateControl()
        hideMenu()
        inGame = true
    }
    
    private func movePlayer(name: String?) {
        if(isMoving && name != nil) {
            gameManager.touchNode(name: name!)
        }
    }
    
    private func initMenu() {
        title = SKLabelNode(text: "George")
        title?.fontName = "ArialRoundedMTBold"
        title?.fontSize = 90
        title?.fontColor = SKColor.white
        title?.position = CGPoint(x: 0, y: (frame.height / 2) - 120)
        self.addChild(title!)
        
        playButton = SKSpriteNode(imageNamed: "play_button.png")
        playButton?.position = CGPoint(x: 0, y: 0)
        playButton?.name = "play"
        playButton?.size = CGSize(width: 180, height: 180)
        self.addChild(playButton!)
        
        highScore = SKLabelNode(text: "Best Score: 0")
        highScore?.position = CGPoint(x: 0, y: (frame.height / -2) + 20)
        highScore?.fontSize = 50
        self.addChild(highScore!)
    }
    
    private func hideMenu() {
        title?.run(SKAction.move(by: CGVector(dx: 0, dy: 200), duration: 0.3))
        title?.isHidden = true
        playButton?.run(SKAction.fadeOut(withDuration: 0.1))
        highScore?.run(SKAction.move(by: CGVector(dx: 0, dy: -100), duration: 0.3))
        let timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (timer) in
            self.highScore?.isHidden = true
        }
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
    }
    
    func showMenu() {
        title?.run(SKAction.move(by: CGVector(dx: 0, dy: -200), duration: 0.3))
        title?.isHidden = false
        playButton?.run(SKAction.fadeIn(withDuration: 0.1))
        highScore?.isHidden = false
        highScore?.text = "Best Score: \(bestScore)"
        highScore?.run(SKAction.move(by: CGVector(dx: 0, dy: 100), duration: 0.3))
    }
}

//
//  GameManager.swift
//  crab
//
//  Created by Vincent Qi on 2020-06-20.
//  Copyright © 2020 Vincent Qi. All rights reserved.
//

import Foundation
import SpriteKit

class GameManager {
    var scene: GameScene!
    var player: Player?
    var fruitNodes: SKNode?
    var control: SKNode?
    var timeText: SKLabelNode?
    var timer: Timer?
    
    var mapZoom: Int = 2
    
    var resultsLabel: SKLabelNode?
    var fruitResultsSprite: SKSpriteNode?, gFruitResultsSprite: SKSpriteNode?
    var fruitResultsLabel: SKLabelNode?, gFruitResultsLabel: SKLabelNode?, scoreLabel: SKLabelNode?, currentScore: SKLabelNode?, okLabel: SKLabelNode?
    
    var pauseButton: SKSpriteNode?
    var pauseMenu: SKNode?
    var resumeLabel: SKLabelNode?, restartLabel: SKLabelNode?, quitLabel: SKLabelNode?
    
    var ateFruit: Int = 0, ateGFruit: Int = 0
    
    var isPaused: Bool = false
    
    init(_ scene: GameScene!) {
        self.scene = scene
        self.player = Player(self.scene, self)
    }
    
    // Post - init
    
    var arrows: [SKSpriteNode] = []
    var cam: SKCameraNode?
    var fruit: SKSpriteNode?
    var gFruit: SKSpriteNode?
    var zooming: Bool = false
    var zoomed: Bool = false
    var showingResults: Bool = false
    
    var score: Double = 0
    var timeLeft: Double?
    
    private var orginCamSize: CGSize?
    
    func gmInit() {
        cam = SKCameraNode()
        fruitNodes = SKNode()
        control = SKNode()
        cam?.addChild(control!)
        scene.worldNode?.addChild(cam!)
        scene.worldNode?.addChild(fruitNodes!)
        scene.camera = cam
        initControl()
        initResults()
    }
    
    func update(_ time: Double) {
        if player?.player != nil {
            cam?.position = (player?.player?.position)!
            player?.update()
            toggleZoom()
        }
    }
    
    func pause() {
        isPaused = true
        zooming = false
        for a in arrows {
            a.run(SKAction.scale(to: 0, duration: 0.1))
        }
        for f in (fruitNodes?.children)! {
            f.run(SKAction.scale(to: 0, duration: 0.18))
        }
        player?.player?.run(SKAction.scale(to: 0, duration: 0.17))
        timeText?.run(SKAction.move(by: CGVector(dx: 0, dy: 200), duration: 0.18))
        currentScore?.run(SKAction.move(to: CGPoint(x: 0, y: (scene.frame.height / -2) - 100), duration: 0.18))
        pauseButton?.run(SKAction.fadeOut(withDuration: 0.18))
        pauseMenu?.run(SKAction.fadeIn(withDuration: 0.199))
        
        let waitForPause = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) { (waitForPause) in
            self.scene.worldNode?.isPaused = true
        }
        
        RunLoop.current.add(waitForPause, forMode: RunLoop.Mode.common)
    }
    
    func unpause() {
        isPaused = false
        scene.worldNode?.isPaused = false
        for a in arrows {
            a.run(SKAction.scale(to: 1, duration: 0.1))
        }
        for f in (fruitNodes?.children)! {
            f.run(SKAction.scale(to: 1, duration: 0.18))
        }
        player?.player?.run(SKAction.scale(to: 1, duration: 0.17))
        timeText?.run(SKAction.move(by: CGVector(dx: 0, dy: -200), duration: 0.18))
        currentScore?.run(SKAction.move(to: CGPoint(x: 0, y: (scene.frame.height / -2) + 40), duration: 0.18))
        pauseButton?.run(SKAction.fadeIn(withDuration: 0.18))
        pauseMenu?.run(SKAction.fadeOut(withDuration: 0.199))
    }
    
    func restart() {
        unpause()
        
        // Player
        player?.player?.removeFromParent()
        player?.player = nil
        
        // Fruits
        for f in (self.fruitNodes?.children)! {
            f.removeFromParent()
        }
        
        // Camera
        cam?.run(SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0))
        cam?.run(SKAction.scale(to: 1, duration: 0))
        
        // Timer
        timer?.invalidate()
        timer = nil
        timeText?.removeFromParent()
        timeText = nil
        startTimer()
        
        // Others
        player?.facingRight = 1
        currentScore?.text = "Score: 0"
        mapZoom = 2
        zooming = false
        zoomed = false
        score = 0
        ateGFruit = 0
        ateFruit = 0
    }
    
    func quit() {
        isPaused = false
        scene.worldNode?.isPaused = false
        pauseMenu?.run(SKAction.fadeOut(withDuration: 0.2))
        timer?.invalidate()
        timer = nil
        showResults()
    }
    
    // Control
    
    func initControl() {
        arrows.append(SKSpriteNode(imageNamed: "arrow-up.png"))
        arrows.append(SKSpriteNode(imageNamed: "arrow-down.png"))
        arrows.append(SKSpriteNode(imageNamed: "arrow-right"))
        arrows.append(SKSpriteNode(imageNamed: "arrow-left"))
        arrows.append(SKSpriteNode(imageNamed: "zoom.png"))
        for i in 0..<arrows.count {
            switch i {
            case 0:
                arrows[i].name = "up"
            case 1:
                arrows[i].name = "down"
            case 2:
                arrows[i].name = "right"
            case 3:
                arrows[i].name = "left"
            case 4:
                arrows[i].name = "zoom"
                arrows[i].run(SKAction.scale(to: 0, duration: 0))
            default:
                continue
            }
        }
    }
    
    func updateControl() {
        for arrow in arrows {
            arrow.size = CGSize(width: 90, height: 90)
            arrow.position = CGPoint(x: 0, y: (scene.frame.height / -2) + 320)
            arrow.zPosition = 3
            arrow.run(SKAction.scale(to: 0, duration: 0))
            arrow.alpha = 0.5
            control?.addChild(arrow)
        }
        
        for i in 0..<arrows.count {
            arrows[i].run(SKAction.scale(to: 1, duration: 0.3))
            switch i {
            case 0:
                arrows[i].run(SKAction.move(by: CGVector(dx: 0, dy: 120), duration: 0.3))
            case 1:
                arrows[i].run(SKAction.move(by: CGVector(dx: 0, dy: -120), duration: 0.3))
            case 2:
                arrows[i].run(SKAction.move(by: CGVector(dx: 120, dy: 0), duration: 0.3))
            case 3:
                arrows[i].run(SKAction.move(by: CGVector(dx: -120, dy: 0), duration: 0.3))
            case 4:
                arrows[i].run(SKAction.scale(to: 1, duration: 0.3))
            default:
                break
            }
        }
        
        // Show CurrentScore and PauseButton
        currentScore?.run(SKAction.move(to: CGPoint(x: 0, y: (scene.frame.height / -2) + 40), duration: 0.3))
        pauseButton?.run(SKAction.fadeIn(withDuration: 0.5))
    }
    
    func touchNode(name: String) {
        if !(scene?.allowMovement)! || isPaused { return }
        switch name {
        case "up":
            player?.movePlayer(1)
            arrows[0].alpha = 1
        case "down":
            player?.movePlayer(2)
            arrows[1].alpha = 1
        case "right":
            player?.movePlayer(3)
            arrows[2].alpha = 1
        case "left":
            player?.movePlayer(4)
            arrows[3].alpha = 1
        case "zoom":
            zooming = true
            arrows[4].alpha = 1
        default:
            break
        }
    }
    
    func uInteract(_ name: String) {
        switch name {
        case "play":
            scene.playGame()
        case "ok":
            if showingResults { endResults() }
        case "pause":
            pause()
        case "resume":
            unpause()
        case "restart":
            restart()
        case "quit":
            quit()
        default:
            break
        }
    }
    
    func initFruit(_ first: Bool) {
        var pos: CGPoint = CGPoint(x: 0, y: 200)
        if !first {
            pos = CGPoint(x: Int.random(in: (-400 * mapZoom * 3) ... (400 * mapZoom * 3)), y: Int.random(in: (-400 * mapZoom * 3) ... (400 * mapZoom * 3)))
        }
        fruit = SKSpriteNode(imageNamed: "fruit.png")
        fruit?.name = "fruit"
        fruit?.size = CGSize(width: 40 * mapZoom, height: 40 * mapZoom)
        fruit?.position = pos
        fruit?.physicsBody = SKPhysicsBody(circleOfRadius: (fruit?.size.width)! / 3)
        fruit?.physicsBody?.affectedByGravity = false
        fruitNodes?.addChild(fruit!)
    }
    
    private func initGFruit() {
        let pos = CGPoint(x: Int.random(in: (-400 * mapZoom * 2) ... (400 * mapZoom * 2)), y: Int.random(in: (-400 * mapZoom * 2) ... (400 * mapZoom * 2)))
        gFruit = SKSpriteNode(imageNamed: "golden_apple.png")
        gFruit?.name = "gFruit"
        gFruit?.size = CGSize(width: 40 * mapZoom * 2, height: 40 * mapZoom * 2)
        gFruit?.position = pos
        gFruit?.physicsBody = SKPhysicsBody(circleOfRadius: (fruit?.size.width)! / 3)
        gFruit?.physicsBody?.affectedByGravity = false
        fruitNodes?.addChild(gFruit!)
    }
    
    func interact(_ node: SKNode) {
        switch node.name {
        case "fruit":
            eatFruit(node as! SKSpriteNode)
        case "gFruit":
            eatFruit(node as! SKSpriteNode)
        default:
            break
        }
    }
    
    func changeAlpha() {
        for arrow in arrows {
            arrow.alpha = 0.5
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        timeLeft = 180
        timeText = SKLabelNode()
        timeText?.zPosition = 3
        timeText?.fontSize = 64
        timeText?.position = CGPoint(x: 0, y: (scene.frame.height / 2))
        timeText?.text = "Time left: 3:00"
        cam?.addChild(timeText!)
        timeText?.run(SKAction.move(by: CGVector(dx: 0, dy: -105), duration: 0.3))
    }
    
    @objc private func onTimerFires() {
        if !isPaused { timeLeft! -= 1 }
        let calcTime = IntToMinutesSeconds(seconds: Int(timeLeft!))
        let timeSecString = (calcTime.1 < 10) ? "0\(calcTime.1)" : "\(calcTime.1)"
        timeText?.text = ("Time left: \(calcTime.0):\(timeSecString)")
        
        if timeLeft! <= 0 {
            timer?.invalidate()
            timer = nil
            scene.allowMovement = false
            showResults()
        }
    }
    
    private func eatFruit(_ node: SKSpriteNode) {
        scene.run(SKAction.playSoundFileNamed("eat.wav", waitForCompletion: false))
        if node.name == "fruit" {
            score += Double(node.size.width / 80)
            ateFruit += 1
            player?.updateSize(node.size.width)
            currentScore?.text = "Score: \(Int(score))"
            if (fruitNodes?.children.count)! > 300 {
                node.removeFromParent()
                return
            }
            initFruit(false)
            initFruit(false)
            if(Int.random(in: 0...100) > 60) {
                initFruit(false)
            } else if(Int.random(in: 0...100) > 90) {
                initFruit(false)
                initFruit(false)
                initFruit(false)
            }
            if(Int.random(in: 0...50) == 3) {
                initGFruit()
            }
            if(Int.random(in: 0...4) > 2) {
                node.position = CGPoint(x: Int.random(in: (-400 * mapZoom / 2) ... (400 * mapZoom / 2)), y: Int.random(in: (-400 * mapZoom / 2) ... (400 * mapZoom / 2)))
            } else if(Int.random(in: 0...6) > 5 && (fruitNodes?.children.count)! > 3) {
                node.removeFromParent()
            } else {
                node.removeFromParent()
                initFruit(false)
            }
        }else if node.name == "gFruit" {
            node.removeFromParent()
            initFruit(false)
            initFruit(false)
            initFruit(false)
            player?.updateSize(node.size.width * 2.5)
            ateGFruit += 1
            score += Double(node.size.width / 80) * 10
            currentScore?.text = "Score: \(Int(score))"
        }
    }
    
    private func toggleZoom() {
        if zooming && !zoomed {
            cam?.run(SKAction.scale(by: 4, duration: 0.2))
            zoomed = true
        } else if !zooming && zoomed {
            cam?.run(SKAction.scale(by: 0.25, duration: 0.2))
            zoomed = false
        }
    }
    
    private func checkForFruits() {
        let fruits = fruitNodes?.children
        if fruits!.count > 150 {
            fruits?[0].removeFromParent()
        }
    }
    
    private func IntToMinutesSeconds (seconds : Int) -> (Int, Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    private func initResults() {
        resultsLabel = SKLabelNode(text: "Results")
        resultsLabel?.fontSize = 120
        resultsLabel?.fontName = "ArialRoundedMTBold"
        resultsLabel?.fontColor = SKColor.white
        resultsLabel?.position = CGPoint(x: 0, y: (scene.frame.height / 2) + 200)
        
        // Score
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel?.fontSize = 50
        scoreLabel?.fontName = "ArialRoundedMTBold"
        scoreLabel?.fontColor = SKColor.white
        scoreLabel?.position = CGPoint(x: 0, y: 200)
        scoreLabel?.run(SKAction.fadeOut(withDuration: 0))
        
        currentScore = SKLabelNode(text: "Score: 0")
        currentScore?.fontSize = 60
        currentScore?.fontColor = SKColor.white
        currentScore?.position = CGPoint(x: 0, y: (scene.frame.height / -2) - 100)
        currentScore?.zPosition = 3
        
        // Pausing
        pauseButton = SKSpriteNode(imageNamed: "pause.png")
        pauseButton?.position = CGPoint(x: (scene.frame.width / 2) - 82, y: (scene.frame.height / 2) - 82)
        pauseButton?.size = CGSize(width: 50, height: 50)
        pauseButton?.name = "pause"
        pauseButton?.run(SKAction.fadeOut(withDuration: 0))
        
        pauseMenu = SKNode()
        resumeLabel = SKLabelNode(text: "Resume")
        resumeLabel?.position = CGPoint(x: 0, y: 100)
        resumeLabel?.fontSize = 75
        resumeLabel?.fontColor = SKColor.white
        resumeLabel?.name = "resume"
        
        restartLabel = SKLabelNode(text: "Restart")
        restartLabel?.position = CGPoint(x: 0, y: -10)
        restartLabel?.fontSize = 75
        restartLabel?.fontColor = SKColor.white
        restartLabel?.name = "restart"
        
        quitLabel = SKLabelNode(text: "Quit Game")
        quitLabel?.position = CGPoint(x: 0, y: -120)
        quitLabel?.fontSize = 75
        quitLabel?.fontColor = SKColor.white
        quitLabel?.name = "quit"
        
        pauseMenu?.addChild(resumeLabel!)
        pauseMenu?.addChild(restartLabel!)
        pauseMenu?.addChild(quitLabel!)
        pauseMenu?.run(SKAction.fadeOut(withDuration: 0))
        
        // Ok
        okLabel = SKLabelNode(text: "OK")
        okLabel?.fontSize = 80
        okLabel?.fontName = "ArialRoundedMTBold"
        okLabel?.fontColor = SKColor.white
        okLabel?.position = CGPoint(x: 0, y: -300)
        okLabel?.name = "ok"
        okLabel?.run(SKAction.fadeOut(withDuration: 0))
        okLabel?.isHidden = true
        
        // Fruit
        fruitResultsSprite = SKSpriteNode(imageNamed: "fruit.png")
        fruitResultsSprite?.size = CGSize(width: 140, height: 140)
        fruitResultsSprite?.position = CGPoint(x: scene.frame.width / -1.5, y: 60)
        // GFruit
        gFruitResultsSprite = SKSpriteNode(imageNamed: "golden_apple.png")
        gFruitResultsSprite?.size = CGSize(width: 140, height: 140)
        gFruitResultsSprite?.position = CGPoint(x: scene.frame.width / -1.5, y: -80)
        // FruitLabel
        fruitResultsLabel = SKLabelNode(text: "x100")
        fruitResultsLabel?.fontColor = SKColor.white
        fruitResultsLabel?.fontSize = 60
        fruitResultsLabel?.fontName = "ArialRoundedMTBold"
        fruitResultsLabel?.position = CGPoint(x: scene.frame.width / 1.5, y: 40)
        fruitResultsLabel?.horizontalAlignmentMode = .left
        //GFruitLabel
        gFruitResultsLabel = SKLabelNode(text: "x1")
        gFruitResultsLabel?.fontColor = SKColor.white
        gFruitResultsLabel?.fontSize = 60
        gFruitResultsLabel?.fontName = "ArialRoundedMTBold"
        gFruitResultsLabel?.position = CGPoint(x: scene.frame.width / 1.5, y: -100)
        gFruitResultsLabel?.horizontalAlignmentMode = .left
        // Adding children
        cam?.addChild(resultsLabel!)
        cam?.addChild(scoreLabel!)
        cam?.addChild(currentScore!)
        cam?.addChild(pauseButton!)
        cam?.addChild(pauseMenu!)
        cam?.addChild(okLabel!)
        cam?.addChild(fruitResultsSprite!)
        cam?.addChild(gFruitResultsSprite!)
        cam?.addChild(fruitResultsLabel!)
        cam?.addChild(gFruitResultsLabel!)
    }
    
    private func showResults() {
        
        // Control
        
        for i in 0..<arrows.count {
            arrows[i].run(SKAction.scale(to: 0, duration: 0.1))
            arrows[i].removeFromParent()
        }
        arrows = []
        initControl()
        
        player?.end()
        
        for f in (self.fruitNodes?.children)! {
            f.run(SKAction.scale(to: 0, duration: 0.2))
            let rFP = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false) {(rFP) in
                f.removeFromParent()
            }
            RunLoop.current.add(rFP, forMode: RunLoop.Mode.common)
        }
        
        // Camera
        cam?.run(SKAction.sequence([
            SKAction.wait(forDuration: 3),
            SKAction.move(to: CGPoint(x: 0, y: 0), duration: 0),
            SKAction.scale(to: 1, duration: 0)
        ]))
        
        scene.inGame = false
        
        // Others
        timeText?.removeFromParent()
        timeText = nil
        showingResults = true
        okLabel?.isHidden = false
        currentScore?.text = "Score: 0"
        pauseButton?.run(SKAction.fadeOut(withDuration: 0.3))
        
        // Show Results
        
        scoreLabel?.text = "Score: \(Int(round(score)))"
        fruitResultsLabel?.text = "x \(ateFruit)"
        gFruitResultsLabel?.text = "x \(ateGFruit)"
        currentScore?.run(SKAction.move(to: CGPoint(x: 0, y: (scene.frame.height / -2) - 100), duration: 0.3))
        
        let sResults = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (sResults) in
            self.resultsLabel?.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.height / 4)), duration: 0.3))
            
            self.scoreLabel?.run(SKAction.sequence([
                SKAction.wait(forDuration: 3),
                SKAction.fadeIn(withDuration: 1)
            ]))
            
            self.fruitResultsSprite?.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.move(to: CGPoint(x: -80, y: 60), duration: 0.4)
            ]))

            self.gFruitResultsSprite?.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.4),
                SKAction.move(to: CGPoint(x: -80, y: -80), duration: 0.4)
            ]))


            self.fruitResultsLabel?.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.0),
                SKAction.move(to: CGPoint(x: 40, y: 40), duration: 0.4)
            ]))
            
            self.gFruitResultsLabel?.run(SKAction.sequence([
                SKAction.wait(forDuration: 2.4),
                SKAction.move(to: CGPoint(x: 40, y: -105), duration: 0.4)
            ]))
            
            self.okLabel?.run(SKAction.sequence([
                SKAction.wait(forDuration: 4),
                SKAction.fadeIn(withDuration: 0.5)
            ]))
        }
        RunLoop.current.add(sResults, forMode: RunLoop.Mode.common)
    }
    
    func endResults() {
        showingResults = false
        okLabel?.run(SKAction.fadeOut(withDuration: 0.3))
        let endOkLabel = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: false) { (endOkLabel) in
            self.okLabel?.isHidden = true
            self.scoreLabel?.run(SKAction.fadeOut(withDuration: 0.2))
            self.resultsLabel?.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.height / 2) + 200), duration: 0.1))
            self.fruitResultsSprite?.run(SKAction.move(to: CGPoint(x: self.scene.frame.width / -1.5, y: 60), duration: 0.3))
            self.gFruitResultsSprite?.run(SKAction.move(to: CGPoint(x: self.scene.frame.width / -1.5, y: -80), duration: 0.3))
            self.fruitResultsLabel?.run(SKAction.move(to: CGPoint(x: self.scene.frame.width / 1.5, y: 40), duration: 0.3))
            self.gFruitResultsLabel?.run(SKAction.move(to: CGPoint(x: self.scene.frame.width / 1.5, y: -100), duration: 0.3))
        }
        RunLoop.current.add(endOkLabel, forMode: RunLoop.Mode.common)
        endGame()
    }
    
    private func endGame() {
        if scene.bestScore < Int(score) {
            scene.bestScore = Int(score)
        }
        let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            self.scene.showMenu()
        }
        RunLoop.current.add(timer, forMode: RunLoop.Mode.common)
        mapZoom = 2
        zooming = false
        zoomed = false
        score = 0
        ateGFruit = 0
        ateFruit = 0
    }
}

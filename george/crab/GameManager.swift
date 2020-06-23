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
    
    var ateFruit: Int = 0, ateGFruit: Int = 0
    
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
        scene.addChild(cam!)
        scene.addChild(fruitNodes!)
        scene.camera = cam
        initControl()
        initResults()
    }
    
    func update(_ time: Double) {
        if player?.player != nil {
            cam?.position = (player?.player.position)!
            player?.update()
            toggleZoom()
        }
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
                break
            }
        }
    }
    
    func updateControl() {
        for arrow in arrows {
            arrow.size = CGSize(width: 90, height: 90)
            arrow.position = CGPoint(x: 0, y: (scene.frame.height / -2) + 320)
            arrow.zPosition = 3
            arrow.run(SKAction.scale(to: 0, duration: 0))
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
        
        // Show CurrentScore
        currentScore?.run(SKAction.move(to: CGPoint(x: 0, y: (scene.frame.height / -2) + 40), duration: 0.3))
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
    
    func touchNode(name: String) {
        if !(scene?.allowMovement)! { return }
        switch name {
        case "up":
            player?.movePlayer(1)
        case "down":
            player?.movePlayer(2)
        case "right":
            player?.movePlayer(3)
        case "left":
            player?.movePlayer(4)
        case "zoom":
            zooming = true
        default:
            break
        }
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
    
    func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        timeLeft = 180
        timeText = SKLabelNode()
        timeText?.zPosition = 3
        timeText?.fontSize = 64
        timeText?.position = CGPoint(x: 0, y: (scene.frame.height / 2))
        timeText?.text = "Time left: 3:00"
        cam?.addChild(timeText!)
        timeText?.run(SKAction.move(by: CGVector(dx: 0, dy: -150), duration: 0.3))
    }
    
    @objc private func onTimerFires() {
        timeLeft! -= 1
        let calcTime = IntToMinutesSeconds(seconds: Int(timeLeft!))
        let timeSecString = (calcTime.1 < 10) ? "0\(calcTime.1)" : "\(calcTime.1)"
        timeText?.text = ("Time left: \(calcTime.0):\(timeSecString)")
        
        if timeLeft! <= 0 {
            timer?.invalidate()
            timer = nil
            showResults()
        }
    }
    
    private func eatFruit(_ node: SKSpriteNode) {
        if node.name == "fruit" {
            score += Double(node.size.width / 80)
            print(node.size.width / 80)
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
            if(Int.random(in: 0...100) == 3) {
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
        resultsLabel?.position = CGPoint(x: 0, y: scene.frame.height)
        
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
        cam?.addChild(okLabel!)
        cam?.addChild(fruitResultsSprite!)
        cam?.addChild(gFruitResultsSprite!)
        cam?.addChild(fruitResultsLabel!)
        cam?.addChild(gFruitResultsLabel!)
    }
    
    private func showResults() {
        player?.end()
        
        // Control
        
        for i in 0..<arrows.count {
            arrows[i].run(SKAction.scale(to: 0, duration: 0.1))
            arrows[i].removeFromParent()
        }
        arrows = []
        initControl()
        
        // Fruits
        
        for f in (fruitNodes?.children)! {
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
        scene.allowMovement = false
        timeText?.removeFromParent()
        timeText = nil
        showingResults = true
        okLabel?.isHidden = false
        currentScore?.text = "Score: 0"
        
        // Show Results
        
        scoreLabel?.text = "Score: \(Int(round(score)))"
        fruitResultsLabel?.text = "x \(ateFruit)"
        gFruitResultsLabel?.text = "x \(ateGFruit)"
        currentScore?.run(SKAction.move(to: CGPoint(x: 0, y: (scene.frame.height / -2) - 100), duration: 0.3))
        
        let sResults = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (sResults) in
            self.resultsLabel?.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.height / 4)), duration: 0.7))
            
            self.scoreLabel?.run(SKAction.sequence([
                SKAction.wait(forDuration: 0.3),
                SKAction.fadeIn(withDuration: 0.5)
            ]))
            
            self.fruitResultsSprite?.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.0),
                SKAction.move(to: CGPoint(x: -100, y: 60), duration: 0.4)
            ]))

            self.gFruitResultsSprite?.run(SKAction.sequence([
                SKAction.wait(forDuration: 1.4),
                SKAction.move(to: CGPoint(x: -100, y: -80), duration: 0.4)
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
                SKAction.wait(forDuration: 3.6),
                SKAction.fadeIn(withDuration: 0.5)
            ]))
        }
        RunLoop.current.add(sResults, forMode: RunLoop.Mode.common)
    }
    
    func endResults() {
        showingResults = false
        resultsLabel?.run(SKAction.move(to: CGPoint(x: 0, y: scene.frame.height), duration: 0.3))
        fruitResultsSprite?.run(SKAction.move(to: CGPoint(x: scene.frame.width / -1.5, y: 60), duration: 0.3))
        gFruitResultsSprite?.run(SKAction.move(to: CGPoint(x: scene.frame.width / -1.5, y: -80), duration: 0.3))
        fruitResultsLabel?.run(SKAction.move(to: CGPoint(x: scene.frame.width / 1.5, y: 40), duration: 0.3))
        gFruitResultsLabel?.run(SKAction.move(to: CGPoint(x: scene.frame.width / 1.5, y: -100), duration: 0.3))
        scoreLabel?.run(SKAction.fadeOut(withDuration: 0.3))
        okLabel?.run(SKAction.fadeOut(withDuration: 0.3))
        let endOkLabel = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (endOkLabel) in
            self.okLabel?.isHidden = true
        }
        RunLoop.current.add(endOkLabel, forMode: RunLoop.Mode.common)
        endGame()
    }
    
    private func endGame() {
        if scene.bestScore < Int(score) {
            scene.bestScore = Int(score)
        }
        scene.showMenu()
        mapZoom = 2
        zooming = false
        zoomed = false
        score = 0
        ateGFruit = 0
        ateFruit = 0
    }
}

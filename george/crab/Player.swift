//
//  Player.swift
//  crab
//
//  Created by Vincent Qi on 2020-06-20.
//  Copyright © 2020 Vincent Qi. All rights reserved.
//

import Foundation
import SpriteKit

class Player {
    var scene: GameScene!
    var gameManager: GameManager!
    
    var player: SKSpriteNode?
    var isActive: Bool = false
    var facingRight: CGFloat = 1
    
    var size: CGFloat = 0
    
    init(_ scene: GameScene, _ gm: GameManager) {
        self.scene = scene
        self.gameManager = gm
    }
    
    private func flip(_ goingRight: Bool) {
        if(goingRight && (facingRight < 0) || !goingRight && !(facingRight < 0)) { return }
        player?.run(SKAction.scaleX(by: -1, y: 1, duration: 0))
        facingRight *= -1
    }
    
    func movePlayer(_ direction: Int) {
        if player == nil {
            initPlayer()
            return
        }
        
        if gameManager.zooming { return }

        switch direction {
            case 1:
                player?.run(SKAction.moveBy(x: 0, y: 10, duration: 0.2))
            case 2:
                player?.run(SKAction.moveBy(x: 0, y: -10, duration: 0.2))
            case 3:
                player?.run(SKAction.moveBy(x: 10, y: 0, duration: 0.2))
                flip(true)
            case 4:
                player?.run(SKAction.moveBy(x: -10, y: 0, duration: 0.2))
                flip(false)
            default:
                break
        }
    }

    func initPlayer() {
        player = SKSpriteNode(imageNamed: "george.png")
        player?.size = CGSize(width: 120, height: 120)
        player?.position = CGPoint(x: 0, y: 0)
        player?.name = "player"
        player?.zPosition = 2
        player?.isHidden = false
        setPhysics()
        scene.worldNode?.addChild(player!)
        gameManager?.initFruit(true)
    }
    
    func update() {
        if player != nil {
            let contacted = player?.physicsBody?.allContactedBodies()
            for contact in contacted! {
                gameManager.interact((contact.node ?? SKNode()))
            }
        }
    }
    
    func end() {
        if player != nil {
            player?.run(SKAction.scale(to: 0, duration: 0.3))
            let rFP = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { (rFP) in
                self.player?.removeFromParent()
                self.player = nil
            }
            RunLoop.current.add(rFP, forMode: RunLoop.Mode.common)
        }
        facingRight = 1
    }
    
    func updateSize(_ nSize: CGFloat) {
        let scaled = nSize / 40 / CGFloat(gameManager.mapZoom)
        size += scaled
        let currentSize = player?.size.width
        player?.size.width += currentSize! / 10 * scaled
        player?.size.height += currentSize! / 10 * scaled
        if(size >= 8) {
            gameManager.cam?.run(SKAction.scale(by: 2, duration: 0.5))
            size = 0
            gameManager.mapZoom *= 2
            setPhysics()
        }
    }
    
    // Misc functions
    
    private func setPhysics() {
        player?.physicsBody = SKPhysicsBody(circleOfRadius: (player?.size.width)! / 3)
        player?.physicsBody?.usesPreciseCollisionDetection = true
        player?.physicsBody?.affectedByGravity = false
        size = 0
    }
    
    private func animatePlayer() {
        
    }
}
